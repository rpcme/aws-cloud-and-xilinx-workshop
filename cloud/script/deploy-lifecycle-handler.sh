#! /bin/bash
prefix=$1

if test -z "$prefix"; then
  echo ERROR: First argument must be provided as a prefix.
  exit 1
fi

# Create role for this lambda function.
role_name=iot-lifecycle-handler-role
function_name=aws_xilinx_workshop_lifecycle_handler

function_found=$(aws lambda list-functions --output text \
        --query "Functions[?FunctionName=='${function_name}']")

if test ! -z "${function_found}"; then
  function_arn=$(aws lambda get-function --output text \
                   --function-name ${function_name} \
                   --query Configuration.FunctionArn)
fi

role_found=$(aws iam list-roles --output text \
        --query "Roles[?RoleName=='${role_name}']")
if test ! -z "${role_found}"; then
    role_arn=$(aws iam get-role --output text \
                    --role-name ${role_name} \
                    --query Role.Arn)
fi

if test -z "${function_arn}"; then
  echo Creating lambda function in the cloud.

  if test -z "${role_arn}"; then
    echo Creating role.

    cat <<EOF > /tmp/${role_name}-trust.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    EOF

    role_arn=$(aws iam create-role --output text \
                   --role-name ${role_name} \
                   --assume-role-policy-document file:///tmp/${role_name}-trust.json \
                   --query Role.Arn)

    aws iam attach-role-policy --role-name ${role_name} --policy-arn "arn:aws:iam::aws:policy/AWSIoTFullAccess"
    aws iam attach-role-policy --role-name ${role_name} --policy-arn "arn:aws:iam::aws:policy/CloudWatchFullAccess"

    sleep 5

    function_version=$(aws lambda create-function --output text \
        --function-name ${function_name} \
        --zip-file fileb://${zipfile}  \
        --handler lambda_function.lambda_handler \
        --runtime python2.7 \
        --publish \
        --role ${role_arn} \
        --query Version)

    aws lambda create-alias \
        --function-name ${function_name} \
        --name PROD \
        --function-version ${function_version}

else

  echo Updating lambda function in the cloud.
  function_version=$(aws lambda update-function-code --output text --publish \
      --function-name ${function_arn} \
      --zip-file fileb://$(dirname $0)/../${function_name}.zip \
      --query Version)

  if test $? != 0; then
    echo Something bad happened. Remove the lambdas in the cloud and try again.
    exit 1
  else
    echo Function updated successfully.
    aws lambda update-alias \
        --name PROD \
        --function-name ${function_arn} \
        --function-version ${function_version}
  fi
fi

# CONNECTED RULE
cat <<EOF > /tmp/${prefix}ConnectedEventCollector.json
{
  "sql": "select principalIdentifier, 1 as is_connected, eventType as type from '\$aws/events/presence/connected/+'",
  "description": "Find all connected events and do something interesting",
  "actions": [
    "lambda": {
      "functionArn": "${is_connected_lambda_arn}"
    }
  ]
}
EOF

aws iot create-topic-rule --output text \
    --rule-name ${prefix}ConnectedEventCollector \
    --topic-rule-payload file:///tmp/${prefix}ConnectedEventCollector.json

# DISCONNECTED RULE
cat <<EOF > /tmp/${prefix}DisconnectedEventCollector.json
{
  "sql": "select principalIdentifier, 0 as is_connected, eventType as type from '\$aws/events/presence/disconnected/+'",
  "description": "Find all connected events and do something interesting",
  "actions": [
    "lambda": {
      "functionArn": "${is_connected_lambda_arn}"
    }
  ]
}
EOF

aws iot create-topic-rule --output text \
    --rule-name ${prefix}DisconnectedEventCollector \
    --topic-rule-payload file:///tmp/${prefix}DisconnectedEventCollector.json
