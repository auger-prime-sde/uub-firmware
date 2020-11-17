// Global definitions for the sde trigger
// 
// 14-Jan-14 DFN Initial version
// 14-May-14 DFN Added SHWR_MEM_WIDTH
// 06-Jun-14 DFN Start defining status register bits
// 19-Jun-15 DFN Add trace start registers
// 29-Mar-16 DFN Change to derive SHWR_MEM_NBUF from SHWR_BUF_NUM_WIDTH and
//               similarly for muon buffers
// 17-Sep-16 DFN Move time tagging definitions to time_tagging_defs.vh
// 08-Nov-16 DFN Increase max SSD delay in single bin triggers.
// 15-Nov-16 DFN Add documentation on what each ADC channel is used for
// 09-Mar-17 DFN Add option to AND SSD trigger with WCD trigger in 
//               addition to default OR mode
// 24-May-18 DFN Add definitions for compatibility tot trigger; change SAG
//               calculations to be nominal RC sag for the V2 circuit,
//               neglecting any sag from PMT base coupling.
// 21-Jun-18 DFN Add definitions for compatibility totd trigger.
// 31-Oct-19 DFN+FC Add definitions for compatibility mops trigger.
// 01-Nov-19 DFN Update definitions for random trigger.
// 27-Mar-20 DFN Add option to include or not delay of non-filtered data
//               Previously this was included by default.
// 06-Apr-20 DFN Add extra latency counters to verify fclk_clk0 and fclk_clk1
//               frequencies in running system.
//
// ADC channel usage:
//  0 Low gain WCD PMT1
//  1 High gain WCD PMT1
//  2 Low gain WCD PMT2
//  3 High gain WCD PMT2
//  4 Low gain WCD PMT3
//  5 High gain WCD PMT3
//  6 Small PMT (a low gain channel) 
//  7 SSD SIPM calibration channel (if SIPM installed)
//  8 Low gain SSD PMT or SIPM
//  9 High gain SSD PMT or SIPM

`ifndef _TRIGGER_DEFS
 `define _TRIGGER_DEFS 1


// Debug definitions -- may have a problem with defines nested very deeply
// so don't nest the DEBUG defines.
//`define ANY_DEBUG 1  // Enable if any of the following is set.
// `define HIGAIN_INTEGRAL_DEBUG 1  // Only enable one of LO/HI GAIN_DEBUG
// `define LOGAIN_INTEGRAL_DEBUG 1
// `define MXDGAIN_INTEGRAL_DEBUG 1
// `define COMPAT_TOTD_DECONV_DEBUG 1
// `define COMPAT_TOTD_INTGRL_DEBUG 1
// `define COMPAT_TOTD_TRIG_DEBUG 1
// `define COMPAT_TOTD_DEBUG 1
// `define COMPAT_TOT_DEBUG 1
// `define COMPAT_MOPS_DEBUG 1
// `define EXTERN_DEBUG 1
// End of debug enable definitions

 `define CLK_FREQ 120 // Clock frequency in MHz
 `define ADC_WIDTH 12 // Number of bits per ADC
 `define NUM_ADCS 10  // Number of ADCs
 `define ENABLE_FILT_DELAY 1 // Add delay to non-filtered data if enabled
