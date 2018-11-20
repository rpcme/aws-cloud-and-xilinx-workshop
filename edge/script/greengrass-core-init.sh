#! /bin/bash

s3_bucket=$1
prefix=$2

if test -z "$s3_bucket"; then
  echo ERROR: first argument must be named S3 bucket.
  exit 1
fi
if test -z "$prefix"; then
  echo ERROR: second argument must be provided as a prefix for your group name.
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
echo Querying thingArn for Greengrass.
thing_agg_arn=$(aws iot describe-thing --output text       \
                    --thing-name ${thing_agg} \
                    --query thingArn)

echo Querying thingArn for Amazon FreeRTOS.
thing_afr_arn=$(aws iot describe-thing --output text       \
                    --thing-name ${thing_afr} \
                    --query thingArn)

# find the certificate arn the thing is attached to.
echo Querying principal for Greengrass.
cert_agg_arn=$(aws iot list-thing-principals --output text \
                   --thing-name ${thing_agg} \
                   --query principals[0])

echo Querying principal for Amazon FreeRTOS.
cert_afr_arn=$(aws iot list-thing-principals --output text \
                   --thing-name ${thing_afr} \
                   --query principals[0])

# Check if the service role exists for the account.  If not, this must be
# created.
echo Checking if the service role for Greengrass has been attached.
service_role_arn=$(aws greengrass-pp get-service-role-for-account --output text \
                       --query RoleArn)

if test -z ${service_role_arn}; then
  echo Service role attachment for AWS Greengrass not found.  Locating existing role definition.
  service_role_arn=$(aws iam get-role --output text \
                             --role-name Greengrass_ServiceRole \
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
                     --role-name Greengrass_ServiceRole \
                     --assume-role-policy-document file://${d_agg_config}/agg-service-role.json \
                     --query Role.Arn)

    echo Attaching AWSGreengrassResourceAccessRolePolicy to Role.
    policy_arn=arn:aws:iam::aws:policy/service-role/AWSGreengrassResourceAccessRolePolicy
    aws iam attach-role-policy --role-name Greengrass_ServiceRole --policy-arn ${policy_arn}

    echo Associating Service role to the Account
    aws greengrass-pp associate-service-role-to-account \
        --role-arn ${agg_sr_arn}

  else
    aws greengrass-pp associate-service-role-to-account \
        --role-arn ${service_role_arn}
  fi
fi

# Create the role for the Greengrass group.  This enables TES for the S3 bucket
# so we can copy the images to the cloud and download bitstream from the cloud.
role_agg_name=role-greengrass-group-${thing_agg}
role_policy_agg_name=role-greengrass-group-${thing_agg}-policy

my_region=$(echo ${thing_agg_arn} | cut -f4 -d':')
my_account=$(echo ${thing_agg_arn} | cut -f5 -d':')

echo Creating the gateway role.
agg_role_found=$(aws iam list-roles --output text --query "Roles[?RoleName == '${role_agg_name}']")
if [ -z "$agg_role_found" ]; then
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
        "Resource": "arn:aws:s3:::${my_account}:${s3_bucket}"
    }
}
EOF

  aws iam put-role-policy                                                     \
      --role-name ${role_agg_name}                                            \
      --policy-name ${role_policy_agg_name}                                   \
      --policy-document file://${d_agg_config}/core-role-policy.json
fi

