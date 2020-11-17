// single_bin_40mhz.v
//
// This module implements the 40 MHz compatibility mode single bin trigger.
//
// 21-Mar-2014 DFN Initial version
// 21-May-2015 DFN Add requirement that multiplicity > 0
// 19-Sep-2016 DFN Correct width of THRES & ADC arrays.
// 17-Oct-2020 DFN Add downsample for consistency with ToT, ToTd, MoPS
// 30-Oct-2020 DFN Add LCL_ENABLE40 to reduce load on ENABLE40

`include "sde_trigger_defs.vh"

`define SB_TRG_DLY 3
  
module single_bin_40mhz(
			input [1:0] ENABLE40,
			input CLK120,
			input [`ADC_WIDTH-1:0] ADC0,
			input [`ADC_WIDTH-1:0] ADC1,
			input [`ADC_WIDTH-1:0] ADC2,
			input [`ADC_WIDTH-1:0] THRES0,
			input [`ADC_WIDTH-1:0] THRES1,
			input [`ADC_WIDTH-1:0] THRES2,
			input [2:0] TRIG_ENABLE,
			input [1:0] MULTIPLICITY,
                        input TWOBINS,
			output reg TRIG
			);
   
   reg [2:0] 			   PMT_TRIG;
   reg [1:0] 			   SUM_PMT_TRIGS;
   reg                             ITRIG;
   reg                             ITRIG1;
   reg                             ITRIG2;
   reg                             PREV_ITRIG;
   reg [`ADC_WIDTH-1:0] 	   THRES[2:0];
   reg [`ADC_WIDTH-1:0] 	   ADC[2:0];
   reg [1:0]                       LCL_ENABLE40;
//   reg [`SB_TRG_DLY:0] 		   TRIG_DLY;
   
   integer                         INDEX;
//   integer                         INDEX2;
   
   always @(posedge CLK120) begin
      LCL_ENABLE40 <= ENABLE40;

      if (LCL_ENABLE40 == 0)
        begin
           THRES[0] <= THRES0;
           THRES[1] <= THRES1;
           THRES[2] <= THRES2;
           ADC[0] <= ADC0;
           ADC[1] <= ADC1;
           ADC[2] <= ADC2;
           
           for (INDEX=0; INDEX<3; INDEX=INDEX+1) 
             begin
	        if ((THRES[INDEX] < ADC[INDEX]) && (TRIG_ENABLE[INDEX] == 1)) 
	          PMT_TRIG[INDEX] <= 1;
	        else 
	          PMT_TRIG[INDEX] <= 0;
             end
           SUM_PMT_TRIGS <= PMT_TRIG[0] + PMT_TRIG[1] + PMT_TRIG[2];
           if ((SUM_PMT_TRIGS >= MULTIPLICITY) && (MULTIPLICITY != 0))
	     ITRIG1 <= 1;
           else
	     ITRIG1 <= 0;
           ITRIG2 <= ITRIG1;
           if (TWOBINS)
             ITRIG <= ITRIG1 & ITRIG2;
           else
             ITRIG <= ITRIG1;
           PREV_ITRIG <= ITRIG;
           if (ITRIG && !PREV_ITRIG)
             TRIG <= 1;
           else
             TRIG <= 0;
        end  // Downsampled loop
      
      // PREV_ITRIG <= ITRIG;
      // if (ITRIG && !PREV_ITRIG)
      //   TRIG_DLY[0] <= 1;
      // else
      //   TRIG_DLY[0] <= 0;

      // // Delay trigger to make delay same as 120 MHz trigger
      // for (INDEX2=1; INDEX2<=`SB_TRG_DLY; INDEX2=INDEX2+1)
      //    TRIG_DLY[INDEX2] <= TRIG_DLY[INDEX2-1];
      // TRIG = TRIG_DLY[`SB_TRG_DLY];

   end

endmodule
