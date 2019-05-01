// scaler.v
//
// This module implements the scaler function.  Note that this operates
// using the 40 MHz filtered signal to be compatible with the older
// implementation.
//
// 05-Apr-2019 DFN Initial version

`include "sde_trigger_defs.vh"

`define TRG_DLY 4
  
module scaler(
	      input [1:0] ENABLE40,
	      input CLK120,
              input RESET,
	      input [`ADC_WIDTH-1:0] ADC0,
	      input [`ADC_WIDTH-1:0] ADC1,
	      input [`ADC_WIDTH-1:0] ADC2,
	      input [`ADC_WIDTH-1:0] THRES0,
	      input [`ADC_WIDTH-1:0] THRES1,
	      input [`ADC_WIDTH-1:0] THRES2,
	      input [2:0] TRIG_ENABLE,
	      input [1:0] MULTIPLICITY,
              output reg [31:0] COUNT,
              output reg [2:0] DEBUG
	      );
   
   reg [2:0] 			   PMT_TRIG;
   reg [1:0] 			   SUM_PMT_TRIGS;
   reg                             ITRIG;
   reg [`ADC_WIDTH-1:0] 	   THRES[2:0];
   reg [`ADC_WIDTH-1:0] 	   ADC[2:0];
   reg [`TRG_DLY-1:0]             ITRIG_PREV;
   
   integer                         INDEX;
   integer                         INDEX2;
   
   always @(posedge CLK120) begin
      if (RESET) begin
         COUNT <= 0;
      end
      THRES[0] <= THRES0;
      THRES[1] <= THRES1;
      THRES[2] <= THRES2;
      ADC[0] <= ADC0;
      ADC[1] <= ADC1;
      ADC[2] <= ADC2;
      
      for (INDEX=0; INDEX<3; INDEX=INDEX+1) begin
	 if ((THRES[INDEX] < ADC[INDEX]) && (TRIG_ENABLE[INDEX] == 1)) 
	   PMT_TRIG[INDEX] <= 1;
	 else 
	   PMT_TRIG[INDEX] <= 0;
      end
      SUM_PMT_TRIGS <= PMT_TRIG[0] + PMT_TRIG[1] + PMT_TRIG[2];
      if ((SUM_PMT_TRIGS >= MULTIPLICITY) && (MULTIPLICITY != 0))
	ITRIG <= 1;
      else
	ITRIG <= 0;

      // Need to insert logic here to avoid double counting.  Previous code
      // required no triger previous 40 MHz clock. 
      // Holdoff is set to ~50 ns in this version.
      
      ITRIG_PREV <= {ITRIG_PREV[`TRG_DLY-2:0], ITRIG};
      if (ITRIG && !(|ITRIG_PREV)) begin
         COUNT <= COUNT + 1;
         DEBUG[0] <= 1;
      end
      else
        DEBUG[0] <= 0;
      
      DEBUG[1] <= ITRIG;
      DEBUG[2] <= |ITRIG_PREV;
   end
   
endmodule
