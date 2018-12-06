# Lab 1: Setup the Environment

In this lab you will prepare the hardware, download the workshop content locally, and initilize the cloud components.  We will also login to your Amazon Web Services account to configure credentials for the Xilinx hardware used in this workshop and to have interface for tracking the data and device shadows of the Xilinx devices.

## Applying your Credits

If as part of this workshop you received credits to offset any potential cost occurred in the AWS Cloud during this workshop, please follow the steps on the card provided to apply the credits.


## Xilinx Hardware Setup

Most of the physical hardware will be pre-configured for you prior to the start of the workshop.  This section outlines the steps to configuring the physical aspects such that you can quickly check your hardware.

The Ultra96 and MicroZed each have one serial connection to your workstation.  We will primarily be using the Ultra96 serial port in this workshop but provide reference on installation for both platforms in this section in case debug is required.

### Avnet MicroZed IIoT Kit
1. Attach the ST Micro X-NUCLEO Shield to the Arduno Carrier Card.  This connects the sensor set to the FPGA programmable logic.
2. Plug in the Maxim 31855 PMOD thermocouple to Arduinio Carrier Card J3 connector labeld "PL_PMOD".  Match pin numbers (pin 1 to pin 1) between the boards - plug into the top row of J3.  This connects the sensor to the FPGA programmable logic.
3. Plug the MicroZed System on Module (SoM) onto the Arduno Carrier Card.  When completed with this step the system should look like the picture below.

   ![alt text](images/MicroZed_IIoT_HW_Overview.png "IIoT Kit Overview")
4. Check that the boot mode jumpers (JP1-JP3) are configured for SD Card boot (JP1 - Pins 1 & 2, JP2 - Pins 2 & 3, JP3 - Pins 2 & 3). See picture below for the proper jumper settings.

   ![alt text](images/MicroZed_SD_CardJumperSettings.png?raw=true "SD Card Boot Jumper Settings")
5. Plug an Ethernet cable from the RJ45 connector of the MicroZed SoM to the Ethernet switch on your table.

Leave the MicroZed assembled as is and we will power it up at the end of Lab 2 after writing the microSD card contents via the Ultra96 platform.  The MicroZed board is powered by the J2 and J7 microUSB connections on the boards.

MicroZed uses a Silicon Labs CP2104 USB-to-UART Bridge. If the driver is not automatically detected by your OS, it can be downloaded from: https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers.

#### Serial Port Installation and Connection: Windows

