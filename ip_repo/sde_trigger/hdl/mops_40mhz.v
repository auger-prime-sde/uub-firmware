// This module implements the mops trigger
//
// 21-Jun-2019 DFN Initial version
// 15-Oct-2020 DFN Updated DEBUG in Fabio's version
// 19-Oct-2020 DFN Major rewrite of Fabio's version
// 30-Oct-2020 DFN Add LCL_ENABLE40 to reduce load on ENABLE40

`include "sde_trigger_defs.vh"

`define COMPATIBILITY_MOPS_OFS_BITS 4
`define TRG_DLY 4
`define WIDTH 122
`define MOPS_OCC_WIDTH (`WIDTH_BITS-2)

module mops_40mhz(
		  input [1:0] ENABLE40,
		  input CLK120,
                  input RESET,
         	  input [`ADC_WIDTH-1:0] ADC0,
		  input [`ADC_WIDTH-1:0] ADC1,
		  input [`ADC_WIDTH-1:0] ADC2,

                  input [`ADC_WIDTH-1:0] MIN0,
                  input [`ADC_WIDTH-1:0] MIN1,
                  input [`ADC_WIDTH-1:0] MIN2,

                  input [`ADC_WIDTH-1:0] MAX0,
                  input [`ADC_WIDTH-1:0] MAX1,
                  input [`ADC_WIDTH-1:0] MAX2,

		  input [2:0] TRIG_ENABLE,
	          input [`MOPS_OCC_WIDTH-1:0] OCCUPANCY,
                  input [`COMPATIBILITY_INTEGRAL_BITS-1:0] INT,
                  input [`COMPATIBILITY_MOPS_OFS_BITS-1:0] OFS,
		  input [1:0] MULTIPLICITY,
   		  output reg TRIG
`ifdef COMPAT_MOPS_DEBUG
                  ,output reg [83:0] DEBUG
`endif
		  );


   reg [`ADC_WIDTH-1:0]      ADC[2:0];
   reg                       SB_TRIG[2:0];
   reg [1:0]                 LCL_ENABLE40;
   reg [`WIDTH-1:0]          WINDOW[2:0];
   reg [`MOPS_OCC_WIDTH-1:0] OCC_COUNTER[2:0];
   reg [2:0]                 PMT_TRIG;
   reg [1:0]                 SUM_PMT_TRIGS;
   reg [`ADC_WIDTH-1:0]      PREV_ADC[2:0];
   reg signed [`ADC_WIDTH:0] THIS_STEP[2:0];
   reg [`ADC_WIDTH+1:0]      STEP[2:0];
   reg                       TRIG_NOW;
   reg                       TRIG_PREV;
   reg [`ADC_WIDTH-1:0]      MAX[2:0];
   reg [`ADC_WIDTH-1:0]      MIN[2:0];
   reg signed [`ADC_WIDTH:0] VETO_COUNTER[2:0];
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL0;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL1;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL2;
   reg [`COMPATIBILITY_INTEGRAL_BITS-1:0]  INTEGRAL[2:0];
   integer                                 PMT;


   integral_40mhz integral0(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC0),
                            .INTEGRAL(INTEGRAL0)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG0)
`endif
                            );
   integral_40mhz integral1(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC1),
                            .INTEGRAL(INTEGRAL1)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG1)
`endif
                            );
   integral_40mhz integral2(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC2),
                            .INTEGRAL(INTEGRAL2)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG2)