// `define ADC_FILT_DELAY 22 // ADC filter delay
 `define ADC_FILT_DELAY 27 // ADC filter delay
 `define WIDTH_BITS 9 // Number of bits in ToT occupancy register

 `define SHWR_MEM_WIDTH 32      // Width of each shower memory block
 `define SHWR_MEM_ADDR_WIDTH 32 // Vivado seems to require 32 bit bus
                                // even though only use a fraction of it.
 `define SHWR_MEM_BUF_SHIFT 13  // Shower memory buffer number shift
                                // Depth of each shower memory buffer (*4 since
                                // addressing is in bytes - 4 to a word)
 `define SHWR_MEM_DEPTH (1<<`SHWR_MEM_BUF_SHIFT)
 `define SHWR_MEM_WORDS (`SHWR_MEM_DEPTH/4)
 `define SHWR_BUF_NUM_WIDTH 2   // Width of buffer number register (for ttag)
 `define SHWR_MEM_NBUF (1<<`SHWR_BUF_NUM_WIDTH) // Num. shower memory buffers
 `define SHWR_EVT_CTR_WIDTH 4   // Width of shower event counter (for ttag)
                                // Delay from trigger to end of buffer
 `define SHWR_TRIG_DLY ((`SHWR_MEM_WORDS*2)/3)
                                // Dead length till next possible trigger,
                                // not counting logic delays
 `define SHWR_DEAD_DLY (`SHWR_MEM_WORDS) // Not counting logic delays
 `define MUON_MEM_WIDTH 32      // Width of each muon memory
 `define MUON_MEM_ADDR_WIDTH 32 // Vivado seems to require 32 bit bus
                                // even though only use a fraction of it.
 `define MUON_MEM_BUF_SHIFT 15  // Muon memory buffer number shift
                                // Depth of each muon memory buffer
 `define MUON_MEM_DEPTH (1<<`MUON_MEM_BUF_SHIFT)
 `define MUON_MEM_WORDS (`MUON_MEM_DEPTH/4)
 `define MUON_BUF_NUM_WIDTH 2   // Width of buffer number register (for ttag)
 `define MUON_MEM_NBUF (1<<`MUON_BUF_NUM_WIDTH) // Num. muon memory buffers
 `define MUON_EVT_CTR_WIDTH 4   // Width of muon event counter (for ttag)
 
// Define "Addresses" of trigger registers
// The first 128 registers are used in compatibility mode and are assigned, 
// as much as possible, to be the same as the pre-upgrade trigger registers.
// Not all of the addresses are used.  Also, some of the registers may also be
// used for native 120 MHz mode, if there is no difference between the contents
// in native mode and in compatibility mode.

`define COMPATIBILITY_AMIGA_TRIG_ADDR 021

`define COMPATIBILITY_MOPS_TRIG_MIN0_ADDR 022
`define COMPATIBILITY_MOPS_TRIG_MIN1_ADDR 023
`define COMPATIBILITY_MOPS_TRIG_MIN2_ADDR 024
`define COMPATIBILITY_MOPS_TRIG_MAX0_ADDR 025
`define COMPATIBILITY_MOPS_TRIG_MAX1_ADDR 026
`define COMPATIBILITY_MOPS_TRIG_MAX2_ADDR 027
`define COMPATIBILITY_MOPS_TRIG_ENAB_ADDR 028
`define COMPATIBILITY_MOPS_TRIG_INT_ADDR 029
`define COMPATIBILITY_MOPS_TRIG_OCC_ADDR 030
`define COMPATIBILITY_MOPS_TRIG_OFS_ADDR 031
 `define COMPATIBILITY_MOPS_TRIG_ENAB_SHIFT 3
 `define COMPATIBILITY_MOPS_TRIG_ENAB_WIDTH 3
 `define COMPATIBILITY_MOPS_TRIG_INCL_PMT0 (1<<`COMPATIBILITY_MOPS_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_MOPS_TRIG_INCL_PMT1 (2<<`COMPATIBILITY_MOPS_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_MOPS_TRIG_INCL_PMT2 (4<<`COMPATIBILITY_MOPS_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_MOPS_TRIG_COINC_LVL_SHIFT 6
 `define COMPATIBILITY_MOPS_TRIG_COINC_LVL_WIDTH 2
 `define COMPATIBILITY_MOPS_OFS_BITS 4


`define COMPATIBILITY_TRIG_RATES_ADDR 044
`define COMPATIBILITY_DELAYED_RATES_ADDR 045

`define COMPATIBILITY_GLOBAL_CONTROL_ADDR 046
 `define COMPATIBILITY_GLOBAL_CONTROL_RESET 1

`define ID_REG_ADDR 047

`define COMPATIBILITY_SB_TRIG_THR0_ADDR 048
`define COMPATIBILITY_SB_TRIG_THR1_ADDR 049
`define COMPATIBILITY_SB_TRIG_THR2_ADDR 050
`define COMPATIBILITY_SB_TRIG_ENAB_ADDR 052
 `define COMPATIBILITY_SB_TRIG_ENAB_SHIFT 3
 `define COMPATIBILITY_SB_TRIG_ENAB_WIDTH 3
 `define COMPATIBILITY_SB_TRIG_INCL_PMT0 (1<<`COMPATIBILITY_SB_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_SB_TRIG_INCL_PMT1 (2<<`COMPATIBILITY_SB_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_SB_TRIG_INCL_PMT2 (4<<`COMPATIBILITY_SB_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_SB_TRIG_COINC_LVL_MASK 'h3
 `define COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT 6
 `define COMPATIBILITY_SB_TRIG_COINC_LVL_WIDTH 2
 `define COMPATIBILITY_SB_TRIG_REQ2BINS_SHIFT 9

`define RANDOM_TRIG_MODE_ADDR 053

`define COMPATIBILITY_TOT_TRIG_THR0_ADDR 056
`define COMPATIBILITY_TOT_TRIG_THR1_ADDR 057
`define COMPATIBILITY_TOT_TRIG_THR2_ADDR 058
`define COMPATIBILITY_TOT_TRIG_ENAB_ADDR 060
`define COMPATIBILITY_TOT_TRIG_OCC_ADDR 062
 `define COMPATIBILITY_TOT_TRIG_ENAB_SHIFT 3
 `define COMPATIBILITY_TOT_TRIG_ENAB_WIDTH 3
 `define COMPATIBILITY_TOT_TRIG_INCL_PMT0 (1<<`COMPATIBILITY_TOT_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_TOT_TRIG_INCL_PMT1 (2<<`COMPATIBILITY_TOT_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_TOT_TRIG_INCL_PMT2 (4<<`COMPATIBILITY_TOT_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_TOT_TRIG_COINC_LVL_SHIFT 6
 `define COMPATIBILITY_TOT_TRIG_COINC_LVL_WIDTH 2

`define COMPATIBILITY_TOTD_TRIG_THR0_ADDR 064
`define COMPATIBILITY_TOTD_TRIG_THR1_ADDR 065
`define COMPATIBILITY_TOTD_TRIG_THR2_ADDR 066
`define COMPATIBILITY_TOTD_TRIG_UP0_ADDR 067
`define COMPATIBILITY_TOTD_TRIG_UP1_ADDR 068
`define COMPATIBILITY_TOTD_TRIG_UP2_ADDR 069
`define COMPATIBILITY_TOTD_TRIG_ENAB_ADDR 070
`define COMPATIBILITY_TOTD_TRIG_OCC_ADDR 072
`define COMPATIBILITY_TOTD_TRIG_FD_ADDR 073
`define COMPATIBILITY_TOTD_TRIG_FN_ADDR 074
`define COMPATIBILITY_TOTD_TRIG_INT_ADDR 075
 `define COMPATIBILITY_TOTD_TRIG_ENAB_SHIFT 3
 `define COMPATIBILITY_TOTD_TRIG_ENAB_WIDTH 3
 `define COMPATIBILITY_TOTD_TRIG_INCL_PMT0 (1<<`COMPATIBILITY_TOTD_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_TOTD_TRIG_INCL_PMT1 (2<<`COMPATIBILITY_TOTD_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_TOTD_TRIG_INCL_PMT2 (4<<`COMPATIBILITY_TOTD_TRIG_ENAB_SHIFT)
 `define COMPATIBILITY_TOTD_TRIG_COINC_LVL_SHIFT 6
 `define COMPATIBILITY_TOTD_TRIG_COINC_LVL_WIDTH 2
 `define COMPATIBILITY_TOTD_FN_BITS 6
 `define COMPATIBILITY_TOTD_FN_FRAC_BITS 4
 `define COMPATIBILITY_TOTD_FD_BITS 6
 `define COMPATIBILITY_DECAY_BITS 11
 `define COMPATIBILITY_FRAC_BITS 11
 `define COMPATIBILITY_INTEGRAL_BITS 24
 `define COMPATIBILITY_BASELINE_DELAY 248

`define COMPATIBILITY_SCALER_A_THR0_ADDR 080
`define COMPATIBILITY_SCALER_A_THR1_ADDR 081
`define COMPATIBILITY_SCALER_A_THR2_ADDR 082
`define COMPATIBILITY_SCALER_A_ENAB_ADDR 084
`define COMPATIBILITY_SCALER_A_COUNT_ADDR 087

`define COMPATIBILITY_SCALER_B_THR0_ADDR 088
`define COMPATIBILITY_SCALER_B_THR1_ADDR 089
`define COMPATIBILITY_SCALER_B_THR2_ADDR 090
`define COMPATIBILITY_SCALER_B_ENAB_ADDR 092
`define COMPATIBILITY_SCALER_B_COUNT_ADDR 095

`define COMPATIBILITY_SCALER_C_THR0_ADDR 096
`define COMPATIBILITY_SCALER_C_THR1_ADDR 097
`define COMPATIBILITY_SCALER_C_THR2_ADDR 098
`define COMPATIBILITY_SCALER_C_ENAB_ADDR 100
`define COMPATIBILITY_SCALER_C_COUNT_ADDR 103

// Normal mode registers.  Note that the global trigger control and the
// buffer handling are done using the normal mode registers as the readout
// operations are necessarily different than in the before 2015 implementation.

// Shower memory status & control registers
// Note that the status register should be read atomicly, which is why
// multiple fields are packed into one register.
`define SHWR_BUF_TRIG_MASK_ADDR 128
  `define COMPATIBILITY_SHWR_BUF_TRIG_SB_SHIFT 0
  `define COMPATIBILITY_SHWR_BUF_TRIG_TOT_SHIFT 1
  `define COMPATIBILITY_SHWR_BUF_TRIG_TOTD_SHIFT 2
  `define COMPATIBILITY_SHWR_BUF_TRIG_MOPS_SHIFT 3
  `define COMPATIBILITY_SHWR_BUF_TRIG_EXT_SHIFT 4
  `define SHWR_BUF_TRIG_RNDM_SHIFT 5
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_SB_SHIFT 6
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT_SHIFT 7
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD_SHIFT 8
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_MOPS_SHIFT 9
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT_SHIFT 10
  `define PRESCALE_SHWR_BUF_TRIG_RNDM_SHIFT 11
  `define SHWR_BUF_TRIG_LED_SHIFT 16
  `define SHWR_BUF_TRIG_SB_SHIFT 17
  `define PRESCALE_SHWR_BUF_TRIG_SB_SHIFT 25

  `define COMPATIBILITY_SHWR_BUF_TRIG_SB (1 << `COMPATIBILITY_SHWR_BUF_TRIG_SB_SHIFT)
  `define COMPATIBILITY_SHWR_BUF_TRIG_TOT (1 << `COMPATIBILITY_SHWR_BUF_TRIG_TOT_SHIFT)
  `define COMPATIBILITY_SHWR_BUF_TRIG_TOTD (1 << `COMPATIBILITY_SHWR_BUF_TRIG_TOTD_SHIFT)
  `define COMPATIBILITY_SHWR_BUF_TRIG_MOPS (1 << `COMPATIBILITY_SHWR_BUF_TRIG_MOPS_SHIFT)
  `define COMPATIBILITY_SHWR_BUF_TRIG_EXT (1 << `COMPATIBILITY_SHWR_BUF_TRIG_EXT_SHIFT)
  `define SHWR_BUF_TRIG_RNDM (1 << `SHWR_BUF_TRIG_RNDM_SHIFT)
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_SB (1 << `COMPAT_PRESCALE_SHWR_BUF_TRIG_SB_SHIFT)
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT (1 << `COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT_SHIFT)
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD (1 << `COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD_SHIFT)
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_MOPS (1 << `COMPAT_PRESCALE_SHWR_BUF_TRIG_MOPS_SHIFT)
  `define COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT (1 << `COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT_SHIFT)
  `define PRESCALE_SHWR_BUF_TRIG_RNDM (1 << `PRESCALE_SHWR_BUF_TRIG_RNDM_SHIFT)
  `define SHWR_BUF_TRIG_LED (1 << `SHWR_BUF_TRIG_LED_SHIFT)
  `define SHWR_BUF_TRIG_SB (1 << `SHWR_BUF_TRIG_SB_SHIFT)
  `define PRESCALE_SHWR_BUF_TRIG_SB (1 << `PRESCALE_SHWR_BUF_TRIG_SB_SHIFT)

