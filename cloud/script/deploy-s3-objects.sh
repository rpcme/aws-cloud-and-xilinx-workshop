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

if test ! -f ${bitstream}; then
  echo ERROR: Bitstream file not found:
  echo "       ${bitstream}"
  echo "       This file is required for Lab 4.  Ensure you are issuing this"
  echo "       command from the Ultra96 development board."
  exit 1
fi

bucket=$(aws s3api create-bucket --output text \
             --create-bucket-configuration '{ "LocationConstraint": "us-west-2" }' \
             --bucket "${bucket_name}" \
             --query Location)

my_ip=$(curl ifconfig.co)

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

echo Upload files to S3 bucket
mkdir -p ${local_path}
cp -f ${bitstream} ${local_path}
cat <<EOF > ${parameters}
5
2
EOF

# Right now the same bitstream file is being used. This shouldn't be the case.
# When separate bitstreams are used, the source to copy will be different
# between the versions.

for i in 1 2; do
  aws s3 cp ${bitstream}  s3://${bucket_name}/bitstream_deploy/${i}/${f_bitstream}
  aws s3 cp ${parameters} s3://${bucket_name}/bitstream_deploy/${i}/${f_paramters}
done

#aws s3 sync ${local_path} s3://${bucket_name}/ --acl public-read

# When the bitstream download operation takes place during Greengrass lambda
# invocation, the birstream will be placed here.

mkdir -p /home/xilinx/download
