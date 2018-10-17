# Lab 1: Setup the Environment

In this lab, you will initialize your account with a static web application, Amazon Cognito, and other configuration.  You will also login to your Amazon Web Services account to configure credentials for the Xilinx hardware used in this workshop.


## AWS Cloud Setup

### Applying your Credits

If part of this workshop you received credits to offset any potential cost occurred in the AWS Cloud during this workshop, please follow these steps to apply the credits.

### Prerequisites

These labs require that you have Git and the AWS Command Line Interface (CLI) installed in order to perform functions to the AWS Cloud.



### Installing Workshop Artifacts


## Xilinx Hardware Setup

### Configuring and Deploying your Devices
Install the CP210x USB-to-UART driver used by both the MicroZed and Ultra96 boards.  If the driver is not automatically detected by your OS drivers can be downloaded from: https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers
#### Avnet MicroZed IIoT Kit
1. Attach the ST Micro X-NUCLEO Shield to the Arduno Carrier Card.  This connects the sensor set to the FPGA programmable logic.
2. Plug in the Maxim 31855 PMOD thermocouple to Arduinio Carrier Card J3 connector labeld "PL_PMOD.  Match pin numbers (pin 1 to pin 1) between the boards - plugging into the top row of J3.  This connects the sensor to the FPGA programmable logic.
3. Plug the MicroZed SoM onto the Arduno Carrier Card.
4. Ensure that the microSD card is plugged in. It is located on the bottom side of the board below the USB UART.  Check that the boot mode jumpers (JP1-JP3) are configured for SD Card boot (JP1 - Pins 1 & 2, JP2 - Pins 2 & 3, JP3 - Pins 2 & 3).
5. Plug an Ethernet cable from the RJ45 connector of the MicroZed SoM to the Ethernet switch on your table.
6. Connect one microUSB cable to J7 of the Arduino Carrier Card and the USB hub.  This provides power to the boards.
7. Connect one micorUSB cable to J2 of the MicroZed SoM and the USB hub.  This provides the debug UART interface. Set COM poart parameters to 115200,n,8,1.
#### Avnet Ultra96
1. Ensure that the microSD is plugged in.
2. Plug in the 12V power supply to J5.
3. Plug in the USB-to-Ethernet adapter to J8, then plug an Ethernet cable between the adapter and the Ethernet switch on your table.
4. Connect one micorUSB cable to J1 of the Ultra96 and the USB hub.  This provides the debug UART interface. Set COM poart parameters to 115200,n,8,1.
5. Press the power button SW3 on the Ultra96 board to power it up.

### Testing your Devices


## Outcomes
In this lab, you installed prerequisites to your workstation and installed lab prerequisites to the AWS Cloud in your account. You learned about how AWS IoT credentials are configured in and deployed to a development board environment. 

[Next Lab](./Lab2.md)

[Index](./README.md)



