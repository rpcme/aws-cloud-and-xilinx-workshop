# Lab 3: Create Distributed Control App
In this lab we will bring sensor data back from the MicroZed Intelligent I/O module to the AWS Cloud for monitoring and asset owner alerts.
## MicroZed Sensor Data
The MicroZed IIoT kit has three sensors availble through the FPGA. The sensors and their interfaces are:
  * Maxim MAX31855 - Thermocouple & IC temperature sensor - SPI
  * ST LPS25HB - Pressure & IC temperature sensor - I2C
  * ST HTS221 - Humidity & IC temperature sensor - I2C
The reference a:FreeRTOS image is pre-programmed to poll these interfaces at a fixed rate and send them to the AWS cloud.  We will simply subscribe to these MQTT topics to verify the data flow to the cloud.
1. In AWS IoT Console go to the "Test" menu on the left pane.
2. Click on "Subscribe to a topic" and enter "remote_io_module/sensor_value".  In the IoT Console now you shoudl see data values coming in from the different sensors.  These are the same values that would be shared with the unit controller in a distributed control application.
3. Click on XYZ to get a live dashboard of the sensor values available in AWS Cloud.  This view is useful for remote asset owners that want to observe the current operation of their system as well as capturing historical operational trends and insights.
## MicroZed Sensor Failure
The MicroZed implements checks around the sensor to identify error conditions and alert the control system such that it can protect itself and the asset under control.  In this section we will simulate a sensor failure by pulling the thermocouple from the MAX31855 board while the system is running.  This will create an open-circuit condition detected by the FPGA platform and generate a health message to the unit controller and AWS Cloud.
1. In AWS IoT Console go to the "Test" menu on the left pane.
2. Click on "Subscribe to a topic" and enter "remote_io_module/sensor_status".  In the IoT Console now you shoudl see a binary health message related to the three sensors.  These values are associated with the "Device Shadow" for the MicroZed and thus when we pulled the thermocouple we triggered a state change.
3. Observe the Ultra96 board (unit controller in our control application) now and you will see that the Intelligent I/O module error LED is now lit (User LED #1).
4. Also see in the Cloud Dashboard that we now see an alert message indicating a failure in the I/O module.  This could be used to trigger other automated notifications (e.g. email, text).
4. Plug the thermocouple module back in and you should see the Intelligent I/O module error LED shutoff and the health bit in the MQTT message for the MAX31855 clear.

# Outcomes
In this lab you brought in live control sensor readings into the AWS cloud and saw them plotted on a dashboard using the MQTT communication mechamisms of a:FreeRTOS.  We then invoked a sensor health failure which caused the MicroZed device shadow to change to a failed state; which was automatically detected by the unit controller and AWS cloud to generate alerts.

# Learning More About These Concepts

[Next Lab](./Lab4.md)

[Index](./README.md)

