# Workshop: Integrate the AWS Cloud with Responsive Xilinx Machine Learning at the Edge
# Copyright (C) 2018 Amazon.com, Inc. and Xilinx Inc.  All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#! /bin/bash

function_name=$1
role_name=lambdas-for-greengrass

base=$(dirname $0)/../${function_name}
zipfile=$(dirname $0)/../${function_name}.zip
pushd ${base} > /dev/null
zip -q -r ${zipfile} *
popd > /dev/null

function_found=$(aws lambda list-functions --output text \
        --query "Functions[?FunctionName=='${function_name}']")
if [ ! -z "${function_found}" ]; then
  function_arn=$(aws lambda get-function --output text \
                   --function-name ${function_name} \
                   --query Configuration.FunctionArn)
fi

role_found=$(aws iam list-roles --output text \
        --query "Roles[?RoleName=='${role_name}']")
if [ ! -z "${role_found}" ]; then
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

aws iam put-role-policy --output text                                                    \
    --role-name ${role_name}                                                \
    --policy-name ${role_name}-policy                                           \
    --policy-document file:///tmp/${role_name}-policy.json
  fi

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

