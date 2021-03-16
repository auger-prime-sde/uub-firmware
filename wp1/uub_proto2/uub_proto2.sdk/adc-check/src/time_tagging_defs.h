// Global definitions for the time_tagging module.  This could or should
// be located in the time_tagging ip directory, but didn't want to make
// any modifications to that project.  This had been included in the
// sde_trigger_defs.vh but is now put in a separate file to facilitate
// including one but not the other.
// 
// 16-Sep-16 DFN Initial version

#ifndef _TIME_TAGGING_DEFS
#define _TIME_TAGGING_DEFS

// For convenience, define "Addresses" of time tagging registers relative
// to the time tagging module base address.

#define TTAG_SHWR_TICS_ADDR 0
#define TTAG_SHWR_SECONDS_ADDR 1
#define TTAG_SHWR_PPS_TICS_ADDR 2
#define TTAG_SHWR_PPS_CAL_ADDR 3
#define TTAG_MUON_TICS_ADDR 4
#define TTAG_MUON_SECONDS_ADDR 5
#define TTAG_MUON_PPS_TICS_ADDR 6
#define TTAG_MUON_PPS_CAL_ADDR 7
#define TTAG_PPS_SECONDS_ADDR 8
#define TTAG_PPS_TICS_ADDR 9
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

#define TTAG_TICS_MASK ((1<<27)-1)
#define TTAG_SECONDS_MASK ((1<<28)-1)
#define TTAG_EVTCTR_MASK 0xf
#define TTAG_EVTCTR_SHIFT 28

#endif // #ifndef _TIME_TAGGING_DEFS
