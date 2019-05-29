// Module to get data transfers from the RD detector.
//
// Sequence of operations:
//  > Receive trigger from trigger module
//  > If not in middle of transfer, save current write buffer number and 
//    pass trigger on to RD
//  > Get ENABLE_XFR from RD, mark buffer as busy
//  > Transfer all data
//  > Get end of ENABLE_XFR, mark buffer as full and not busy
//
// Some time later:
//  > Transfer WCD & SSD data to processor
//  > Check if same buffer number is full for RD
//  > If not full, but busy, wait a short while, otherwise skip to last step
//  > Transfer RD data to processor
//  > Reset RD buffer full status
//  > Reset WCD buffer full status
//
// 31-Jan-2019 DFN Initial version
// 05-Mar-2019 DFN Correct error - missing PARITY reset
// 13-May-2019 Sjoerd T. Timmer: keep parity bits in output

`include "rd_interface_defs.vh"

module rd_interface
  (
   input wire SERIAL_DATA0_IN,
   input wire SERIAL_DATA1_IN,
   input wire SERIAL_CLK_IN,
   input wire ENABLE_XFR_IN,
   input wire [1:0] BUF_WNUM,
   input wire [1:0] BUF_RNUM,
   input wire TRIG_IN,
   input wire[31:0] AXI_CONTROL,
   input wire AXI_CONTROL_WRITTEN,
   input wire RST,
   output reg[31:0] STATUS,
   output reg[31:0] DATA_ADDR,
   output reg[31:0] DATA_TO_MEM,
   output reg ENABLE_MEM_WRT,
   output wire TRIG_OUT,
   output reg DBG1,
   output reg DBG2
   );
   

   reg [3:0]  SERIAL_IN_BIT_COUNT;
   reg        PREV_ENABLE_XFR_IN;
   reg [31:0] NEXT_DATA_ADDR;
   reg        PARITY0;
   reg        PARITY1;
   reg        PARITY0_ERROR;
   reg        PARITY1_ERROR;
   reg [11:0] DATA0;
   reg [11:0] DATA1;
   wire [1:0] LCL_CONTROL;
   wire       LCL_TRIG_IN;
   reg [1:0]  LCL_BUF_NUM; // Current buffer writing
   reg        RD_BUSY;  // Set when transfer from RD is in progress
   reg        LCL_TRIG_OUT;
   
   


   rd_sync_1bit control_wrtsync(.ASYNC_IN(AXI_CONTROL_WRITTEN),
                                .CLK(SERIAL_CLK_IN),
                                .SYNC_OUT(LCL_CONTROL_WRITTEN));
   rd_sync_1bit control_sync0(.ASYNC_IN(AXI_CONTROL[0]),
                              .CLK(SERIAL_CLK_IN),
                              .SYNC_OUT(LCL_CONTROL[0]));
   rd_sync_1bit control_sync1(.ASYNC_IN(AXI_CONTROL[1]),
                              .CLK(SERIAL_CLK_IN),
                              .SYNC_OUT(LCL_CONTROL[1]));

   rd_sync_1bit trig_sync(.ASYNC_IN(TRIG_IN),
                          .CLK(SERIAL_CLK_IN),
                          .SYNC_OUT(LCL_TRIG_IN));
   stretch trig_stretch(.IN(LCL_TRIG_OUT),
                        .CLK(SERIAL_CLK_IN),
                        .OUT(TRIG_OUT));


   always @(posedge SERIAL_CLK_IN)
     if (RST)
       begin
          STATUS <= 0;
          PARITY0_ERROR <= 0;
          PARITY1_ERROR <= 0;
       end
     else
       begin
          
          DBG1 <= TRIG_OUT;
          DBG2 <= LCL_TRIG_IN;
          PREV_ENABLE_XFR_IN <= ENABLE_XFR_IN;
          STATUS[`RD_BUF_RNUM_SHIFT+1:`RD_BUF_RNUM_SHIFT] <= BUF_RNUM;
          
          if (LCL_CONTROL_WRITTEN)
            begin
               STATUS[`RD_BUF_FULL_SHIFT+LCL_CONTROL[`RD_BUF_RNUM_SHIFT+1:
                                                     `RD_BUF_RNUM_SHIFT]] <= 0;
            end
          
          // Grab serial data
          // High order bit is 1st and parity bit is last
          if (ENABLE_XFR_IN)
            begin
               if (~PREV_ENABLE_XFR_IN)
                 begin
                    RD_BUSY <= 1;
                    STATUS[`RD_BUF_BUSY_SHIFT+LCL_BUF_NUM] <= 1;
                 end
               
               if (SERIAL_IN_BIT_COUNT <12)
                 begin
                    DATA0[11-SERIAL_IN_BIT_COUNT] <= SERIAL_DATA0_IN;
                    DATA1[11-SERIAL_IN_BIT_COUNT] <= SERIAL_DATA1_IN;
                    PARITY0 <= PARITY0+SERIAL_DATA0_IN;
                    PARITY1 <= PARITY1+SERIAL_DATA1_IN;
                    ENABLE_MEM_WRT <= 0;
                    SERIAL_IN_BIT_COUNT <= SERIAL_IN_BIT_COUNT+1;
                 end
               if (SERIAL_IN_BIT_COUNT == 12)
                 begin
                    // Parity should be odd, so equality means parity error
                    if (SERIAL_DATA0_IN == PARITY0)
                      STATUS[`RD_PARITY0_SHIFT+LCL_BUF_NUM] <= 1;
                    if (SERIAL_DATA1_IN == PARITY1)
                      STATUS[`RD_PARITY1_SHIFT+LCL_BUF_NUM] <= 1;
                    PARITY0_ERROR <= SERIAL_DATA0_IN == PARITY0;
                    PARITY1_ERROR <= SERIAL_DATA1_IN == PARITY1;
                    
                    // Write data to memory
                    DATA_TO_MEM[12:1] <= DATA0;
                    DATA_TO_MEM[0] <= SERIAL_DATA0_IN;
                    DATA_TO_MEM[28:17] <= DATA1;
                    DATA_TO_MEM[16] <= SERIAL_DATA1_IN;
                    ENABLE_MEM_WRT <= 1;
                    DATA_ADDR[12:0] <= NEXT_DATA_ADDR;
                    DATA_ADDR[14:13] <= LCL_BUF_NUM;
                    NEXT_DATA_ADDR <= NEXT_DATA_ADDR+4;

                    // Prepare for next word
                    SERIAL_IN_BIT_COUNT <= 0;
                    PARITY0 <= 0;
                    PARITY1 <= 0;
                    
                 end // if (SERIAL_IN_BIT_COUNT == 12)
            end // if (ENABLE_XFER_IN)
          else  // ENABLE_XFR_IN not set
            begin
               RD_BUSY <= 0;  // Readout no longer busy
               ENABLE_MEM_WRT <= 0;  // Not writing to memory
               DATA_TO_MEM <= 0;
               DATA_ADDR <= 0;
               NEXT_DATA_ADDR <= 0;
               PARITY0 <= 0;
               PARITY1 <= 0;
               DATA0 <= 0;
               DATA1 <= 0;
               SERIAL_IN_BIT_COUNT <= 0;
               
               // Have we just finished loading a buffer? If so flag full.
               // Also mark no longer busy.
               if (PREV_ENABLE_XFR_IN)
                 begin
                    STATUS[`RD_BUF_FULL_SHIFT+LCL_BUF_NUM] <= 1;
                    STATUS[`RD_BUF_BUSY_SHIFT+LCL_BUF_NUM] <= 0;
                 end
            end // else: !if(ENABLE_XFER_IN)
          

          // We need to save buffer number we are writing this trigger to.  But
          // we also have to handle the case where another trigger occurs before
          // we have finished reading out the buffer from the RD.  We assume 
          // here the RD cannot both transfer and accept a new trigger.
          // So we need to also worry about interlocks.  
          
          if (LCL_TRIG_IN &&  !RD_BUSY)
            begin
               LCL_TRIG_OUT <= 1;
               LCL_BUF_NUM <= BUF_WNUM;
               STATUS[`RD_BUF_WNUM_SHIFT+1:`RD_BUF_WNUM_SHIFT] <= BUF_WNUM;
               NEXT_DATA_ADDR <= 0;

               // Reset parity error indicators
               STATUS[`RD_PARITY0_SHIFT+LCL_BUF_NUM] <= 0;
               STATUS[`RD_PARITY1_SHIFT+LCL_BUF_NUM] <= 0;
            end
          else
            LCL_TRIG_OUT <= 0;
       end // always @ (posedge SERIAL_CLK_IN)

endmodule // rd_interface


