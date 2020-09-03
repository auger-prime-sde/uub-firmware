// Module to synchronize 2 bits between 2 clock domains using the ASYNC_REG
// attribute. 
//
// 09-Apr-2020 DFN Initial version
//

module synchronizer_2bit
  (
   input wire [1:0] ASYNC_IN,
   input wire CLK,
   output reg [1:0] SYNC_OUT                          
   );

   wire [1:0] STAGE1;
   reg [1:0] STAGE2;

   // Clock domain crossing
   genvar i;
   generate for (i = 0; i<2; i=i+1) 
     begin: sync2
        synchronizer_1bit sync(.ASYNC_IN(ASYNC_IN[i]), .CLK(CLK), 
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
