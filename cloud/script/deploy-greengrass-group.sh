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

echo "deploying id      [$group_info_id]"
echo "          version [$group_info_version]"

deployment_id=$(aws greengrass create-deployment \
                    --deployment-type NewDeployment \
                    --group-id ${group_info_id} \
                    --group-version ${group_info_version} \
                    --query DeploymentId)

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
