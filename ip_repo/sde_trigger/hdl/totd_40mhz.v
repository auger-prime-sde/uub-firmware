// This module implements the 40 MHz compatibility mode ToTd trigger.
//
// 21-Jun-2018 DFN Initial version
// 28-Jun-2018 DFN Need to add integral constraint yet
// 17-Aug-2018 DFN Add integral constraint
// 22-Sep-2018 DFN Remove unnecessary resets; add requirement that not
//                 triggered on previous clock cycle
// 14-Oct-2018 DFn Add missing UPx registers
// 30-Oct-2020 DFN Add LCL_ENABLE40 to reduce load on ENABLE40
// 04-Nov-2020 DFN Change WIDTH from 122 to 121 & rename to TOTD_WIDTH
// 09-Nov-2020 DFN Remove Baseline arguments
// 16-Nov-2020 DFN Change TOTD_WIDTH to 120
// 28-Jan-2021 DFN Add delay to synchronize integral with occupancy

`include "sde_trigger_defs.vh"

`define TRG_DLY 4
`define TOTD_WIDTH 120
`define TOTD_WIDTH_SIZE (`WIDTH_BITS-2)
`define TOTD_INTEGRAL_DLY 4

module totd_40mhz(
		  input [1:0] 				  ENABLE40,
		  input 				  CLK120,
		  input [`ADC_WIDTH-1:0] 		  ADC0,
		  input [`ADC_WIDTH-1:0] 		  ADC1,
		  input [`ADC_WIDTH-1:0] 		  ADC2,
		  input [`ADC_WIDTH-1:0] 		  THRES0,
		  input [`ADC_WIDTH-1:0] 		  THRES1,
		  input [`ADC_WIDTH-1:0] 		  THRES2,
		  input [`ADC_WIDTH-1:0] 		  UP0,
		  input [`ADC_WIDTH-1:0] 		  UP1,
		  input [`ADC_WIDTH-1:0] 		  UP2,
		  input [2:0] 				  TRIG_ENABLE,
		  input [1:0] 				  MULTIPLICITY,
                  input [`TOTD_WIDTH_SIZE-1:0] 		  OCCUPANCY,
                  input [`COMPATIBILITY_TOTD_FD_BITS-1:0] FD,
                  input [`COMPATIBILITY_TOTD_FN_BITS-1:0] FN,
                  input [`COMPAT_INTEGRAL_BITS-3:0] 	  INT,
		  output reg 				  TRIG
`ifdef COMPAT_TOTD_DEBUG
		  ,output reg [59:0] DEBUG
`endif
		  );

   reg 				    SB_TRIG[2:0];
   reg [`TOTD_WIDTH-1:0] 	    WINDOW[2:0];
   reg [`TOTD_WIDTH_SIZE:0] 	    OCC_COUNTER[2:0];
   reg [2:0] 			    PMT_TRIG;
   reg [1:0] 			    SUM_PMT_TRIGS;
   reg [`ADC_WIDTH-1:0] 	    THRES[2:0];
   reg [`ADC_WIDTH-1:0] 	    UP[2:0];
   reg 				    TRIG_NOW;
   reg 				    TRIG_PREV;
   reg [`ADC_WIDTH-1:0] 	    ADCD[2:0];
   reg [1:0] 			    LCL_ENABLE40;
   wire [`ADC_WIDTH-1:0] 	    ADCD0;
   wire [`ADC_WIDTH-1:0] 	    ADCD1;
   wire [`ADC_WIDTH-1:0] 	    ADCD2;
   wire [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL0;
   wire [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL1;
   wire [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL2;
   reg [`COMPAT_INTEGRAL_BITS-1:0]  DLYD_INTEGRAL0[0:`TOTD_INTEGRAL_DLY];
   reg [`COMPAT_INTEGRAL_BITS-1:0]  DLYD_INTEGRAL1[0:`TOTD_INTEGRAL_DLY];
   reg [`COMPAT_INTEGRAL_BITS-1:0]  DLYD_INTEGRAL2[0:`TOTD_INTEGRAL_DLY];
   reg [`COMPAT_INTEGRAL_BITS-1:0]  INTEGRAL[2:0];

`ifdef COMPAT_TOTD_DECONV_DEBUG
   wire [59:0] 			  DECONV_DEBUG0;
   wire [59:0] 			  DECONV_DEBUG1;
   wire [59:0] 			  DECONV_DEBUG2;
`endif
`ifdef COMPAT_TOTD_INTGRL_DEBUG
   wire [47:0] 			  INTEGRAL_DEBUG0;
   wire [47:0] 			  INTEGRAL_DEBUG1;
   wire [47:0] 			  INTEGRAL_DEBUG2;
`endif
   
   integer 			  INDEX;
   integer 			  J;
   
   // Deconvolute each filtered FADC trace
   deconvolve_40mhz deconv0(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC_IN(ADC0),
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
			    .THRESHOLD(INT),
                            .INTEGRAL(INTEGRAL0)
`ifdef COMPAT_TOTD_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG0)
`endif
                            );
   integral_40mhz integral1(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC1),
			    .THRESHOLD(INT),
                            .INTEGRAL(INTEGRAL1)
`ifdef COMPAT_TOTD_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG1)
`endif
                            );
   integral_40mhz integral2(
                            .CLK(CLK120),
                            .ENABLE40(LCL_ENABLE40),
                            .ADC(ADC2),
			    .THRESHOLD(INT),
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
		!INTEGRAL[INDEX][`COMPAT_INTEGRAL_BITS-1]
                && (INTEGRAL[INDEX] > INT)) SB_TRIG[INDEX] <= 1;
            else SB_TRIG[INDEX] <= 0;
         end // for (INDEX=0; INDEX<3; INDEX=INDEX+1)
	 
	 THRES[0] <= THRES0;
	 THRES[1] <= THRES1;
	 THRES[2] <= THRES2;
	 UP[0] <= UP0;
	 UP[1] <= UP1;
	 UP[2] <= UP2;
	 ADCD[0] <= ADCD0;
	 ADCD[1] <= ADCD1;
	 ADCD[2] <= ADCD2;

	 // Delay integral to compensate for deconvolution delay
	 DLYD_INTEGRAL0[0] <= INTEGRAL0;
	 DLYD_INTEGRAL1[0] <= INTEGRAL1;
	 DLYD_INTEGRAL2[0] <= INTEGRAL2;
	 for (J=1; J<=`TOTD_INTEGRAL_DLY; J=J+1)
	   begin
	      DLYD_INTEGRAL0[J] <= DLYD_INTEGRAL0[J-1];
	      DLYD_INTEGRAL1[J] <= DLYD_INTEGRAL1[J-1];
	      DLYD_INTEGRAL2[J] <= DLYD_INTEGRAL2[J-1];
	   end
	 INTEGRAL[0] <= DLYD_INTEGRAL0[`TOTD_INTEGRAL_DLY];
	 INTEGRAL[1] <= DLYD_INTEGRAL1[`TOTD_INTEGRAL_DLY];
	 INTEGRAL[2] <= DLYD_INTEGRAL2[`TOTD_INTEGRAL_DLY];

	 SUM_PMT_TRIGS <= SB_TRIG[0] + SB_TRIG[1] + SB_TRIG[2];
	 if ((SUM_PMT_TRIGS >= MULTIPLICITY) && (MULTIPLICITY != 0)) begin
	    TRIG_NOW <= 1;
	 end
	 else
	   TRIG_NOW <= 0;
	 
	 // Only trigger if did not trigger previous clock cycle
	 TRIG <= TRIG_NOW && !TRIG_PREV;
	 TRIG_PREV <= TRIG_NOW;

	 // Debug outputs
`ifdef COMPAT_TOTD_DECONV_DEBUG
         DEBUG[11:0] <= DECONV_DEBUG0[23:12];
         DEBUG[23:12] <= DECONV_DEBUG1[23:12];
         DEBUG[35:24] <= DECONV_DEBUG2[23:12];
	 DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
			 (OCC_COUNTER[1][3:0] << 4) |
			 (OCC_COUNTER[2][3:0] << 8);
	 DEBUG[48] <= SB_TRIG[0];
	 DEBUG[49] <= SB_TRIG[1];
	 DEBUG[50] <= SB_TRIG[2];
	 DEBUG[51] <= TRIG_NOW;
	 DEBUG[53:52] <= SUM_PMT_TRIGS;
	 DEBUG[59:54] <= 0;
`endif //  `ifdef COMPAT_TOTD_DECONV_DEBUG
	 

`ifdef COMPAT_TOTD_INTGRL_DEBUG
	 DEBUG[11:0] <= INTEGRAL[0][11:0];
	 DEBUG[23:12] <= INTEGRAL[1][11:0];
	 DEBUG[35:24] <= INTEGRAL[2][11:0];
	 DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
			 (OCC_COUNTER[1][3:0] << 4) |
			 (OCC_COUNTER[2][3:0] << 8);
	 DEBUG[48] <= SB_TRIG[0];
	 DEBUG[49] <= SB_TRIG[1];
	 DEBUG[50] <= SB_TRIG[2];
	 DEBUG[51] <= TRIG_NOW;
	 DEBUG[53:52] <= SUM_PMT_TRIGS;
	 DEBUG[59:54] <= 0;
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
`endif //  `ifdef COMPAT_TOTD_TRIG_DEBUG
	 
      end  // Downsampled loop

      // Need to do reset of OCC & WINDOW on different clock cycle than
      // above code to avoid possibly trying to increment and reset registers
      // on the same clock cycle.
      if (LCL_ENABLE40 == 1)
	begin
	   if (TRIG) begin
	      OCC_COUNTER[0] <= 0;
	      OCC_COUNTER[1] <= 0;
	      OCC_COUNTER[2] <= 0;
	      WINDOW[0] <= 0;
	      WINDOW[1] <= 0;
	      WINDOW[2] <= 0;
	   end

`ifdef COMPAT_TOTD_DECONV_DEBUG
         DEBUG[11:0] <= DECONV_DEBUG0[35:24];
         DEBUG[23:12] <= DECONV_DEBUG1[35:24];
         DEBUG[35:24] <= DECONV_DEBUG2[35:24];
	 DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
			 (OCC_COUNTER[1][3:0] << 4) |
			 (OCC_COUNTER[2][3:0] << 8);
	 DEBUG[48] <= SB_TRIG[0];
	 DEBUG[49] <= SB_TRIG[1];
	 DEBUG[50] <= SB_TRIG[2];
	 DEBUG[51] <= TRIG_NOW;
	 DEBUG[53:52] <= SUM_PMT_TRIGS;
	 DEBUG[59:54] <= 0;
`endif //  `ifdef COMPAT_TOTD_DECONV_DEBUG
	   

`ifdef COMPAT_TOTD_INTGRL_DEBUG
	   DEBUG[11:0] <= INTEGRAL_DEBUG0[11:0];
	   DEBUG[23:12] <= INTEGRAL_DEBUG1[11:0];
	   DEBUG[35:24] <= INTEGRAL_DEBUG2[11:0];
	   DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
			   (OCC_COUNTER[1][3:0] << 4) |
			   (OCC_COUNTER[2][3:0] << 8);
	   DEBUG[48] <= SB_TRIG[0];
	   DEBUG[49] <= SB_TRIG[1];
	   DEBUG[50] <= SB_TRIG[2];
	   DEBUG[51] <= TRIG_NOW;
	   DEBUG[53:52] <= SUM_PMT_TRIGS;
	   DEBUG[59:54] <= 0;
`endif //  `ifdef COMPAT_TOTD_INTGRL_DEBUG

	end

      if (LCL_ENABLE40 == 2)
	begin

`ifdef COMPAT_TOTD_DECONV_DEBUG
	   DEBUG[11:0] <= ADCD[0];
	   DEBUG[23:12] <= ADCD[1];
	   DEBUG[35:24] <= ADCD[2];
	   DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
			   (OCC_COUNTER[1][3:0] << 4) |
			   (OCC_COUNTER[2][3:0] << 8);
	   DEBUG[48] <= SB_TRIG[0];
	   DEBUG[49] <= SB_TRIG[1];
	   DEBUG[50] <= SB_TRIG[2];
	   DEBUG[51] <= TRIG_NOW;
	   DEBUG[53:52] <= SUM_PMT_TRIGS;
	   DEBUG[59:54] <= 0;
`endif //  `ifdef COMPAT_TOTD_DECONVL_DEBUG
	   

`ifdef COMPAT_TOTD_INTGRL_DEBUG
	   DEBUG[11:0] <= ADCD[0];
	   DEBUG[23:12] <= ADCD[1];
	   DEBUG[35:24] <= ADCD[2];
//	   DEBUG[11:0] <= INTEGRAL_DEBUG0[35:24];
//	   DEBUG[23:12] <= INTEGRAL_DEBUG1[35:24];
//	   DEBUG[35:24] <= INTEGRAL_DEBUG2[35:24];
	   DEBUG[47:36] <= (OCC_COUNTER[0][3:0]) |
			   (OCC_COUNTER[1][3:0] << 4) |
			   (OCC_COUNTER[2][3:0] << 8);
	   DEBUG[48] <= SB_TRIG[0];
	   DEBUG[49] <= SB_TRIG[1];
	   DEBUG[50] <= SB_TRIG[2];
	   DEBUG[51] <= TRIG_NOW;
	   DEBUG[53:52] <= SUM_PMT_TRIGS;
	   DEBUG[59:54] <= 0;
`endif //  `ifdef COMPAT_TOTD_INTGRL_DEBUG
	   
	end
   end
   
endmodule
