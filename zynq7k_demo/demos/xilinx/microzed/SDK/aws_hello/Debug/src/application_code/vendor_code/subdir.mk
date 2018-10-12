################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/FreeRTOS_tick_config.c \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/hr_gettime.c \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/memcpy.c \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/uncached_memory.c 

S_UPPER_SRCS += \
C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/FreeRTOS_asm_vectors.S 

OBJS += \
./src/application_code/vendor_code/FreeRTOS_asm_vectors.o \
./src/application_code/vendor_code/FreeRTOS_tick_config.o \
./src/application_code/vendor_code/hr_gettime.o \
./src/application_code/vendor_code/memcpy.o \
./src/application_code/vendor_code/uncached_memory.o 

S_UPPER_DEPS += \
./src/application_code/vendor_code/FreeRTOS_asm_vectors.d 

C_DEPS += \
./src/application_code/vendor_code/FreeRTOS_tick_config.d \
./src/application_code/vendor_code/hr_gettime.d \
./src/application_code/vendor_code/memcpy.d \
./src/application_code/vendor_code/uncached_memory.d 


# Each subdirectory must supply rules for building sources it contributes
src/application_code/vendor_code/FreeRTOS_asm_vectors.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/FreeRTOS_asm_vectors.S
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/application_code/vendor_code/FreeRTOS_tick_config.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/FreeRTOS_tick_config.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/application_code/vendor_code/hr_gettime.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/hr_gettime.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/application_code/vendor_code/memcpy.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/memcpy.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/application_code/vendor_code/uncached_memory.o: C:/Users/elberger/Downloads/AFR_MicroZed_12Sep2018/ToWes/AmazonFreeRTOS/demos/xilinx/microzed/common/application_code/vendor_code/uncached_memory.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -I"../../../../../../demos/common/include" -I../../../../../../lib/third_party/jsmn -I../../../../../../lib/FreeRTOS-Plus-TCP/source/protocols/include -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/ -I../../../../../../lib/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC -I../../../../../../lib/FreeRTOS-Plus-TCP/include -I../../../../../../lib/third_party/pkcs11 -I"../../../../../../demo" -I../../../../../../tests/common/third_party/unity/src -I"../../../../../../lib/include" -I../../../../../../lib/include/private -I../../../../../../lib/FreeRTOS/portable/GCC/ARM_CA9 -I../../../../../../demos/xilinx/microzed/common/config_files -I"../../../../../../lib/third_party/mbedtls/include" -I../../../../../../demos/xilinx/microzed/common/application_code/vendor_code -I"C:\Users\elberger\Downloads\AFR_MicroZed_12Sep2018\ToWes\AmazonFreeRTOS\demos\xilinx\microzed\SDK\test1_bsp\ps7_cortexa9_0\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -I../../test1_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


