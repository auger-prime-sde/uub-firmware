################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/config_trigger.c \
../src/linux_trigger_test.c \
../src/map_registers.c \
../src/muon_buf_utils.c \
../src/shwr_buf_utils.c \
../src/trigger_test.c 

OBJS += \
./src/config_trigger.o \
./src/linux_trigger_test.o \
./src/map_registers.o \
./src/muon_buf_utils.o \
./src/shwr_buf_utils.o \
./src/trigger_test.o 

C_DEPS += \
./src/config_trigger.d \
./src/linux_trigger_test.d \
./src/map_registers.d \
./src/muon_buf_utils.d \
./src/shwr_buf_utils.d \
./src/trigger_test.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Linux gcc compiler'
	arm-xilinx-linux-gnueabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


