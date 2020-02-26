 // integral_40mhz.v
//
// This keeps track of the continuos integral of a shower signal for
// triggering purposes.
//
// 01-Jul-2018 DFN Initial version

`include "sde_trigger_defs.vh"

module integral_40mhz(
		      input CLK,
                      input[1:0] ENABLE40,
		      input [`ADC_WIDTH-1:0] ADC,
		      output reg[`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL
                      `ifdef COMPAT_TOTD_INTGRL_DEBUG
                      ,output reg[47:0] DEBUG
                      `endif		      );
   
//   (* dont_touch = "true" *) reg [`COMPATIBILITY_INTEGRAL_BITS-1+`COMPATIBILITY_FRAC_BITS:0] INTEGRALA;
//   (* dont_touch = "true" *) reg [`COMPATIBILITY_INTEGRAL_BITS-1+`COMPATIBILITY_FRAC_BITS:0] DECAY;
//   (* dont_touch = "true" *) reg [`COMPATIBILITY_INTEGRAL_BITS-1+`COMPATIBILITY_FRAC_BITS:0] DELTA;
      (* dont_touch = "true" *) reg signed [`COMPATIBILITY_INTEGRAL_BITS-1+`COMPATIBILITY_FRAC_BITS:0] INTEGRALA;
   (* dont_touch = "true" *) reg signed [`COMPATIBILITY_INTEGRAL_BITS-1+`COMPATIBILITY_FRAC_BITS:0] DECAY;
   (* dont_touch = "true" *) reg signed [`COMPATIBILITY_INTEGRAL_BITS-1+`COMPATIBILITY_FRAC_BITS:0] DELTA;
   reg [`ADC_WIDTH-1:0] BASELINE_DELAY[0:`COMPATIBILITY_BASELINE_DELAY];
   reg [`ADC_WIDTH-1:0] BASELINE;
   integer              J;

   
   always @(posedge CLK) begin
      if (ENABLE40 == 0) begin
         // We need to keep track of ADC value in the past to use
         // as baseline for integral.
         BASELINE_DELAY[0] <= ADC;
         for (J=1; J<=`COMPATIBILITY_BASELINE_DELAY; J=J+1)
           BASELINE_DELAY[J] <= BASELINE_DELAY[J-1];
         BASELINE <= BASELINE_DELAY[`COMPATIBILITY_BASELINE_DELAY];

         // Get delta of signal from baseline
         DELTA <= ((ADC - BASELINE) <<< `COMPATIBILITY_FRAC_BITS);

         // Decay integral to 0 with COMPATIBILITY_DECAY_BITS time constant
         DECAY <= INTEGRALA >>> `COMPATIBILITY_DECAY_BITS;
 
        // Keep integral from abruptly flipping from positive to negative or
         // visa-versa due to exceeding the number of bits.
         //        if ((INTEGRAL>0) && (DELTA>0) && (INTEGRALA<0))
         //          INTEGRAL <= (1 << `COMPATIBILITY_INTEGRAL_BITS-1+
         //                       `COMPATIBILITY_FRAC_BITS)-1;
         //        else if ((INTEGRAL<0) && (DELTA<0) && (INTEGRALA>0))
         //          INTEGRAL <= (1 << `COMPATIBILITY_INTEGRAL_BITS-1+
         //                       `COMPATIBILITY_FRAC_BITS);
         // Keep INTEGRAL positive
         if (INTEGRALA[`COMPATIBILITY_INTEGRAL_BITS
                       +`COMPATIBILITY_FRAC_BITS-1] == 1)
           begin
              INTEGRAL <= 0;
              INTEGRALA <= 0;
           end
         else
           INTEGRAL <= INTEGRALA[`COMPATIBILITY_INTEGRAL_BITS
                                 +`COMPATIBILITY_FRAC_BITS-1:
                                 `COMPATIBILITY_FRAC_BITS];         
      end // if (ENABLE40 == 0)
      else if (ENABLE40 == 1) begin
         INTEGRALA <= INTEGRALA + DELTA;
      end
      else if (ENABLE40 == 2) begin
         INTEGRALA <= INTEGRALA - DECAY;
      end
   
      `ifdef COMPAT_TOTD_INTGRL_DEBUG
      DEBUG[11:0] <= BASELINE;
      DEBUG[22:12] <= DECAY[10:0];
      DEBUG[23] <= DECAY[`COMPATIBILITY_INTEGRAL_BITS
                         -1+`COMPATIBILITY_FRAC_BITS];
      DEBUG[34:24] <= DELTA[`COMPATIBILITY_FRAC_BITS+11:
                            `COMPATIBILITY_FRAC_BITS];
      DEBUG[35] <= DELTA[`COMPATIBILITY_INTEGRAL_BITS
                            -1+`COMPATIBILITY_FRAC_BITS];
      DEBUG[46:36] <= INTEGRALA[`COMPATIBILITY_FRAC_BITS+11:
                                `COMPATIBILITY_FRAC_BITS];
      DEBUG[47] <= INTEGRALA[`COMPATIBILITY_INTEGRAL_BITS
                            -1+`COMPATIBILITY_FRAC_BITS];

      `endif
   end // always @ (posedge CLK120)
   
endmodule // integral_40mhz