`define SHWR_BUF_TRIG_ID_ADDR 129
  `define COMPATIBILITY_SHWR_BUF_TRIG_SB_DLYD (`COMPATIBILITY_SHWR_BUF_TRIG_SB<<8)
  `define COMPATIBILITY_SHWR_BUF_TRIG_TOT_DLYD (`COMPATIBILITY_SHWR_BUF_TRIG_TOT<<8)
  `define COMPATIBILITY_SHWR_BUF_TRIG_TOTD_DLYD (`COMPATIBILITY_SHWR_BUF_TRIG_TOTD<<8)
  `define COMPATIBILITY_SHWR_BUF_TRIG_MOPS_DLYD (`COMPATIBILITY_SHWR_BUF_TRIG_MOPS<<8)
  `define COMPATIBILITY_SHWR_BUF_TRIG_EXT_DLYD (`COMPATIBILITY_SHWR_BUF_TRIG_EXT<<8)
  `define SHWR_BUF_TRIG_RNDM_DLYD (`SHWR_BUF_TRIG_RNDM<<8)
  `define SHWR_BUF_TRIG_LED_DLYD (`SHWR_BUF_TRIG_LED<<8)
  `define SHWR_BUF_TRIG_SB_DLYD (`SHWR_BUF_TRIG_SB<<8)
`define SHWR_BUF_CONTROL_ADDR 130
`define SHWR_BUF_STATUS_ADDR 131
 `define SHWR_BUF_RNUM_MASK ((1<<`SHWR_BUF_NUM_WIDTH)-1)
 `define SHWR_BUF_RNUM_SHIFT 0
 `define SHWR_BUF_WNUM_MASK ((1<<`SHWR_BUF_NUM_WIDTH)-1)
 `define SHWR_BUF_WNUM_SHIFT (`SHWR_BUF_RNUM_SHIFT+`SHWR_BUF_NUM_WIDTH)
 `define SHWR_BUF_FULL_MASK ((1<<`SHWR_MEM_NBUF)-1)
 `define SHWR_BUF_FULL_SHIFT (`SHWR_BUF_WNUM_SHIFT+`SHWR_BUF_NUM_WIDTH)
 `define SHWR_INTR_PEND_MASK 1
 `define SHWR_INTR_PEND_SHIFT (`SHWR_BUF_FULL_SHIFT+`SHWR_MEM_NBUF)
 `define SHWR_BUF_NFULL_MASK ((1<<(`SHWR_BUF_NUM_WIDTH+1))-1)
 `define SHWR_BUF_NFULL_SHIFT (`SHWR_INTR_PEND_SHIFT+1)
 `define SHWR_BUF_NOTUSED_SHIFT (`SHWR_BUF_NFULL_SHIFT+`SHWR_BUF_NUM_WIDTH+1)
 `define SHWR_EVT_ID_WIDTH 16
 `define SHWR_EVT_ID_SHIFT 16
 `define SHWR_EVT_ID_MASK  ((1<<(`SHWR_EVT_ID_WIDTH))-1)
 `define SHWR_BUF_START_ADDR 132
 `define SHWR_BUF_LATENCY_ADDR 133
// The following 2 are useful for debugging to check clock frequencies
// in case there is doubt about what is set in the FSBL
 `define SHWR_BUF_LATENCY0_ADDR 134  // Same, but using AXI clock=fclk_clk
 `define SHWR_BUF_LATENCY1_ADDR 135   // Same, but using AXI_MEM clock=fclk_clk1

`define MUON_TRIG1_THR0_ADDR 140
`define MUON_TRIG1_THR1_ADDR 141
`define MUON_TRIG1_THR2_ADDR 142
`define MUON_TRIG1_SSD_ADDR 143
`define MUON_TRIG1_ENAB_ADDR 144

`define MUON_TRIG2_THR0_ADDR 145
`define MUON_TRIG2_THR1_ADDR 146
`define MUON_TRIG2_THR2_ADDR 147
`define MUON_TRIG2_SSD_ADDR 148
`define MUON_TRIG2_ENAB_ADDR 149

// `define MUON_TRIG3_THR0_ADDR 150
// `define MUON_TRIG3_THR1_ADDR 151
// `define MUON_TRIG3_THR2_ADDR 152
// `define MUON_TRIG3_SSD_ADDR 153
// `define MUON_TRIG3_ENAB_ADDR 154

// `define MUON_TRIG4_THR0_ADDR 155
// `define MUON_TRIG4_THR1_ADDR 156
// `define MUON_TRIG4_THR2_ADDR 157
// `define MUON_TRIG4_SSD_ADDR 158
// `define MUON_TRIG4_ENAB_ADDR 159

 `define MUON_TRIG_ENAB_SHIFT 0
 `define MUON_TRIG_ENAB_WIDTH 4
 `define MUON_TRIG_INCL_PMT0 (1<<`MUON_TRIG_ENAB_SHIFT)
 `define MUON_TRIG_INCL_PMT1 (2<<`MUON_TRIG_ENAB_SHIFT)
 `define MUON_TRIG_INCL_PMT2 (4<<`MUON_TRIG_ENAB_SHIFT)
 `define MUON_TRIG_INCL_SSD (8<<`MUON_TRIG_ENAB_SHIFT)
 `define MUON_TRIG_COINC_LVL_SHIFT `MUON_TRIG_ENAB_WIDTH
 `define MUON_TRIG_COINC_LVL_WIDTH 3
 `define MUON_TRIG_COINC_LVL_MASK ((1<<`MUON_TRIG_COINC_LEVEL_WIDTH)-1)
 `define MUON_TRIG_DELAY_WIDTH 3
 `define MUON_TRIG_DELAY_LEN_MASK ((1<<`MUON_TRIG_DELAY_WIDTH)-1)
 `define MUON_TRIG_DELAY_MAX (1<<`MUON_TRIG_DELAY_WIDTH)
 `define MUON_TRIG_SSD_DELAY_SHIFT (`MUON_TRIG_COINC_LVL_SHIFT+`MUON_TRIG_COINC_LVL_WIDTH)
 `define MUON_TRIG_COINC_OVLP_WIDTH 3
 `define MUON_TRIG_COINC_OVLP_MASK ((1<<`MUON_TRIG_COINC_OVLP_WIDTH)-1)
 `define MUON_TRIG_COINC_OVLP_MAX ((1<<`MUON_TRIG_COINC_OVLP_WIDTH)-1)
 `define MUON_TRIG_COINC_OVLP_SHIFT (`MUON_TRIG_SSD_DELAY_SHIFT+`MUON_TRIG_DELAY_WIDTH)    
 `define MUON_TRIG_CONSEC_BINS_WIDTH 3
 `define MUON_TRIG_CONSEC_BINS_MASK ((1<<`MUON_TRIG_CONSEC_BINS_WIDTH)-1)
 `define MUON_TRIG_CONSEC_BINS_MAX ((1<<`MUON_TRIG_CONSEC_BINS_WIDTH)-1)
 `define MUON_TRIG_CONSEC_BINS_SHIFT (`MUON_TRIG_COINC_OVLP_SHIFT+`MUON_TRIG_COINC_OVLP_WIDTH)
 `define MUON_TRIG_SSD_AND_SHIFT (`MUON_TRIG_CONSEC_BINS_SHIFT+`MUON_TRIG_CONSEC_BINS_WIDTH)

 `define MUON_TRIG_DELAY_EXTRA 10
 `define MUON_TRIG_PIPELINE_DLY (`MUON_TRIG_DELAY_MAX+`MUON_TRIG_COINC_OVLP_MAX+`MUON_TRIG_CONSEC_BINS_MAX+`MUON_TRIG_DELAY_EXTRA)
 `define MUON_EXT_TRIG_DELAY 20
 `define MUON_BURST_LEN 70      // # of bins to save for each muon

