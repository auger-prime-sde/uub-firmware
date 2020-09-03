// Header file for routine to map registers and trace buffers
// radio detector interface PL.
//
// 02-Nov-2018 DFN Initial version
// 06-Apr-2020 DFN Initial version with common mapping



#include <stdio.h>
#include "sde_trigger_defs.h"
#include "time_tagging_defs.h"
#include "interface_uub_dfn3.h"
#include "test_control_defs.h"
#include "test_control.h"
#include "rd_interface_defs.h"
#include "rd_interface.h"
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

extern volatile u32 *rd_regs;
extern volatile u32 *trig_regs;
extern volatile u32 *ttag_regs;
extern volatile u32 *ifc_regs;
extern volatile u32 *tstctl_regs;

#define write_rd(RegNumber, Data) rd_regs[RegNumber] = Data
#define read_rd(RegNumber) rd_regs[RegNumber]
#define write_trig(RegNumber, Data) trig_regs[RegNumber] = Data
#define read_trig(RegNumber) trig_regs[RegNumber]
#define write_ttag(RegNumber, Data) ttag_regs[RegNumber] = Data
#define read_ttag(RegNumber) ttag_regs[RegNumber]
#define write_ifc(RegNumber, Data) ifc_regs[RegNumber] = Data
#define read_ifc(RegNumber) ifc_regs[RegNumber]
#define write_tstctl(RegNumber, Data) tstctl_regs[RegNumber] = Data
#define read_tstctl(RegNumber) tstctl_regs[RegNumber]

extern volatile u32 shwr_mem_ptr[6];
extern u32 shwr_mem_addr[6];



