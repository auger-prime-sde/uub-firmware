
#ifndef RD_INTERFACE_H
#define RD_INTERFACE_H

// 27-Mar-2020 DFN Define more explicly RD memory address.

/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define RD_INTERFACE_S00_AXI_SLV_REG0_OFFSET 0
#define RD_INTERFACE_S00_AXI_SLV_REG1_OFFSET 4
#define RD_INTERFACE_S00_AXI_SLV_REG2_OFFSET 8
#define RD_INTERFACE_S00_AXI_SLV_REG3_OFFSET 12


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a RD_INTERFACE register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the RD_INTERFACEdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void RD_INTERFACE_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define RD_INTERFACE_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a RD_INTERFACE register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the RD_INTERFACE device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 RD_INTERFACE_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define RD_INTERFACE_mReadReg(BaseAddress, RegOffset) \
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
 * @param   baseaddr_p is the base address of the RD_INTERFACE instance to be worked on.
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
XStatus RD_INTERFACE_Reg_SelfTest(void * baseaddr_p);

// 21-Feb-2019 DFN Define shortcuts to base addresses

#ifndef RD_BASE
  #define RD_BASE XPAR_RD_BLOCK_RD_INTERFACE_0_S00_AXI_BASEADDR
#endif

#ifndef RD_EVENT_BASE
  #define RD_EVENT_BASE  0x80000000
#endif

#endif // RD_INTERFACE_H
