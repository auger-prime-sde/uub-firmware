// Module to get data transfers from the RD detector.
//
// 31-Jan-2019 DFN Initial version


`define ADDR_BITS 10 // Number of address bits for event memory
`define MEM_SIZE 2048

// Status register bit usage
`define BUF_WRT_MASK 0x3 // Curent buffer number writing to
`define BUF_WRT_SHIFT 0 // Shift to current active buffer
`define BUF_RD_MASK 0x3 // Buffer to read from mask
`define BUF_RD_SHIFT 2 // Shift to buffer to read from buffer

`define BUF_FULL_MASK 0xf // Full buffer bits
`define BUF_FULL_SHIFT 4  // Shift to full buffer bits
`define PARITY0_MASK 0xf  // Parity error corresponding in buffer if set
`define PARITY0_SHIFT 8
`define PARITY1_MASK 0xf  // Parity error corresponding in buffer if set
`define PARITY1_SHIFT 12

// Control register bit usage
`define BUF_RESET_MASK  0x3 // Buffer number to reset to empty
`define BUF_RESET_SHIFT 0

module rd_interface
  (
   input wire SERIAL_DATA0_IN,
   input wire SERIAL_DATA1_IN,
   input wire SERIAL_CLK_IN,
   input wire ENABLE_XFR_IN,
   input wire [1:0] BUF_NUM,
   input wire TRIG_IN,
   input wire[31:0] AXI_CONTROL,
   input wire AXI_CONTROL_WRITTEN,
   output reg[31:0] STATUS,

   output reg[31:0] DATA_ADDR,
   output reg[31:0] DATA_TO_MEM,
   output reg ENABLE_MEM_WRT,
   output reg DEBUG1,
   output reg DEBUG2
   );
   

   reg [3:0]  SERIAL_IN_BIT_COUNT;
   reg        LOCAL_XFR_DONE;
   reg        PREV_ENABLE_XFR_IN;
   reg [31:0] NEXT_DATA_ADDR;
   reg        PARITY0;
   reg        PARITY1;
   reg [11:0] DATA0;
   reg [11:0] DATA1;
   wire [31:0] LCL_CONTROL;
   reg [31:0]  LCL_STATUS;
   wire        LCL_TRIG_IN;
   reg [1:0]   LCL_BUF_NUM;


   rd_sync_1bit control_wrtsync(.ASYNC_IN(AXI_CONTROL_WRITTEN),
                                .CLK(SERIAL_CLK_IN),
                                .SYNC_OUT(LCL_CONTROL_WRITTEN));
   rd_sync_32bit control_sync(.ASYNC_IN(AXI_CONTROL),
                              .CLK(SERIAL_CLK_IN),
                              .SYNC_OUT(LCL_CONTROL));

   rd_sync_1bit trig_sync(.ASYNC_IN(TRIG_IN),
                          .CLK(SERIAL_CLK_IN),
                          .SYNC_OUT(LCL_TRIG_IN));




   // Get and store data from RD
   //   assign DEBUG1 = PREV_ENABLE_XFR_IN;
   //   assign DEBUG2 = LOCAL_XFR_DONE;

   always @(posedge SERIAL_CLK_IN)
     begin
        PREV_ENABLE_XFR_IN <= ENABLE_XFR_IN;
        
        // Grab serial data
        // High order bit is 1st and parity bit is last
        if (ENABLE_XFR_IN)
          begin
             if (~PREV_ENABLE_XFR_IN)
               SERIAL_IN_BIT_COUNT <= 0;
             
             if (SERIAL_IN_BIT_COUNT <12)
               begin
                  DATA0[12-SERIAL_IN_BIT_COUNT] <= SERIAL_DATA0_IN;
                  DATA1[12-SERIAL_IN_BIT_COUNT] <= SERIAL_DATA1_IN;
                  SERIAL_IN_BIT_COUNT <= SERIAL_IN_BIT_COUNT+1;
                  PARITY0 = PARITY0+SERIAL_DATA0_IN;
                  PARITY1 = PARITY1+SERIAL_DATA1_IN;
               end
             if (SERIAL_IN_BIT_COUNT == 12)
               begin
                  // Parity should be odd, so equality means parity error
                  if (SERIAL_DATA0_IN == PARITY0)
                    LCL_STATUS[`PARITY0_SHIFT+BUF_NUM] <= 1;
                  if (SERIAL_DATA1_IN == PARITY1)
                    LCL_STATUS[`PARITY1_SHIFT+BUF_NUM] <= 1;

                  // Write data to memory
                  DATA_TO_MEM[11:0] <= DATA0;
                  DATA_TO_MEM[27:16] <= DATA1;
                  ENABLE_MEM_WRT <= 1;
                  DATA_ADDR[12:0] <= NEXT_DATA_ADDR;
                  DATA_ADDR[31:13] <= LCL_BUF_NUM;
                  NEXT_DATA_ADDR <= NEXT_DATA_ADDR+4;

                  // Prepare for next word
                  SERIAL_IN_BIT_COUNT <= 0;
                  
               end // if (SERIAL_IN_BIT_COUNT == 12)
          end // if (ENABLE_XFER_IN)
        else  // ENABLE_XFR_IN not set
          begin
             // Have we just finished loading a buffer?
             if (PREV_ENABLE_XFR_IN)
               LCL_STATUS[`BUF_FULL_SHIFT+LCL_BUF_NUM] <= 1;
          end // else: !if(ENABLE_XFER_IN)
        
        // Remember which buffer we are writing this trigger to
        // This won't work because we can get anoter trigger while still writing
        // Previous buffer.  Need to do something else here.
        if (LCL_TRIG_IN)
          begin
             LCL_BUF_NUM <= BUF_NUM;
             NEXT_DATA_ADDR <= 0;
             // Reset parity error indicators
             LCL_STATUS[`PARITY1_SHIFT+BUF_NUM] <= 0;
          end
     end // always @ (posedge SERIAL_CLK_IN)
endmodule // rd_interface


