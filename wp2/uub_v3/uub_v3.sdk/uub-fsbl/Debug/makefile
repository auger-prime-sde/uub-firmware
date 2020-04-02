################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
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
uub-fsbl.elf.size \


# All Target
all: uub-fsbl.elf secondary-outputs

# Tool invocations
uub-fsbl.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM gcc linker'
	arm-xilinx-eabi-gcc -L"/afs/auger.mtu.edu/common/scratch/dfnitz/git_clones/uub-firmware-Mar2020test/wp2/uub_v3/uub_v3.sdk/uub-fsbl/src" -Wl,-T -Wl,../src/lscript.ld -L../../uub-fsbl_bsp/ps7_cortexa9_0/lib -o "uub-fsbl.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

uub-fsbl.elf.size: uub-fsbl.elf
	@echo 'Invoking: ARM Print Size'
	arm-xilinx-eabi-size uub-fsbl.elf  |tee "uub-fsbl.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) uub-fsbl.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
