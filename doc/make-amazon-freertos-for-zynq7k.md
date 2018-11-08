Clone it, let’s call that ``CLONEPATH`` (e.g. ```/home/xilinxfae/myData/aws_cloud-and-xilinx-workshop_copy```)
Open Xilinx SDK workspace at: ```CLONEPATH/zynq7k_demo/demos/xilinx/microzed/xsdk```

1. Close the help tab by clicking the **X**.

   ![alt text](images/xsdk_help_tab_close.jpeg "")

2. Disable ‘Project -> Build automatically’

   ![alt text](images/xsdk_disable_build_automatically.jpeg "")

3. Open ‘Window -> Preferences -> Run/Debug -> String Substitution’ and click New

   ![alt text](images/xsdk_string_subst.jpeg "")

4. Create a new variable ```AFR_HOME``` and set its value to ```CLONEPATH/zynq7k_demo```

   ![alt text](images/xsdk_new_variable.jpeg "")

5. OK your way back to the empty workspace
6. Import all projects as described in document – the root directory should be the same as the ```AFR_HOME``` directory.


   DOUBLE CHECK THIS AFTER SETTING IT AS IT SEEMS TO REFER TO A SUBDIRECTORY AFTER SETTING IT. MANUALLY EDIT IF NECESSARY.
   
   ![alt text](images/xsdk_import_project1.jpeg "")

   ![alt text](images/xsdk_import_project2.jpeg "")

   ![alt text](images/xsdk_import_project3.jpeg "")

	Click Finish.
	
7. Enable ```Project -> Build automatically``` and everything will build, albeit with warnings
8. Follow documented flow to create BOOT.BIN for MicroZed
