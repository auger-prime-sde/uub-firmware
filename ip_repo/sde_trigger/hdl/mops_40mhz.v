// This module implements the mops trigger
//
// 21-Jun-2019 DFN Initial version
// 15-Oct-2020 DFN Updated DEBUG in Fabio's version
// 19-Oct-2020 DFN Major rewrite of Fabio's version
// 30-Oct-2020 DFN Add LCL_ENABLE40 to reduce load on ENABLE40
// 02-Nov-2020 DFN Move veto computation to 2nd and 3rd clock phases to reduce pipeline delay.
// 04-Nov-2020 DFN Change WIDTH from 122 to 121 & rename to MOPS_WIDTH
// 16-Nov-2020 DFN Change MOPS_WIDTH to 120

`include "sde_trigger_defs.vh"

`define COMPAT_MOPS_OFS_BITS 4
`define TRG_DLY 4
`define MOPS_WIDTH 120
`define MOPS_OCC_WIDTH (`WIDTH_BITS-2)

module mops_40mhz(
		  input [1:0] ENABLE40,
		  input CLK120,
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
                  input [`COMPAT_INTEGRAL_BITS-3:0] INT,
                  input [`COMPAT_MOPS_OFS_BITS-1:0] OFS,
		  input [1:0] MULTIPLICITY,
   		  output reg TRIG
`ifdef COMPAT_MOPS_DEBUG
                  ,output reg [83:0] DEBUG
`endif
		  );


   reg [`ADC_WIDTH-1:0]      ADC[2:0];
   reg                       SB_TRIG[2:0];
   reg [1:0]                 LCL_ENABLE40;
   reg [`MOPS_WIDTH-1:0]     WINDOW[2:0];
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
   wire [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL0;
   wire [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL1;
   wire [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL2;
   reg [`COMPAT_INTEGRAL_BITS-1:0]  INTEGRAL[2:0];
   reg [11:0] 			    LOG2[2:0];
   reg [`COMPAT_MOPS_OFS_BITS:0]    THIS_OFS;
   
   
   integer                                 IPMT, JPMT, KPMT;


   integral_40mhz integral0(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC0),
                            .THRESHOLD(INT),
			    .INTEGRAL(INTEGRAL0)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG0)
`endif
                            );
   integral_40mhz integral1(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC1),
                            .THRESHOLD(INT),
                            .INTEGRAL(INTEGRAL1)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG1)
`endif
                            );
   integral_40mhz integral2(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC2),
                            .THRESHOLD(INT),
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

	 // This works with -0-OFS compat_mops.c
	 // THIS_OFS <= OFS + 2;

	 // This should work with -1-OFS in compat_mops.c
	 // but it does not seem to for some reason.
	 // -2-OFS seems to be preferred in the ref. code.
	 // Perhaps the distribution of signals in the randoms data
	 // has some strange properties.  In any case OFS+3 with
	 // -2-OFS in compat_mops.c works much better than any of
	 // the other options.
	  THIS_OFS <= OFS + 3;
	 
         for (IPMT=0; IPMT<3; IPMT=IPMT+1) 
           begin
	      PREV_ADC[IPMT] <= ADC[IPMT];

              if (VETO_COUNTER[IPMT] > 0) 
                begin
                   VETO_COUNTER[IPMT] <= VETO_COUNTER[IPMT] - 1;
                   STEP[IPMT] <= 0;
                   PMT_TRIG[IPMT] <= 0;
                   THIS_STEP[IPMT] <= 0;
                end
              else
                begin
                   // Accumulate positive steps
                   THIS_STEP[IPMT][`ADC_WIDTH:0]
                  <= ADC[IPMT][`ADC_WIDTH-1:0] - PREV_ADC[IPMT][`ADC_WIDTH-1:0];
                   
	           if (THIS_STEP[IPMT] >= 0) 
                     begin
	                STEP[IPMT][`ADC_WIDTH+1:0] <= STEP[IPMT][`ADC_WIDTH:0] + 
                                                     THIS_STEP[IPMT][`ADC_WIDTH:0];
                        PMT_TRIG[IPMT] <= 0;
                     end
                   else
                     begin
                        // Positive step is finished.  Do we have a
                        // single IPMT occupancy increase?
	                if ((STEP[IPMT][`ADC_WIDTH-1:0] <= MAX[IPMT][`ADC_WIDTH-1:0])
                            && (STEP[IPMT][`ADC_WIDTH-1:0] > MIN[IPMT][`ADC_WIDTH-1:0]) 
                            && (TRIG_ENABLE[IPMT] == 1)) PMT_TRIG[IPMT] <= 1;
                        else
                          PMT_TRIG[IPMT] <= 0;

                        STEP[IPMT] <= 0;
                     end // else: !if(THIS_STEP[IPMT] > 0)
                end // else: !if(VETO_COUNTER[IPMT] > 0)
              
              WINDOW[IPMT][`MOPS_WIDTH-1:0] 
                <= {WINDOW[IPMT][`MOPS_WIDTH-2:0],PMT_TRIG[IPMT]};
              if (WINDOW[IPMT][`MOPS_WIDTH-1] && !PMT_TRIG[IPMT])
                OCC_COUNTER[IPMT] <= OCC_COUNTER[IPMT] - 1;
              else if ((!WINDOW[IPMT][`MOPS_WIDTH-1]) && PMT_TRIG[IPMT])
                OCC_COUNTER[IPMT] <= OCC_COUNTER[IPMT] + 1;
              if ((OCC_COUNTER[IPMT] > OCCUPANCY) &&
                  (INTEGRAL[IPMT] > INT)) SB_TRIG[IPMT] <= 1;
              else SB_TRIG[IPMT] <= 0;
           end // for (IPMT=0; IPMT<3; IPMT=IPMT+1)

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

      // First half of veto computation -- we do this in the 2nd and 3rd phases of clock to
      // get result before the next time ENABLE40 = 0.
      if (LCL_ENABLE40 == 1) begin
         for (JPMT=0; JPMT<3; JPMT=JPMT+1) 
           begin
              if (THIS_STEP[JPMT] < 0)
                begin
                   // Compute LOG2(STEP)
                   LOG2[JPMT][0:0] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111111111110) == 0);
                   LOG2[JPMT][1:1] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111111111100) == 0);
                   LOG2[JPMT][2:2] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111111111000) == 0);
                   LOG2[JPMT][3:3] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111111110000) == 0);
                   LOG2[JPMT][4:4] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111111100000) == 0);
                   LOG2[JPMT][5:5] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111111000000) == 0);
                   LOG2[JPMT][6:6] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111110000000) == 0);
                   LOG2[JPMT][7:7] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111100000000) == 0);
                   LOG2[JPMT][8:8] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b111000000000) == 0);
                   LOG2[JPMT][9:9] <= ((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b110000000000) == 0);
                   LOG2[JPMT][10:10]<=((STEP[JPMT][`ADC_WIDTH-1:0] & 12'b100000000000) == 0);
                   LOG2[JPMT][11:11]<= 1;
                end // if (THIS_STEP[JPMT < 0)
           end // for (JPMT=0; PMT<3; PMT=PMT+1)
      end // if (LCL_ENABLE40 == 1)

      // 2nd half of veto computatation.  
      if (LCL_ENABLE40 == 2) begin
         for (KPMT=0; KPMT<3; KPMT=KPMT+1) 
           begin
              if (THIS_STEP[KPMT] < 0)
                begin
                   // Apply veto count to this step. 
                   if (LOG2[KPMT][0:0]) VETO_COUNTER[KPMT] <= 0 - THIS_OFS;
                   else if (LOG2[KPMT][1:1]) VETO_COUNTER[KPMT] <= 1 - THIS_OFS;
                   else if (LOG2[KPMT][2:2]) VETO_COUNTER[KPMT] <= 2 - THIS_OFS;
                   else if (LOG2[KPMT][3:3]) VETO_COUNTER[KPMT] <= 3 - THIS_OFS;
                   else if (LOG2[KPMT][4:4]) VETO_COUNTER[KPMT] <= 4 - THIS_OFS;
                   else if (LOG2[KPMT][5:5]) VETO_COUNTER[KPMT] <= 5 - THIS_OFS;
                   else if (LOG2[KPMT][6:6]) VETO_COUNTER[KPMT] <= 6 - THIS_OFS;
                   else if (LOG2[KPMT][7:7]) VETO_COUNTER[KPMT] <= 7 - THIS_OFS;
                   else if (LOG2[KPMT][8:8]) VETO_COUNTER[KPMT] <= 8 - THIS_OFS;
                   else if (LOG2[KPMT][9:9]) VETO_COUNTER[KPMT] <= 9 - THIS_OFS;
                   else if (LOG2[KPMT][10:10]) VETO_COUNTER[KPMT] <= 10 - THIS_OFS;
                   else if (LOG2[KPMT][11:11]) VETO_COUNTER[KPMT] <= 11 - THIS_OFS;
                   LOG2[KPMT] <= 0;
                end // if (THIS_STEP[KPMT] < 0)
           end
      end
      
`ifdef COMPAT_MOPS_DEBUG
      if (LCL_ENABLE40 == 2)
        begin
           DEBUG[11:0] <= STEP[0][11:0];
           DEBUG[23:12] <= STEP[1][11:0];
           DEBUG[35:24] <= STEP[2][11:0];
           DEBUG[39:36] <= OCC_COUNTER[0][3:0];
           DEBUG[43:40] <= OCC_COUNTER[1][3:0];
           DEBUG[47:44] <= OCC_COUNTER[2][3:0];
//           DEBUG[39:36] <= VETO_COUNTER[0][3:0];
//           DEBUG[43:40] <= VETO_COUNTER[1][3:0];
//           DEBUG[47:44] <= VETO_COUNTER[2][3:0];
           DEBUG[59:48] <= INTEGRAL0[11:0];
           DEBUG[71:60] <= INTEGRAL1[11:0];
           DEBUG[83:72] <= INTEGRAL2[11:0];
        end
`endif      
      
   end // always @ (posedge CLK120)
endmodule
