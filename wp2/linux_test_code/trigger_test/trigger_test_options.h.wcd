// Header file to set options for for test routine to interact with the
// sde_trigger PL.  This file will be different for Linux & Standalone
// versions, allowing trigger_test.h to be common.
//
// 06-Feb-2017 DFN Initial version extracted from trigger_test.h
// 17-May-2018 DFN Add compatibility tot trigger option
// 26-Jun-2018 DFN Add compatibility totd trigger option
// 04-Nov-2019 DFN Add MoPS and Random trigger options
// 13-Mar-2020 DFN Add symbolic TEST_CONTROL bits


//#define STAND_ALONE
#define MAX_EVENTS 10000
//#define CHECK_MISSING_EVENT
//#define EXT_IN_PERIOD 0.1
#define EXT_IN_TOLERANCE 0.01
#define EVENT_COUNT_INTERVAL 5000
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
#define FAKE_SIGNAL_MODE (8 | (PMT0_DLY<<5) | (PMT1_DLY<<7) | (PMT2_DLY<<9) | (FAKE_SIGNAL_WIDTH<<11) | (EXP_DECAY<<19) | (SIGNAL_HT<<20))
//#define RAMP
#define USE_FAKE_GPS
#define USE_TRIG_OUT_PATTERN

//#define DO_LED_PULSE
//#define DO_LED_NOW
#define LED_DELAY0 50
#define LED_DELAY1 100
#define LED_PULSWID0 10
#define LED_PULSWID1 20

#define TRIG_THR0 2000
#define TRIG_THR1 3000
#define TRIG_THR2 3000
#define TRIG_SSD 4095
#define LPMT_THR0 0000   // Software large PMT threshold for small PMT cal
#define LPMT_THR1 0000
#define LPMT_THR2 0000

#define SHWR_TRIGGERS

#ifdef SHWR_TRIGGERS 
  #define COMPAT_SB_TRIGGER
//    #define COMPAT_SB_TRIG_2BINS
 // #define COMPAT_TOT_TRIGGER
 // #define COMPAT_TOT_TRIG_OCC 10
 // #define COMPAT_TOTD_TRIGGER
 // #define COMPAT_TOTD_TRIG_OCC 1
  // #define COMPAT_TOTD_FD 42  // 60ns decay constant
  // #define COMPAT_TOTD_FN 47
     #define COMPAT_TOTD_FD 32  // 17ns decay constant
     #define COMPAT_TOTD_FN 32
     #define COMPAT_TOTD_UP0 4095
     #define COMPAT_TOTD_UP1 4095
     #define COMPAT_TOTD_UP2 4095
     #define COMPAT_TOTD_INT  5
//  #define SB_TRIGGER
//  #define SSD_AND	
  #define SB_COINC_LVL 1
  #define SB_COINC_OVLP 3
  #define SB_CONSEC_BINS 0
  #define SSD_DELAY 0
//  #define EXT_TRIGGER
//  #define PRESCALE_EXT_TRIGGER
//  #define PRESCALE_COMPAT_SB_TRIGGER
//  #define LED_TRIGGER
// #define COMPAT_MOPS_TRIGGER
  #define COMPAT_MOPS_MIN 12
  #define COMPAT_MOPS_MAX 124
  #define COMPAT_MOPS_INT 120
  #define COMPAT_MOPS_OCC 3
  #define COMPAT_MOPS_OFS 3
//  #define RNDM_TRIGGER
// Modes 1=10ms 2=100ms 3=1s, 4=10s, 5=100s, 6=200s, 7=400s, 8=800s
// 11, 15, 18, 21, 22, 23, 25, 28, 31 pseudo random delays
//  #define RNDM_MODE 2
//  #define ROTATE_RNDM // Rotate through 3-8 if defined
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






