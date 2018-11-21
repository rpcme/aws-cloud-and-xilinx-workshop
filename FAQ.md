# FAQ

In this section we will provide answers to common questions that users may see
in this workshop.

### What should I do if the Greengrass group deployment is always in progress?
In the IoT Console go to the GG Group being debugged and from the "Actions" menu select "Reset Deployments".

If that does not resolve the deployment, next make sure that the AWS Greengrass daemon is running on your GG core device. Run the following commands in the termina to check whether the daemon is running:
  ps aux | grep -E 'greengrass.*daemon'
If the output contains a root entry for /greengrass/ggc/packages/1.X.X/bin/daemon, then the daemon is running.

If the daemon is not running then start the daemon:
  cd /greengrass/ggc/core/
  sudo ./greengrassd start

Once the daemon is running retry deployment.  

If deployment is still failing and the GG dameon was already running in the previous step, then stop and then start the GG Daemon.
  cd /greengrass/ggc/core/
  sudo ./greengrassd stop
  sudo ./greengrassd start

### What should I do if the Greengrass group deployment failed?
First make sure that the AWS Greengrass daemon is running on your GG core device. Run the following commands in the termina to check whether the daemon is running:
  ps aux | grep -E 'greengrass.*daemon'
If the output contains a root entry for /greengrass/ggc/packages/1.X.X/bin/daemon, then the daemon is running.

If the daemon is not running then start the daemon:
  cd /greengrass/ggc/core/
  sudo ./greengrassd start
Now retry the deployment.

Next in the IoT Console go to the GG Group being debugged and from the "Actions" menu select "Reset Deployments".

### How can I reset the Greengrass group deployment?
In the AWS IoT Console go to the GG Group being debugged and from the "Actions" menu select "Reset Deployments".

### How can I deploy the same Greengrass group?

### How can I delete the Greengrass group and recreate the group?
First to delete group do so from the IoT Console by selecting "Greengrass" from the left service pane, then select "Greengrass" -> "Groups".  You should now see the group in question and then click on the "..." on the group and select "Delete".  

### How can I change the Lambda functions and then redeploy the Greengrass group?
If you have already completed the intial Lambda function build deployments created in Lab 2 by the make-and-deploy-lambda.sh script they should show up in the AWS Labmda service interface.  In AWS IoT Console select "Services" and then "Lambda".

From the AWS Lambda interface you will see any functions that you have built listed under the "Functions" menu.  Select the Lambda function that you want to change and you can view the source code in the "Function code" window.  Once code modifications are completed click "Save", then you select "Actions" menu and select "Publish new version" to make it available for deployment.

Ensure that the Alias "PROD" is linked to the new version of the Lambda function; then re-deploy the GG Group.  This should automatically pull the updated version of the function.

### How can I delete the IoT things created by this workshop?
In the AWS IoT Console select "Manage" -> "Things" from the left navication pane and then click on the "..." on the group and select "Delete".  

### How can I delete the IAM roles created by this workshop?
Within AWS IAM Management Console click the box next to the "User name" that you want to delete and then click on the "Delete user" button.

[Index](./README.md)
