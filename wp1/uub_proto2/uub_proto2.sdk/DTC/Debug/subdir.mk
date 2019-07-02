################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../checks.c \
../data.c \
../dtc.c \
../fdtdump.c \
../fdtget.c \
../fdtput.c \
../flattree.c \
../fstree.c \
../livetree.c \
../srcpos.c \
../treesource.c \
../util.c 

OBJS += \
./checks.o \
./data.o \
./dtc.o \
./fdtdump.o \
./fdtget.o \
./fdtput.o \
./flattree.o \
./fstree.o \
./livetree.o \
./srcpos.o \
./treesource.o \
./util.o 

C_DEPS += \
./checks.d \
./data.d \
./dtc.d \
./fdtdump.d \
./fdtget.d \
./fdtput.d \
./flattree.d \
./fstree.d \
./livetree.d \
./srcpos.d \
./treesource.d \
./util.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Linux gcc compiler'
	arm-xilinx-linux-gnueabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


