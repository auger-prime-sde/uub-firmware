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
#include "xparameters.h"  // Peripheral parameters (GPIO addresses, etc.)

#ifdef STAND_ALONE
#include "xil_types.h"
#include "xil_printf.h"
#include "xaxicdma.h"
#include "xdebug.h"
#include "xil_cache.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xpseudo_asm_gcc.h"
#include "xreg_cortexa9.h"
#include "test_periph.h"
#endif

#ifndef STAND_ALONE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#define MUONS_PER_BUF (MUON_MEM_WORDS/MUON_BURST_LEN)
#define ADC_MASK ((1<<ADC_WIDTH)-1)

void map_registers();
void config_trigger();
void adjust_baseline();
void enable_trigger_intr();
void disable_trigger_intr();
void read_shw_buffers();
void unpack_shw_buffers();
void check_shw_buffers();
void print_shw_buffers();
void read_muon_buffers();
void unpack_muon_buffers();
void check_muon_buffers();
void print_muon_buffers();
#if defined(DMA) && defined(SIMPLE)
int do_simple_polled_dma(u32 *src, u32 *dest, int length);
#endif
void sde_shwr_intr_handler(void *CallbackRef);
void sde_muon_intr_handler(void *CallbackRef);

#ifdef SCATTER_GATHER
#define NUM_SHWR_BDS_TO_TRANSFER	5
#define NUM_MUON_BDS_TO_TRANSFER	2
int check_scatter_gather_completion();
int do_scatter_gather_polled_shwr_dma();
int do_scatter_gather_polled_muon_dma();
#endif

// Macros


#ifdef STAND_ALONE
#define write_trig(RegNumber, Data)					\
  SDE_TRIGGER_mWriteReg(SDE_TRIGGER_BASE, 4*RegNumber, Data)

#define read_trig(RegNumber)						\
  SDE_TRIGGER_mReadReg(SDE_TRIGGER_BASE, 4*RegNumber)

#define write_ttag(RegNumber, Data)					\
  TIME_TAGGING_mWriteReg(TIME_TAGGING_BASE, 4*RegNumber, Data)

#define read_ttag(RegNumber)						\
  TIME_TAGGING_mReadReg(TIME_TAGGING_BASE, 4*RegNumber)

#define write_ifc(RegNumber, Data)					\
  INTERFACE_UUB_DFN3_mWriteReg(INTERFACE_UUB_BASE, 4*RegNumber, Data)

#define read_ifc(RegNumber)						\
  INTERFACE_UUB_DFN3_mReadReg(INTERFACE_UUB_BASE, 4*RegNumber)

#define write_tstctl(RegNumber, Data)					\
  TEST_CONTROL_mWriteReg(TEST_CONTROL_BASE, 4*RegNumber, Data)

#define read_tstctl(RegNumber)						\
  TEST_CONTROL_mReadReg(TEST_CONTROL_BASE, 4*RegNumber)

#else

extern volatile u32 *trig_regs;
extern volatile u32 *ttag_regs;
extern volatile u32 *ifc_regs;
extern volatile u32 *tstctl_regs;

#define write_trig(RegNumber, Data) trig_regs[RegNumber] = Data
#define read_trig(RegNumber) trig_regs[RegNumber]
#define write_ttag(RegNumber, Data) ttag_regs[RegNumber] = Data
#define read_ttag(RegNumber) ttag_regs[RegNumber]
#define write_ifc(RegNumber, Data) ifc_regs[RegNumber] = Data
#define read_ifc(RegNumber) ifc_regs[RegNumber]
#define write_tstctl(RegNumber, Data) tstctl_regs[RegNumber] = Data
#define read_tstctl(RegNumber) tstctl_regs[RegNumber]

#endif

extern volatile u32 shwr_mem_ptr[5];
extern volatile u32 muon_mem_ptr[2];
extern u32 shwr_mem_addr[5];
extern u32 muon_mem_addr[2];
extern volatile u32 fake_event_ptr[2];
extern u32 fake_event_addr[2];

// Shower memory buffers
#define NUM_BUFFERS 8
extern volatile int readto_shw_buf_num;
extern volatile int full_shw_rd_bufs[NUM_BUFFERS];
extern volatile int unpack_shw_buf_num;

extern u32 shw_mem0[NUM_BUFFERS][SHWR_MEM_WORDS];
extern u32 shw_mem1[NUM_BUFFERS][SHWR_MEM_WORDS];
extern u32 shw_mem2[NUM_BUFFERS][SHWR_MEM_WORDS];
extern u32 shw_mem3[NUM_BUFFERS][SHWR_MEM_WORDS];
extern u32 shw_mem4[NUM_BUFFERS][SHWR_MEM_WORDS];

// ADC traces & extra bits
extern u32 shw_mem[5][SHWR_MEM_WORDS];
extern u16 adc[10][SHWR_MEM_WORDS];
extern u16 filt_adc[3][SHWR_MEM_WORDS];
extern u8 flags[SHWR_MEM_WORDS];

// Muon memory buffers
extern u32 muon_mem0[MUON_MEM_WORDS];
extern u32 muon_mem1[MUON_MEM_WORDS];
extern u16 muon_adc[4][MUON_BURST_LEN][MUONS_PER_BUF];
extern u16 muon_seq_num[MUON_BURST_LEN][MUONS_PER_BUF];
extern u16 muon_trig_tags[MUONS_PER_BUF];
extern u32 muon_burst_start[MUONS_PER_BUF];
extern u32 muon_buffer_start;
extern u32 muon_buffer_end;
extern int mu_word_count;

// Fake event buffers
//extern u32 fake_event0[SHWR_MEM_WORDS];
//extern u32 fake_event1[SHWR_MEM_WORDS];


