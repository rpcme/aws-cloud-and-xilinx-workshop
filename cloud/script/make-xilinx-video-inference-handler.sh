#! /bin/sh

function_name=xilinx-video-inference-handler
role_name=lambdas-for-greengrass

base=$(dirname $0)/../${function_name}
zipfile=$(dirname $0)/../${function_name}.zip
pushd ${base}
zip -q -r ${zipfile} *
popd

function_arn=$(aws lambda get-function \
                   --function-name ${function_name} \
                   --query Configuration.FunctionArn)
role_arn=$(aws iam get-role \
               --role-name ${role_name} \
               --query Role.Arn)

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
role_arn=$(aws iam create-role \
               --role-name ${role_name} \
               --assume-role-policy-document file:///tmp/${role_name}-trust.json \
               --query Role.Arn)
cat <<EOF > /tmp/${role_name}-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
aws iam put-role-policy                                                     \
    --role-name ${role_name}                                                \
    --policy-name ${role_name}-policy                                           \
    --policy-document file:///tmp/${role_name}-policy.json
  fi

  function_version=$(aws lambda create-function \
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
    echo Something bad happened.  Maybe you need to remove the lambda function in the cloud and start again.
    exit 1
  else
    echo Function updated successfully.
    aws lambda update-alias \
        --name PROD \
        --function-name ${function_arn} \
        --function-version ${function_version}
  fi
fi
