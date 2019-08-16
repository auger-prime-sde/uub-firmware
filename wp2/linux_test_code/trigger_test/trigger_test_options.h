// Header file to set options for for test routine to interact with the
// sde_trigger PL.  This file will be different for Linux & Standalone
// versions, allowing trigger_test.h to be common.
//
// 06-Feb-2017 DFN Initial version extracted from trigger_test.h
// 17-May-2018 DFN Add compatibility tot trigger option
// 26-Jun-2018 DFN Add compatibility totd trigger option


//#define STAND_ALONE
#define MAX_EVENTS 1000
//#define CHECK_MISSING_EVENT
//#define EXT_IN_PERIOD 0.1
#define EXT_IN_TOLERANCE 0.01
#define EVENT_COUNT_INTERVAL 1000
//#define VERBOSE_BUFFERS  // Print more buffer status if set

//#define ADJUST_BASELINE
//#define TOGGLE_WATCHDOG
//#define TOGGLE_ADCPWD
//#define USE_FAKE_MUON
//#define USE_FAKE_SIGNAL
#define PMT0_DLY 0
#define PMT1_DLY 0
#define PMT2_DLY 0
#define FAKE_SIGNAL_WIDTH 30
#define SIGNAL_HT 3000
#define EXP_DECAY 0
#define FAKE_SIGNAL_MODE (7 | (PMT0_DLY<<5) | (PMT1_DLY<<7) | (PMT2_DLY<<9) | (FAKE_SIGNAL_WIDTH<<11) | (EXP_DECAY<<19) | (SIGNAL_HT<<20))
//#define RAMP
#define USE_FAKE_GPS
//#define DO_LED_PULSE
//#define DO_LED_NOW
#define LED_DELAY0 50
#define LED_DELAY1 100
#define LED_PULSWID0 10
#define LED_PULSWID1 20

#define TRIG_THR0 3000
#define TRIG_THR1 3000
#define TRIG_THR2 3000
#define TRIG_SSD 4095
#define LPMT_THR0 0000   // Software large PMT threshold for small PMT cal
#define LPMT_THR1 0000
#define LPMT_THR2 0000

#define SHWR_TRIGGERS

#ifdef SHWR_TRIGGERS 
 // #define COMPAT_SB_TRIGGER
 // #define COMPAT_TOT_TRIGGER
 // #define COMPAT_TOT_TRIG_OCC 1
 //  #define COMPAT_TOTD_TRIGGER
 //  #define COMPAT_TOTD_TRIG_OCC 1
  //   #define COMPAT_TOTD_FD 42  // 60ns decay constant
  //   #define COMPAT_TOTD_FN 47
     #define COMPAT_TOTD_FD 32  // 17ns decay constant
     #define COMPAT_TOTD_FN 32
     #define COMPAT_TOTD_UP0 4095
     #define COMPAT_TOTD_UP1 4095
     #define COMPAT_TOTD_UP2 4095
     #define COMPAT_TOTD_INT  5
  #define SB_TRIGGER
//  #define SSD_AND	
  #define SB_COINC_LVL 1
  #define SB_COINC_OVLP 3
  #define SB_CONSEC_BINS 0
  #define SSD_DELAY 0
//  #define EXT_TRIGGER
//  #define PRESCALE_EXT_TRIGGER
//  #define PRESCALE_COMPAT_SB_TRIGGER
//  #define LED_TRIGGER
#endif
//#define MUON_TRIGGERS
//#define MUON_SIPM_CAL

// TRIGGGER_POLLED checks sde_trigger module status register for buffers
// to be read in a polling loop.  TRIGGER_INTERRUPT used an interrupt routine
// to process any full buffers.  TRIGGER_POLLED is the only option that
// works in Linux currently.
#define TRIGGER_POLLED
//#define TRIGGER_INTERRUPT

// PDT mode. Read shower/muon buffers using simple memory mapped access.
// This is the only option that works in Linux currently.
 #define PDT

// If DMA & SIMPLE are defined then readout polls for completion of read from 
// each of the memory blocks before continuing.  This is sufficient to test
// DMA operatation but it not intended as a model for use.  DMA_INTERRUPT
// is not implemented in this program for the simple DMA mode.
//
// If DMA && SCATTER_GATHER are defined then all of the memory blocks for an
// event are read in one DMA operation.  If in addition, DMA_INTERRUPT is
// is defined, the DMA completion invokes an interrupt routine to finish
// processing the event, otherwise the readout polls for completion of the
// the DMA operation.
//#define DMA
//#define SIMPLE
//#define SCATTER_GATHER
//#define DMA_INTERRUPT






