 // integral_40mhz.v
//
// This keeps track of the continuos integral of a shower signal for
// triggering purposes.
//
// 01-Jul-2018 DFN Initial version
// 16-Jan-2021 DFN Modify to compute integral relative to baseline and
//                 to reset large signals after integration period
// 22-Jan-2021 DFN Modify to decay at linear rate rather than exponential

`include "sde_trigger_defs.vh"

module integral_40mhz(
		      
 input 					CLK,
 input [1:0] 				ENABLE40,
 input [`ADC_WIDTH-1:0] 		ADC,
 input [`COMPAT_INTEGRAL_BITS-3:0]	THRESHOLD,
 output reg [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL
`ifdef COMPAT_TOTD_INTGRL_DEBUG
		      ,output reg[47:0] DEBUG
`endif
		      );

   reg [`COMPAT_INTEGRAL_BITS-1+`COMPAT_FRAC_BITS:0] INTEGRALA;
   reg [`COMPAT_INTEGRAL_BITS-1+`COMPAT_FRAC_BITS:0] DECAY;
   reg [`COMPAT_INTEGRAL_BITS-1+`COMPAT_FRAC_BITS:0] DELTA;
   reg [`COMPAT_INTEGRAL_BITS-1:0] INTEGRAL_DELAY[0:`COMPAT_INTEGRAL_WIDTH];
   reg [`COMPAT_INTEGRAL_BITS-1:0] DLYD_INTEGRAL;
   reg [`ADC_WIDTH+`COMPAT_FRAC_BITS-1:0] ADCLONG;
   reg [`ADC_WIDTH+`COMPAT_FRAC_BITS-1:0] BASELINE;
   reg [`ADC_WIDTH+`COMPAT_FRAC_BITS-1:0] BASELINE_PLUS_HALF;
   reg [`ADC_WIDTH+`COMPAT_FRAC_BITS-1:0] BASELINE_MINUS_HALF;
   reg [`ADC_WIDTH+`COMPAT_FRAC_BITS-1:0] BASELINE_PLUS_ONE;
   reg [`ADC_WIDTH+`COMPAT_FRAC_BITS-1:0] BASELINE_MINUS_ONE;
   
   integer              J;
   
   
   always @(posedge CLK) begin
      if (ENABLE40 == 0) begin

	 // Keep track of integral history
         INTEGRAL_DELAY[0] <= INTEGRAL;
         for (J=1; J<=`COMPAT_INTEGRAL_WIDTH; J=J+1)
           INTEGRAL_DELAY[J] <= INTEGRAL_DELAY[J-1];
         DLYD_INTEGRAL <= INTEGRAL_DELAY[`COMPAT_INTEGRAL_WIDTH];
	 
	 ADCLONG[`ADC_WIDTH+`COMPAT_FRAC_BITS-1:`COMPAT_FRAC_BITS] <= ADC;
	 ADCLONG[`COMPAT_FRAC_BITS-1:0] <= 0;
	 
         // Get delta of signal from baseline
         DELTA <= ADCLONG - BASELINE;
	 
	 // Decay integral to 0 at constant rate
	 if (INTEGRALA[`COMPAT_INTEGRAL_BITS+`COMPAT_FRAC_BITS-1] == 0)
	   DECAY <= `COMPAT_INTEGRAL_DECAY;
	 else
	   DECAY <= 0;
	 
	 // Keep integral positive and also reset integral if previously
	 // passed integral threshold
	 if ((INTEGRALA[`COMPAT_INTEGRAL_BITS+`COMPAT_FRAC_BITS-1] == 1)
	     || (DLYD_INTEGRAL > {2'b00,THRESHOLD})) INTEGRALA <= 0;

	// Limit integral to 2*THRESHOLD (exclusive of above). Integral may
	// briefly exceed 2*THRESHOLD if DELTA applied later is positive. 
	 else if (INTEGRAL[`COMPAT_INTEGRAL_BITS-1:0] > {1'b0,THRESHOLD,1'b0})
	   begin
	      INTEGRALA[`COMPAT_INTEGRAL_BITS+`COMPAT_FRAC_BITS-1:
			`COMPAT_FRAC_BITS] <= {1'b0,THRESHOLD,1'b0};
	      INTEGRALA[`COMPAT_FRAC_BITS-1:0] <= 0;
	   end

	 // Precompute this for later use
	 BASELINE_PLUS_HALF <= BASELINE + `COMPAT_BASE_HALF;
	 BASELINE_MINUS_HALF <= BASELINE - `COMPAT_BASE_HALF;
	 BASELINE_PLUS_ONE <= BASELINE + `COMPAT_BASE_ONE;
	 BASELINE_MINUS_ONE <= BASELINE - `COMPAT_BASE_ONE;
	 
      end // if (ENABLE40 == 0)

      if (ENABLE40 == 1) begin
	 INTEGRAL <= INTEGRALA[`COMPAT_INTEGRAL_BITS+`COMPAT_FRAC_BITS-1:
			       `COMPAT_FRAC_BITS];     
	 INTEGRALA <= INTEGRALA + DELTA;

	 // Keep track of baseline
	 if (ADCLONG > BASELINE_PLUS_ONE)
	   BASELINE <= BASELINE +
			(4 << (`COMPAT_FRAC_BITS-`COMPAT_BASE_BITS));
	 else if (ADCLONG > BASELINE_PLUS_HALF)
	   BASELINE <= BASELINE +
			(2 << (`COMPAT_FRAC_BITS-`COMPAT_BASE_BITS));
	 else if (ADCLONG > BASELINE)
	   BASELINE <= BASELINE +
			(1 << (`COMPAT_FRAC_BITS-`COMPAT_BASE_BITS));
	 else if (ADCLONG < BASELINE_MINUS_ONE)
	   BASELINE <= BASELINE - 
			(4 << (`COMPAT_FRAC_BITS-`COMPAT_BASE_BITS));
	 else if (ADCLONG < BASELINE_MINUS_HALF)
	   BASELINE <= BASELINE - 
			(2 << (`COMPAT_FRAC_BITS-`COMPAT_BASE_BITS));
	 else if  (ADCLONG < BASELINE)
	   BASELINE <= BASELINE - 
			(1 << (`COMPAT_FRAC_BITS-`COMPAT_BASE_BITS));
      end

      if (ENABLE40 == 2) begin
	 if (INTEGRALA[`COMPAT_INTEGRAL_BITS+`COMPAT_FRAC_BITS-1] == 0)
	   INTEGRALA <= INTEGRALA - DECAY;
	 else
	   INTEGRALA <= 0;
      
`ifdef COMPAT_TOTD_INTGRL_DEBUG
	 DEBUG[11:0] <= BASELINE[`COMPAT_FRAC_BITS+7:`COMPAT_FRAC_BITS-4];
	 DEBUG[23:12] <= DECAY[11:0];
	 DEBUG[35:24] <= DELTA[`COMPAT_FRAC_BITS+7:`COMPAT_FRAC_BITS-4];
	 DEBUG[47:36] <= INTEGRALA[`COMPAT_FRAC_BITS+10:`COMPAT_FRAC_BITS-1];
`endif

      end
   end // always @ (posedge CLK120)
   
endmodule // integral_40mhz
