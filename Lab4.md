# Lab 4: Deploy Edge ML

In this lab we will deploy an FPGA based edge machine learning (ML) video surveillance application to the remote asset unit controller (Ultra96).  Amazon IoT Console will serve as the system deployment dashboard and operation mechanism to incrementally add this function to the running system.

1. Connect the eCon USB camera to the Ultra96 board J8.  See the picture below showing Ultra96 with the camera connected.
![alt text](images/Ultra96_WithCamera.jpg?raw=true "Ultra96 with USB Camera")
2. Copy the pre-packaged ML file set reInvent_Xilinx_EdgeML_Example.zip from Git at XYZ location.  The zip file contains the machine learning model configuration (.so) and the FPGA bitstream (.bit) for supporting a pedestrian detection model.
3. Upload reInvent_Xilinx_EdgeML_Example.zip to the S3 bucket associated with your AWS account.  This was create automatically for you by the cloud configuration script in Lab 1.
5. Next find the associated Lambda function for deploying and running the new FPGA ML function by copying reInvent_Xilinx_EdgeML_Lambda.zip from Git at XYZ location. 
6. In AWS IoT Console go to the Lambda Service and click "Create function".
  * Name = reInvent_Xilinx_EdgeML_Example
  * Runtime = Python 2.7
7. Add details on getting Lambda published...
8. Go to your AWS Greengrass Console Group created for the Ultra96.  
  * Click on Lambdas in the left column and select "Add Lambda"
  * Select "Use existing Lambda"
  * Select "reInvent_Xilinx_EdgeML_Example"
  * Configure Lambda function with lifetime, local resources, and timeout - Need to add details on what is required.
9. In the AWS Console select "Action" and "Deploy" to update the Ultra96 with the new Lambda function and associated FPGA update placed in S3.  Upon deployment the AWS Greengrass envionrment running locally on the Ultra96 will receive the ML configuration files (.so and .bit) from the AWS cloud and then will interact with the Xilinx platform configuration interfaces to update the FPGA and runtime software.
10. After the AWS Console indicates that the Lambda function is successfully deployed connect to the Ultra96 debugger.  Point the camera at a person and you should see message XYZ when a person is detected including the number of persons in a given frame.  You should also see User LED 3 lit when a person is in view of the camera.  Point the camera at a location where this are no persons - you should see User LED 3 turn off and corresponding messages in the debugger.
![alt text](images/Ultra96_LED_Configuration.PNG?raw=true "Ultra96 User LED Definitions")


# Outcomes
In this lab we used AWS Greengrass to deploy a new machine learning application to a running control system in the Ultra96 platform. 

# Learning More About These Concepts

[Next Lab](./Lab5.md)

[Index](./README.md)

