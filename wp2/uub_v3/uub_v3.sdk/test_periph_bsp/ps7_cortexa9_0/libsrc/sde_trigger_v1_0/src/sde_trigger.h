
#ifndef SDE_TRIGGER_H
#define SDE_TRIGGER_H

// 28-May-2015 DFN Add Interrupt API.
// 07-Jun-2016 DFN Added work around for missing entries in xparameters.h.
//                 Note that xparameters.h must be included before this
//                 header file in application programs.
// 29-Apr-2018 DFN Modify for separate shower & muon interrupts

/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xparameters.h"

#define SDE_TRIGGER_GLOBAL_INTR_EN_OFFSET 0
#define SDE_TRIGGER_INTR_EN_OFFSET 4
#define SDE_TRIGGER_INTR_STATUS_OFFSET 8
#define SDE_TRIGGER_INTR_ACK_OFFSET 12
#define SDE_TRIGGER_INTR_PENDING_OFFSET 16

#ifndef INTR_GLOBAL_EN_ADDR
 #define INTR_GLOBAL_EN_ADDR 0
#endif
#ifndef INTR_EN_ADDR
 #define INTR_EN_ADDR 1
#endif
#ifndef INTR_STATUS_ADDR
 #define INTR_STATUS_ADDR 2
#endif
#ifndef INTR_ACK_ADDR
 #define INTR_ACK_ADDR 3
#endif
#ifndef INTR_PENDING_ADDR
 #define INTR_PENDING_ADDR 4
#endif

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a SDE_TRIGGER register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the SDE_TRIGGERdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void SDE_TRIGGER_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
  #define SDE_TRIGGER_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
/**
 *
 * Read a value from a SDE_TRIGGER register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the SDE_TRIGGER device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 SDE_TRIGGER_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
  #define SDE_TRIGGER_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the SDE_TRIGGER instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus SDE_TRIGGER_Reg_SelfTest(void * baseaddr_p);

/**
 * Interrupt API
 */
void SDE_TRIGGER_EnableInterrupts(void * baseaddr_p, u32 data);
void SDE_TRIGGER_ACK(void * baseaddr_p, u32 data);

// Do to a bug in Vivado 15.2, some IP addresses are not transferred to 
// xparameters.h.  We try to work around that below. 

//#ifdef XPAR_CPU_ID  // Proxy for xparameters.h already included

#ifndef XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S_AXI_INTR_BASEADDR
  #define XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S_AXI_INTR_BASEADDR 0x43c10000
#endif

#ifndef XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S1_AXI_INTR_BASEADDR
  #define XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S1_AXI_INTR_BASEADDR 0x43c50000
#endif

#ifndef SDE_SHWR_TRIGGER_INTR_BASE
 #define SDE_SHWR_TRIGGER_INTR_BASE XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S_AXI_INTR_BASEADDR
#endif

#ifndef SDE_MUON_TRIGGER_INTR_BASE
 #define SDE_MUON_TRIGGER_INTR_BASE XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S1_AXI_INTR_BASEADDR
#endif

#ifndef SDE_TRIGGER_BASE
  #define SDE_TRIGGER_BASE XPAR_TRIGGER_MEMORY_BLOCK_SDE_TRIGGER_0_S00_AXI_BASEADDR
#endif

#ifndef TRIGGER_MEMORY_MUON0_BASE
  #define TRIGGER_MEMORY_MUON0_BASE 0x40000000
#endif

#ifndef TRIGGER_MEMORY_MUON1_BASE
  #define TRIGGER_MEMORY_MUON1_BASE 0x42000000
#endif

#ifndef TRIGGER_MEMORY_SHWR0_BASE
  #define TRIGGER_MEMORY_SHWR0_BASE 0x44000000
#endif

#ifndef TRIGGER_MEMORY_SHWR1_BASE
  #define TRIGGER_MEMORY_SHWR1_BASE 0x46000000
#endif

#ifndef TRIGGER_MEMORY_SHWR2_BASE
  #define TRIGGER_MEMORY_SHWR2_BASE 0x48000000
#endif

#ifndef TRIGGER_MEMORY_SHWR3_BASE
  #define TRIGGER_MEMORY_SHWR3_BASE 0x4A000000
#endif

#ifndef TRIGGER_MEMORY_SHWR4_BASE
  #define TRIGGER_MEMORY_SHWR4_BASE 0x4C000000
#endif


//#endif // XPAR_CPU_ID

#endif // SDE_TRIGGER_H
