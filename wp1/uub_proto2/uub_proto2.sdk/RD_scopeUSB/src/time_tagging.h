
#ifndef TIME_TAGGING_H
#define TIME_TAGGING_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define TIME_TAGGING_S00_AXI_SLV_REG0_OFFSET 0
#define TIME_TAGGING_S00_AXI_SLV_REG1_OFFSET 4
#define TIME_TAGGING_S00_AXI_SLV_REG2_OFFSET 8
#define TIME_TAGGING_S00_AXI_SLV_REG3_OFFSET 12
#define TIME_TAGGING_S00_AXI_SLV_REG4_OFFSET 16
#define TIME_TAGGING_S00_AXI_SLV_REG5_OFFSET 20
#define TIME_TAGGING_S00_AXI_SLV_REG6_OFFSET 24
#define TIME_TAGGING_S00_AXI_SLV_REG7_OFFSET 28
#define TIME_TAGGING_S00_AXI_SLV_REG8_OFFSET 32
#define TIME_TAGGING_S00_AXI_SLV_REG9_OFFSET 36
#define TIME_TAGGING_S00_AXI_SLV_REG10_OFFSET 40
#define TIME_TAGGING_S00_AXI_SLV_REG11_OFFSET 44
#define TIME_TAGGING_S00_AXI_SLV_REG12_OFFSET 48
#define TIME_TAGGING_S00_AXI_SLV_REG13_OFFSET 52
#define TIME_TAGGING_S00_AXI_SLV_REG14_OFFSET 56
#define TIME_TAGGING_S00_AXI_SLV_REG15_OFFSET 60

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



/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a TIME_TAGGING register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the TIME_TAGGINGdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void TIME_TAGGING_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define TIME_TAGGING_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a TIME_TAGGING register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the TIME_TAGGING device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 TIME_TAGGING_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define TIME_TAGGING_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset) )

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the TIME_TAGGING instance to be worked on.
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
XStatus TIME_TAGGING_Reg_SelfTest(void * baseaddr_p);

#ifndef TIME_TAGGING_BASE
  #define TIME_TAGGING_BASE XPAR_TIME_TAGGING_0_S00_AXI_BASEADDR
#endif

#endif // TIME_TAGGING_H
