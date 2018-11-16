These are the steps to build the MicroZed code for the workshop:

1. Clone the workshop repo https://github.com/rpcme/aws-cloud-and-xilinx-workshop. Let’s call that ``CLONEPATH`` (e.g. ```/home/xilinxfae/myData/aws_cloud-and-xilinx-workshop_copy```).

2. Launch Xilinx SDK, and specify the workspace location as: ```CLONEPATH/zynq7k_demo/demos/xilinx/microzed/xsdk```.
   ![alt text](images/xsdk_specify_workspace.jpeg "")

3. When XSDK starts, a help tab covers most of the GUI. Close the help tab by clicking the **X**.

   ![alt text](images/xsdk_help_tab_close.jpeg "")

4. You will see an empty workspace. Disable ‘Project -> Build automatically’

   ![alt text](images/xsdk_disable_build_automatically.jpeg "")

5. Open ‘Window -> Preferences -> Run/Debug -> String Substitution’ and click New...

   ![alt text](images/xsdk_string_subst.jpeg "")

6. Create a new variable ```AFR_HOME``` and set its value to ```CLONEPATH/zynq7k_demo```
   YOU SHOULD USE ONLY FORWARD SLASHES '/' FOR THE PATH SEPARATOR, EVEN ON WINDOWS
   e.g. D:/b/reinvent/aws-cloud-and-xilinx-workshop-master/zynq7k_demo

   ![alt text](images/xsdk_new_variable.jpeg "")

7. OK your way back to the empty workspace

8. Import pre-defined projects into workspace – the root directory should be ```AFR_HOME```.

   File -> Import... -> General -> Existing Projects into Workspace -> Next -> Select Root Directory -> Browse...
   DOUBLE CHECK THE ROOT DIRECTORY AFTER SETTING IT AS IT MAY END UP SELECTING A SUBDIRECTORY. MANUALLY EDIT IF NECESSARY.
   Make sure to select all projects except 'aws_tests' which is not used in this workshop.
   
   ![alt text](images/xsdk_import_project1.jpeg "")

   ![alt text](images/xsdk_import_project2.jpeg "")

   ![alt text](images/xsdk_import_project3.jpeg "")

	Click Finish.
	
9. Edit the file "aws_demos/src/application_code/common_demos/inclued/aws_clientcredential.h" and edit the initializations based on your AWS account:
    - clientcredentialMQTT_BROKER_ENDPOINT
    - clientcredentialIOT_THING_NAME


Remember to save the file when you are done

10. Enable ```Project -> Build automatically``` and everything will build, albeit with warnings. Click on the Console tab so you know when the build is done.

11. Highlight the project 'aws_demos' by left-clicking it once. Right click on it, and select 'Create Boot Image'

   ![alt text](images/xsdk_create_boot_image.jpeg "")

12. A menu will pop up, prefilled with files to include. Note the 'Output Path'. Click 'Create Image'.
   ![alt text](images/xsdk_create_boot_image_menu.jpeg "")

13. Copy BOOT.BIN from the Output path to your SD card.
