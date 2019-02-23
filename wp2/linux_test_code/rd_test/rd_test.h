// Header file for simple standalone test routine to interact with the
// radio detector interface PL.
//
// 02-Nov-2018 DFN Initial version



#include <stdio.h>
#include "sde_trigger_defs.h"
#include "time_tagging_defs.h"
#include "interface_uub_dfn3.h"
#include "test_control_defs.h"
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

#define RD_MEM_DEPTH 8192
#define RD_MEM_WORDS 2048
#define RD_MEM_NBUF 4

#define MAX_EVENTS 1000
#define USE_FAKE_GPS

#define USE_FAKE_SIGNAL
#define PMT0_DLY 0
#define PMT1_DLY 0
#define PMT2_DLY 0
#define FAKE_SIGNAL_WIDTH 30
#define SIGNAL_HT 3000
#define EXP_DECAY 0
#define FAKE_SIGNAL_MODE (8 | (PMT0_DLY<<5) | (PMT1_DLY<<7) | (PMT2_DLY<<9) | (FAKE_SIGNAL_WIDTH<<11) | (EXP_DECAY<<19) | (SIGNAL_HT<<20))

#define TRIG_THR0 2000
#define TRIG_THR1 4095
#define TRIG_THR2 4095
#define TRIG_SSD 400

#define SHWR_TRIGGERS

#ifdef SHWR_TRIGGERS 
  #define COMPAT_SB_TRIGGER
//  #define SB_TRIGGER
//  #define SSD_AND	
//  #define SSD_DELAY 5
//  #define EXT_TRIGGER
//  #define PRESCALE_EXT_TRIGGER
//  #define PRESCALE_COMPAT_SB_TRIGGER
//  #define LED_TRIGGER
#endif

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

extern volatile u32 shwr_mem_ptr[5];
extern u32 shwr_mem_addr[5];
extern volatile u32 rd_mem_ptr[1];
extern u32 rd_mem_addr[1];

extern u32 shw_mem0[SHWR_MEM_NBUF][SHWR_MEM_WORDS];
extern u32 shw_mem1[SHWR_MEM_NBUF][SHWR_MEM_WORDS];
extern u32 shw_mem2[SHWR_MEM_NBUF][SHWR_MEM_WORDS];
extern u32 shw_mem3[SHWR_MEM_NBUF][SHWR_MEM_WORDS];
extern u32 shw_mem4[SHWR_MEM_NBUF][SHWR_MEM_WORDS];
extern u32 rd_mem[RD_MEM_NBUF][RD_MEM_WORDS];

