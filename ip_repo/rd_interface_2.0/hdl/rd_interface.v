// Module to get data transfers from the RD detector.
//
// Sequence of operations:
//  > Receive trigger from trigger module
//  > If not in middle of transfer, save current write buffer number and 
//    pass trigger on to RD
//  > Get first clock from RD, mark buffer as busy
//  > Transfer all data
//  > Get last clock from RD, mark buffer as full and not busy
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
// 02-May-2019 DFN Version 2 without ENABLE_XFR (DATA_VALID) signal
// 06-Jul-2019 DFN Add local reset command
// 10-Jul-2019 DFN Add watchdog timer provided by Sjoerd
// 18-Jul-2019 DFN Added block against triggers for 25 clock cycles after
//                 end of transfer.
// 03-Dec-2019 DFN Increase block to 600 clock cycles. This is a quick
//                 kludge, not most efficient way to do it.
// 03-Dec-2019 DFN Add flag if timout occurred. May not be so easy to see,
//                 however.
// 23-Mar-2020 DFN Watchdog not working if not XFR clock. Change countdown
//                 enable from RD_BUSY120 to ENABLE_XFR120

`include "rd_interface_defs.vh"

module rd_interface
  (
   input wire SERIAL_DATA0_IN,
   input wire SERIAL_DATA1_IN,
   input wire SERIAL_CLK_IN,
   input wire CLK120,
   input wire [1:0] BUF_WNUM,
   input wire [1:0] BUF_RNUM,
   input wire TRIG_IN,
   input wire [31:0] AXI_CONTROL,
   input wire AXI_CONTROL_WRITTEN,
   input wire [31:0] AXI_RESET,
   input wire AXI_RESET_WRITTEN,
   input wire RST,
   output reg[31:0] STATUS,
   output reg[31:0] DATA_ADDR,
   output reg[31:0] DATA_TO_MEM,
   output reg ENABLE_MEM_WRT,
   output wire TRIG_OUT,
   output reg DBG1,
   output reg DBG2,
   output reg DBG3,
   output reg DBG4,
   output reg DBG5
   );
   

   reg [3:0]  SERIAL_IN_BIT_COUNT;
   reg [31:0] NEXT_DATA_ADDR;
   reg        PARITY0;
   reg        PARITY1;
   reg        PARITY0_ERROR;
   reg        PARITY1_ERROR;
   wire       PARITY0_ERROR120;
   wire       PARITY1_ERROR120;
   
   reg [11:0] DATA0;
   reg [11:0] DATA1;
   wire [1:0] LCL_CONTROL;
   wire       LCL_RESET;
   
   reg [1:0]  LCL_BUF_NUM; // Current buffer writing
   reg        RD_BUSY;  // Set when transfer from RD is in progress
   wire       RD_BUSY_STRETCH;
   wire       RD_BUSY120;
   reg        PREV_RD_BUSY120;
   wire       RD_BUSY120_STRETCH;
   reg        LCL_TRIG_OUT;
   reg [15:0] XFR_COUNT;
   wire       ENABLE_XFR;
   reg        ENABLE_XFR120;
   reg        PREV_ENABLE_XFR120;
   reg [15:0] WATCHDOG_COUNTER;
   

   rd_sync_1bit control_wrtsync(.ASYNC_IN(AXI_CONTROL_WRITTEN),
                                .CLK(CLK120),
                                .SYNC_OUT(LCL_CONTROL_WRITTEN));
   rd_sync_1bit control_sync0(.ASYNC_IN(AXI_CONTROL[0]),
                              .CLK(CLK120),
                              .SYNC_OUT(LCL_CONTROL[0]));
   rd_sync_1bit control_sync1(.ASYNC_IN(AXI_CONTROL[1]),
                              .CLK(CLK120),
                              .SYNC_OUT(LCL_CONTROL[1]));
   rd_sync_1bit reset_wrtsync(.ASYNC_IN(AXI_RESET_WRITTEN),
                              .CLK(CLK120),
                              .SYNC_OUT(LCL_RESET_WRITTEN));
   rd_sync_1bit reset_sync(.ASYNC_IN(AXI_RESET[0]),
                           .CLK(CLK120),
                           .SYNC_OUT(LCL_RESET));
   rd_sync_1bit busy_sync(.ASYNC_IN(RD_BUSY),
                          .CLK(CLK120),
                          .SYNC_OUT(RD_BUSY120));
   rd_sync_1bit parity0(.ASYNC_IN(PARITY0_ERROR),
                        .CLK(CLK120),
                        .SYNC_OUT(PARITY0_ERROR120));
   rd_sync_1bit parity1(.ASYNC_IN(PARITY1_ERROR),
                        .CLK(CLK120),
                        .SYNC_OUT(PARITY1_ERROR120));
   rd_sync_1bit enable_sync(.ASYNC_IN(ENABLE_XFR120),
                            .CLK(SERIAL_CLK_IN),
                            .SYNC_OUT(ENABLE_XFR));

   stretch trig_stretch(.IN(LCL_TRIG_OUT),
                        .CLK(CLK120),
                        .OUT(TRIG_OUT));

   // This will work to ignore 11 extra clock cycles only if XFR clock
   // frequency is 60 MHz or greater.  If not, or there are more than
   // 11 extra clock cycles, may need to increase delay.
   // stretch #(25) busy120_stretch(.IN(RD_BUSY120),
   //                               .CLK(CLK120),
   //                               .OUT(RD_BUSY120_STRETCH));
   // Increase ignore to 5us.
   stretch #(600) busy120_stretch(.IN(RD_BUSY120),
                                 .CLK(CLK120),
                                 .OUT(RD_BUSY120_STRETCH));

   // This stretch is OK if XFR clock fequency is 60 MHz or less.  If not, may
   // need to increase delay    
   stretch #(5) busy_stretch(.IN(RD_BUSY),
                             .CLK(SERIAL_CLK_IN),
                             .OUT(RD_BUSY_STRETCH));


   always @(posedge CLK120)
     begin

        DBG4 <= ENABLE_XFR120;
        DBG5 <= WATCHDOG_COUNTER[12];

        if (RST || (LCL_RESET && LCL_RESET_WRITTEN))
          begin
             STATUS <= 0;
             ENABLE_XFR120 <= 0;
             PREV_RD_BUSY120 <= 0;
             WATCHDOG_COUNTER <= 16'hffff;
          end
        else
          begin
             PREV_ENABLE_XFR120 <= ENABLE_XFR120;
             STATUS[`RD_BUF_RNUM_SHIFT+1:`RD_BUF_RNUM_SHIFT] <= BUF_RNUM;
             
             if (LCL_CONTROL_WRITTEN)
               begin
                  STATUS[`RD_BUF_FULL_SHIFT
                         +LCL_CONTROL[`RD_BUF_RNUM_SHIFT+1:
                                      `RD_BUF_RNUM_SHIFT]] <= 0;
               end
             
             // We need to save buffer number we are writing this trigger to.
             // But we also have to handle the case where another trigger
             // occurs before we have finished reading out the buffer from
             // the RD.  We assume here the RD cannot both transfer and 
             // accept a new trigger. So we need to also worry about 
             // interlocks.  
             
             PREV_RD_BUSY120 <= RD_BUSY120_STRETCH;

             if (!(RD_BUSY120_STRETCH | RD_BUSY120))
               begin
                  if (TRIG_IN)  // Not busy and trigger
                    begin
                       LCL_TRIG_OUT <= 1;
                       LCL_BUF_NUM <= BUF_WNUM;
                       STATUS[`RD_BUF_WNUM_SHIFT+1:`RD_BUF_WNUM_SHIFT]
                         <= BUF_WNUM;
                       
                       // Arm for next transfer
                       ENABLE_XFR120 <= 1;
                       WATCHDOG_COUNTER <= 16'hffff;  //546 us
                       
                       // Reset error indicators
                       STATUS[`RD_PARITY0_SHIFT+BUF_WNUM] <= 0;
                       STATUS[`RD_PARITY1_SHIFT+BUF_WNUM] <= 0;
                       STATUS[`RD_BUF_TIMEOUT_SHIFT+BUF_WNUM] <= 0;
                       DBG1 <= 0;
                   end // if (TRIG_IN)

                  // We assume here that trigger is shorter than delay
                  // from trigger to start of serial clock. 
                  // Otherwise this won't work.
                  else  // Not busy & no trigger
                    begin
                       LCL_TRIG_OUT <= 0;
                    end // else: !if(TRIG_IN)
               end
             
             // If busy goes from 1 to 0, transfer is over
             if (PREV_RD_BUSY120 && !RD_BUSY120)
               begin
                  ENABLE_XFR120 <= 0;
                  if (PARITY0_ERROR120)
                    STATUS[`RD_PARITY0_SHIFT+LCL_BUF_NUM] <= 1;
                  if (PARITY1_ERROR120)
                    STATUS[`RD_PARITY1_SHIFT+LCL_BUF_NUM] <= 1;
                  STATUS[`RD_BUF_FULL_SHIFT+LCL_BUF_NUM] <= 1;
                  STATUS[`RD_BUF_BUSY_SHIFT+LCL_BUF_NUM] <= 0;
                end

             // Decrement and check watchdog timer
             if (ENABLE_XFR120)
               begin
                  if (WATCHDOG_COUNTER == 0)
                    begin
                       ENABLE_XFR120 <= 0;
                       STATUS[`RD_BUF_TIMEOUT_SHIFT+LCL_BUF_NUM] <= 1;
                       DBG1 <= 1;
                    end
                  else
                    begin
                       WATCHDOG_COUNTER <= WATCHDOG_COUNTER-1;
                    end
               end

             // Flag transfer as busy if it is
             STATUS[`RD_BUF_BUSY_SHIFT+LCL_BUF_NUM] <= RD_BUSY120_STRETCH;

          end // else: !if(RST)
     end // always @ (posedge CLK120)

   // The next block of code operates in the SERIAL_CLK_IN domain

   always @(posedge SERIAL_CLK_IN)
     begin
        DBG2 <= SERIAL_DATA0_IN; 
        DBG3 <= SERIAL_DATA1_IN;

        if (!ENABLE_XFR)
          begin
             RD_BUSY <= 0;
             XFR_COUNT <= 0;
             NEXT_DATA_ADDR <= 0;
             ENABLE_MEM_WRT <= 0;  // Not writing to memory
             DATA_TO_MEM <= 0;
             DATA_ADDR <= 0;
             NEXT_DATA_ADDR <= 0;
             PARITY0 <= 0;
             PARITY1 <= 0;
             PARITY0_ERROR <= 0;
             PARITY1_ERROR <= 0;
             DATA0 <= 0;
             DATA1 <= 0;
             SERIAL_IN_BIT_COUNT <= 0;
          end
        
        if (!(RD_BUSY_STRETCH||RD_BUSY) && ENABLE_XFR)
          begin
             RD_BUSY <= 1;
          end

        // Grab serial data
        // High order bit is 1st and parity bit is last
        if (RD_BUSY)
          begin
             XFR_COUNT <= XFR_COUNT+1;
             if (XFR_COUNT >= 2048*13)
               begin
                  RD_BUSY <= 0;
               end
             if (SERIAL_IN_BIT_COUNT < 12)
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
                  if (SERIAL_DATA0_IN == PARITY0) PARITY0_ERROR <= 1;
                  if (SERIAL_DATA1_IN == PARITY1) PARITY1_ERROR <= 1;

                  // Write data to memory
                  DATA_TO_MEM[12:1] <= DATA0[11:0];
                  DATA_TO_MEM[28:17] <= DATA1[11:0];
                  //DATA_TO_MEM[0] <= PARITY0;
                  //DATA_TO_MEM[16] <= PARITY1;
                  DATA_TO_MEM[0] <= SERIAL_DATA0_IN;
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
          end // if (RD_BUSY)
        
     end // always @ (posedge SERIAL_CLK_IN)

endmodule // rd_interface


