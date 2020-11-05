// This module implements the 40 MHz compatibility mode ToTd trigger.
//
// 21-Jun-2018 DFN Initial version
// 28-Jun-2018 DFN Need to add integral constraint yet
// 17-Aug-2018 DFN Add integral constraint
// 22-Sep-2018 DFN Remove unnecessary resets; add requirement that not
//                 triggered on previous clock cycle
// 14-Oct-2018 DFn Add missing UPx registers
// 30-Oct-2020 DFN Add LCL_ENABLE40 to reduce load on ENABLE40
// 04-nOV-2020 DFN Change WIDTH from 122 to 121 & rename to TOTD_WIDTH

`include "sde_trigger_defs.vh"

`define TRG_DLY 4
`define TOTD_WIDTH 121
`define TOTD_WIDTH_SIZE (`WIDTH_BITS-2)

module totd_40mhz(
		  input [1:0] ENABLE40,
		  input CLK120,
                  input RESET,
		  input [`ADC_WIDTH-1:0] ADC0,
		  input [`ADC_WIDTH-1:0] ADC1,
		  input [`ADC_WIDTH-1:0] ADC2,
                  input [`ADC_WIDTH+`SHWR_BASELINE_EXTRA_BITS-1:0] BASELINE0,
                  input [`ADC_WIDTH+`SHWR_BASELINE_EXTRA_BITS-1:0] BASELINE1,
                  input [`ADC_WIDTH+`SHWR_BASELINE_EXTRA_BITS-1:0] BASELINE2,
		  input [`ADC_WIDTH-1:0] THRES0,
		  input [`ADC_WIDTH-1:0] THRES1,
		  input [`ADC_WIDTH-1:0] THRES2,
		  input [`ADC_WIDTH-1:0] UP0,
		  input [`ADC_WIDTH-1:0] UP1,
		  input [`ADC_WIDTH-1:0] UP2,
		  input [2:0] TRIG_ENABLE,
		  input [1:0] MULTIPLICITY,
                  input [`TOTD_WIDTH_SIZE-1:0] OCCUPANCY,
                  input [`COMPATIBILITY_TOTD_FD_BITS-1:0] FD,
                  input [`COMPATIBILITY_TOTD_FN_BITS-1:0] FN,
                  input [`COMPATIBILITY_INTEGRAL_BITS-1:0] INT,
		  output reg TRIG
