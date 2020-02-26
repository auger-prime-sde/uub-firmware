// Module to synchronize 24 bits between 2 clock domains using the ASYNC_REG
// attribute. This version accepts ddr data; the input data is clocked on
// on both clock edges.
//
// 06-Feb-2016 DFN Initial version
// 26-Feb-2016 DFN Initial 24 bit version derived from 26 bit version
// 12-Apr-2016 DFN Add input sync stage on DDR_CLK clocked data.
// 28-Apr-2016 DFN Change instantiation of 1 bit synchronizer to
//                 ddr_synchronizer_1bit to differentiate from similar module
//                 used by sde_trigger.
// 09-Feb-2020 DFN Add debug outputs to allow timing checks
//

module ddr_synchronizer_24bit
  (
   input [11:0] ASYNC_IN,
   input  DDR_CLK,
   input CLK,
   output [23:0] SYNC_OUT,
   output reg DBG_ASYNC,
   output DBG_SYNC                         
   );

   wire [11:0]   POSSTAGE2;
   wire [11:0]   NEGSTAGE2;
   wire [11:0]   POSSTAGE1;
   wire [11:0]   NEGSTAGE1;
   reg [11:0]    POSEDGE;
   reg [11:0]    NEGEDGE;

   always @(ASYNC_IN[11])
     DBG_ASYNC <= ASYNC_IN[11];

   always @(negedge DDR_CLK)
     NEGEDGE <= ASYNC_IN;

   always @(posedge DDR_CLK)
     POSEDGE <= ASYNC_IN;
   
   // Clock domain crossing
   genvar        i;
   generate for (i = 0; i<12; i=i+1) 
     begin: syncddr
        ddr_synchronizer_1bit synca(.ASYNC_IN(POSEDGE[i]), .CLK(DDR_CLK), 
	 	                .SYNC_OUT(POSSTAGE1[i]));
        ddr_synchronizer_1bit syncb(.ASYNC_IN(NEGEDGE[i]), .CLK(DDR_CLK), 
	 	                .SYNC_OUT(NEGSTAGE1[i]));
        ddr_synchronizer_1bit syncc(.ASYNC_IN(POSSTAGE1[i]), .CLK(CLK), 
	 	                .SYNC_OUT(POSSTAGE2[i]));
        ddr_synchronizer_1bit syncd(.ASYNC_IN(NEGSTAGE1[i]), .CLK(CLK), 
	 	                .SYNC_OUT(NEGSTAGE2[i]));
	assign SYNC_OUT[i] = POSSTAGE2[i];
	assign SYNC_OUT[i+12] = NEGSTAGE2[i];
     end
   endgenerate

   assign DBG_SYNC = SYNC_OUT[23];
   
endmodule
