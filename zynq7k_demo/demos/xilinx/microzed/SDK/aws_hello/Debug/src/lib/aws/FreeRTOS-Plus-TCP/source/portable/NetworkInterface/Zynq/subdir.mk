################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/NetworkInterface.c \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_dma.c \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_hw.c \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_physpeed.c 

OBJS += \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/NetworkInterface.o \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_dma.o \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_hw.o \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_physpeed.o 

C_DEPS += \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/NetworkInterface.d \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_dma.d \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_hw.d \
./src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_physpeed.d 


# Each subdirectory must supply rules for building sources it contributes
src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/NetworkInterface.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/NetworkInterface.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_dma.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_dma.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_hw.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_hw.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_physpeed.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/x_emacpsif_physpeed.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


