// Header file for simple standalone test routine to interact with the
// digital interface PL.
//
// 25-Mar-2019 DFN Initial version

#include <stdio.h>
#include "digital_interface_defs.h"
#include "digital_interface.h"
#include "xparameters.h"  // Peripheral parameters (GPIO addresses, etc.)
#include "xil_types.h"

#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdbool.h>

void map_dig_ifc();

#define MAX_EVENTS 1000000

// Loopback connector currently has D2<=>D5, D0<=>D7, D1<=>D6

#define BIT1_OUT 1 << 1
#define BIT6_OUT 1 << 6

#define BIT0_OUT 1 << 0
#define BIT7_OUT 1 << 7

#define BIT2_OUT 1 << 2
#define BIT5_OUT 1 << 5

#define BIT3_OUT 0
#define BIT4_OUT 0

#define CTL_SET0 ((BIT1_OUT) | (BIT0_OUT) | (BIT2_OUT))
#define CTL_SET1 ((BIT6_OUT) | (BIT7_OUT) | (BIT5_OUT))


extern volatile u32 *dig_ifc_regs;

#define write_dig_ifc(RegNumber, Data) dig_ifc_regs[RegNumber] = Data
#define read_dig_ifc(RegNumber) dig_ifc_regs[RegNumber]

