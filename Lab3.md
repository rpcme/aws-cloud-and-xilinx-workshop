# Lab 3: Create Distributed Control App
In this lab we will bring sensor data back from the MicroZed Intelligent I/O module to the AWS Cloud for monitoring and asset owner alerts.
## MicroZed Sensor Data
Upon a temperature value change sensor data is published to AWS IoT Cloud.  If the temperature sensor is ever in a faulted state it will change the device shadow state.  This device shadow state is shared with the Ultra96 unit controller and when it sees the temperature sensor in a faulted state it illuminates a user LED.

# Outcomes

# Learning More About These Concepts

[Next Lab](./Lab4.md)

[Index](./README.md)

