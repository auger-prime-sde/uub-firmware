#include "sde_trigger.h"
#include "sde_trigger_options.h"
#include "time_tagging.h"

// Global definitions for the sde trigger
 // 
 // 14-Jan-14 DFN Initial version
 // 14-May-14 DFN Added SHWR_MEM_WIDTH
 // 06-Jun-14 DFN Start defining status register bits
 // 19-Jun-15 DFN Add trace start registers
 // 29-Mar-16 DFN Change to derive SHWR_MEM_NBUF from SHWR_BUF_NUM_WIDTH and
 //               similarly for muon buffers

#ifndef _TRIGGER_DEFS
 #define _TRIGGER_DEFS

 #define ADC_WIDTH 12 // Number of bits per ADC
 #define NUM_ADCS 10  // Number of ADCs

 #define WIDTH_BITS 9 // Number of bits in ToT occupancy register

 #define SHWR_MEM_WIDTH 32      // Width of each shower memory block
 #define SHWR_MEM_ADDR_WIDTH 32 // Vivado seems to require 32 bit bus
                                // even though only use a fraction of it.
 #define SHWR_MEM_BUF_SHIFT 13  // Shower memory buffer number shift
                                // Depth of each shower memory buffer (*4 since
                                // addressing is in bytes - 4 to a word)
 #define SHWR_MEM_DEPTH (1<<SHWR_MEM_BUF_SHIFT)
 #define SHWR_MEM_WORDS (SHWR_MEM_DEPTH/4)
 #define SHWR_BUF_NUM_WIDTH 2   // Width of buffer number register (for ttag)
 #define SHWR_MEM_NBUF (1<<SHWR_BUF_NUM_WIDTH) // Num. shower memory buffers
 #define SHWR_EVT_CTR_WIDTH 4   // Width of shower event counter (for ttag)
                                // Delay from trigger to end of buffer
 #define SHWR_TRIG_DLY ((SHWR_MEM_WORDS*2)/3)
                                // Dead length till next possible trigger,
                                // not counting logic delays
 #define SHWR_DEAD_DLY (SHWR_MEM_WORDS) // Not counting logic delays
 #define MUON_MEM_WIDTH 32      // Width of each muon memory
 #define MUON_MEM_ADDR_WIDTH 32 // Vivado seems to require 32 bit bus
                                // even though only use a fraction of it.
 #define MUON_MEM_BUF_SHIFT 15  // Muon memory buffer number shift
                                // Depth of each muon memory buffer
 #define MUON_MEM_DEPTH (1<<MUON_MEM_BUF_SHIFT)
 #define MUON_MEM_WORDS (MUON_MEM_DEPTH/4)
 #define MUON_BUF_NUM_WIDTH 2   // Width of buffer number register (for ttag)
 #define MUON_MEM_NBUF (1<<MUON_BUF_NUM_WIDTH) // Num. muon memory buffers
 #define MUON_EVT_CTR_WIDTH 4   // Width of muon event counter (for ttag)
 
 #define SHWR_TRIGGER_INTR_BIT 0 // Shower trigger bit in interrupt regs.  
 #define MUON_TRIGGER_INTR_BIT 1 // Muon trigger bit in interrupt regs.  


// Define "Addresses" of trigger registers
// The first 128 registers are used in compatibility mode and are assigned, 
// as much as possible, to be the same as the pre-upgrade trigger registers.
// Not all of the addresses are used.  Also, some of the registers may also be
// used for native 120 MHz mode, if there is no difference between the contents
// in native mode and in compatibility mode.

#define COMPATIBILITY_AMIGA_TRIG_ADDR 21

#define COMPATIBILITY_MOPS_TRIG_MIN0_ADDR 22
#define COMPATIBILITY_MOPS_TRIG_MIN1_ADDR 23
#define COMPATIBILITY_MOPS_TRIG_MIN2_ADDR 24
#define COMPATIBILITY_MOPS_TRIG_MAX0_ADDR 25
#define COMPATIBILITY_MOPS_TRIG_MAX1_ADDR 26
#define COMPATIBILITY_MOPS_TRIG_MAX2_ADDR 27
#define COMPATIBILITY_MOPS_TRIG_ENAB_ADDR 28
#define COMPATIBILITY_MOPS_TRIG_INT_ADDR 29
#define COMPATIBILITY_MOPS_TRIG_OCC_ADDR 30
#define COMPATIBILITY_MOPS_TRIG_OFS_ADDR 31

