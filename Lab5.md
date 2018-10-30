# Lab 5: Bring Back Data
In this lab, you will make use of the Lambda function we deployed in Lab 4 to to send a ML based "person activity" alert from the remote asset unit controller USB camera to the AWS Cloud along with a still frame video capture of the image.

1. In AWS IoT Console go to your Greengrass group and select the Ultra96 board.  Click on Subscriptions and click on "Add Subscription".
  * Source = Lambda function: reInvent_Xilinx_EdgeML_Example
  * Target = IoT Cloud
  * Topic = unit_controller/person_detect
2. Click on "Actions" and "Deploy" to update the MQTT data communications from the Ultra96.
3. In AWS IoT Console go to "Test" in the left column.  Click on "Subcribe to a topic" and enter "unit_controller/person_detect".  You should now see two pieces of data in the received message:
  * Detection_Event_Trigger - Boolean that indicates if any persons were detected
  * Num_Persons_Detected - Integer value indicating the number of persons in the frame
4. Experiment by pointing the camera to areas with no persons versus areas with persons. In order to avoid overwhelming the local network we are limiting the communication action to every 5 seconds - so point the camera in a direction for 5+ seconds to see changes in the reported values and state.
5. When a person is detected at the Edge device it will also trigger a capture of the video frame, add bounding boxes to identify the persons within the video frame captured, and transmit the frame to AWS Cloud.  Go to the dashboard and point the camera at a person - you should see a "unathorized person" event triggered in the Cloud Dashboard and a still frame of the captured video stream sent from the edge device.

# Outcomes
In this lab you saw the ability to bring data back from an FPGA based machine learning application deployed at the edge.  Deploying ML inference at the edge offers the ability to dramatically reduce the volume of data required to be sent back to the cloud which is important for remote industrial assets where connectivity is intermittent, expensive, and bandwidth limited.

# Learning More About These Concepts


[Index](./README.md)

