// Module to test data transfers from the RD detector.
//
// 11-Oct-2018 DFN Initial version
// 07-Feb-2019 DFN Modified to work in conjunction with true rd_interface
// 05-Mar-2019 DFN Note: Be careful of which clock edge is used.
// 06-Jul-2019 DFN Modify for rd_interface_2.0
// 11-Jul-2019 DFN Add delay of transfer start to be more realistic
// 17-Mar-2020 DFN Note "TRIGGER" input does not need to be the same as the
//                 TRIG_OUT output of the SDE trigger module.  Rather it is
//                 signal to indicate when fake transfer should start.  Might
//                 be better to the the SHWR_TRIGGER signal.
// 18-Mar-2020 DFN Add capture/replay of data from spare input


`define MEM_SIZE 2048
`define FAKE_RD_TRIG_DLY 20

module fake_rd 
  (
   input wire ENABLE,
   input wire LOCAL_CLK,
   input wire CLK120,
   input wire TRIGGER,
   input wire[11:0] RD_DATA,
   input wire[23:0] ADC_DATA,
  
   output wire XFR_CLK,
   output reg SERIAL_OUT0,
   output reg SERIAL_OUT1,
   output reg[10:0] RD_ADDR,
   output reg[10:0] WRT_ADDR,
   output reg[11:0] WRT_DATA,
   output reg WE,
   output reg RE,
   output reg DBG1,
   output reg DBG2,
   output reg DBG3,
   output reg DBG4
   );

   reg [3:0]  BIT_COUNT;
   reg [11:0] DATA0;
   reg [11:0] DATA1;
   reg        PARITY0;
   reg        PARITY1;
   reg [15:0] WORD_COUNT;
   wire       LOCAL_TRIGGER;
   wire       LOCAL_ENABLE;
   reg        EMAB;
   reg        ENABLE_XFR;
   reg        PRE_ENABLE1;
   reg        PRE_ENABLE2;
   reg        PRE_ENABLE3;
   reg        NO_CLK;
   reg        LOCAL_TRIG_DLYD;
   reg        TRIG_EDGE;
   reg        PREV_TRIGGER;
   wire       ENABLE_XFR120;
   wire       STRETCH_TRIG;
   reg [`FAKE_RD_TRIG_DLY-1:0] TRIG_DLYD;
   
   
   
   rd_synchronizer enable_sync(.ASYNC_IN(ENABLE),
                               .CLK(LOCAL_CLK),
                               .SYNC_OUT(LOCAL_ENABLE));
   rd_synchronizer trig_sync(.ASYNC_IN(STRETCH_TRIG),
                             .CLK(LOCAL_CLK),
                             .SYNC_OUT(LOCAL_TRIGGER));
   rd_synchronizer xfr_sync(.ASYNC_IN(ENABLE_XFR),
                             .CLK(CLK120),
                             .SYNC_OUT(ENABLE_XFR120));
   rd_stretch str_trig(.IN(TRIG_EDGE), .CLK(CLK120), .OUT(STRETCH_TRIG));
   

   // Gated clock
   mux2 clk(.SEL_B(ENABLE_XFR|PRE_ENABLE1|PRE_ENABLE2|PRE_ENABLE3),
            .D({NO_CLK,~LOCAL_CLK}),.Q(XFR_CLK));

   always @(posedge CLK120)
     begin
        TRIG_EDGE <= TRIGGER & ~PREV_TRIGGER;
        PREV_TRIGGER <= TRIGGER;
        if (~ENABLE)
          begin
             WRT_ADDR <= 0;
             WE <= 0;
          end
        else
          begin
             if (~ENABLE_XFR120)
               begin
                  WRT_DATA[11:0] <= ADC_DATA[23:12];
//                  WRT_DATA[11:0] <= ADC_DATA[11:0];
                  WRT_ADDR <= WRT_ADDR+1;
                  WE <= 1;
               end
             else
               WE <= 0;
          end // else: !if(~ENABLE)
        DBG1 <= WE;
        DBG4 <= STRETCH_TRIG;
     end
             
            
   always @(posedge LOCAL_CLK)
     begin
        NO_CLK <= 1;
        DBG2 <= DATA0[0];
        DBG3 <= RE;
        
        // Reset registers if not enabled
        if (~LOCAL_ENABLE)
          begin
             ENABLE_XFR <= 0;
             PRE_ENABLE1 <= 0;
             PRE_ENABLE2 <= 0;
             PRE_ENABLE3 <= 0;
             SERIAL_OUT0 <= 1;
             SERIAL_OUT1 <= 1;
             RD_ADDR <= 0;
          end
        else
          begin
             // Delay trigger by some clock cycles to be more realistic
             TRIG_DLYD <= {TRIG_DLYD[`FAKE_RD_TRIG_DLY-2:0], LOCAL_TRIGGER};
             LOCAL_TRIG_DLYD <= TRIG_DLYD[`FAKE_RD_TRIG_DLY-1];

             // Look for trigger to enable transfer of data
             if (LOCAL_TRIG_DLYD & ~ENABLE_XFR)
               begin
                  PRE_ENABLE1 <= 1;
                  DATA0 <= 0;
                  DATA1 <= 0;
                  WORD_COUNT <= 0;
                  BIT_COUNT <= 0;
                  PARITY0 <= 0;
                  PARITY1 <= 0;
                  SERIAL_OUT0 <= 1;
                  SERIAL_OUT1 <= 1;
               end // if (TRIGGER & ~ENABLE_XFR)

             // Add extra clock cycles before start of data transfer
             if (PRE_ENABLE1)
               begin
                  PRE_ENABLE2 <= 1;
                  PRE_ENABLE1 <= 0;
               end 
             if (PRE_ENABLE2)
               begin
                  PRE_ENABLE3 <= 1;
                  PRE_ENABLE2 <= 0;
               end 
             if (PRE_ENABLE3)
               begin
                  ENABLE_XFR <= 1;
                  PRE_ENABLE3 <= 0;
// Crossing clock domains ... but WRT_ADDR should be stable here
                  RD_ADDR <= WRT_ADDR;
               end 
             if (ENABLE_XFR)
               begin
                  RE <= 1;
                  if (WORD_COUNT < `MEM_SIZE)
                    begin
                       if (BIT_COUNT == 12)
                         begin
                            RD_ADDR <= RD_ADDR+1;
                            DATA0 <= RD_DATA;
                            DATA1 <= DATA1-1;
                            WORD_COUNT <= WORD_COUNT+1;
                            SERIAL_OUT0 <= ~PARITY0;
                            SERIAL_OUT1 <= ~PARITY1;
                            BIT_COUNT <= 0;
                            PARITY0 <= 0;
                            PARITY1 <= 0;
                         end
                       if (BIT_COUNT < 12)  
                         begin
                            SERIAL_OUT0 <= DATA0[11-BIT_COUNT];
                            SERIAL_OUT1 <= DATA1[11-BIT_COUNT];
                            PARITY0 <= PARITY0+DATA0[11-BIT_COUNT];
                            PARITY1 <= PARITY1+DATA1[11-BIT_COUNT];
                            BIT_COUNT <= BIT_COUNT+1;
                         end
                    end // if (WORD_COUNT < `MEM_SIZE)
                  else begin
                     RE <= 0;
                     SERIAL_OUT0 <= 1;
                     SERIAL_OUT1 <= 1;
                     BIT_COUNT <= BIT_COUNT+1;
                     // If reach word count, then terminate transfer
                     // kludge to add extra clock cycles at end of transfer
                     if (BIT_COUNT >= 11)
                       ENABLE_XFR <= 0;
                  end
               end // if (ENABLE_XFR)
          end 
     end  
endmodule  

// 2 to 1 mux

module mux2
  (
   input SEL_B,
   input [0:1] D,
   output wire Q
   );
   
   assign Q = D[SEL_B];

endmodule
