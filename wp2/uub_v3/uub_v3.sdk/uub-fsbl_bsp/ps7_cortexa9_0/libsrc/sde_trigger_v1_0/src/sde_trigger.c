

/***************************** Include Files *******************************/
#include "sde_trigger.h"

/************************** Function Definitions ***************************/

void SDE_TRIGGER_EnableInterrupts(void * baseaddr_p, u32 data)
{
  u32 baseaddr;

  baseaddr = (u32) baseaddr_p;

  // Enable selected set of sources (shower trigger and/or muon trigger)
  SDE_TRIGGER_mWriteReg(baseaddr,SDE_TRIGGER_INTR_EN_OFFSET,data);

  // Set (sde_trigger) global interrupt enable
  SDE_TRIGGER_mWriteReg(baseaddr,SDE_TRIGGER_GLOBAL_INTR_EN_OFFSET,1);
}

void SDE_TRIGGER_ACK(void * baseaddr_p, u32 data)
{
  u32 baseaddr;

  baseaddr = (u32) baseaddr_p;

  // ACK the interrupt
  SDE_TRIGGER_mWriteReg(baseaddr,SDE_TRIGGER_INTR_ACK_OFFSET,data);
}