agg_role=$(aws iam get-role --output text \
               --role-name ${role_agg_name} --query Role.Arn)

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
core_v_arn=$(aws greengrass-pp create-core-definition --output text             \
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
device_v_arn=$(aws greengrass-pp create-device-definition --output text                          \
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
logger_v_arn=$(aws greengrass-pp create-logger-definition --output text \
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
  "Resources": []
}
EOF

echo Creating the resource definition.
resource_v_arn=$(aws greengrass-pp create-resource-definition --output text \
                     --name ${thing_agg}-resource \
                     --initial-version file://${d_agg_config}/resource-definition-init.json \
                     --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass resource definition creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Create the function definition
# All the lambda functions: 
#   xilinx-hello-world
#   xilinx-bitstream-deploy-handler
#   xilinx-video-inference-handler
#   xilinx-image-upload-handler
# These functions MUST be deployed to AWS Lambda with Alias PROD prior to running this.
xilinx_hello_world_arn=arn:aws:lambda:${my_region}:${my_account}:function:xilinx-hello-world:PROD
xilinx_bitstream_deploy_handler_arn=arn:aws:lambda:${my_region}:${my_account}:function:xilinx-bitstream-deploy-handler:PROD
xilinx_video_inference_handler_arn=arn:aws:lambda:${my_region}:${my_account}:function:xilinx-video-inference-handler:PROD
xilinx_image_upload_handler_arn=arn:aws:lambda:${my_region}:${my_account}:function:xilinx-image-upload-handler:PROD

# Note MemorySize is in MB, multiply by 1024
cat <<EOF > ${d_agg_config}/function-definition-init.json
{
  "DefaultConfig":{
    "Execution": {
      "IsolationMode":"NoContainer"
    }
  },
  "Functions": [
    {
      "Id": "xilinx_hello_world",
      "FunctionArn": "${xilinx_hello_world_arn}",
      "FunctionConfiguration": {
        "EncodingType": "json",
        "Environment": {
          "ResourceAccessPolicies": [],
          "Execution": {
            "IsolationMode": "NoContainer",
            "RunAs": {
              "Uid": 0,
              "Gid": 0
            }
          },
          "Variables": {
                "BOARD":"Ultra96"
           }
        },
        "Executable": "python",
        "Pinned": true,
        "Timeout": 500
      }
    },
    {
      "Id": "xilinx_bitstream_deploy_handler",
      "FunctionArn": "${xilinx_bitstream_deploy_handler_arn}",
      "FunctionConfiguration": {
        "EncodingType": "json",
        "Environment": {
          "ResourceAccessPolicies": [],
          "Execution": {
            "IsolationMode": "NoContainer",
            "RunAs": {
              "Uid": 0,
              "Gid": 0
            }
          },
          "Variables": { 
                "BOARD":"Ultra96"
           }
        },
        "Executable": "python",
        "Pinned": false,
        "Timeout": 500
      }
    },
    {
      "Id": "xilinx_video_inference_handler",
      "FunctionArn": "${xilinx_video_inference_handler_arn}",
      "FunctionConfiguration": {
        "EncodingType": "json",
        "Environment": {
          "ResourceAccessPolicies": [],
          "Execution": {
            "IsolationMode": "NoContainer",
            "RunAs": {
              "Uid": 0,
              "Gid": 0
            }
          },
          "Variables": {
                "BOARD":"Ultra96"
           }
        },
        "Executable": "python",
        "Pinned": false,
        "Timeout": 500
      }
    },
    {
      "Id": "xilinx_image_upload_handler",
      "FunctionArn": "${xilinx_image_upload_handler_arn}",
      "FunctionConfiguration": {
        "EncodingType": "json",
        "Environment": {
          "ResourceAccessPolicies": [],
          "Execution": {
            "IsolationMode": "NoContainer",
            "RunAs": {
              "Uid": 0,
              "Gid": 0
            }
          },
          "Variables": {
                "BOARD":"Ultra96"
           }
        },
        "Executable": "python",
        "Pinned": true,
        "Timeout": 500
      }
    }
  ]
}
EOF

echo Creating the function definition.
function_v_arn=$(aws greengrass-pp create-function-definition --output text \
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
      "Id":      "hello-world-to-cloud",
      "Source":  "${xilinx_hello_world_arn}",
      "Subject": "hello/world",
      "Target":  "cloud"
    },
    {
      "Id":      "cloud-to-hello-world",
      "Source":  "cloud",
      "Subject": "hello/world",
      "Target":  "${xilinx_hello_world_arn}"
    },
    {
      "Id":      "deployer-handler-to-cloud",
      "Source":  "${xilinx_bitstream_deploy_handler_arn}",
      "Subject": "/unit-controller/bitstream-deploy",
      "Target":  "cloud"
    },
    {
      "Id":      "cloud-to-deployer-handler",
      "Source":  "cloud",
      "Subject": "/unit-controller/bitstream-deploy",
      "Target":  "${xilinx_bitstream_deploy_handler_arn}"
    },
    {
      "Id":      "inference-handler-to-cloud",
      "Source":  "${xilinx_video_inference_handler_arn}",
      "Subject": "/unit_controller/video-inference",
      "Target":  "cloud"
    },
    {
      "Id":      "cloud-to-inference-handler",
      "Source":  "cloud",
      "Subject": "/unit_controller/video-inference",
      "Target":  "${xilinx_video_inference_handler_arn}"
    },
    {
      "Id":      "upload-handler-to-cloud",
      "Source":  "${xilinx_image_upload_handler_arn}",
      "Subject": "/unit_controller/image-upload",
      "Target":  "cloud"
    },
    {
      "Id":      "cloud-to-upload-handler",
      "Source":  "cloud",
      "Subject": "/unit_controller/image-upload",
      "Target":  "${xilinx_image_upload_handler_arn}"
    },
    {
      "Id":      "sensor-value-to-cloud",
      "Source":  "${thing_afr_arn}",
      "Subject": "/remote_io_module/sensor_value",
      "Target":  "cloud"
    },
    {
      "Id":      "cloud-to-sensor-value",
      "Source":  "cloud",
      "Subject": "/remote_io_module/sensor_value",
      "Target":  "${thing_afr_arn}"
    },
    {
      "Id":      "sensor-status-to-cloud",
      "Source":  "${thing_afr_arn}",
      "Subject": "/remote_io_module/sensor_status",
      "Target":  "cloud"
    },
    {
      "Id":      "cloud-to-sensor-status",
      "Source":  "cloud",
      "Subject": "/remote_io_module/sensor_status",
      "Target":  "${thing_afr_arn}"
    },
    {
      "Id":      "core-shadow-to-bitstream-deploy-delta",
      "Source":  "GGShadowService",
      "Subject": "\$aws/things/${thing_agg}/shadow/update/delta",
      "Target":  "${xilinx_bitstream_deploy_handler_arn}"
    },
    {
      "Id":      "core-shadow-to-bitstream-deploy-update",
      "Source":  "${xilinx_bitstream_deploy_handler_arn}",
      "Subject": "\$aws/things/${thing_agg}/shadow/update",
      "Target":  "GGShadowService"
    },
    {
      "Id":      "core-shadow-to-bitstream-deploy-accepted",
      "Source":  "GGShadowService",
      "Subject": "\$aws/things/${thing_agg}/shadow/update/accepted",
      "Target":  "${xilinx_bitstream_deploy_handler_arn}"
    },
    {
      "Id":      "core-shadow-to-bitstream-deploy-rejected",
      "Source":  "GGShadowService",
      "Subject": "\$aws/things/${thing_agg}/shadow/update/rejected",
      "Target":  "${xilinx_bitstream_deploy_handler_arn}"
    }
  ]
}
EOF

echo Creating the subscription definition.
subscription_v_arn=$(aws greengrass-pp create-subscription-definition --output text \
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
group_v_arn=$(aws greengrass-pp create-group --output text \
                         --name ${thing_agg}-group \
                         --initial-version file://${d_agg_config}/group-init.json \
                         --query LatestVersionArn)

if test $? != 0; then
  echo Greengrass group creation failed. Clean and try again.
  echo Exiting.
  exit 1
fi

echo Associating the role to the Greengrass group.
group_info_raw=$(aws greengrass list-groups --output text \
                     --query "Groups[?Name == '${thing_agg}-group'].[Id,LatestVersion]")
group_info_id=$(echo $group_info_raw | tr -s ' ' ' ' | cut -f1 -d ' ')
aws greengrass-pp associate-role-to-group --group-id ${group_info_id} --role-arn ${agg_role}

if test $? != 0; then
  echo Greengrass role association failed. Clean and try again.
  echo Exiting.
  exit 1
fi

# Finish
echo Thank you and have a nice day.
