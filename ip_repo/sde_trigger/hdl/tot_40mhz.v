// This module implements the 40 MHz compatibility mode ToT trigger.
//
// 16-May-2018 DFN Initial version
// 22-Sep-2018 DFN Add requirement of not triggered previous clock cycle;
//                 remove unnecessary resets
// 30-Oct-2020 DFN Add LCL_ENABLE40 to reduce load on ENABLE40

`include "sde_trigger_defs.vh"

`define TRG_DLY 4
`define WIDTH 122
`define WIDTH_SIZE 7

module tot_40mhz(
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
                 input [`WIDTH_SIZE-1:0] OCCUPANCY,
		 output reg TRIG,
                 output reg DEBUG
		 );

   reg                      SB_TRIG;
   reg [`WIDTH-1:0]         WINDOW;
   reg [`WIDTH_SIZE-1:0]    OCC_COUNTER;
   reg [2:0]                PMT_TRIG;
   reg [1:0]                SUM_PMT_TRIGS;
   reg                      TRIG_NOW;
   reg                      TRIG_PREV;
   reg [`ADC_WIDTH-1:0]     THRES[2:0];
   reg [`ADC_WIDTH-1:0]     ADC[2:0];
   reg [1:0]                LCL_ENABLE40;

   integer                  INDEX;
   
   always @(posedge CLK120)
     begin
        LCL_ENABLE40 <= ENABLE40;
        
        if (LCL_ENABLE40 == 0) 
          begin
             
             // First do a simple single bin trigger on each bin
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
	       SB_TRIG <= 1;
             else
	       SB_TRIG <= 0;

             // Then keep track of occupancy
             WINDOW <= {WINDOW[`WIDTH-2:0],SB_TRIG};
             if (WINDOW[`WIDTH-1] && !SB_TRIG)
               OCC_COUNTER <= OCC_COUNTER-1;
             else if (!WINDOW[`WIDTH-1] && SB_TRIG)
               OCC_COUNTER <= OCC_COUNTER+1;
          end  // Downsampled loop

        DEBUG <= SB_TRIG;  // Debug code to look like single bin
        if (OCC_COUNTER > OCCUPANCY) 
          begin
             TRIG_NOW <= 1;
             OCC_COUNTER <= 0;
             WINDOW <= 0;
          end
        else
          TRIG_NOW <= 0;

        // Trigger only if not triggered previous clock cycle
        TRIG <= TRIG_NOW && !TRIG_PREV;
        TRIG_PREV <= TRIG_NOW;
     end
   
endmodule
