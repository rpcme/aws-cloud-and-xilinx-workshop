# FAQ

In this section we will provide answers to common questions that users may see
in this workshop.

### What should I do if the Greengrass group deployment is always in progress?
First make sure that the AWS Greengrass daemon is running on your GG core device. Run the following commands in the termina to check whether the daemon is running:
  ps aux | grep -E 'greengrass.*daemon'
If the output contains a root entry for /greengrass/ggc/packages/1.6.0/bin/daemon, then the daemon is running.

If the daemon is not running then start the daemon:
  cd /greengrass/ggc/core/
  sudo ./greengrassd start
Now retry the deployment.

Next in the IoT Console go to the GG Group being debugged and from the "Actions" menu select "Reset Deployments".

### What should I do if the Greengrass group deployment failed?
First make sure that the AWS Greengrass daemon is running on your GG core device. Run the following commands in the termina to check whether the daemon is running:
  ps aux | grep -E 'greengrass.*daemon'
If the output contains a root entry for /greengrass/ggc/packages/1.6.0/bin/daemon, then the daemon is running.

If the daemon is not running then start the daemon:
  cd /greengrass/ggc/core/
  sudo ./greengrassd start
Now retry the deployment.

Next in the IoT Console go to the GG Group being debugged and from the "Actions" menu select "Reset Deployments".

### How can I reset the Greengrass group deployment?
In the AWS IoT Console go to the GG Group being debugged and from the "Actions" menu select "Reset Deployments".

### How can I deploy the same Greengrass group?

### How can I delete the Greengrass group and recreate the group?

### How can I change the lambda functions and then redeploy the Greengrass group?

### How can I delete the IoT things created by this workshop?

### How can I delete the IAM roles created by this workshop?



[Index](./README.md)