#define COMPATIBILITY_TRIG_RATES_ADDR 44
#define COMPATIBILITY_DELAYED_RATES_ADDR 45

#define COMPATIBILITY_GLOBAL_CONTROL_ADDR 46
 #define COMPATIBILITY_GLOBAL_CONTROL_RESET 1

#define ID_REG_ADDR 47

#define COMPATIBILITY_SB_TRIG_THR0_ADDR 48
#define COMPATIBILITY_SB_TRIG_THR1_ADDR 49
#define COMPATIBILITY_SB_TRIG_THR2_ADDR 50
#define COMPATIBILITY_SB_TRIG_ENAB_ADDR 52
 #define COMPATIBILITY_SB_TRIG_ENAB_SHIFT 3
 #define COMPATIBILITY_SB_TRIG_ENAB_WIDTH 3
 #define COMPATIBILITY_SB_TRIG_INCL_PMT0 (1<<COMPATIBILITY_SB_TRIG_ENAB_SHIFT)
 #define COMPATIBILITY_SB_TRIG_INCL_PMT1 (2<<COMPATIBILITY_SB_TRIG_ENAB_SHIFT)
 #define COMPATIBILITY_SB_TRIG_INCL_PMT2 (4<<COMPATIBILITY_SB_TRIG_ENAB_SHIFT)
 #define COMPATIBILITY_SB_TRIG_COINC_LVL_MASK 0x3
 #define COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT 6
 #define COMPATIBILITY_SB_TRIG_COINC_LVL_WIDTH 2
 #define COMPATIBILITY_SB_TRIG_REQ2BINS 0x200

#define COMPATIBILITY_RANDOM_TRIG_DELAY_A_ADDR 53
#define COMPATIBILITY_RANDOM_TRIG_DELAY_B_ADDR 54
#define COMPATIBILITY_RANDOM_TRIG_START_ADDR 55

#define COMPATIBILITY_TOT_TRIG_THR0_ADDR 56
#define COMPATIBILITY_TOT_TRIG_THR1_ADDR 57
#define COMPATIBILITY_TOT_TRIG_THR2_ADDR 58
#define COMPATIBILITY_TOT_TRIG_ENAB_ADDR 60
#define COMPATIBILITY_TOT_TRIG_OCC_ADDR 62

#define COMPATIBILITY_TOTD_TRIG_THR0_ADDR 64
#define COMPATIBILITY_TOTD_TRIG_THR1_ADDR 65
#define COMPATIBILITY_TOTD_TRIG_THR2_ADDR 66
#define COMPATIBILITY_TOTD_TRIG_UP0_ADDR 67
#define COMPATIBILITY_TOTD_TRIG_UP1_ADDR 68
#define COMPATIBILITY_TOTD_TRIG_UP2_ADDR 69
#define COMPATIBILITY_TOTD_TRIG_ENAB_ADDR 70
#define COMPATIBILITY_TOTD_TRIG_OCC_ADDR 72
#define COMPATIBILITY_TOTD_TRIG_FD_ADDR 73
#define COMPATIBILITY_TOTD_TRIG_FN_ADDR 74

#define COMPATIBILITY_SCALAR_A_THR0_ADDR 80
#define COMPATIBILITY_SCALAR_A_THR1_ADDR 81
#define COMPATIBILITY_SCALAR_A_THR2_ADDR 82
#define COMPATIBILITY_SCALAR_A_ENAB_ADDR 84
#define COMPATIBILITY_SCALAR_A_COUNT_ADDR 87

#define COMPATIBILITY_SCALAR_B_THR0_ADDR 88
#define COMPATIBILITY_SCALAR_B_THR1_ADDR 89
#define COMPATIBILITY_SCALAR_B_THR2_ADDR 90
#define COMPATIBILITY_SCALAR_B_ENAB_ADDR 92
#define COMPATIBILITY_SCALAR_B_COUNT_ADDR 95

