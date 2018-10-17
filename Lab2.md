# Lab 2. Establish Amazon FreeRTOS and AWS Greengrass Connectivity
In this lab we will establish basic connectivity to the AWS cloud for both the MicroZed and Ultra96 devices.  In order to do this we need to establish unique device identities that link the device to your AWS IoT account.  This is done through a unique certificate and encyrption key.  You will need to create these credentials in your AWS account and then manually copy them to each device.
## MicroZed
The MicroZed device is running a:FreeRTOS.  You will copy the credentials you download from the IoT console to the MicroZed SD Card with TBD file name(s) into TBD directory.  These credentials will link the device to your account which we will then subscribe to a pre-defined MQTT message from the platform.
1. Power off the MiroZed board by unplugging the USB cables.
2. Eject the SD Card.
3. Copy the AWS credential files to TBD directory.  Ensure they have TBD file names.
4. Plug the SD Card back into the MicroZed board and re-power the system.
5. In AWS IoT Console navigate to the "Test" tool listed in the left column.
6. Select "Publish to a topic" sub-menu and enter "freertos/demos/echo" and click the "Publich to topic".  You should now see a MQTT response from the MicroZed platform.
## Ultra96
The Ultra96 is running Linux with the Greengrass SDK.  You will copy the credentials you download from the IoT console to the Ultra96 SD Card with TBD file name(s) into TBD directory. These credentials will link the device to your account which we will then use to deploy a simple "Hello world" Lambda function and subscribe to the associated MQTT message from the platform.

# Outcomes

# Learning More About These Concepts

[Next Lab](./Lab3.md)

[Index](./README.md)

