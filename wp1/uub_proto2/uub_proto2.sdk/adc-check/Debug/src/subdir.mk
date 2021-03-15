################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/FeShwrRead_test.c \
../src/acd-check.c \
../src/read_evt.c 

OBJS += \
./src/FeShwrRead_test.o \
./src/acd-check.o \
./src/read_evt.o 

C_DEPS += \
./src/FeShwrRead_test.d \
./src/acd-check.d \
./src/read_evt.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 Linux gcc compiler'
	arm-linux-gnueabihf-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