`endif
                            );


   always @(posedge CLK120) begin
      LCL_ENABLE40 <= ENABLE40;
      
      if (LCL_ENABLE40 == 0) begin
         ADC[0] <= ADC0;
         ADC[1] <= ADC1;
         ADC[2] <= ADC2;
         MIN[0] <= MIN0;
         MIN[1] <= MIN1;
         MIN[2] <= MIN2;
         MAX[0] <= MAX0;
         MAX[1] <= MAX1;
         MAX[2] <= MAX2;
         INTEGRAL[0] <= INTEGRAL0;
         INTEGRAL[1] <= INTEGRAL1;
         INTEGRAL[2] <= INTEGRAL2;
         
         for (PMT=0; PMT<3; PMT=PMT+1) 
           begin
	      PREV_ADC[PMT] <= ADC[PMT];

              if (VETO_COUNTER[PMT] > 0) 
                begin
                   VETO_COUNTER[PMT] <= VETO_COUNTER[PMT] - 1;
                   STEP[PMT] <= 0;
                   PMT_TRIG[PMT] <= 0;
                   THIS_STEP[PMT] <= 0;
                end
              else
                begin
                   // Accumulate positive steps
                   THIS_STEP[PMT][`ADC_WIDTH:0]
                  <= ADC[PMT][`ADC_WIDTH-1:0] - PREV_ADC[PMT][`ADC_WIDTH-1:0];
                   
	           if (THIS_STEP[PMT] >= 0) 
                     begin
	                STEP[PMT][`ADC_WIDTH+1:0] <= STEP[PMT][`ADC_WIDTH:0] + 
                                                     THIS_STEP[PMT][`ADC_WIDTH:0];
                        PMT_TRIG[PMT] <= 0;
                     end
                   else
                     begin
                        STEP[PMT] <= 0;

                        // Positive step is finished.  Do we have a
                        // single PMT occupancy increase?
	                if ((STEP[PMT][`ADC_WIDTH-1:0] <= MAX[PMT][`ADC_WIDTH-1:0])
                            && (STEP[PMT][`ADC_WIDTH-1:0] > MIN[PMT][`ADC_WIDTH-1:0]) 
                            && (TRIG_ENABLE[PMT] == 1)) PMT_TRIG[PMT] <= 1;
                        else
                          PMT_TRIG[PMT] <= 0;

                        // Apply veto count to this step.  Note we need to subtract one more
                        // than the published equation because we're already one bin behind
                        // due to the pipelineing (eg do -2 - OFS instead of -1 - OFS)
                        // Actually may be 2 bins behind.  Try -3 - OFS

                        if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111111111110) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 0 - 3 -
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111111111100) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 1 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111111111000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 2 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111111110000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 3 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111111100000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 4 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH:0] & 12'b111111000000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 5 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111110000000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 6 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111100000000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 7 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b111000000000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 8 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b110000000000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 9 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else if ((STEP[PMT][`ADC_WIDTH-1:0] & 12'b100000000000) == 0)
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 10 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                        else 
                          VETO_COUNTER[PMT][`ADC_WIDTH:0] <= 11 - 3 - 
                                                             OFS[`COMPATIBILITY_MOPS_OFS_BITS-1:0];
                     end // else: !if(THIS_STEP[PMT] > 0)
                end // else: !if(VETO_COUNTER[PMT] > 0)
              
              WINDOW[PMT][`WIDTH-1:0] 
                <= {WINDOW[PMT][`WIDTH-2:0],PMT_TRIG[PMT]};
              if (WINDOW[PMT][`WIDTH-1] && !PMT_TRIG[PMT])
                OCC_COUNTER[PMT] <= OCC_COUNTER[PMT] - 1;
              else if ((!WINDOW[PMT][`WIDTH-1]) && PMT_TRIG[PMT])
                OCC_COUNTER[PMT] <= OCC_COUNTER[PMT] + 1;
              if ((OCC_COUNTER[PMT] > OCCUPANCY) &&
                  (INTEGRAL[PMT] > INT)) SB_TRIG[PMT] <= 1;
              else SB_TRIG[PMT] <= 0;
           end // for (PMT=0; PMT<3; PMT=PMT+1)

         SUM_PMT_TRIGS <= SB_TRIG[0] + SB_TRIG[1] + SB_TRIG[2];
         if ((SUM_PMT_TRIGS >= MULTIPLICITY) && (MULTIPLICITY != 0)) 
           begin
	      TRIG_NOW <= 1;
              WINDOW[0] <= 0;
              OCC_COUNTER[0] <= 0;
              WINDOW[1] <= 0;
              OCC_COUNTER[1] <= 0;
              WINDOW[2] <= 0;
              OCC_COUNTER[2] <= 0;
           end
         else
           TRIG_NOW <= 0;
         
         // Only trigger if did not trigger previous clock cycle
         TRIG <= TRIG_NOW && !TRIG_PREV;
         TRIG_PREV <= TRIG_NOW;
      end // if (LCL_ENABLE40 == 0)
      
`ifdef COMPAT_MOPS_DEBUG
      if (LCL_ENABLE40 == 2)
        begin
           DEBUG[11:0] <= STEP[0][11:0];
           DEBUG[23:12] <= STEP[1][11:0];
           DEBUG[35:24] <= STEP[2][11:0];
           DEBUG[39:36] <= OCC_COUNTER[0][3:0];
           DEBUG[43:40] <= OCC_COUNTER[1][3:0];
           DEBUG[47:44] <= OCC_COUNTER[2][3:0];
           DEBUG[59:48] <= INTEGRAL0[14:3];
           DEBUG[71:60] <= INTEGRAL1[14:3];
           DEBUG[83:72] <= INTEGRAL2[14:3];
        end
`endif      
      
   end // always @ (posedge CLK120)
endmodule