`ifdef COMPAT_TOTD_DEBUG
                  ,output reg [59:0] DEBUG
`endif
		  );

   reg                       SB_TRIG[2:0];
   reg [`TOTD_WIDTH-1:0]          WINDOW[2:0];
   reg [`TOTD_WIDTH_SIZE-1:0] OCC_COUNTER[2:0];
   reg [2:0]                  PMT_TRIG;
   reg [1:0]                  SUM_PMT_TRIGS;
   reg [`ADC_WIDTH-1:0]       THRES[2:0];
   reg [`ADC_WIDTH-1:0]       UP[2:0];
   reg                        TRIG_NOW;
   reg                        TRIG_PREV;
   reg [`ADC_WIDTH-1:0]       ADCD[2:0];
   reg [1:0]                  LCL_ENABLE40;
   wire [`ADC_WIDTH-1:0]      ADCD0;
   wire [`ADC_WIDTH-1:0]      ADCD1;
   wire [`ADC_WIDTH-1:0]      ADCD2;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL0;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL1;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL2;
   reg [`COMPATIBILITY_INTEGRAL_BITS-1:0]  INTEGRAL[2:0];
   
`ifdef COMPAT_TOTD_DECONV_DEBUG
   wire [59:0]                             DECONV_DEBUG0;
   wire [59:0]                             DECONV_DEBUG1;
   wire [59:0]                             DECONV_DEBUG2;
`endif
`ifdef COMPAT_TOTD_INTGRL_DEBUG
   wire [47:0]                             INTEGRAL_DEBUG0;
   wire [47:0]                             INTEGRAL_DEBUG1;
   wire [47:0]                             INTEGRAL_DEBUG2;
`endif
   
   integer                                 INDEX;
   
   // Deconvolute each filtered FADC trace
   deconvolve_40mhz deconv0(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC_IN(ADC0),
                            .BASELINE(BASELINE0),
                            .FD(FD),
                            .FN(FN),
                            .ADC_OUT(ADCD0)
`ifdef COMPAT_TOTD_DECONV_DEBUG
                            ,.DEBUG(DECONV_DEBUG0)
`endif
                            );
   deconvolve_40mhz deconv1(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC_IN(ADC1),
                            .BASELINE(BASELINE1),
                            .FD(FD),
                            .FN(FN),
                            .ADC_OUT(ADCD1)
`ifdef COMPAT_TOTD_DECONV_DEBUG
                            ,.DEBUG(DECONV_DEBUG1)
`endif
                            );
   deconvolve_40mhz deconv2(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC_IN(ADC2),
                            .BASELINE(BASELINE2),
                            .FD(FD),
                            .FN(FN),
                            .ADC_OUT(ADCD2)
`ifdef COMPAT_TOTD_DECONV_DEBUG
                            ,.DEBUG(DECONV_DEBUG2)
`endif
                            );

   integral_40mhz integral0(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC0),
                            .INTEGRAL(INTEGRAL0)
`ifdef COMPAT_TOTD_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG0)
`endif
                            );
   integral_40mhz integral1(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC1),
                            .INTEGRAL(INTEGRAL1)
`ifdef COMPAT_TOTD_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG1)
`endif
                            );
   integral_40mhz integral2(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC2),
                            .INTEGRAL(INTEGRAL2)
`ifdef COMPAT_TOTD_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG2)
`endif
                            );
   
   always @(posedge CLK120) begin
      LCL_ENABLE40 <= ENABLE40;
      
      if (LCL_ENABLE40 == 0) begin
         
         // First do a simple single bin trigger on each bin
         for (INDEX=0; INDEX<3; INDEX=INDEX+1) begin
	    if ((THRES[INDEX] < ADCD[INDEX]) 
                && (UP[INDEX] >= ADCD[INDEX])
                && (TRIG_ENABLE[INDEX] == 1)) 
	      PMT_TRIG[INDEX] <= 1;
	    else 
	      PMT_TRIG[INDEX] <= 0;
            WINDOW[INDEX][`TOTD_WIDTH-1:0]
              <= {WINDOW[INDEX][`TOTD_WIDTH-2:0],PMT_TRIG[INDEX]};
            if (WINDOW[INDEX][`TOTD_WIDTH-1] && !PMT_TRIG[INDEX])
              OCC_COUNTER[INDEX] <= OCC_COUNTER[INDEX]-1;
            else if (!WINDOW[INDEX][`TOTD_WIDTH-1] && PMT_TRIG[INDEX])
              OCC_COUNTER[INDEX] <= OCC_COUNTER[INDEX]+1;
            if ((OCC_COUNTER[INDEX] > OCCUPANCY) &&
                (INTEGRAL[INDEX] > INT)) SB_TRIG[INDEX] <= 1;
            else SB_TRIG[INDEX] <= 0;
         end // for (INDEX=0; INDEX<3; INDEX=INDEX+1)
      end  // Downsampled loop
      
      THRES[0] <= THRES0;
      THRES[1] <= THRES1;
      THRES[2] <= THRES2;
      UP[0] <= UP0;
      UP[1] <= UP1;
      UP[2] <= UP2;
      ADCD[0] <= ADCD0;
      ADCD[1] <= ADCD1;
      ADCD[2] <= ADCD2;
      INTEGRAL[0] <= INTEGRAL0;
      INTEGRAL[1] <= INTEGRAL1;
      INTEGRAL[2] <= INTEGRAL2;

      SUM_PMT_TRIGS <= SB_TRIG[0] + SB_TRIG[1] + SB_TRIG[2];
      if ((SUM_PMT_TRIGS >= MULTIPLICITY) && (MULTIPLICITY != 0)) begin
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

      // Debug outputs
      `ifdef`COMPAT_TOTD_DECONV_DEBUG
        DEBUG <= DECONV_DEBUG0;
`endif
`ifdef COMPAT_TOTD_INTGRL_DEBUG
      DEBUG[11:0] <= INTEGRAL_DEBUG0[11:0];
      DEBUG[23:12] <= INTEGRAL_DEBUG0[23:12];
      DEBUG[35:24] <= INTEGRAL_DEBUG0[35:24];
      DEBUG[47:36] <= INTEGRAL_DEBUG0[47:36];
      if (INTEGRAL0 < 4095)
        DEBUG[59:48] <= INTEGRAL0[11:0];
      else 
        DEBUG[59:48] <= 0;

`endif //  `ifdef COMPAT_TOTD_INTGRL_DEBUG
`ifdef COMPAT_TOTD_TRIG_DEBUG
      DEBUG[11:0] <= ADCD0[11:0];
      DEBUG[23:12] <= ADCD1[11:0];
      DEBUG[35:24] <= ADCD2[11:0];
      DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
                      (OCC_COUNTER[1][3:0] << 4) |
                      (OCC_COUNTER[2][3:0] << 8);
      DEBUG[48] <= SB_TRIG[0];
      DEBUG[49] <= SB_TRIG[1];
      DEBUG[50] <= SB_TRIG[2];
      DEBUG[51] <= TRIG_NOW;
      DEBUG[53:52] <= SUM_PMT_TRIGS;
      DEBUG[59:54] <= 0;
`endif
      
   end
   
endmodule
