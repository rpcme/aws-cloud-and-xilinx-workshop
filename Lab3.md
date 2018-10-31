# Lab 3: Create Distributed Control App
In this lab we will bring sensor data back from the MicroZed Intelligent I/O module to the AWS Cloud for monitoring and asset owner alerts.
## MicroZed Sensor Data via Greengrass Core
The MicroZed IIoT kit has three sensors availble through the FPGA. The sensors and their interfaces are:
  * Maxim MAX31855 - Thermocouple & IC temperature sensor - SPI
  * ST LPS25HB - Pressure & IC temperature sensor - I2C
  * ST HTS221 - Humidity & IC temperature sensor - I2C

The reference a:FreeRTOS image is pre-programmed to poll these interfaces at a fixed rate and send them to the Greengrass Core instance running on the Ultra96. The Greengrass Core will then route these messages to the AWS Cloud.  The a:FreeRTOS on MicroZed will use the Greengrass Discovery capability to identify and configure the message route via the Ultra96 associated with your acccounts Greengrass Group.  We will then subscribe to the sensor MQTT topics to verify the data flow to the cloud.
1. In AWS IoT Console go to the "Test" menu on the left pane.
2. Click on "Subscribe to a topic" and enter "remote_io_module/sensor_value".  In the IoT Console now you should see data values coming in from the different sensors.  These are the same values that would be shared with the unit controller in a distributed control application.
3. Click on XYZ to get a live dashboard of the sensor values available in AWS Cloud.  This view is useful for remote asset owners that want to observe the current operation of their system as well as capturing historical operational trends and insights.

## MicroZed Sensor Failure
The MicroZed implements checks around the sensor to identify error conditions and alerts the control system such that it can protect itself and the asset under control.  In this section we will simulate a sensor failure by pulling the thermocouple from the MAX31855 board while the system is running.  This will create an open-circuit condition detected by the FPGA platform and generate a sensor health message to the unit controller and AWS Cloud.
1. In AWS IoT Console go to the "Test" menu on the left pane.
2. Click on "Subscribe to a topic" and enter "remote_io_module/sensor_status".  In the IoT Console now you should see a non-error state message for all sensors.  These values are also associated with the "Device Shadow" for the MicroZed.
3. Observe the Ultra96 board (unit controller in our control application) now and you will see that the Intelligent I/O module error LED is NOT lit (User LED #1).  See the LED defintions in the picture below.
![alt text](images/Ultra96_LED_Configuration.PNG "Ultra96 LED Defintions")
4. Now unplug the thermocouple (NOT the entire board) from the MAX31855.  See picture below for reference.
![alt text](images/MicroZed_MAX31855_Thermocouple_Removed.jpg "MAX31855 Thermocouple Removed")
5. Now observe the Ultra96 board and you will see that the Intelligent I/O module error LED is lit (User LED #1).  This information was passed via the Device Shadow.
6. Observe in the AWS Cloud MQTT Test window for the "remote_io_module/sensor_status" topic we now see the error bit with the MAX31855 set, which is also reflected in the Cloud Dashboard.  This cloud data point could be used to trigger other automated notifications (e.g. email, text) to the asset owner and field engineer.
7. Plug the thermocouple module back in and you should see the Intelligent I/O module error LED shutoff and the health bit in the MQTT message for the MAX31855 clear.

# Outcomes
In this lab you brought in live control sensor readings into the AWS cloud and saw them plotted on a dashboard using the MQTT communication mechamisms of a:FreeRTOS.  We then invoked a sensor health failure which caused the MicroZed device shadow to change to a failed state; which was automatically detected by the unit controller and AWS cloud to generate alerts.

# Learning More About These Concepts

[Next Lab](./Lab4.md)

[Index](./README.md)

