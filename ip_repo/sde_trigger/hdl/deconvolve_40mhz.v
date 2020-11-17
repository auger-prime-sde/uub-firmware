//  deconvolute_40mhz.v
//
//  This module implements one instance of a FADC trace deconvolution.
//
//  Note that the master enable and any inhibit conditions are applied
//  externally to the output of this module.
//
//
//   21-Jun-2018 DFN Initial version (ported from deconvolute.tdf)
//   08-Nov-2020 DFN Remove constraint signal above baseline.

`include "sde_trigger_defs.vh"

module deconvolve_40mhz(
                        input CLK,               // 120 MHz clock
                        input [1:0] ENABLE40,          // Clock enable for 40 MHz
                        input [`ADC_WIDTH-1:0] ADC_IN, // Filtered ADC input
                        input [`COMPATIBILITY_TOTD_FD_BITS-1:0] FD, // .yyyyyy Fractional decay constant
                        input [`COMPATIBILITY_TOTD_FN_BITS-1:0] FN, // xx.yyyy fixed point normalizer
                        output reg [`ADC_WIDTH-1:0] ADC_OUT // Output deconvoluted value
`ifdef COMPAT_TOTD_DECONV_DEBUG
                        ,output reg [59:0] DEBUG
`endif
                        );
   
   // Pipeline registers
   (* dont_touch = "true" *) reg [`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1:0] INT_A;
   (* dont_touch = "true" *) reg [`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH:0] INT_B;
   (* dont_touch = "true" *) reg [`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1:0] INT_C;
   (* dont_touch = "true" *) reg [`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH+`COMPATIBILITY_TOTD_FN_BITS-1:0] INT_D;
   (* dont_touch = "true" *) reg [`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH+`COMPATIBILITY_TOTD_FN_BITS:0] INT_E;
   (* dont_touch = "true" *) reg [`ADC_WIDTH-1:0] ADC_LIMITED; // ADC constrained to be > pedestal

   
   always @(posedge CLK) begin
      if (ENABLE40 == 0) begin
         ADC_LIMITED <= ADC_IN;

         // Multiply previous ADC value by decay factor.  
         // Result will have 6 fractional binary digits.
         INT_A <= ADC_LIMITED * FD;
         
         // Subtract result of previous stage from current limited ADC value.
         // Note that the clock delays in the previous operation means this
         // calculation is taking the current ADC value and subtracting the
         // product of the previous ADC value and the decay constant - just
         // what we want.
         INT_B <= {ADC_LIMITED,`COMPATIBILITY_TOTD_FD_BITS'b0} - INT_A;

         // Test if result of previous stage is less than zero.  
         // If so, replace with zero.
         if (INT_B[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH])
           INT_C <= 0;
         else
           INT_C <= INT_B[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1:0];
         
         // Multiply what we have so far by the nomalizer
         INT_D <= INT_C * FN;

         // Add 1/2 to force rounding rather than truncation
         INT_E <= INT_D + (1 << `COMPATIBILITY_TOTD_FN_FRAC_BITS+`COMPATIBILITY_TOTD_FD_BITS-1);
         
         // Load output value, limiting maximum value to 4095.
         if ( INT_E[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH+`COMPATIBILITY_TOTD_FN_FRAC_BITS])
           ADC_OUT <= 4095;
         else
           ADC_OUT <= INT_E[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1+
                            `COMPATIBILITY_TOTD_FN_FRAC_BITS:
                            `COMPATIBILITY_TOTD_FD_BITS+`COMPATIBILITY_TOTD_FN_FRAC_BITS];
      end
      else begin
         ADC_LIMITED <= ADC_LIMITED;
         INT_A <= INT_A;
         INT_B <= INT_B;
         INT_C <= INT_C;
         INT_D <= INT_D;
         INT_E <= INT_E;
         ADC_OUT <= ADC_OUT;
      end
      
 `ifdef COMPAT_TOTD_DECONV_DEBUG
      DEBUG[11:0]  <= ADC_LIMITED;
      DEBUG[23:12] <= INT_A[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1:`COMPATIBILITY_TOTD_FD_BITS];
      DEBUG[35:24] <= INT_C[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1:`COMPATIBILITY_TOTD_FD_BITS];
      DEBUG[47:36] <= INT_E[`COMPATIBILITY_TOTD_FD_BITS+`ADC_WIDTH-1+`COMPATIBILITY_TOTD_FN_FRAC_BITS:
                            `COMPATIBILITY_TOTD_FD_BITS+`COMPATIBILITY_TOTD_FN_FRAC_BITS];
      DEBUG[59:48] <= ADC_OUT;
`endif
   end

endmodule