#define COMPATIBILITY_SCALAR_C_THR0_ADDR 96
#define COMPATIBILITY_SCALAR_C_THR1_ADDR 97
#define COMPATIBILITY_SCALAR_C_THR2_ADDR 98
#define COMPATIBILITY_SCALAR_C_ENAB_ADDR 100
#define COMPATIBILITY_SCALAR_C_COUNT_ADDR 103

// Normal mode registers.  Note that the global trigger control and the
// buffer handling are done using the normal mode registers as the readout
// operations are necessarily different than in the before 2015 implementation.

// Shower memory status & control registers
// Note that the status register should be read atomicly, which is why
// multiple fields are packed into one register.
#define SHWR_BUF_TRIG_MASK_ADDR 128
  #define COMPATIBILITY_SHWR_BUF_TRIG_SB_SHIFT 0
  #define COMPATIBILITY_SHWR_BUF_TRIG_TOT_SHIFT 1
  #define COMPATIBILITY_SHWR_BUF_TRIG_TOTD_SHIFT 2
  #define COMPATIBILITY_SHWR_BUF_TRIG_MOPS_SHIFT 3
  #define COMPATIBILITY_SHWR_BUF_TRIG_EXT_SHIFT 4
  #define COMPATIBILITY_SHWR_BUF_TRIG_RNDM_SHFT 5
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_SB_SHIFT 6
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT_SHIFT 7
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD_SHIFT 8
  #define COMPAT_PESCALE_SHWR_BUF_TRIG_MOPS_SHIFT 9
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT_SHIFT 10
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_RNDM_SHFT 11
  #define SHWR_BUF_TRIG_LED_SHIFT 16

  #define COMPATIBILITY_SHWR_BUF_TRIG_SB (1 << COMPATIBILITY_SHWR_BUF_TRIG_SB_SHIFT)
  #define COMPATIBILITY_SHWR_BUF_TRIG_TOT (1 << COMPATIBILITY_SHWR_BUF_TRIG_TOT_SHIFT)
  #define COMPATIBILITY_SHWR_BUF_TRIG_TOTD (1 << COMPATIBILITY_SHWR_BUF_TRIG_TOTD_SHIFT)
  #define COMPATIBILITY_SHWR_BUF_TRIG_MOPS (1 << COMPATIBILITY_SHWR_BUF_TRIG_MOPS_SHIFT)
  #define COMPATIBILITY_SHWR_BUF_TRIG_EXT (1 << COMPATIBILITY_SHWR_BUF_TRIG_EXT_SHIFT)
  #define COMPATIBILITY_SHWR_BUF_TRIG_RNDM (1 << COMPATIBILITY_SHWR_BUF_TRIG_RNDM_SHIFT)
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_SB (1 << COMPAT_PRESCALE_SHWR_BUF_TRIG_SB_SHIFT)
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT (1 << COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT_SHIFT)
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD (1 << COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD_SHIFT)
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_MOPS (1 << COMPAT_PRESCALE_SHWR_BUF_TRIG_MOPS_SHIFT)
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT (1 << COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT_SHIFT)
  #define COMPAT_PRESCALE_SHWR_BUF_TRIG_RNDM (1 << COMPAT_PRESCALE_SHWR_BUF_TRIG_RNDM_SHIFT)
  #define SHWR_BUF_TRIG_LED (1 << SHWR_BUF_TRIG_LED_SHIFT)

