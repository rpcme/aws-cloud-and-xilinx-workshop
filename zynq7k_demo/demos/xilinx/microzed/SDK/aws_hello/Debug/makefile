################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/lib/third_party/mbedtls/source/subdir.mk
-include src/lib/third_party/jsmn/subdir.mk
-include src/lib/aws/utils/subdir.mk
-include src/lib/aws/tls/subdir.mk
-include src/lib/aws/secure_sockets/subdir.mk
-include src/lib/aws/pkcs11/subdir.mk
-include src/lib/aws/mqtt/subdir.mk
-include src/lib/aws/greengrass/subdir.mk
-include src/lib/aws/crypto/subdir.mk
-include src/lib/aws/bufferpool/subdir.mk
-include src/lib/aws/FreeRTOS/portable/MemMang/subdir.mk
-include src/lib/aws/FreeRTOS/portable/GCC/ARM_CA9/subdir.mk
-include src/lib/aws/FreeRTOS-Plus-TCP/source/portable/NetworkInterface/Zynq/subdir.mk
-include src/lib/aws/FreeRTOS-Plus-TCP/source/portable/BufferManagement/subdir.mk
-include src/lib/aws/FreeRTOS-Plus-TCP/source/subdir.mk
-include src/lib/aws/FreeRTOS/subdir.mk
-include src/application_code/vendor_code/subdir.mk
-include src/application_code/common_demos/source/subdir.mk
-include src/application_code/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
aws_hello.elf.size \


# All Target
all: pre-build main-build

# Main-build Target
main-build: aws_hello.elf secondary-outputs

# Tool invocations
aws_hello.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM v7 gcc linker'
	arm-none-eabi-gcc -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -Wl,-build-id=none -specs=Xilinx.spec -Wl,-T -Wl,../src/lscript.ld -L../../test1_bsp/ps7_cortexa9_0/lib -o "aws_hello.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

aws_hello.elf.size: aws_hello.elf
	@echo 'Invoking: ARM v7 Print Size'
	arm-none-eabi-size aws_hello.elf  |tee "aws_hello.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) aws_hello.elf
	-@echo ' '

pre-build:
	-a9-linaro-pre-build-step
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents
.SECONDARY: main-build pre-build

-include ../makefile.targets
