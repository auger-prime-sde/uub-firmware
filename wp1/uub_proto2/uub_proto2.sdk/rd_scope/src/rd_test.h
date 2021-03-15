// Header file for simple standalone test routine to interact with the
// radio detector interface PL.
//
// 02-Nov-2018 DFN Initial version
// 15-Mar-2020 DFN Add trigger out pattern mode



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

#define RD_MEM_DEPTH 8192
#define RD_MEM_WORDS 2048
#define RD_MEM_NBUF 4

#define MAX_EVENTS 1000
//#define MAX_EVENTS 100
#define USE_FAKE_GPS
#define USE_TRIG_OUT_PATTERN


#define SHWR_TRIGGERS

#ifdef SHWR_TRIGGERS
  #define RNDM_TRIGGER
// Modes 1=10ms 2=100ms 3=1s, 4=10s, 5=100s, 6=200s, 7=400s, 8=800s
// 11, 15, 18, 21, 22, 23, 25, 28, 31 pseudo random delays
  #define RNDM_MODE 21
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

extern u32 shw_mem0[MAX_EVENTS][SHWR_MEM_WORDS];
extern u32 shw_mem1[MAX_EVENTS][SHWR_MEM_WORDS];
extern u32 shw_mem2[MAX_EVENTS][SHWR_MEM_WORDS];
extern u32 shw_mem3[MAX_EVENTS][SHWR_MEM_WORDS];
extern u32 shw_mem4[MAX_EVENTS][SHWR_MEM_WORDS];
//extern u32 rd_mem[MAX_EVENTS][RD_MEM_WORDS];

extern int buf_start_offset[MAX_EVENTS];
extern int buf_num[MAX_EVENTS];
extern int buf_latency[MAX_EVENTS];
extern double buf_dt[MAX_EVENTS];
extern u32 buf_rd_status[MAX_EVENTS];
