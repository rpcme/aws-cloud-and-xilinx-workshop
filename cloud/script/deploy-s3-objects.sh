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

prefix=$1
if test -z "${prefix}"; then
  echo ERROR: first argument must be the bucket prefix.
  exit 1
fi

f_bitstream=gstreamer_deephi.bit
d_bitstream=/usr/local/lib/python3.6/dist-packages/pydeephi/boards/Ultra96
bitstream=${d_bitstream}/${f_bitstream}

d_parameters=/tmp
f_parameters=parameters.txt
parameters=${d_parameters}/${f_parameters}

bucket_name=${prefix}-aws-cloud-and-xilinx-workshop
local_path=/home/xilinx/${bucket_name}
bucket_policy_location=./bucket-policy.json
echo Checking if the bucket prefix is OK.

bucket_check=$(aws s3api head-bucket --bucket ${bucket_name} 2>&1 | xargs echo | sed -e 's/.*(\(...\)).*/\1/')

echo Check completed.

if test "${bucket_check}" -eq "404"; then
  echo The bucket prefix you have chosen is OK.
elif test "${bucket_check}" -eq "403"; then
  echo The bucket prefix you have chosen is taken by another AWS Account.
  echo Choose another.
  exit 1
else
  echo The bucket prefix you have chosen already exists in your account.  Either
  echo delete the existing bucket or choose another prefix.  The bucket name
  echo is: ${bucket_name}
  exit 1
fi

if test ! -f ${bitstream}; then
  echo ERROR: Bitstream file not found:
  echo "       ${bitstream}"
  echo "       This file is required for Lab 4.  Ensure you are issuing this"
  echo "       command from the Ultra96 development board."
  exit 1
fi

echo Creating S3 bucket [${bucket_name}]
bucket=$(aws s3api create-bucket --output text \
             --create-bucket-configuration '{ "LocationConstraint": "us-west-2" }' \
             --bucket "${bucket_name}" \
             --query Location)
if test $? != 0; then
  echo Error creating bucket.  It could have been an itermittent problem.
  echo Please try again.
fi

my_ip=$(curl ifconfig.co  --stderr /dev/null)

cat <<EOF > ${bucket_policy_location}
{
  "Version": "2012-10-17",
  "Id": "S3PolicyId1",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${bucket_name}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${my_ip}/32"
        }
      }
    }
  ]
}
EOF

echo Constraining bucket access to this specific device

aws s3api put-bucket-policy --bucket ${bucket_name} --policy file://${bucket_policy_location}

echo Stage deployable bitstream files to S3 for Lab 4

cat <<EOF > ${parameters}1
5
2
EOF

cat <<EOF > ${parameters}2
5
3
EOF

# Right now the same bitstream file is being used. This shouldn't be the case.
# When separate bitstreams are used, the source to copy will be different
# between the versions.

for i in 1 2; do
  echo Staging ${f_bitstream} to version ${i}
  aws s3 cp --quiet  --acl public-read \
    ${bitstream}  s3://${bucket_name}/bitstream_deploy/${i}/${f_bitstream}
  echo Staging ${f_parameters} to version ${i}
  aws s3 cp --quiet  --acl public-read \
  ${parameters}${i} s3://${bucket_name}/bitstream_deploy/${i}/${f_parameters}
done

# When the bitstream download operation takes place during Greengrass lambda
# invocation, the bitstream will be placed here.

mkdir -p /home/xilinx/download
