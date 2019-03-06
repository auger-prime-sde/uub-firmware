// Module to test data transfers from the RD detector.
//
// 11-Oct-2018 DFN Initial version
// 07-Feb-2019 DFN Modified to work in conjunction with true rd_interface


//`define MEM_SIZE 2048
`define MEM_SIZE 32  // Temporarily smaller for behavioral simulation

module fake_rd_interface 
  (
   input wire ENABLE,
   input wire LOCAL_CLK,
   input wire TRIGGER,
  
   output reg ENABLE_XFR,
   output reg SERIAL_OUT0,
   output reg SERIAL_OUT1
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


   // Reset registers if not enabled
   always @(posedge LOCAL_CLK)
     begin
        if (~LOCAL_ENABLE)
          begin
             DATA0 <= 0;
             DATA1 <= 0;
             WORD_COUNT <= 0;
             BIT_COUNT <= 0;
             PARITY0 <= 0;
             PARITY1 <= 0;
             ENABLE_XFR <= 0;
          end
     end

   always @(posedge LOCAL_CLK)
     begin
        // Look for trigger to enable transfer of data
        if (LOCAL_TRIGGER & ~ENABLE_XFR)
          begin
             ENABLE_XFR <= 1;
             DATA0 <= 0;
             DATA1 <= 0;
             WORD_COUNT <= 0;
             BIT_COUNT <= 0;
             PARITY0 <= 0;
             PARITY1 <= 0;
             SERIAL_OUT0 <= 0;
             SERIAL_OUT1 <= 0;
          end // if (TRIGGER & ~ENABLE_XFR)

        // If reach word count, then terminate transfer

        if (ENABLE_XFR && (WORD_COUNT == `MEM_SIZE))
          ENABLE_XFR <= 0;
     end    
   
   // Send fake data out
   always @(negedge LOCAL_CLK)
     begin
        if (ENABLE_XFR)
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
             else   
               begin
                  SERIAL_OUT0 <= DATA0[11-BIT_COUNT];
                  SERIAL_OUT1 <= DATA0[11-BIT_COUNT];
                  PARITY0 <= PARITY0+DATA0[11-BIT_COUNT];
                  PARITY1 <= PARITY1+DATA0[11-BIT_COUNT];
                  BIT_COUNT <= BIT_COUNT+1;
               end
          end
     end  
endmodule  

