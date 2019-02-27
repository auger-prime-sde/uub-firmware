// Header file for simple standalone test routine to interact with the
// radio detector interface PL.
//
// 02-Nov-2018 DFN Initial version


#include <stdio.h>
#include "sde_trigger_defs.h"
#include "sde_trigger.h"
#include "time_tagging_defs.h"
#include "time_tagging.h"
#include "test_control_defs.h"
#include "test_control.h"
#include "xparameters.h"  // Peripheral parameters (GPIO addresses, etc.)
#include "xil_types.h"

#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

void map_ttag();

#define MAX_EVENTS 10
#define USE_FAKE_GPS

extern volatile u32 *ttag_intr_regs;
extern volatile u32 *tstctl_regs;
extern volatile u32 *trig_regs;

#define write_ttag_intr(RegNumber, Data) ttag_intr_regs[RegNumber] = Data
#define read_ttag_intr(RegNumber) ttag_intr_regs[RegNumber]
#define write_tstctl(RegNumber, Data) tstctl_regs[RegNumber] = Data
#define read_tstctl(RegNumber) tstctl_regs[RegNumber]
#define write_trig(RegNumber, Data) trig_regs[RegNumber] = Data
#define read_trig(RegNumber) trig_regs[RegNumber]

