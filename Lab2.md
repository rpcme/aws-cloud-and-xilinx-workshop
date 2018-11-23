# Lab 2. Establish Amazon FreeRTOS and AWS Greengrass Connectivity

In this lab we will establish basic connectivity to the AWS cloud for both the MicroZed and Ultra96 devices.  In order to do this, we need to establish unique device identities that enable authentication to AWS IoT.  This is done through a client certificate and private key.  You will need to create these credentials in your AWS account and then configure them to each device.

## Configure AWS IoT Credentials and Deploy to MicroZed microSD card

In this section, you will configure and deploy AWS IoT Credentials and copy them to the MicroZed microSD card. The physical credential files, the private key and certificate for each device, will be placed in ```$HOME/aws-cloud-and-xilinx-workshop/edge/auth-GGGROUP-node-zynq7k``` and ```$HOME/aws-cloud-and-xilinx-workshop/edge/auth-GGGROUP-gateway-ultra96```.

1. Ensure the the MiroZed board is powered off by unplugging its two USB cables.
2. Eject the MicroZed microSD card.
3. Plug the microSD into the USB-to-SD Card adapter.
4. Plug the USB-to-SD Card adapter into the USB port of the Ultra96 board. Wait a few seconds.
5. Mount the microSD card on the file system, supplying password 'xilinx' if required:

   ```bash
   sudo mount /dev/sda /media
   ```
6. On the Ultra96 debug interface navigate to the directory containing the scripts for deploying cloud objects.

   ```bash
   cd $HOME/aws-cloud-and-xilinx-workshop/cloud/script
   ```
7. Run the script that configures the credentials for the devices to connect to your AWS account through AWS IoT. The edge hardware that you are using in this workshop is uniquely identified with a group prefix within your AWS account. This allows people at multiple tables who may be sharing a corporate AWS account to operate with their own hardware. Your group prefix does not have to be the same as the S3 prefix you have used previously.

	```bash
	./deploy-awsiot-objects.sh <your-group-prefix>
	```

   When the script completes, the keys and certificates will be in the directories specified above. The script will also copy any necessary files directly to the MicroZed microSD card. Run the following command to see what is on the SD card:

	```bash
	ls /media
	```
   
   You should see the following files, where GGGROUP is your group prefix:
   
   
    - BOOT.bin
    - GGGROUP-node-zynq7k.crt.pem	
    - GGGROUP-node-zynq7k.key.prv.pem
    - ggconfig.txt
   
   
   BOOT.bin contains the application run on the MicroZed and its associated hardware design.
   The credential files link the device to your account to allow subscription of pre-defined MQTT messages from the platform.
   The file 'ggconfig.txt' contains broker endpoint information and GGGROUP for use by the application.
   
8. Unmount the microSD card
	```bash
	sudo umount /media
	```

9. Unplug the USB-to-SD Card adapter from the Ultra96 USB port. 

## Configure and Deploy AWS Greengrass on Xilinx Ultra96

The Ultra96 runs Linux and AWS Greengrass. Use the following steps to prepare the credentials for your Ultra96 board,
so that your Ultra96 can be used as a greengrass core.

1. Copy the private key and certificate to AWS Greengrass.

   ```bash
   sudo cp $HOME/aws-cloud-and-xilinx-workshop/edge/auth-*gateway-ultra96/*pem /greengrass/certs/
   ```

2. Copy the AWS Greengrass configuration file ```config.json``` to the AWS Greengrass installation.

   ```bash
   sudo cp $HOME/aws-cloud-and-xilinx-workshop/edge/auth-*gateway-ultra96/config.json /greengrass/config/
   ```

3. With the certificates and configuration file in place,  we can start 
   the AWS Greengrass core service. Run the following commands in the 
   Ultra96 terminal window.

	```bash
	sudo /greengrass/ggc/core/greengrassd start
	```
	Verify that you see the Greengrass daemon start by seeing a response in the CLI of "Greengrass successfully started with PID: XXXX".

4. Build and upload the AWS Lambda function named ```xilinx-hello-world```.

	```bash
	cd $HOME/aws-cloud-and-xilinx-workshop/cloud/script
	./make-and-deploy-lambda.sh xilinx-hello-world
	```

	You can see from its output that the script performs the following acts:

	- Creates a Role for the function if the Role does not already exist
	- Packages the code located in ```$HOME/aws-cloud-and-xilinx-workshop/cloud/xilinx-hello-world``` to a zip file
	- Uploads the code to the AWS Lambda service
	- Applies a version number to the function
	- Creates an alias for the function

5. Although in this lab we are only using one lambda function, let's repeat this step for all the lambda
   functions so that we do not need to re-create the AWS Greengrass group.
   
	```bash
	./make-and-deploy-lambda.sh xilinx-bitstream-deploy-handler
	./make-and-deploy-lambda.sh xilinx-image-upload-handler
	./make-and-deploy-lambda.sh xilinx-video-inference-handler
	```
   Again, these lambdas will be used in later labs.

6. Make the initial AWS Greengrass group configuration. The group creation 
   has been automated to reduce the amount of time required for this procedure.

	```bash
	cd $HOME/aws-cloud-and-xilinx-workshop/edge/script
	./greengrass-core-init.sh <your-s3-bucket-name> <your-group-prefix>
	```
   Based on the previous lab, your s3 bucket name should have a format of `<your-unique-prefix>-aws-cloud-and-xilinx-workshop`.

7. Perform the initial deployment of AWS Greengrass.

	Run these commands in the Ultra96 terminal window.

	```bash
	cd $HOME/aws-cloud-and-xilinx-workshop/cloud/script
	./deploy-greengrass-group.sh <your-group-prefix>
	```
   Afer a few seconds, you should be able to see the group has been deployed 
   successfully.

8. Go to the AWS IoT Console page and click on "Test". 
Click on "Subscribe to a topic" and enter "hello/world". 
Click on "Subscribe to topic" to confirm. 
You should now see a MQTT response from the Ultra96 platform in the test window response.
See picture below for expected response.

![alt text](images/Greengrass_HelloWorld_Test.PNG "Greengrass Successful Response")


## Configure and Deploy Amazon FreeRTOS on Xilinx Zynq-7010

The MicroZed device boots Amazon FreeRTOS from a microSD card.

1. Remove the microSD card from the USB adapter and plug the microSD card into the MicroZed board
2. Power the microZed by plugging in the two USB cables.
2. In the AWS IoT Console for your region, navigate to the **Test** tool listed in the left column.
3. Select "Publish to a topic" sub-menu, enter "freertos/demos/echo" for the topic, and click "Publish to topic". See picture below.

	![alt text](images/AFR_HelloWorld_Test.png "a:FreeRTOS Publish Test")
7. You should now see an MQTT response from the MicroZed platform in the test window response.  See picture below for expected response.

	![alt text](images/AFR_HelloWorld_Test_Response.png "a:FreeRTOS Successful Response")

## Outcomes

In this lab we established basic "hello world" connectivity from an a:FreeRTOS IoT node on the MicroZed platform and from a Linux Greengrass IoT node on the Ultra96 platform.

## Learning More About These Concepts

[Next Lab](./Lab3.md)

[Index](./README.md)
