# Lab 1: Setup the Environment

In this lab, you will initialize your account with a static web application, Amazon Cognito, and other configuration.  You will also login to your Amazon Web Services account to configure credentials for the Xilinx hardware used in this workshop.

## Applying your Credits

If part of this workshop you received credits to offset any potential cost occurred in the AWS Cloud during this workshop, please follow these steps to apply the credits.


## Xilinx Hardware Setup

Most of the physical hardware will be pre-configured for you prior to the start of the workshop.  This section outlines the steps to configuring the physical aspects such that you can quickly check your hardware.

### Avnet MicroZed IIoT Kit
1. Attach the ST Micro X-NUCLEO Shield to the Arduno Carrier Card.  This connects the sensor set to the FPGA programmable logic.
2. Plug in the Maxim 31855 PMOD thermocouple to Arduinio Carrier Card J3 connector labeld "PL_PMOD".  Match pin numbers (pin 1 to pin 1) between the boards - plug into the top row of J3.  This connects the sensor to the FPGA programmable logic.
3. Plug the MicroZed System on Module (SoM) onto the Arduno Carrier Card.  When completed with this step the system should look like the picture below.

   ![alt text](images/MicroZed_IIoT_HW_Overview.png "IIoT Kit Overview")
4. Ensure that the microSD card is plugged in. It is located on the bottom side of the board below the USB UART.  Check that the boot mode jumpers (JP1-JP3) are configured for SD Card boot (JP1 - Pins 1 & 2, JP2 - Pins 2 & 3, JP3 - Pins 2 & 3). See picture below for the proper jumper settings.

   ![alt text](images/MicroZed_SD_CardJumperSettings.png?raw=true "SD Card Boot Jumper Settings")
5. Plug an Ethernet cable from the RJ45 connector of the MicroZed SoM to the Ethernet switch on your table.
6. Connect one microUSB cable to J7 of the Arduino Carrier Card and the USB hub.  This provides power to the boards.
7. Connect one microUSB cable to J2 of the MicroZed SoM and the USB hub.  This provides the debug UART interface. Set COM port parameters to 115200,N,8,1.

### Avnet Ultra96

1. Ensure that the microSD is plugged in.
2. Plug in the 12V power supply to J5.
3. Plug in the USB-to-Ethernet adapter to J9, then plug an Ethernet cable between the adapter and the Ethernet switch on your table.
4. Connect a microUSB cable to J1 of the Ultra96 and the USB hub. This provides three services to your PC:
    1. A debug UART interface
    2. A portable drive named 'PYNQ-USB' to navigate the Ultra96 file system
    3. An RNDIS (Ethernet over USB) interface

After the set-up the Ultra96 should look like the picture below.

![alt text](images/Ultra96_NoCamera.jpg?raw=true "Ultra96 Kit Overview")

### Power up your Hardware

The MicroZed should power up automatically when you plug in the microUSB cable. Ensure that D2 (blue LED) and D5 (green LED) on the MicroZed SoM are illuminated.
The Ultra96 should power up after pressing SW3. S3 is the pushbutton switch near the power connector. You should see DS6 and DS9 (green LEDs) illuminated.

### System Software Installation

#### Ultra96 Portable Drive
No installation is required - you should see 'PYNQ-USB' mapped to a drive letter in Windows Explorer. Note the drive letter.

#### Serial Port Installation
The MicroZed and the Ultra96 have one COM port each.
(Windows 7) Open Device Manager to locate your COM ports.  Note the two COM port numbers.

MicroZed uses a Silicon Labs CP2104 USB-to-UART Bridge. If the driver is not automatically detected by your OS, it can be downloaded from: https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers.

Ultra96 uses a Gadget Serial Driver. If the driver is not automatically detected by your OS, load the driver from the 'serial_driver' folder on the Ultra96 portable drive.

Ensure you have a serial port terminal emulator such as Putty installed. It can be downloaded from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html.

### Configuring and Deploying your Hardware
Ensure you do not have VPN software running for this workshop.

Configure your terminal emulator to access the two COM ports by saving individual sessions for them. Each session should use 115200,8,N,1 for the serial port settings.

