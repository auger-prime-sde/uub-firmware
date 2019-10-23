# MCU name
MCU = msp430f2618
# CPU Clock 16Mhz
F_CPU = 16000000
CC = msp430-gcc
#---------------- Compiler Options ----------------
#  -g*:          generate debugging information
#  -O*:          optimization level
#  -f...:        tuning, see GCC manual and avr-libc documentation
#  -Wall...:     warning level
#  -Wa,...      tell GCC to pass this to the assembler.
#    -adhlns...: create assembler listing
#debugging format
DEBUG =
# Place -I options here
CINCS = -I ./

# Place -D or -U options here
CDEFS = -DF_CPU=$(F_CPU)UL

# Optimization level, can be [0, 1, 2, 3, s].
#     0 = turn off optimization. s = optimize for size.
OPT = 1	

CFLAGS = -g$(DEBUG)
CFLAGS += $(CDEFS) $(CINCS)
CFLAGS += -O$(OPT)
#CFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -Wall 
#CFLAGS += -Wstrict-prototypes
#CFLAGS += -Wa,-adhlns=$(<:.c=.lst)
#CFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))
#CFLAGS += $(CSTANDARD)
# Target file name (without extension).
#TARGET = sde_sc_test
TARGET = sde_sc
#TARGET = msp_test


# List C source files here. (C dependencies are automatically generated.)
SRC = $(TARGET).c 
SRC += USCIAB0.c
SRC += wiring.c 
SRC += wiring_shift.c 
SRC += wiring_digital.c 
SRC += USCI_I2C_slave.c 
SRC += i2c.c 
SRC += MISC_func.c
SRC += IO_func.c
# SRC += ../TI_USCI_I2C_master.c 
SRC += ishan.c 
#SRC += BMP180_func.c 
SRC += BME280.c
SRC += DS28CM00_func.c 
# SRC += ds18x20.c 
SRC += adc.c
SRC += DAC_func.c
SRC += DAC_led_func.c
SRC += eeprom.c
//TTY = $(wildcard /dev/tty.TIVCP*)
TTY = $(wildcard /dev/tty.usbmodem24121)

# Default target.
#all: begin gccversion sizebefore build sizeafter end
all: begin gccversion build end

begin:
gccversion:
	@$(CC) --version
build:
	$(CC) $(CFLAGS) -mmcu=$(MCU) -o $(TARGET).elf $(SRC) 
end:
	@echo done
testversion:
	$(CC) $(CFLAGS) -mmcu=$(MCU) -o $(T_TARGET).elf $(T_SRC)

program: $(TARGET).elf
	msp430-objcopy -O ihex $(TARGET).elf $(TARGET).hex
	export LD_LIBRARY_PATH=/home/khb/MSPFlasher_1.3.10/
#	MSP430Flasher
#	MSP430Flasher -n MSP430F2618 -w $(TARGET).hex -v -z [VCC]
	 LD_LIBRARY_PATH=/home/khb/MSPFlasher_1.3.10/ /home/khb/MSPFlasher_1.3.10/MSP430Flasher -n $(MCU)  -w $(TARGET).hex -v -g -z [VCC]
# TTY
#ifeq ($(TTY),)
#	$(error no usable TTY found)
#else
#	@echo using $(TTY)
#endif
#	mspdebug -d $(TTY) -j uif "prog $(TARGET).elf"


# sudo mspdebug uif "prog breathing-led-$MCU.elf"

#SRC=test_USCI_I2C_slave.c
#msp430-gcc -Os -Wall -g -mmcu=$MCU -o $TARGET.elf $SRC  wiring.c wiring_shift.c wiring_digital.c USCI_I2C_slave.c TI_USCI_I2C_master.c ishan.c ds18x20.c adc.c
