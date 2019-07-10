// Header file for module to get data transfers from the RD detector.
//
// 12-Feb-2019 DFN Initial version as separate file
// 03-Mar-2019 DFN Add ID register
// 06-Jul-2019 DFN Add Reset register

// RD interface register assignments
`define RD_IFC_CONTROL_ADDR 0
`define RD_IFC_STATUS_ADDR 1
`define RD_IFC_ID_ADDR 2
`define RD_IFC_RESET_ADDR 3

// Status register bit usage
`define RD_BUF_RNUM_WIDTH 2
`define RD_BUF_RNUM_MASK 0x3 // Buffer to read from mask
`define RD_BUF_RNUM_SHIFT 0 // Shift to buffer to read from buffer
`define RD_BUF_WNUM_WIDTH 2
`define RD_BUF_WNUM_MASK 0x3 // Curent buffer number writing to
`define RD_BUF_WNUM_SHIFT (`RD_BUF_RNUM_SHIFT+`RD_BUF_RNUM_WIDTH)
`define RD_BUF_BUSY_WIDTH 4
`define RD_BUF_BUSY_MASK 0xf // Busy (current transfer) buffer bits
`define RD_BUF_BUSY_SHIFT (`RD_BUF_WNUM_SHIFT+`RD_BUF_WNUM_WIDTH)
`define RD_BUF_FULL_WIDTH 4
`define RD_BUF_FULL_MASK 0xf // Full buffer bits
`define RD_BUF_FULL_SHIFT (`RD_BUF_BUSY_SHIFT+`RD_BUF_BUSY_WIDTH)
`define RD_PARITY0_WIDTH 4
`define RD_PARITY0_MASK 0xf  // Parity error corresponding in buffer if set
`define RD_PARITY0_SHIFT (`RD_BUF_FULL_SHIFT+`RD_BUF_FULL_WIDTH)
`define RD_PARITY1_WIDTH 4
`define RD_PARITY1_MASK 0xf  // Parity error corresponding in buffer if set
`define RD_PARITY1_SHIFT (`RD_PARITY0_SHIFT+`RD_PARITY0_WIDTH)

// Control register bit usage
`define RD_BUF_RESET_MASK  0x3 // Buffer number to reset to empty
`define RD_BUF_RESET_SHIFT 0


