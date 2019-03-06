// Module to test data transfers from the RD detector.
//
// 11-Oct-2018 DFN Initial version
// 07-Feb-2019 DFN Modified to work in conjunction with true rd_interface
// 05-Mar-2019 DFN Note: Be careful of which clock edge is used.


`define MEM_SIZE 2048

module fake_rd 
  (
   input wire ENABLE,
   input wire LOCAL_CLK,
   input wire TRIGGER,
  
   output reg ENABLE_XFR,
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
   reg [11:0] WORD_COUNT;
   wire       LOCAL_TRIGGER;
   wire       LOCAL_ENABLE;
   
   
   rd_synchronizer enable_sync(.ASYNC_IN(ENABLE),
                               .CLK(LOCAL_CLK),
                               .SYNC_OUT(LOCAL_ENABLE));
   rd_synchronizer trig_sync(.ASYNC_IN(TRIGGER),
                             .CLK(LOCAL_CLK),
                             .SYNC_OUT(LOCAL_TRIGGER));

   always @(posedge LOCAL_CLK)
     begin
   // Reset registers if not enabled
        if (~LOCAL_ENABLE)
          begin
             ENABLE_XFR <= 0;
          end
        else
          begin
             // Look for trigger to enable transfer of data
             if (LOCAL_TRIGGER & ~ENABLE_XFR)
               begin
                  ENABLE_XFR <= 1;
                end // if (TRIGGER & ~ENABLE_XFR)

             // If reach word count, then terminate transfer
             else
               if (ENABLE_XFR && (WORD_COUNT == `MEM_SIZE))
                 ENABLE_XFR <= 0;
          end  
     end  
   
   // Send fake data out
   always @(negedge LOCAL_CLK)
     begin
        if (ENABLE_XFR)
          begin
             DBG1 <= BIT_COUNT[3];
             DBG2 <= PARITY1;
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
          end // if (ENABLE_XFR)
        else
          begin
             DATA0 <= 0;
             DATA1 <= 0;
             WORD_COUNT <= 0;
             BIT_COUNT <= 0;
             PARITY0 <= 0;
             PARITY1 <= 0;
          end // else: !if(ENABLE_XFR)
        
     end  
endmodule  

