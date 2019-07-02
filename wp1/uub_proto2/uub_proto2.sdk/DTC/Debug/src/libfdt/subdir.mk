################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/libfdt/fdt.c \
../src/libfdt/fdt_addresses.c \
../src/libfdt/fdt_empty_tree.c \
../src/libfdt/fdt_overlay.c \
../src/libfdt/fdt_ro.c \
../src/libfdt/fdt_rw.c \
../src/libfdt/fdt_strerror.c \
../src/libfdt/fdt_sw.c \
../src/libfdt/fdt_wip.c 

OBJS += \
./src/libfdt/fdt.o \
./src/libfdt/fdt_addresses.o \
./src/libfdt/fdt_empty_tree.o \
./src/libfdt/fdt_overlay.o \
./src/libfdt/fdt_ro.o \
./src/libfdt/fdt_rw.o \
./src/libfdt/fdt_strerror.o \
./src/libfdt/fdt_sw.o \
./src/libfdt/fdt_wip.o 

C_DEPS += \
./src/libfdt/fdt.d \
./src/libfdt/fdt_addresses.d \
./src/libfdt/fdt_empty_tree.d \
./src/libfdt/fdt_overlay.d \
./src/libfdt/fdt_ro.d \
./src/libfdt/fdt_rw.d \
./src/libfdt/fdt_strerror.d \
./src/libfdt/fdt_sw.d \
./src/libfdt/fdt_wip.d 


# Each subdirectory must supply rules for building sources it contributes
src/libfdt/%.o: ../src/libfdt/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Linux gcc compiler'
	arm-xilinx-linux-gnueabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


