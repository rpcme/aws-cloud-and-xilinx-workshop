#! /bin/sh

s3_bucket=$1
prefix=$2

if test -z "$s3_bucket"; then
  echo ERROR: first argument must be named S3 bucket.
  exit 1
fi

if test -z "$prefix"; then
  thing_agg=gateway-ultra96
  thing_afr=node-zynq7k
else
  thing_agg=${prefix}-gateway-ultra96
  thing_afr=${prefix}-node-zynq7k
fi

d_agg_config=$(dirname $0)/../ggc-config
if test ! -d ${d_agg_config}; then mkdir ${d_agg_config}; fi

# find the thing arn
echo Querying thingArn for Greengrass
thing_agg_arn=$(aws iot describe-thing --output text       \
                    --thing-name ${thing_agg} \
                    --query thingArn)

echo Querying thingArn for Amazon FreeRTOS
thing_afr_arn=$(aws iot describe-thing --output text       \
                    --thing-name ${thing_afr} \
                    --query thingArn)

# find the certificate arn the thing is attached to.
echo Querying principal for Greengrass
cert_agg_arn=$(aws iot list-thing-principals --output text \
                   --thing-name ${thing_agg} \
                   --query principals[0])

echo Querying principal for Amazon FreeRTOS
cert_afr_arn=$(aws iot list-thing-principals --output text \
                   --thing-name ${thing_afr} \
                   --query principals[0])

# Check if the service role exists for the account.  If not, this must be
# created.
echo Checking if the service role for Greengrass has been attached.
service_role_arn=$(aws greengrass get-service-role-for-account --output text \
                       --query RoleArn)

if test -z ${service_role_arn}; then
  echo Service role for AWS Greengrass for this region not found.  Locating.
  service_role_arn=$(aws iam get-role --output text \
                             --role-name GreengrassServiceRole \
                             --query Role.Arn)
  if test -z ${service_role_arn}; then
    echo Service role not found.  Creating.

cat <<EOF > ${d_agg_config}/agg-service-role.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "greengrass.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    echo Creating the service role.
    agg_sr_arn=$(aws iam create-role --output text \
                     --path /service-role/ \
                     --role-name GreengrassServiceRole \
                     --assume-role-policy-document file://${d_agg_config}/agg-service-role.json \
                     --query Role.Arn)

    #TODO IT LOOKS LIKE WE ARE MISSING POLICY ATTACHMENT HERE!
    
    aws greengrass associate-service-role-to-account \
        --role-arn ${agg_sr_arn}
  else
    aws greengrass associate-service-role-to-account \
        --role-arn ${service_role_arn}
  fi
fi
# Create the role for the Greengrass group.  This enables TES for the S3 bucket
# so we can copy the images to the cloud and download bitstream from the cloud.
role_agg_name=role-greengrass-group-${thing_agg}
role_policy_agg_name=role-greengrass-group-${thing_agg}-policy

my_region=$(echo ${thing_agg_arn} | cut -f4 -d':')
my_account=$(echo ${thing_agg_arn} | cut -f5 -d':')

agg_role=$(aws iam get-role --output text --role-name ${role_agg_name} --query Role.Arn)

if test $? != 0; then
cat <<EOF > ${d_agg_config}/core-role-trust.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "greengrass.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  agg_role=$(aws iam create-role --output text \
                 --role-name ${role_agg_name} \
                 --assume-role-policy-document file://${d_agg_config}/core-role-trust.json \
                 --query Role.Arn)

cat <<EOF > ${d_agg_config}/core-role-policy.json
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": ["s3:Put","s3:Get"],
        "Resource": "arn:aws:s3::${my_account}:${s3_bucket}"
    }
}
EOF

  aws iam put-role-policy                                                     \
      --role-name ${role_agg_name}                                            \
      --policy-name ${role_policy_agg_name}                                   \
      --policy-document file://${d_agg_config}/core-role-policy.json
fi
# Create the core definition with initial version
cat <<EOF > ${d_agg_config}/core-definition-init.json
{
  "Cores": [
    {
      "Id":             "${thing_agg}-core",
      "CertificateArn": "${cert_agg_arn}",
      "SyncShadow":     true,
      "ThingArn":       "${thing_agg_arn}"
    }
  ]
}
EOF