#define SHWR_BUF_TRIG_ID_ADDR 129
  #define COMPATIBILITY_SHWR_BUF_TRIG_SB_DLYD (COMPATIBILITY_SHWR_BUF_TRIG_SB<<8)
  #define COMPATIBILITY_SHWR_BUF_TRIG_TOT_DLYD (COMPATIBILITY_SHWR_BUF_TRIG_TOT<<8)
  #define COMPATIBILITY_SHWR_BUF_TRIG_TOTD_DLYD (COMPATIBILITY_SHWR_BUF_TRIG_TOTD<<8)
  #define COMPATIBILITY_SHWR_BUF_TRIG_MOPS_DLYD (COMPATIBILITY_SHWR_BUF_TRIG_MOPS<<8)
  #define COMPATIBILITY_SHWR_BUF_TRIG_EXT_DLYD (COMPATIBILITY_SHWR_BUF_TRIG_EXT<<8)
  #define COMPATIBILITY_SHWR_BUF_TRIG_RNDM_DLYD (COMPATIBILITY_SHWR_BUF_TRIG_RNDM<<8)
  #define SHWR_BUF_TRIG_LED_DLYD (SHWR_BUF_TRIG_LED<<8)
#define SHWR_BUF_CONTROL_ADDR 130
#define SHWR_BUF_STATUS_ADDR 131
 #define SHWR_BUF_RNUM_MASK ((1<<SHWR_BUF_NUM_WIDTH)-1)
 #define SHWR_BUF_RNUM_SHIFT 0
 #define SHWR_BUF_WNUM_MASK ((1<<SHWR_BUF_NUM_WIDTH)-1)
 #define SHWR_BUF_WNUM_SHIFT (SHWR_BUF_RNUM_SHIFT+SHWR_BUF_NUM_WIDTH)
 #define SHWR_BUF_FULL_MASK ((1<<SHWR_MEM_NBUF)-1)
 #define SHWR_BUF_FULL_SHIFT (SHWR_BUF_WNUM_SHIFT+SHWR_BUF_NUM_WIDTH)
 #define SHWR_INTR_PEND_MASK 1
 #define SHWR_INTR_PEND_SHIFT (SHWR_BUF_FULL_SHIFT+SHWR_MEM_NBUF)
 #define SHWR_BUF_NFULL_MASK ((1<<(SHWR_BUF_NUM_WIDTH+1))-1)
 #define SHWR_BUF_NFULL_SHIFT (SHWR_INTR_PEND_SHIFT+1)
 #define SHWR_BUF_NOTUSED_SHIFT (SHWR_BUF_NFULL_SHIFT+SHWR_BUF_NUM_WIDTH+1)
#define SHWR_BUF_START_ADDR 132
#define SHWR_BUF_START0_ADDR 133
#define SHWR_BUF_START1_ADDR 134
#define SHWR_BUF_START2_ADDR 135
#define SHWR_BUF_START3_ADDR 136

#define MUON_TRIG1_THR0_ADDR 140
#define MUON_TRIG1_THR1_ADDR 141
#define MUON_TRIG1_THR2_ADDR 142
#define MUON_TRIG1_SSD_ADDR 143
#define MUON_TRIG1_ENAB_ADDR 144

#define MUON_TRIG2_THR0_ADDR 145
#define MUON_TRIG2_THR1_ADDR 146
#define MUON_TRIG2_THR2_ADDR 147
#define MUON_TRIG2_SSD_ADDR 148
#define MUON_TRIG2_ENAB_ADDR 149

#define MUON_TRIG3_THR0_ADDR 150
#define MUON_TRIG3_THR1_ADDR 151
#define MUON_TRIG3_THR2_ADDR 152
#define MUON_TRIG3_SSD_ADDR 153
#define MUON_TRIG3_ENAB_ADDR 154

