// Header file for simple standalone test routine to interact with the
// axi_iic IP.
//
// 17-Jan-2019 DFN Initial version



#include <stdio.h>
#include "xparameters.h"  // Peripheral parameters (GPIO addresses, etc.)
#include "xil_types.h"

#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

void map_registers();

// Macros

#ifndef IIC_BASE
  #define IIC_BASE XPAR_IIC_0_BASEADDR
#endif


extern volatile u32 *iic_regs;

#define write_iic(RegNumber, Data) iic_regs[RegNumber] = Data
#define read_iic(RegNumber) iic_regs[RegNumber]

extern volatile u32 fake_iic_mem_ptr[1];
extern u32 fake_iic_mem_addr[1];
extern volatile u32 iic_mem_ptr[1];
extern u32 iic_mem_addr[1];


