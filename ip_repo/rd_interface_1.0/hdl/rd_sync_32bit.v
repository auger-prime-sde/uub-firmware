// Module to synchronize 32 bits between 2 clock domains using the ASYNC_REG
// attribute. 
//
// 25-Sep-2014 DFN Initial version
// 10-Nov-2014 DFN Added requirement that no transition in any of the 32 bits
//                 before passing changing output
//

module rd_sync_32bit
  (
   input wire [31:0] ASYNC_IN,
   input wire CLK,
   output reg [31:0] SYNC_OUT                          
   );

   wire [31:0] STAGE1;
   reg [31:0] STAGE2;

   // Clock domain crossing
   genvar i;
   generate for (i = 0; i<32; i=i+1) 
     begin: sync32
        rd_sync_1bit sync(.ASYNC_IN(ASYNC_IN[i]), .CLK(CLK), 
		                    .SYNC_OUT(STAGE1[i]));
     end
   endgenerate

   // Require that output is stable for 2 consecutive clock cycles.
   always @(posedge CLK) begin
      if (STAGE1 == STAGE2)
         SYNC_OUT <= STAGE2;
      else
        SYNC_OUT <= SYNC_OUT;
      STAGE2 <= STAGE1;
   end
endmodule