#define MUON_TRIG4_THR0_ADDR 155
#define MUON_TRIG4_THR1_ADDR 156
#define MUON_TRIG4_THR2_ADDR 157
#define MUON_TRIG4_SSD_ADDR 158
#define MUON_TRIG4_ENAB_ADDR 159

 #define MUON_TRIG_ENAB_SHIFT 0
 #define MUON_TRIG_ENAB_WIDTH 4
 #define MUON_TRIG_INCL_PMT0 (1<<MUON_TRIG_ENAB_SHIFT)
 #define MUON_TRIG_INCL_PMT1 (2<<MUON_TRIG_ENAB_SHIFT)
 #define MUON_TRIG_INCL_PMT2 (4<<MUON_TRIG_ENAB_SHIFT)
 #define MUON_TRIG_INCL_SSD (8<<MUON_TRIG_ENAB_SHIFT)
 #define MUON_TRIG_COINC_LVL_MASK 0x7
 #define MUON_TRIG_COINC_LVL_SHIFT MUON_TRIG_ENAB_WIDTH
 #define MUON_TRIG_COINC_LVL_WIDTH 3
 #define MUON_TRIG_DELAY_LEN_MASK 0x3
 #define MUON_TRIG_DELAY_WIDTH 2
 #define MUON_TRIG_DELAY_MAX (1<<MUON_TRIG_DELAY_WIDTH)
 #define MUON_TRIG_WCD_DELAY_SHIFT (MUON_TRIG_COINC_LVL_SHIFT+MUON_TRIG_COINC_LVL_WIDTH)
 #define MUON_TRIG_SSD_DELAY_SHIFT (MUON_TRIG_WCD_DELAY_SHIFT+MUON_TRIG_DELAY_WIDTH)
 #define MUON_TRIG_COINC_OVLP_MASK 0x3
 #define MUON_TRIG_COINC_OVLP_WIDTH 2
 #define MUON_TRIG_COINC_OVLP_MAX ((1<<MUON_TRIG_COINC_OVLP_WIDTH)-1)
 #define MUON_TRIG_COINC_OVLP_SHIFT (MUON_TRIG_SSD_DELAY_SHIFT+MUON_TRIG_COINC_OVLP_WIDTH)    
 #define MUON_TRIG_CONSEC_BINS_MASK 0x3
 #define MUON_TRIG_CONSEC_BINS_WIDTH 2
 #define MUON_TRIG_CONSEC_BINS_MAX ((1<<MUON_TRIG_CONSEC_BINS_WIDTH)-1)
 #define MUON_TRIG_CONSEC_BINS_SHIFT (MUON_TRIG_COINC_OVLP_SHIFT+MUON_TRIG_DELAY_WIDTH)
 #define MUON_TRIG_DELAY_EXTRA 10
 #define MUON_TRIG_PIPELINE_DLY (MUON_TRIG_DELAY_MAX+MUON_TRIG_COINC_OVLP_MAX+MUON_TRIG_CONSEC_BINS_MAX+`MUON_TRIG_DELAY_EXTRA)
 #define MUON_EXT_TRIG_DELAY 20
 #define MUON_BURST_LEN 70      // # of bins to save for each muon

#define MUON_BUF_TIME_TAG_A_ADDR 160
#define MUON_BUF_TIME_TAG_B_ADDR 161
#define MUON_BUF_TRIG_MASK_ADDR 162
  #define MUON_BUF_TRIG_SB1_SHIFT 0
  #define MUON_BUF_TRIG_SB2_SHIFT 1
  #define MUON_BUF_TRIG_SB3_SHIFT 2
  #define MUON_BUF_TRIG_SB4_SHIFT 3
  #define MUON_BUF_TRIG_EXT_SHIFT 4
  #define MUON_BUF_TRIG_SB1 (1 << MUON_BUF_TRIG_SB1_SHIFT)
  #define MUON_BUF_TRIG_SB2 (1 << MUON_BUF_TRIG_SB2_SHIFT)
  #define MUON_BUF_TRIG_SB3 (1 << MUON_BUF_TRIG_SB3_SHIFT)
  #define MUON_BUF_TRIG_SB4 (1 << MUON_BUF_TRIG_SB4_SHIFT)
  #define MUON_BUF_TRIG_EXT (1 << MUON_BUF_TRIG_EXT_SHIFT)
  #define MUON_NUM_TRIGS 5
