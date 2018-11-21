# Lab 4: Deploy ML in the edge

In this lab we will deploy an FPGA based machine learning (ML) video 
surveillance application to the remote asset unit controller (Ultra96).
Amazon IoT console will serve as the system deployment dashboard; we will
 incrementally add and test functions for the running system.

## Preparation

In lab 2, we already deployed the lambda functions in your Greengrass group. 
So in this lab we will just reuse the same group.
As a summary,

1. Your group name was defined to be `<your-group-prefix>-gateway-ultra96-group`.
2. Your S3 bucket name was defined to be `<your-unique-prefix>-aws-cloud-and-xilinx-workshop`.

Make sure your greengrass core service are still running. To check that:

```shell
ps aux | grep /greengrass/gg/packages/1.7.0/bin/daemon
```

You should be able to see a running process in the background.

## Lab Steps
In lab 2 we tested our AWS Greengrass group on the topic "hello/world"; in this
lab we will try the other topics: 

* "/unit_controller/bistream_deploy": subscribed lambda function will download 
bitstream from your S3 bucket.
* "/unit_controller/image_upload": subscribed lambda function will upload 
captured pictures with detected people onto the S3 bucket.
* "/unit_controller/video_inference": subscribed lambda function will capture
video frames as pictures, and generate some text files storing the number of 
persons detected in the pictures.

Our ML video surveillance application takes in 2 parameters:

* 'num_seconds': specifies how long this application is going to run.
* 'threshold': specifies the capture condition; that is, the video frame is 
capture only if there are a number of persons no less than the threshold value.

Now lets get started with the existing AWS Greengrass group:

1. Connect the eCon USB camera to the Ultra96 board J8.  See the picture below 
showing Ultra96 with the camera connected.

   ![alt text](images/Ultra96_WithCamera.jpg?raw=true "Ultra96 with USB Camera")

2. Go to `/home/xilinx/download`; verify that this folder is empty before we 
   do anything.

3. Now lets redeploy the AWS Greengass group.

   ```shell
   cd $HOME/aws-cloud-and-xilinx-workshop/cloud/script
   ./deploy-greengrass-group.sh <your-group-prefix>
   ```

   After a few seconds your group should be successfully deployed.

4. Go to the AWS IoT Console page and click on "Test". Click on 
"Subscribe to a topic" and enter "/unit_controller/bitstream_deploy". Click on
"Subscribe to topic" to confirm. Repeat this for the topics 
"/unit_controller/image_upload" and "/unit_controller/video_inference".

   See picture below for expected result.

   ![alt text](images/Subscribe_Video_Inference.PNG)

   Notice that your have a long-running lambda function already publishing
   on the topic "/unit_controller/video_inference", indicating the video 
   inference is being called. 
   
   Since you have not provided any ML 
   configurations, the video surveillance application will just use the default
   parameters ('num_seconds' = 5, 'threshold' = 2).

5. Now click on the topic "/unit_controller/bitstream_deploy". Click on 
"Publish to topic" to trigger the lambda function. After a few seconds, you 
should be able to see the following result:

   ![alt text](images/Publish_Bitstream_Deploy.PNG)

   After this call, your `/home/xilinx/download` is no longer empty.
   This indicates the Ultra96 has received the ML configuration files 
   ('.bit' and '.txt') from the AWS cloud. 
   You can publish on this topic again, and you will get similar response 
   each time.
   
   In the file `parameters.txt`, the first value is the parameter 
   'num_seconds', and the second value is the parameter 'threshold'.

6. When you have seen the message "starting video inference" under the topic 
"/unit_controller/video_inference", point the camera at a few persons; 
you should see the "Person Detect Indicator" LED lit when a number of 
persons are in view of the camera. 

   ![alt text](images/Ultra96_LED_Configuration.PNG?raw=true "Ultra96 User LED Definitions")

   Point the camera at a location where there are no persons; you should see 
that LED turn off.

7. If there are people detected, you will see a number of files generated in 
`<your-unique-prefix>-aws-cloud-and-xilinx-workshop`. 
These files will be uploaded onto the S3 bucket, so
you will also see some messages on the topic "/unit_controller/image_upload".

   ![alt text](images/Publish_Image_Upload.PNG)

8. On the Ultra96 debug interface navigate to the directory that is 
synchronized with your S3 bucket.

   ```shell
   cd <your-unique-prefix>-aws-cloud-and-xilinx-workshop
   ```

   You will see a bunch of new files generated. The 
   '\<epoch-time\>.png' files are the captured frames; the '\<epoch-time\>.txt'
   files store the number of people captured in that frame.

9. Go to your S3 bucket on AWS cloud; you will see there is a new folder 
`images` created. Check the images stored in that folder.


## Outcomes
In this lab we used AWS Greengrass to deploy an ML video 
surveillance application to a running control system in the Ultra96 platform. 

## Learning More About These Concepts

[Next Lab](./Lab5.md)

[Index](./README.md)

