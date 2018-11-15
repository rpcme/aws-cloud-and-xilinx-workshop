# Lab 2. Establish Amazon FreeRTOS and AWS Greengrass Connectivity

In this lab we will establish basic connectivity to the AWS cloud for both the MicroZed and Ultra96 devices.  In order to do this, we need to establish unique device identities that enable authentication to AWS IoT.  This is done through a client certificate and private key.  You will need to create these credentials in your AWS account and then configure them to each device.

## Configure and Deploy AWS IoT Credentials

In this section, you will configure and deploy AWS IoT Credentials.  The physical credential files, the private key and certificate for each device, will be placed in ```$WORKSHOP_HOME/edge/auth-node-zynq7k``` and ```$WORKSHOP_HOME/edge/auth-gateway-ultra96```.

1. Navigate to the directory containing the scripts for deploying cloud objects.

   ```bash
   cd $WORKSHOP_HOME/cloud/script
   ```
2. Run the script that configures the credentials for the devices to connect to your AWS account through AWS IoT.

	```bash
	./deploy-awsiot-objects.sh
	```

When the script completes, the keys and certificates will be in the directories specified above.

## Configure and Deploy AWS Greengrass on Xilinx Ultra96

The Ultra96 runs Linux and AWS Greengrass. Use the following steps to prepare the credentials for your Ultra96 board,
so that your Ultra96 can be used as a greengrass core.

1. Copy the private key and certificate to AWS Greengrass.

   ```bash
   sudo cp $WORKSHOP_HOME/edge/auth-gateway-ultra96/*pem /greengrass/certs/
   ```

2. Copy the AWS Greengrass configuration file ```config.json``` to the AWS Greengrass installation.

   ```bash
   sudo cp $WORKSHOP_HOME/edge/auth-gateway-ultra96/config.json /greengrass/config/
   ```

6. Build and upload the AWS Lambda function named ```xilinx-hello-world```.

	```bash
	cd $WORKSHOP_HOME/cloud/script
	./make-and-deploy-lambda.sh xilinx-hello-world
	```

	You can see from its output that the script performs the following acts:

	- Creates a Role for the function if the Role does not already exist
	- Packages the code located in ```$WORKSHOP_HOME/cloud/xilinx-hello-world``` to a zip file
	- Uploads the code to the AWS Lambda service
	- Applies a version number to the function
	- Creates an alias for the function


 Copy the "hello world" Lambda function from Git at XYZ.  It will be wrapped as a zip file labeled hello_world_python_lambda.zip.


7. Upload the function to the AWS Lambda in the AWS Console.  Ensure that the "Handler" is defined as greengrassHelloWorld.function_handler.
8. In the Greengrass device menu of AWS Console select "Add Lambda" function.  Point to the "Hello World" function just created.
9. Edit the Lambda function as:
	Memory limit = 16MB
	Timeout = 25s
	Lambda lifecycle = Make this function long-lived and keep it running indefinitely
	Read access to /sys directory = Disable
	Iput payload data type = JSON
10. Add a subscription so that AWS will receive the hello world MQTT messages.  Click "Add Subscription" with the following information:
	Source = Lambda Function -> Greengrass_HelloWorld
	Target = IoT Cloud
	Topic = hello/world

3. Make the initial AWS Greengrass group configuration.  The group creation has been automated to reduce the amount of time required for this procedure.

	```bash
	cd $WORKSHOP_HOME/edge/script
	./greengrass-core-init.sh test1-aws-cloud-and-xilinx-workshop
	```

4. Start AWS Greengrass.

	Run these commands in the Ultra96 terminal window.

	```bash
	/greengrass/ggc/core/greengrassd start
	```

5. Perform the initial deployment of AWS Greengrass.

	Run these commands in the Ultra96 terminal window.

	```bash
	cd $WORKSHOP_HOME/cloud/script
	./greengrass-core-deploy.sh
	```

12. Go to the AWS IoT Console page and click on "Test".  Click on "Subscribe to a topic" and enter "hello/world". You should now see a MQTT response from the Ultra96 platform in the test window response.  See picture below for expected response.

![alt text](images/Greengrass_HelloWorld_Test.PNG "Greengrass Successful Response")


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

# Outcomes

In this lab we established basic "hello world" connectivity from an a:FreeRTOS IoT node on the MicroZed platform and from a Linux Greengrass IoT node on the Ultra96 platform.

# Learning More About These Concepts

[Next Lab](./Lab3.md)

[Index](./README.md)