echo Creating the core definition.
core_v_arn=$(aws greengrass create-core-definition --output text             \
                 --name ${thing_agg}-core                                    \
                 --initial-version file://${d_agg_config}/core-definition-init.json \
                 --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass core definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Create the device definition.  This enables the Zynq device to be recognized
# by the core.

cat <<EOF > ${d_agg_config}/device-definition-init.json
{
  "Devices": [
    {
      "Id":             "${thing_afr}-core",
      "CertificateArn": "${cert_afr_arn}",
      "SyncShadow":     true,
      "ThingArn":       "${thing_afr_arn}"
    }
  ]
}
EOF

echo Creating the device definition.
device_v_arn=$(aws greengrass create-device-definition --output text                          \
                 --name ${thing_agg}-device                                    \
                 --initial-version file://${d_agg_config}/device-definition-init.json \
                 --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass device definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Create the logger definition

cat <<EOF > ${d_agg_config}/logger-definition-init.json
{
  "Loggers": [
    {
      "Component": "GreengrassSystem",
      "Id": "GreengrassSystem-${thing_afr}",
      "Level": "INFO",
      "Space": 1024,
      "Type": "FileSystem"
    },
    {
      "Component": "Lambda",
      "Id": "Lambda-${thing_afr}",
      "Level": "INFO",
      "Space": 1024,
      "Type": "FileSystem"
    }
  ]
}
EOF

echo Creating the logger definition.
logger_v_arn=$(aws greengrass create-logger-definition --output text \
                   --name ${thing_agg}-logger \
                   --initial-version file://${d_agg_config}/logger-definition-init.json \
                   --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass logger definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Create the resource definition

# this needs to be created before deployment or else the deployment will fail
if test ! -d /home/xilinx/bitstream; then mkdir -p /home/xilinx/bitstream; fi

cat <<EOF > ${d_agg_config}/resource-definition-init.json
{
  "Resources": [
    {
      "Id": "${thing_afr}-i2c-0",
      "Name": "i2c-0",
      "ResourceDataContainer": {
        "LocalDeviceResourceData": {
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/dev/i2c-0"
        }
      }
    },
    {
      "Id": "${thing_afr}-i2c-1",
      "Name": "i2c-1",
      "ResourceDataContainer": {
        "LocalDeviceResourceData": {
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/dev/i2c-1"
        }
      }
    },
    {
      "Id": "${thing_afr}-uio0",
      "Name": "uio0",
      "ResourceDataContainer": {
        "LocalDeviceResourceData": {
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/dev/uio0"
        }
      }
    },
    {
      "Id": "${thing_afr}-mem",
      "Name": "mem",
      "ResourceDataContainer": {
        "LocalDeviceResourceData": {
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/dev/mem"
        }
      }
    },
    {
      "Id": "${thing_afr}-lib-firmware",
      "Name": "lib-firmware",
      "ResourceDataContainer": {
        "LocalVolumeResourceData": {
          "DestinationPath": "/lib/firmware",
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/lib/firmware"
        }
      }
    },
    {
      "Id": "${thing_afr}-home-xilinx",
      "Name": "home-xilinx",
      "ResourceDataContainer": {
        "LocalVolumeResourceData": {
          "DestinationPath": "/home/xilinx",
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/home/xilinx"
        }
      }
    },
    {
      "Id": "${thing_afr}-home-xilinx-bitstream",
      "Name": "home-xilinx-bitstream",
      "ResourceDataContainer": {
        "LocalVolumeResourceData": {
          "DestinationPath": "/home/xilinx/bitstream",
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/home/xilinx/bitstream"
        }
      }
    },
    {
      "Id": "${thing_afr}-home-xilinx-out",
      "Name": "home-xilinx-bitstream",
      "ResourceDataContainer": {
        "LocalVolumeResourceData": {
          "DestinationPath": "/home/xilinx/out",
          "GroupOwnerSetting": {
            "AutoAddGroupOwner": true
          },
          "SourcePath": "/home/xilinx/out"
        }
      }
    }
  ]
}
EOF

echo Creating the resource definition.
resource_v_arn=$(aws greengrass create-resource-definition --output text \
                     --name ${thing_agg}-resource \
                     --initial-version file://${d_agg_config}/resource-definition-init.json \
                     --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass resource definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Create the function definition
# Two lambda functions: xilinx-bitstream-deployer-handler, xilinx-video-inference-handler
# These functions MUST be deployed to AWS Lambda with Alias PROD prior to running this.
xilinx_bitstream_deployer_handler_arn=arn:aws:lambda:${my_region}:${my_account}:function:xilinx-bitstream-deployer-handler:PROD
xilinx_video_inference_handler_arn=arn:aws:lambda:${my_region}:${my_account}:function:xilinx-video-inference-handler:PROD

# Note MemorySize is in MB, multiply by 1024
cat <<EOF > ${d_agg_config}/function-definition-init.json
{
  "Functions": [
    {
      "Id": "xilinx_video_inference_handler",
      "FunctionArn": "${xilinx_video_inference_handler_arn}",
      "FunctionConfiguration": {
        "EncodingType": "json",
        "Environment": {
          "AccessSysfs": true,
          "ResourceAccessPolicies": []
        },
        "Execution": {
          "IsolationMode": "NoContainer",
          "RunAs": {
            "Uid": 0,
            "Gid": 0
          }
        },
        "Executable": "python",
        "MemorySize": 1048576,
        "Pinned": true,
        "Timeout": 500
      }
    },
    {
      "Id": "xilinx_bitstream_deployer_handler",
      "FunctionArn": "${xilinx_bitstream_deployer_handler_arn}",
      "FunctionConfiguration": {
        "EncodingType": "json",
        "Environment": {
          "AccessSysfs": true,
          "ResourceAccessPolicies": []
        },
        "Execution": {
          "IsolationMode": "NoContainer",
          "RunAs": {
            "Uid": 0,
            "Gid": 0
          }
        },
        "Executable": "python",
        "MemorySize": 1048576,
        "Pinned": false,
        "Timeout": 500
      }
    }
  ]
}
EOF

echo Creating the function definition.
function_v_arn=$(aws greengrass create-function-definition --output text \
                     --name ${thing_agg}-function \
                     --initial-version file://${d_agg_config}/function-definition-init.json \
                     --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass function definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Create the subscription definition
cat <<EOF > ${d_agg_config}/subscription-definition-init.json
{
  "Subscriptions": [
    {
      "Id":      "inference-handler-to-cloud",
      "Source":  "${xilinx_video_inference_handler_arn}",
      "Subject": "/generator/camera",
      "Target":  "cloud"
    },
    {
      "Id":      "greengrass-device-to-cloud",
      "Source":  "${thing_afr_arn}",
      "Subject": "/generator/sensingdata",
      "Target":  "cloud"
    },
    {
      "Id":      "core-shadow-to-bitstream-deployer-delta",
      "Source":  "GGShadowService",
      "Subject": "\$aws/things/${thing_agg}/shadow/update/delta",
      "Target":  "${xilinx_bitstream_deployer_handler_arn}"
    },
    {
      "Id":      "core-shadow-to-bitstream-deployer-update",
      "Source":  "${xilinx_bitstream_deployer_handler_arn}",
      "Subject": "\$aws/things/${thing_agg}/shadow/update",
      "Target":  "GGShadowService"
    },
    {
      "Id":      "core-shadow-to-bitstream-deployer-accepted",
      "Source":  "GGShadowService",
      "Subject": "\$aws/things/${thing_agg}/shadow/update/accepted",
      "Target":  "${xilinx_bitstream_deployer_handler_arn}"
    },
    {
      "Id":      "core-shadow-to-bitstream-deployer-rejected",
      "Source":  "GGShadowService",
      "Subject": "\$aws/things/${thing_agg}/shadow/update/rejected",
      "Target":  "${xilinx_bitstream_deployer_handler_arn}"
    }
  ]
}
EOF

echo Creating the subscription definition.
subscription_v_arn=$(aws greengrass create-subscription-definition --output text \
                         --name ${thing_agg}-subscription \
                         --initial-version file://${d_agg_config}/subscription-definition-init.json \
                         --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass subscription definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi
# Create the group


cat <<EOF > ${d_agg_config}/group-init.json
{
  "CoreDefinitionVersionArn":         "${core_v_arn}",
  "DeviceDefinitionVersionArn":       "${device_v_arn}",
  "FunctionDefinitionVersionArn":     "${function_v_arn}",
  "LoggerDefinitionVersionArn":       "${logger_v_arn}",
  "ResourceDefinitionVersionArn":     "${resource_v_arn}",
  "SubscriptionDefinitionVersionArn": "${subscription_v_arn}"
}
EOF

echo Creating the Greengrass group.
group_v_arn=$(aws greengrass create-group --output text \
                         --name ${thing_agg}-group \
                         --initial-version file://${d_agg_config}/group-init.json \
                         --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass group creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

echo Associating the role to the Greengrass group.
aws greengrass associate-role-to-group --group-id $(echo $group_v_arn | cut -f5 -d'/') --role-arn ${agg_role}

if test $? != 0; then
  echo Greengrass role association failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Finis
echo Thank you and have a nice day.
