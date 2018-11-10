# Workshop:  Integrate the AWS Cloud with Responsive Xilinx Machine Learning at the Edge

In this workshop, learn how you can integrate Xilinx edge machine learning with massive scale AWS Cloud analytics, machine learning model building, and dashboards.  Based on an Oil & Gas scenario, you will learn how to combine AWS Cloud services with AWS Greengrass on Zynq Ultrascale+ and Amazon FreeRTOS on Xilinx Zynq-7000.  After this workshop, you will have a concrete understanding of Machine Learning applicability at the edge and its relationship with the AWS Cloud.

# Lab 1: Setup the Environment

Time to completion: 20 minutes

In this lab you will download the Xilinx tools required for customizing the runtime images of the embedded platforms and set-up your corresponding cloud environment.

[Go to Lab 1](./Lab1.md)

# Lab 2: Establish Amazon FreeRTOS and AWS Greengrass Connectivity

Time to completion: 20 minutes

In this lab we will establish basic connectivity to the AWS cloud for both the MicroZed and Ultra96 devices. In order to do this we need to establish unique device identities that link the device to your AWS IoT account. This is done through a unique certificate and encyrption key. You will need to create these credentials in your AWS account and then manually copy them to each device.

[Go to Lab 2](./Lab2.md)

# Lab 3: Create Distributed Control App

Time to completion: 20 minutes

In this lab we will demonstrate the intelligent I/O module of the MicroZed kit collecting sensor data, sending it to the cloud, while also alerting the control system and remote asset owner to a change in the state of the system using AWS Device Shadow.

[Go to Lab 3](./Lab3.md)

# Lab 4: Deploy Edge ML

Time to completion: 25 minutes

In this lab we will deploy a new machine learning edge inference function to the FPGA of the unit controller running on Ultra96.  This new edge ML inference function will be used to monitor a local camera that is monitoring the remote asset to any persons in the area of the asset. 

[Go to Lab 4](./Lab4.md)


# Lab 5: Bring Back Data

Time to completion: 25 minutes

In this lab we will use the video machine learning inference function of the FPGA to trigger an interaction with AWS cloud.  The Ultra96 upon detection of a person send a copy of the video frame capture to AWS cloud which will then be used to add an alert to the system monitor dash board that someone is near the asset and display a picture of that person. 

[Go to Lab 5](./Lab5.md)




# Time to Completion Summary

| duration | topic |
|----------|-------|
|Lab 1 | 20 minutes |
|Lab 2 | 20 minutes |
|Lab 3 | 20 minutes |
|Lab 4 | 25 minutes |
|Lab 5 | 25 minutes |

110 minutes.  10 minutes buffer. 