#define MUON_BUF_CONTROL_ADDR 163
#define MUON_BUF_STATUS_ADDR 164
 #define MUON_BUF_RNUM_MASK ((1<<MUON_BUF_NUM_WIDTH)-1)
 #define MUON_BUF_RNUM_SHIFT 0
 #define MUON_BUF_WNUM_MASK ((1<<MUON_BUF_NUM_WIDTH)-1)
 #define MUON_BUF_WNUM_SHIFT (MUON_BUF_RNUM_SHIFT+MUON_BUF_NUM_WIDTH)
 #define MUON_BUF_FULL_MASK ((1<<MUON_MEM_NBUF)-1)
 #define MUON_BUF_FULL_SHIFT (MUON_BUF_WNUM_SHIFT+MUON_BUF_NUM_WIDTH)
 #define MUON_INTR_PEND_MASK 1
 #define MUON_INTR_PEND_SHIFT (MUON_BUF_FULL_SHIFT+MUON_MEM_NBUF)
 #define MUON_BUF_NFULL_MASK (1<<(MUON_BUF_NUM_WIDTH+1))
 #define MUON_BUF_NFULL_SHIFT (MUON_INTR_PEND_SHIFT+1)
 #define MUON_BUF_NOTUSED_SHIFT (MUON_BUF_NFULL_SHIFT+MUON_BUF_NUM_WIDTH+1)
#define MUON_BUF_WORD_COUNT_ADDR 165
#define MUON_BUF_WORD_COUNT0_ADDR 166
#define MUON_BUF_WORD_COUNT1_ADDR 167
#define MUON_BUF_WORD_COUNT2_ADDR 168
#define MUON_BUF_WORD_COUNT3_ADDR 169

// Addresses to sample instantaneious filtered PMT values for setup, test, etc.
#define FILT_PMT0_TEST_ADDR 247
#define FILT_PMT1_TEST_ADDR 248
#define FILT_PMT2_TEST_ADDR 249

// Addresses to sample instantaneous ADC values for setup, test, debug.
#define ADC0_TEST_ADDR 250
#define ADC1_TEST_ADDR 251
#define ADC2_TEST_ADDR 252 
#define ADC3_TEST_ADDR 253
#define ADC4_TEST_ADDR 254

#define LED_CONTROL_ADDR 255
 #define LED_NOW 1 
 #define LED_ENAPPS_SHIFT 1
 #define LED_ENAPPS (1<<LED_ENAPPS_SHIFT)
 #define LED_DELAY_SHIFT 2
 #define LED_DELAY_WIDTH 17
 #define LED_DELAY_MASK ((1<<LED_DELAY_WIDTH)-1)
 #define LED_PULSWID_SHIFT (LED_DELAY_SHIFT+LED_DELAY_WIDTH)
 #define LED_PULSWID_WIDTH 11
 #define LED_PULSWID_MASK ((1<<LED_PULSWID_WIDTH)-1)
 #define LED_FLAG_DURATION 500;

// For convenience, define "Addresses" of time tagging registers relative
// to the time tagging module base address.

#define TTAG_SHWR_NANOSEC_ADDR 0
#define TTAG_SHWR_SECONDS_ADDR 1
#define TTAG_SHWR_PPS_NANOSEC_ADDR 2
#define TTAG_SHWR_PPS_SECONDS_ADDR 3
#define TTAG_MUON_NANOSEC_ADDR 4
#define TTAG_MUON_SECONDS_ADDR 5
#define TTAG_MUON_PPS_NANOSEC_ADDR 6
#define TTAG_MUON_PPS_SECONDS_ADDR 7
#define TTAG_PPS_SECONDS_ADDR 8
#define TTAG_PPS_NANOSEC_ADDR 9
#define TTAG_PPS_CAL_ADDR 10
#define TTAG_DEAD_CTR_ADDR 11
#define TTAG_STATUS_ADDR 12
  #define TTAG_MUON_TRIG 1
  #define TTAG_PPS 2
  #define TTAG_SHWR_TRIG 4
  #define TTAG_DEAD_TIME 8
#define TTAG_CTRL_ADDR 13
  #define TTAG_RESET 1
  #define TTAG_CLR_PPS 2
  #define TTAG_CLR_SHWR_TRIG 4
  #define TTAG_CLR_MUON_TRIG 8
  #define TTAG_CLR_DEAD_TIME 16
#define TTAG_ID_ADDR 14

#define TTAG_NANOSEC_MASK ((1<<27)-1)
#define TTAG_SECONDS_MASK ((1<<28)-1)
#define TTAG_EVTCTR_MASK 0xf
#define TTAG_EVTCTR_SHIFT 28

#endif // #ifndef _TRIGGER_DEFS