Ensure you have a serial port terminal emulator such as [Putty](//www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) or [Tera Term](https://osdn.net/projects/ttssh2/releases/) installed.

1. Open Device Manager.  View the current COM ports available.
2. Plug in the MicroZed device.
3. Identify the change in COM ports.
4. Use Putty, Tera Term, or your other favorite serial program to connect to the COM port at 115200-N-1.

#### Serial Port Installation and Connection: MacOS/Linux

Virtually all Linux distributions have ```screen``` installed and MacOS has ```screen``` installed by default.

1. Open a [Terminal](https://en.wikipedia.org/wiki/Terminal_(macOS)) window on MacOS or an XTerm (or your favorite terminal program) on Linux.
2. Issue the following command to view current serial devices.

   ```bash
   ls /dev/cu.usb*
   ```
3. Plug in the MicroZed.
4. Issue the following command again to identify the device.

   ```bash
   ls /dev/cu.usb*
   ```
5. Identify the change of items in the list, and issue the following command:

   ```bash
   screen /dev/<device> 115200 -L
   ```

   For example, if the difference was ```cu.usbmodem0003```, the command would be:

   ```bash
   screen /dev/cu.usbmodem0003 115200 -L
   ```

Alternatively, if you use MacOS, the application [Serial](https://www.decisivetactics.com/products/serial/) is a great choice.  It is not free, but has many usability features that are common to applications running on MacOS.

### Avnet Ultra96
A pre-built Ultra96 image has been created to support this workshop.  As a user you need to first download this image and burn it to the 16GB microSD card included in the Ultra96 kit and boot the board.  The steps below outline this process:

1. Download the Ultra96 AWS re:Invent 2018 SD-card image from this [link](http://avnet.me/ultra96-pynq-aws-image).  For reference the MD5 checksum should be E385BE22AD5506A33F4B5D5CCA0FD3DF.
2. Unzip and image the microSD card with Win32DiskImager or similiar program.
3. Plug the microSD is plugged in.
4. Plug in the 12V power supply to J5.
5. Plug in the USB-to-Ethernet adapter to J9, then plug an Ethernet cable between the adapter and the Ethernet switch on your table.
6. Connect a microUSB cable to J1 of the Ultra96 and the USB hub. This USB interface provides the following three services to your PC but we will only be using the UART interface in this workshop.  
    1. A debug UART interface
    2. A portable drive named 'PYNQ-USB' to navigate the Ultra96 file system
    3. An RNDIS (Ethernet over USB) interface
7. Plug in the USB to microSD card reader with an 8GB microSD card installed. We will use this in Lab 2 to have Ultra96 write the MicroZed boot image.

After the set-up the Ultra96 should look like the picture below.

![alt text](images/Ultra96_NoCamera.jpg?raw=true "Ultra96 Kit Overview")


#### Serial Port Installation and Connection


The Ultra96 uses a Gadget Serial Driver. If the driver is not automatically detected by your OS, load the driver from the 'serial_driver' folder on the Ultra96 portable drive named 'PYNQ-USB'.

Open the terminal emulator for Ultra96 by following instructions for either the Windows operating system or MacOS/Linux operating system.


#### Serial Port Installation and Connection: Windows

1. Open Device Manager.  View the current COM ports available.
2. Plug in the MicroZed device.
3. Identify the change in COM ports.
4. Use Putty, Tera Term, or your other favorite serial program to connect to the COM port at 115200-8-N-1.

#### Serial Port Installation and Connection: MacOS/Linux

1. Open a [Terminal](https://en.wikipedia.org/wiki/Terminal_(macOS)) window on MacOS or an XTerm (or your favorite terminal program) on Linux.
2. Issue the following command to view current serial devices.

   ```bash
   ls /dev/cu.usb*
   ```
3. Plug in the MicroZed.
4. Issue the following command again to identify the device.

   ```bash
   ls /dev/cu.usb*
   ```
5. Identify the change of items in the list, and issue the following command:

   ```bash
   screen /dev/<device> 115200 -L
   ```

   For example, if the difference was ```cu.usbmodem0004```, the command would be:

   ```bash
   screen /dev/cu.usbmodem0004 115200 -L
   ```

### Configuring and Deploying your Hardware

**IMPORTANT** Ensure you do not have VPN software running for this workshop.

1. Login if requested.  For refernce at log-in and in future commands requiring sudo access:
	The username is ```xilinx``` and the password is ```xilinx```. 
	The ```sudo``` password is also ```xilinx```.
2. Run the command ```ip a``` to see all ethernet interfaces. You should see:
    1. ```usb0``` at 192.168.3.1/24
    2. ```eth0``` at an address determined by your DHCP server. This is the address for the Ultra96 running AWS Greengrass.
    3. Other interfaces will not be used in this workshop.
3. Run the command ```ping -c 3 aws.amazon.com``` to verify internet connectivity.

## AWS Cloud Setup


### Prerequisites

A general familiarity with Linux command line operation under the bash shell is assumed.

The labs require that you have Git and the AWS Command Line Interface (CLI) installed to perform functions in the AWS Cloud. The Ultra96 root file system includes these commands. All shell commands shown in the labs are assumed to be performed in the terminal emulator for the Ultra96, after logging in as ```xilinx```, which is the default user. 

The following scripts will succeed if your IAM user has the *```AdministratorAccess```* policy attached with no permission boundaries.
This is very broad, and narrower options might succeed.

### Clone Workshop Repository

In this section, you will clone the workshop Git repository.  The Git repository contains all the workshop code and scripts you will use.

1. If not already done, open the UART connection to the Ultra96 device as 115200-8-N-1, and login as xilinx user if requested.
2. Ensure you are in the $HOME directory

   ```bash
   cd $HOME
   ```
3. Clone the repository by running the following command.

   ```bash
   git clone https://github.com/rpcme/aws-cloud-and-xilinx-workshop
   cd aws-cloud-and-xilinx-workshop
   ```
   
   The total repository size is more than 30MB so it may take some time to download. Please be patient.
   
You're done! Let's move to the next section.

### AWS IoT Console Sign In

In this section you will log-in to the AWS IoT Console if you have not already done so.  Leave this interface open for the remainder of the lab as it is used for monitoring and testing the Xilinx edge devices.

Go to [AWS Console Sign In](https://aws.amazon.com/) page and click on the "Sign In" box in the upper right.  Log in with your AWS credentials and then browse to the IoT Core page.  We will use the services provided under IoT Core in the next few labs.

### Configure AWS Command Line Interface (CLI)

In this section, we will configure the AWS CLI on the Ultra96 board.  The AWS CLI provides the mechanisms for driving AWS IoT Console cloud actions from the CLI on the edge target - in this case Ultra96. For more information or details on configuration, visit the [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) page and follow steps 1-5 to add the *```AdministratorAccess```* policy to your username and capture the Key ID and Secret Access Key as you will need them in the steps below.

The AWS CLI has already been installed on the Ultra96 for you.

Start the configuration as follows:
```bash
aws configure
```
This step will ask for the following pieces of information:

1. Type or copy-paste your AWS Access Key ID acquired above and press ```Enter```.
2. Type or copy-paste AWS Secret Access Key acquired above and press ```Enter```.
3. Default region name - use ```us-west-2```
4. Default output format - use ```json```

Note that the first two will be stored unencrypted in the file ```~/.aws/credentials```, the rest will be stored in ```~/.aws/config```. For your security, delete the credentials file at the end of the workshop.

### Deploy AWS Cloud Artifacts

In this section, you will deploy AWS Cloud artifacts to your AWS account by using AWS Cloudformation.

1. Navigate to the directory containing the scripts for deploying cloud objects.

   ```bash
   cd $HOME/aws-cloud-and-xilinx-workshop/cloud/script
   ```

2. In this step, you will run a script that creates an S3 bucket in your account and adds artifacts that are used throughout the labs.  You will need to append this command with a unique prefix of your definition which we will use through other aspects of the workshop.

   ```bash
   ./deploy-s3-objects.sh <prefix>
   ```
   
   If you receive an error from the script stating the prefix has already been chosen, then please choose another.

   The script will create an Amazon S3 bucket named ```<prefix>-aws-cloud-and-xilinx-workshop```.



## Outcomes
In this lab, you installed prerequisites to your workstation and installed lab prerequisites to the AWS Cloud in your account.

[Next Lab](./Lab2.md)

[Index](./README.md)

Copyright (C) 2018 Amazon.com, Inc. and Xilinx Inc.  All Rights Reserved.
