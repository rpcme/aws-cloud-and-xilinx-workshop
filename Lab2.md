# Lab 2. Establish Amazon FreeRTOS and AWS Greengrass Connectivity
In this lab we will establish basic connectivity to the AWS cloud for both the MicroZed and Ultra96 devices.  In order to do this we need to establish unique device identities that link the device to your AWS IoT account.  This is done through a unique certificate and encyrption key.  You will need to create these credentials in your AWS account and then manually copy them to each device.

## Configure and Deploy AWS IoT Credentials

In this section, you will configure and deploy AWS IoT Credentials.  The physical credential files, the private key and certificate for each device, will be placed in ```$WORKSHOP_HOME/edge/auth-node-zynq7k``` and ```$WORKSHOP_HOME/edge/auth-gateway-ultra96```.

1. Navigate to the directory containing the scripts for deploying cloud objects.

   ```bash
   cd $WORKSHOP_HOME/cloud/script
   ```
2. Run the script that configures the credentials for the devices to connect to your AWS account through AWS IoT.

	```bash
	./deploy-awsiot.sh
	```

When the script completes, the keys and certificates will be in the directories specified above.


## Configure and Deploy Amazon FreeRTOS on Xilinx Zynq-7010

The MicroZed device runs Amazon FreeRTOS.  You will copy the credentials you download from the IoT console to the MicroZed SD Card with ```$WORKSHOP_HOME/edge/auth-node-zynq7k/gateway-ultra96.crt.pem``` and ```$WORKSHOP_HOME/edge/auth-node-zynq7k/gateway-ultra96.key.prv.pem``` files into **TBD** directory.  These credentials will link the device to your account which we will then subscribe to a pre-defined MQTT message from the platform.

1. Power off the MiroZed board by unplugging the USB cables.
2. Eject the SD Card.
3. Copy the AWS credential files to TBD directory.  Ensure they have TBD file names.
4. Plug the microSD card into the MicroZed board and power the system.
5. In the AWS IoT Console, navigate to the **Test** tool listed in the left column.
6. Select "Publish to a topic" sub-menu and enter "freertos/demos/echo" and click the "Publish to topic". See picture below.

	![alt text](images/AFR_HelloWorld_Test.png "a:FreeRTOS Publish Test")
7. You should now see a MQTT response from the MicroZed platform in the test window response.  See picture below for expected response.

	![alt text](images/AFR_HelloWorld_Test_Response.png "a:FreeRTOS Successful Response")

## Configure and Deploy AWS Greengrass on Xilinx Ultra96

The Ultra96 runs Linux and AWS Greengrass.  You will copy the credentials you download from the IoT console to the Ultra96 SD Card with TBD file name(s) into TBD directory. These credentials will link the device to your account which we will then use to deploy a simple "Hello world" Lambda function and subscribe to the associated MQTT message from the platform.

1. Copy the private key and certificate to AWS Greengrass.
2. Modify the AWS Greengrass configuration file so the Thing ARN attribute matches the provisioned Thing ARN.  In this workshop, this means modifying the AWS account number.
3. Copy the configuration to AWS Greengrass.
4. Start AWS Greengrass.

	```bash
	/greengrass/ggc/core/greengrassd start
	```
5. Perform the initial deployment of AWS Greengrass.  

# Outcomes

# Learning More About These Concepts

[Next Lab](./Lab3.md)

[Index](./README.md)