`define MUON_BUF_TIME_TAG_A_ADDR 160
`define MUON_BUF_TIME_TAG_B_ADDR 161
`define MUON_BUF_TRIG_MASK_ADDR 162
  `define MUON_BUF_TRIG_SB1_SHIFT 0
  `define MUON_BUF_TRIG_SB2_SHIFT 1
  // `define MUON_BUF_TRIG_SB3_SHIFT 2
  // `define MUON_BUF_TRIG_SB4_SHIFT 3
  `define MUON_BUF_TRIG_EXT_SHIFT 4
  `define MUON_BUF_SIPM_CAL_SHIFT 5
  `define MUON_BUF_TRIG_SB1 (1 << `MUON_BUF_TRIG_SB1_SHIFT)
  `define MUON_BUF_TRIG_SB2 (1 << `MUON_BUF_TRIG_SB2_SHIFT)
  // `define MUON_BUF_TRIG_SB3 (1 << `MUON_BUF_TRIG_SB3_SHIFT)
  // `define MUON_BUF_TRIG_SB4 (1 << `MUON_BUF_TRIG_SB4_SHIFT)
  `define MUON_BUF_TRIG_EXT (1 << `MUON_BUF_TRIG_EXT_SHIFT)
  `define MUON_BUF_SIPM_CAL (1 << `MUON_BUF_SIPM_CAL_SHIFT)
  `define MUON_NUM_TRIGS 5  // Don't include SIPM_CAL
  `define MUON_BUF_TRIG_BITS_MASK ((1<<`MUON_BUF_NUM_TRIGS)-1)
`define MUON_BUF_CONTROL_ADDR 163
`define MUON_BUF_STATUS_ADDR 164
 `define MUON_BUF_RNUM_MASK ((1<<`MUON_BUF_NUM_WIDTH)-1)
 `define MUON_BUF_RNUM_SHIFT 0
 `define MUON_BUF_WNUM_MASK ((1<<`MUON_BUF_NUM_WIDTH)-1)
 `define MUON_BUF_WNUM_SHIFT (`MUON_BUF_RNUM_SHIFT+`MUON_BUF_NUM_WIDTH)
 `define MUON_BUF_FULL_MASK ((1<<`MUON_MEM_NBUF)-1)
 `define MUON_BUF_FULL_SHIFT (`MUON_BUF_WNUM_SHIFT+`MUON_BUF_NUM_WIDTH)
 `define MUON_INTR_PEND_MASK 1
 `define MUON_INTR_PEND_SHIFT (`MUON_BUF_FULL_SHIFT+`MUON_MEM_NBUF)
 `define MUON_BUF_NFULL_MASK ((1<<(`MUON_BUF_NUM_WIDTH+1))-1)
 `define MUON_BUF_NFULL_SHIFT (`MUON_INTR_PEND_SHIFT+1)
 `define MUON_BUF_NOTUSED_SHIFT (`MUON_BUF_NFULL_SHIFT+`MUON_BUF_NUM_WIDTH+1)
`define MUON_BUF_WORD_COUNT_ADDR 165
`define MUON_BUF_WORD_COUNT0_ADDR 166
`define MUON_BUF_WORD_COUNT1_ADDR 167
`define MUON_BUF_WORD_COUNT2_ADDR 168
`define MUON_BUF_WORD_COUNT3_ADDR 169

