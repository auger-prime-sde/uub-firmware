// Header file for simple standalone test routine to interact with the
// sde_trigger PL.
//
// 25-May-2016 DFN Initial version extracted from trigger_test.c
// 05-Dec-2016 DFN Add TOGGLE_WATCHDOG switch
// 25-Dec-2016 DFN Add LED_TRIGGER option; allows a "random" trigger if
//                 LED is not connected.


#include <stdio.h>
#include "sde_trigger_defs.h"
#include "time_tagging_defs.h"
#include "time_tagging.h"
#include "interface_uub_dfn3.h"
#include "test_control.h" 
#include "test_control_defs.h"
#include "rd_interface.h"
#include "rd_interface_defs.h"
#include "xparameters.h"  // Peripheral parameters (GPIO addresses, etc.)

#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

void map_registers();
void config_trigger();
void read_shw_buffers();
void unpack_shw_buffers();

extern volatile u32 *trig_regs;
extern volatile u32 *ttag_regs;
extern volatile u32 *ifc_regs;
extern volatile u32 *rd_regs;
extern volatile u32 *tstctl_regs;

#define write_trig(RegNumber, Data) trig_regs[RegNumber] = Data
#define read_trig(RegNumber) trig_regs[RegNumber]
#define write_ttag(RegNumber, Data) ttag_regs[RegNumber] = Data
#define read_ttag(RegNumber) ttag_regs[RegNumber]
#define write_ifc(RegNumber, Data) ifc_regs[RegNumber] = Data
#define read_ifc(RegNumber) ifc_regs[RegNumber]
#define write_rd(RegNumber, Data) rd_regs[RegNumber] = Data
#define read_rd(RegNumber) rd_regs[RegNumber]
#define write_tstctl(RegNumber, Data) tstctl_regs[RegNumber] = Data
#define read_tstctl(RegNumber) tstctl_regs[RegNumber]

extern volatile u32 shwr_mem_ptr[6];
extern u32 shwr_mem_addr[6];
extern FILE *output_file;

// Shower memory buffers
extern u32 shwr_mem[6][SHWR_MEM_WORDS];

#define USE_FAKE_GPS

// Modes 1=10ms 2=100ms 3=1s, 4=10s, 5=100s, 6=200s, 7=400s, 8=800s
// 11, 15, 18, 21, 22, 23, 25, 28, 31 pseudo random delays
  #define RNDM_MODE 1







