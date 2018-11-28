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

if test -z "$prefix"; then
  group_agg=gateway-ultra96-group
else
  group_agg=${prefix}-gateway-ultra96-group
fi

group_info_raw=$(aws greengrass list-groups --output text \
                     --query "Groups[?Name == '${group_agg}'].[Id,LatestVersion]")
group_info_id=$(echo $group_info_raw | tr -s ' ' ' ' | cut -f1 -d ' ')
group_info_version=$(echo $group_info_raw | tr -s ' ' ' ' | cut -f2 -d ' ')

echo "deployment id      [$group_info_id]"
echo "deployment version [$group_info_version]"

deployment_id_raw=$(aws greengrass create-deployment \
                    --deployment-type NewDeployment \
                    --group-id ${group_info_id} \
                    --group-version ${group_info_version} \
                    --query DeploymentId)
deployment_id=$(echo $deployment_id_raw | cut -d'"' -f 2)

deployment_status=InProgress

while test "${deployment_status}" == "InProgress" || \
      test "${deployment_status}" == "Building" ; do
  echo Still deploying... status is [${deployment_status}]... waiting 2 seconds.
  sleep 2
  deployment_status=$(aws greengrass get-deployment-status --output text \
                          --group-id ${group_info_id} \
                          --deployment-id ${deployment_id} \
                          --query DeploymentStatus)

done

echo Finished! Resulting status: ${deployment_status}