// Full bandwidth single bin trigger
`define SB_TRIG_THR0_ADDR 170
`define SB_TRIG_THR1_ADDR 171
`define SB_TRIG_THR2_ADDR 172
`define SB_TRIG_SSD_ADDR 173
`define SB_TRIG_ENAB_ADDR 174

 `define SB_TRIG_ENAB_SHIFT 0
 `define SB_TRIG_ENAB_WIDTH 4
 `define SB_TRIG_INCL_PMT0 (1<<`SB_TRIG_ENAB_SHIFT)
 `define SB_TRIG_INCL_PMT1 (2<<`SB_TRIG_ENAB_SHIFT)
 `define SB_TRIG_INCL_PMT2 (4<<`SB_TRIG_ENAB_SHIFT)
 `define SB_TRIG_INCL_SSD (8<<`SB_TRIG_ENAB_SHIFT)
 `define SB_TRIG_COINC_LVL_SHIFT `SB_TRIG_ENAB_WIDTH
 `define SB_TRIG_COINC_LVL_WIDTH 3
 `define SB_TRIG_COINC_LVL_MASK ((1<<`SB_TRIG_COINC_LVL_WIDTH)-1)
 `define SB_TRIG_DELAY_WIDTH 3
 `define SB_TRIG_DELAY_MASK ((1<<`SB_TRIG_DELAY_WIDTH)-1)
 `define SB_TRIG_DELAY_MAX (1<<`SB_TRIG_DELAY_WIDTH)
 `define SB_TRIG_SSD_DELAY_SHIFT  (`SB_TRIG_COINC_LVL_SHIFT+`SB_TRIG_COINC_LVL_WIDTH)
 `define SB_TRIG_COINC_OVLP_WIDTH 3
 `define SB_TRIG_COINC_OVLP_MASK ((1<<`SB_TRIG_COINC_OVLP_WIDTH)-1)
 `define SB_TRIG_COINC_OVLP_MAX ((1<<`SB_TRIG_COINC_OVLP_WIDTH)-1)
 `define SB_TRIG_COINC_OVLP_SHIFT (`SB_TRIG_SSD_DELAY_SHIFT+`SB_TRIG_DELAY_WIDTH)    
 `define SB_TRIG_CONSEC_BINS_WIDTH 3
 `define SB_TRIG_CONSEC_BINS_MASK ((1<<`SB_TRIG_CONSEC_BINS_WIDTH)-1)
 `define SB_TRIG_CONSEC_BINS_MAX ((1<<`SB_TRIG_CONSEC_BINS_WIDTH)-1)
 `define SB_TRIG_CONSEC_BINS_SHIFT (`SB_TRIG_COINC_OVLP_SHIFT+`SB_TRIG_COINC_OVLP_WIDTH)
 `define SB_TRIG_SSD_AND_SHIFT (`SB_TRIG_CONSEC_BINS_SHIFT+`SB_TRIG_CONSEC_BINS_WIDTH)

// Registers containing the peak and integral of each ADC trace for the current
// shower buffer.
`define SHWR_PEAK_AREA0_ADDR 180
`define SHWR_PEAK_AREA1_ADDR 181
`define SHWR_PEAK_AREA2_ADDR 182
`define SHWR_PEAK_AREA3_ADDR 183
`define SHWR_PEAK_AREA4_ADDR 184
`define SHWR_PEAK_AREA5_ADDR 185
`define SHWR_PEAK_AREA6_ADDR 186
`define SHWR_PEAK_AREA7_ADDR 187
`define SHWR_PEAK_AREA8_ADDR 188
`define SHWR_PEAK_AREA9_ADDR 189
 `define SHWR_AREA_FRAC_WIDTH 14
 `define SHWR_AREA_WIDTH 19
 `define SHWR_AREA_SHIFT 0
 `define SHWR_AREA_MASK ((1<<`SHWR_AREA_WIDTH)-1)
 `define SHWR_PEAK_SHIFT (`SHWR_AREA_WIDTH)
 `define SHWR_PEAK_MASK ((1<<`ADC_WIDTH)-1)
 `define SHWR_SATURATED_SHIFT 31
 `define SHWR_SATURATED (1<<`SHWR_SATURATED_SHIFT)
 `define SHWR_SATURATED_LEVEL ((1<<`ADC_WIDTH)-1)
 `define SHWR_AREA_BINS 100
 `define SHWR_AREA_ADC_DLY 20  // Delay to compensate for trigger formation dly
`define SHWR_BASELINE0_ADDR 190
`define SHWR_BASELINE1_ADDR 191
`define SHWR_BASELINE2_ADDR 192
`define SHWR_BASELINE3_ADDR 193
`define SHWR_BASELINE4_ADDR 194
 `define SHWR_BASELINE_EXTRA_BITS 4
 `define BASELINE_EXTRA_BITS 4
 `define BASELINE_FRAC_INCR 8    // ~Step size when following baseline
 `define BASELINE_FRAC_WIDTH 20  // Extra bits when computing baseline sag
 `define BASELINEL_SAG_SHIFT1 15 // Frac. multipliers to account for RC decay
 `define BASELINEL_SAG_SHIFT2 20 // Set for 1000 nF front-end block cap.
 `define BASELINEL_SAG_SHIFT3 21 // Low gain channels - 274 Ohm input
 `define BASELINEH_SAG_SHIFT1 14 // High gain channels - 100 Ohm input
 `define BASELINEH_SAG_SHIFT2 16 
 `define BASELINEH_SAG_SHIFT3 17 

// Addresses to sample instantaneous filtered PMT values for setup, test, etc.
`define FILT_PMT0_TEST_ADDR 247
`define FILT_PMT1_TEST_ADDR 248
`define FILT_PMT2_TEST_ADDR 249

// Addresses to sample instantaneous ADC values for setup, test, debug.
`define ADC0_TEST_ADDR 250
`define ADC1_TEST_ADDR 251
`define ADC2_TEST_ADDR 252 
`define ADC3_TEST_ADDR 253
`define ADC4_TEST_ADDR 254

`define LED_CONTROL_ADDR 255
 `define LED_NOW 1 
 `define LED_ENAPPS_SHIFT 1
 `define LED_ENAPPS (1<<`LED_ENAPPS_SHIFT)
 `define LED_DELAY_SHIFT 2
 `define LED_DELAY_WIDTH 17
 `define LED_DELAY_MASK ((1<<`LED_DELAY_WIDTH)-1)
 `define LED_PULSWID_SHIFT (`LED_DELAY_SHIFT+`LED_DELAY_WIDTH)
 `define LED_PULSWID_WIDTH 11
 `define LED_PULSWID_MASK ((1<<`LED_PULSWID_WIDTH)-1)
 `define LED_FLAG_DURATION 1500
 `define LED_FLAG_DELAY 82

`endif // `ifndef _TRIGGER_DEFS
