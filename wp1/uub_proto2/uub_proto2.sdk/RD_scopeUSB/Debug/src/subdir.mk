################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/rd_interface.c \
../src/rd_scope.c \
../src/reg.c \
../src/teste.c 

OBJS += \
./src/rd_interface.o \
./src/rd_scope.o \
./src/reg.o \
./src/teste.o 

C_DEPS += \
./src/rd_interface.d \
./src/rd_scope.d \
./src/reg.d \
./src/teste.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Linux gcc compiler'
	arm-xilinx-linux-gnueabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