Open the terminal emulator for Ultra96 and do the following:
1. Login: The username is 'xilinx' and the password is 'xilinx'. Your sudo password is also 'xilinx'.
2. Run the command `ip a` to see all ethernet interfaces. You should see:
    1. usb0 at 192.168.3.1/24
    2. eth0 at an address determined by your DHCP server. This is the address for the ultra96 as a greengrass controller.
    3. Other interfaces will not be used in this workshop
3. Now run `ping -c 3 www.xilinx.com` to verify internet connectivity.

## AWS Cloud Setup


### Prerequisites

These labs require that you have Git and the AWS Command Line Interface (CLI) installed in order to perform functions to the AWS Cloud. The Ultra96 root file system includes these commands. All shell commands shown in the labs are assumed to be performed in the terminal emulator for the Ultra96, after logging in as 'xilinx'. A general familiarity with Linux command line operation under the bash shell is assumed.

The following scripts will succeed if your IAM user has the *AdministratorAccess* policy attached with no permission boundaries.
This is very broad, and narrower options might succeed.

### Clone Workshop Repository

In this section, you will clone the workshop Git repository.  The Git repository contains all the workshop code and scripts you will use.

1. If not already done, open the UART connection to the Ultra96 device as 115200-8-N-1, and login.
2. Ensure you are in the $HOME directory

   ```bash
   cd $HOME
   ```
3. Clone the repository by running the following command.

   ```bash
   git clone https://github.com/rpcme/aws-cloud-and-xilinx-workshop
   cd aws-cloud-and-xilinx-workshop
   ```
You're done! Let's move to the next section.

### Configure AWS Command Line Interface (CLI)

In this section, we will configure the AWS CLI on the Ultra96 board. The AWS CLI provides the mechanisms for driving AWS IoT Console cloud actions from the CLI on the edge target. For more information or details on configuration, visit the [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) page. 
The AWS CLI has already been installed on the Ultra96 for you.

Start the configuration as follows:
```bash
aws configure
```
This step will ask for the following pieces of information:
1. Your AWS Access Key ID
2. Your AWS Secret Access Key
3. Default region name - use *eu-west-1*
4. Default output format - use *json*


Note that the first two will be stored unencrypted in the file ~/.aws/credentials, the rest will be stored in ~/.aws/config. For your security, delete the credentials file at the end of the workshop.


### Deploy AWS Cloud Artifacts

In this section, you will deploy AWS Cloud artifacts to your AWS account by using AWS Cloudformation.

1. Navigate to the directory containing the scripts for deploying cloud objects.

   ```bash
   cd $HOME/aws-cloud-and-xilinx-workshop/cloud/script
   ```
2. Run the script that triggers the Cloudformation deployment. The script packages deployable artifacts 
such as AWS Lambda functions, copies all the artifacts to an S3 bucket, and then executes the 
Cloudformation script from that S3 bucket.  Ensure you include a unique-prefix that is short and easily remembered. 

	```bash
	./deploy-s3-objects.sh <your-unique-prefix>
	```

The Cloudformation deployment occurs asynchronously, so the script will immediately return with a resulting stack deployment ID. You can use this stack deployment ID to check the status of the deployment. 

The above deployment will prepare an S3 bucket named `<your-unique-prefix>-aws-cloud-and-xilinx-workshop` for you. 
The script will also create a local folder `/home/xilinx/<your-unique-prefix>-aws-cloud-and-xilinx-workshop` 
for your files to synchronize with the S3 bucket. You should be able to see an FPGA bitstream uploaded to your S3 bucket,
while your local folder is empty. In later labs we will download this FPGA bitstream onto your board.

Note that S3 bucket names are globally unique. This means that if someone else has a bucket 
of a certain name, you cannot have a bucket with that same name. 
If you see *BucketAlreadyExists* error, try to rerun the script with another prefix.


## Outcomes
In this lab, you installed prerequisites to your workstation and installed lab prerequisites to the AWS Cloud in your account.

# Learning More About These Concepts


[Next Lab](./Lab2.md)

[Index](./README.md)
