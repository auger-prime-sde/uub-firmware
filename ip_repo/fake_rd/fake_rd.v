// Module to test data transfers from the RD detector.
//
// 11-Oct-2018 DFN Initial version
// 07-Feb-2019 DFN Modified to work in conjunction with true rd_interface
// 05-Mar-2019 DFN Note: Be careful of which clock edge is used.
// 06-Jul-2019 DFN Modify for rd_interface_2.0 


//`define MEM_SIZE 2048
`define MEM_SIZE 5000  // Extra long just for test

module fake_rd 
  (
   input wire ENABLE,
   input wire LOCAL_CLK,
   input wire TRIGGER,
  
   output reg ENABLE_XFR,
   output wire XFR_CLK,
   output reg SERIAL_OUT0,
   output reg SERIAL_OUT1,
   output reg DBG1,
   output reg DBG2
   );

   reg [3:0]  BIT_COUNT;
   reg [11:0] DATA0;
   reg [11:0] DATA1;
   reg        PARITY0;
   reg        PARITY1;
   reg [15:0] WORD_COUNT;
   wire       LOCAL_TRIGGER;
   wire       LOCAL_ENABLE;
   reg        PRE_ENABLE1;
   reg        PRE_ENABLE2;
   reg        PRE_ENABLE3;
   reg        NO_CLK;
   
   
   rd_synchronizer enable_sync(.ASYNC_IN(ENABLE),
                               .CLK(LOCAL_CLK),
                               .SYNC_OUT(LOCAL_ENABLE));
   rd_synchronizer trig_sync(.ASYNC_IN(TRIGGER),
                             .CLK(LOCAL_CLK),
                             .SYNC_OUT(LOCAL_TRIGGER));
   

   // Gated clock
   mux2 clk(.SEL_B(ENABLE_XFR|PRE_ENABLE1|PRE_ENABLE2|PRE_ENABLE3),
            .D({NO_CLK,~LOCAL_CLK}),.Q(XFR_CLK));
            
   always @(posedge LOCAL_CLK)
     begin
        NO_CLK <= 1;
        DBG1 <= ENABLE_XFR;
        DBG2 <= SERIAL_OUT0;
        
        // Reset registers if not enabled
        if (~LOCAL_ENABLE)
          begin
             ENABLE_XFR <= 0;
             PRE_ENABLE1 <= 0;
             PRE_ENABLE2 <= 0;
             PRE_ENABLE3 <= 0;
             SERIAL_OUT0 <= 1;
             SERIAL_OUT1 <= 1;
          end
        else
          begin
             // Look for trigger to enable transfer of data
             if (LOCAL_TRIGGER & ~ENABLE_XFR)
               begin
                  PRE_ENABLE1 <= 1;
                  DATA0 <= 0;
                  DATA1 <= 0;
                  WORD_COUNT <= 0;
                  BIT_COUNT <= 0;
                  PARITY0 <= 0;
                  PARITY1 <= 0;
               end // if (TRIGGER & ~ENABLE_XFR)

             // Add 3 extra clock cycles before start of data transfer
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
               end 
             if (ENABLE_XFR)
               begin
                  if (WORD_COUNT < `MEM_SIZE)
                    begin
                       if (BIT_COUNT == 12)
                         begin
                            DATA0 <= DATA0+1;
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
