#! /bin/sh
#
# deploy-awsiot-objects.sh
#
# Create AWS IoT objects for the lab.
#

prefix=$1

if test -z "$prefix"; then
  thing_agg=gateway-ultra96
  thing_afr=node-zynq7k
else
  thing_agg=${prefix}-gateway-ultra96
  thing_afr=${prefix}-node-zynq7k
fi

policy_agg=${thing_agg}-policy
policy_afr=${thing_afr}-policy

dc_agg=$(dirname $0)/../../edge/auth-${thing_agg}
dc_afr=$(dirname $0)/../../edge/auth-${thing_afr}

if test ! -d ${dc_agg}; then mkdir -p ${dc_agg}; fi
if test ! -d ${dc_afr}; then mkdir -p ${dc_afr}; fi

# AWS provisioned Certificate for Greengrass
echo Creating AWS generated Key and Certificate for [${thing_agg}].
cert_arn_agg=$(aws iot create-keys-and-certificate --output text              \
                   --set-as-active                                            \
                   --certificate-pem-outfile $dc_agg/${thing_agg}.crt.pem     \
                   --public-key-outfile      $dc_agg/${thing_agg}.key.pub.pem \
                   --private-key-outfile     $dc_agg/${thing_agg}.key.prv.pem \
                   --query certificateArn)

# AWS provisioned Certificate for Amazon FreeRTOS
echo Creating AWS generated Key and Certificate for [${thing_afr}].
cert_arn_afr=$(aws iot create-keys-and-certificate --output text              \
                   --set-as-active                                            \
                   --certificate-pem-outfile $dc_afr/${thing_afr}.crt.pem     \
                   --public-key-outfile      $dc_afr/${thing_afr}.key.pub.pem \
                   --private-key-outfile     $dc_afr/${thing_afr}.key.prv.pem \
                   --query certificateArn)


echo Creating thing [${thing_agg}].
thing_arn_agg=$(aws iot create-thing --output text \
                    --thing-name ${thing_agg} \
                    --query thingArn)

echo Attaching thing [${thing_agg}] to its certificate.
aws iot attach-thing-principal   \
    --thing-name ${thing_agg}    \
    --principal  ${cert_arn_agg}

echo Creating thing [${thing_afr}].
thing_arn_afr=$(aws iot create-thing --output text         \
                    --thing-name ${thing_afr} \
                    --query thingArn)

# eventual consistency
echo Please Wait...
sleep 5

echo Attaching thing [${thing_afr}] to its certificate.
aws iot attach-thing-principal   \
    --thing-name ${thing_afr}    \
    --principal  ${cert_arn_afr}

cat <<EOF > $dc_agg/policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action":["iot:*", "greengrass:*"],
    "Resource": ["*"]
  }]
}
EOF

echo Creating policy [${policy_agg}].
aws iot create-policy   --output text              \
    --policy-name ${policy_agg}                    \
    --policy-document file://${dc_agg}/policy.json \
    --query policyArn

# Potential for eventual consistency here.
echo Please wait...
sleep 5

echo Attaching policy [${policy_agg}] to its certificate.
aws iot attach-principal-policy \
    --policy-name ${policy_agg} \
    --principal ${cert_arn_agg}

cat <<EOF > $dc_afr/policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action":["iot:*", "greengrass:*"],
    "Resource": ["*"]
  }]
}
EOF

echo Creating policy [${policy_afr}].
aws iot create-policy --output text                \
    --policy-name ${policy_afr}                    \
    --policy-document file://${dc_afr}/policy.json \
    --query policyArn

# Potential for eventual consistency here.
echo Please wait...
sleep 5

echo Attaching policy [${policy_afr}] to its certificate.
aws iot attach-principal-policy \
    --policy-name ${policy_afr} \
    --principal ${cert_arn_afr}


echo Constructing the AWS Greengrass config.json for this deployment.
my_region=$(echo ${thing_arn_agg} | cut -f4 -d:)
my_iothost=$(aws iot describe-endpoint --output text)
wget -O ${dc_agg}/rootca.pem \
https://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem

cat <<EOF > $dc_agg/config.json
{
    "coreThing": {
        "caPath": "rootca.pem",
        "certPath": "${thing_agg}.crt.pem",
        "keyPath": "${thing_agg}.key.prv.pem",
        "thingArn": "${thing_arn_agg}",
        "iotHost": "${my_iothost}",
        "ggHost": "greengrass.iot.${my_region}.amazonaws.com"
    },
    "runtime": {
      "allowFunctionsToRunAsRoot":"yes",
      "cgroup": {
        "useSystemd": "no",
      }
    },
    "managedRespawn": false
}
EOF

echo Done!
