// This module implements the mops trigger
// 21-Jun-2019 DFN Initial version
`timescale 1 ns / 1 ps

`include "sde_trigger_defs.vh"
`define COMPATIBILITY_MOPS_OFS_BITS 4

`define TRG_DLY 4
`define WIDTH 122
`define MOPS_WIDTH_SIZE (`WIDTH_BITS-2)

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
	          input [`MOPS_WIDTH_SIZE-1:0] OCCUPANCY,
                  input [`COMPATIBILITY_INTEGRAL_BITS-1:0] INT,
                  input [`COMPATIBILITY_MOPS_OFS_BITS-1:0] OFS,
		  input [1:0] MULTIPLICITY,
   		  output reg TRIG,
                  output reg [4:0] DEBUG
		  );


   reg [`ADC_WIDTH-1:0]             ADC[2:0];
   reg                              SB_TRIG[2:0];
   reg [`WIDTH-1:0]                 WINDOW[2:0];
   reg [`MOPS_WIDTH_SIZE-1:0]       OCC_COUNTER[2:0];
   reg [2:0]                        PMT_TRIG;
   reg [1:0]                        SUM_PMT_TRIGS;
   reg [`ADC_WIDTH-1:0]             PREV_ADC[2:0];
   reg [`ADC_WIDTH-1:0]             DELTAA[2:0];
   reg [`ADC_WIDTH-1:0]             DELTAB[2:0];
   reg [`ADC_WIDTH-1:0]             DELTA[2:0];
   reg                              TRIG_NOW;
   reg                              TRIG_PREV;
   
   reg	[`ADC_WIDTH-1:0]            YMAX[2:0];
   reg	[`ADC_WIDTH-1:0]	    YMIN[2:0];
   
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL0;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL1;
   wire [`COMPATIBILITY_INTEGRAL_BITS-1:0] INTEGRAL2;
   reg [`COMPATIBILITY_INTEGRAL_BITS-1:0]  INTEGRAL[2:0];
   
   wire [`ADC_WIDTH-1:0]		           VETO_wire[2:0];	
   reg [`ADC_WIDTH-1:0]		           VETO[2:0];	
   reg [`ADC_WIDTH-1:0]		           VETO_COUNTER[2:0];
    reg                                 INDEX_BIN[2:0];
					

   integer                                INDEX;
 //  integer                                INDEX_BIN[2:0];


   integral_40mhz integral0(
                            .CLK(CLK120),
                            .ENABLE40(ENABLE40),
                            //.RESET(RESET),
                            .ADC(ADC0),
                            .INTEGRAL(INTEGRAL0)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG0)
`endif
                            );
   integral_40mhz integral1(
                            .CLK(CLK120),
                            .ENABLE40(ENABLE40),
                           // .RESET(RESET),
                            .ADC(ADC1),
                            .INTEGRAL(INTEGRAL1)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG1)
`endif
                            );
   integral_40mhz integral2(
                            .CLK(CLK120),
                            .ENABLE40(ENABLE40),
                           // .RESET(RESET),
                            .ADC(ADC2),
                            .INTEGRAL(INTEGRAL2)
`ifdef COMPAT_MOPS_INTGRL_DEBUG
                            ,.DEBUG(INTEGRAL_DEBUG2)
`endif
  
                          );
/*
generate

genvar i;

 for (i=0; i<3; i=i+1) 

    begin: veto_calculate
    
    veto veto_bins(
                            .CLK(CLK120),
                            .ENABLE40(ENABLE40),
                            .DELTA(DELTA[i]),
                            .OFS(OFS),
	                        .VETO(VETO_wire[i])
                            );
end
endgenerate
*/
/*
initial begin

 for (INDEX=0; INDEX<3; INDEX=INDEX+1) begin
         
                  PREV_ADC[INDEX] <= ADC[INDEX];
                  DELTAA[INDEX] <=  ADC[INDEX];
                  DELTAB[INDEX] <= ADC[INDEX];
                  VETO[INDEX] <= 0;
                  VETO_COUNTER[INDEX] <= 1;
                  DELTA[INDEX] <= 0;
                  INDEX_BIN[INDEX]<=0;
                  OCC_COUNTER[INDEX] <= 0;

         end
end
*/

  always @(posedge CLK120) begin

                 if (ENABLE40 == 0) begin

        

         for (INDEX=0; INDEX<3; INDEX=INDEX+1) begin
         
         if (RESET) begin
                  PREV_ADC[INDEX] <= ADC[INDEX];
                          DELTAA[INDEX] <=  ADC[INDEX];
                          DELTAB[INDEX] <= ADC[INDEX];
                          VETO[INDEX] <= 0;
                          VETO_COUNTER[INDEX] <= 1;
                          DELTA[INDEX] <= 0;
                          INDEX_BIN[INDEX]<=0;
                          OCC_COUNTER[INDEX] <= 0;

             end
         end
       
       
        
        // First do a simple single bin trigger on each bin
        for (INDEX=0; INDEX<3; INDEX=INDEX+1) begin
                      
         
	    if (ADC[INDEX] > PREV_ADC[INDEX]) begin
	   
	    DELTA[INDEX]<=0;

		if  (INDEX_BIN[INDEX]==1) DELTAB[INDEX] <= PREV_ADC[INDEX];
		PREV_ADC[INDEX] <= ADC[INDEX];
		DELTAA[INDEX] <= ADC[INDEX];
		INDEX_BIN[INDEX]<=0;

		end

		else 
		 begin
		
		DELTA[INDEX]<=(DELTAA[INDEX]-DELTAB[INDEX]);
		PREV_ADC[INDEX] <= ADC[INDEX];
		DELTAB[INDEX] <= ADC[INDEX];	
		DELTAA[INDEX] <= ADC[INDEX];
		INDEX_BIN[INDEX]<=1;

		 end



	    if (DELTA[INDEX]<YMAX[INDEX] && DELTA[INDEX]>YMIN[INDEX] && TRIG_ENABLE[INDEX] == 1 && VETO_COUNTER[INDEX]==0) begin
              
        case (DELTA[INDEX]/4)
              /* 
               12'd0:  if(12'd0 +12'd1>OFS) VETO[INDEX][INDEX] <= 12'd0 +12'd1 -OFS; else VETO[INDEX][INDEX] <= 0;
              
               12'd1:  if(12'd0 +12'd1>OFS) VETO[INDEX] <= 12'd0 +12'd1 -OFS; else VETO[INDEX] <= 0;
                   
               12'd2:  if(12'd1 +12'd1>OFS) VETO[INDEX] <= 12'd1 +12'd1 -OFS; else VETO[INDEX] <= 0;
               
               12'd3:  if(12'd1+12'd1>OFS) VETO[INDEX] <= 12'd1 +12'd1  -OFS; else VETO[INDEX] <= 0;
               */
               12'd0:  VETO_COUNTER[INDEX] <= 12'd0 +12'd1 -OFS;
                 
               12'd1:  VETO_COUNTER[INDEX] <= 12'd0 +12'd1 -OFS;
                     
               12'd2:  VETO_COUNTER[INDEX] <= 12'd1 +12'd1 -OFS;
                  
               12'd3:  VETO_COUNTER[INDEX] <= 12'd1 +12'd1 -OFS;
           
               12'd4:  VETO_COUNTER[INDEX] <= 12'd2 +12'd1 -OFS;
               
               12'd5:  VETO_COUNTER[INDEX] <= 12'd2 +12'd1 -OFS;
           
               12'd6:  VETO_COUNTER[INDEX] <= 12'd2+12'd1 -OFS;
           
               12'd7:  VETO_COUNTER[INDEX] <= 12'd2+12'd1 -OFS;
           
               12'd8:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
           
               12'd9:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
               
               12'd10:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
               
               12'd11:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
           
               12'd12:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
           
               12'd13:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
           
               12'd14:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
           
               12'd15:  VETO_COUNTER[INDEX] <= 12'd3+12'd1 -OFS;
           
               12'd16:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
           
               12'd17:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
               
               12'd18:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
             
               12'd19:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
               
               12'd20:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
               
               12'd21:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
           
               12'd22:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
              
               12'd23:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
               
               12'd24:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
               
               12'd25:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
              
               12'd26:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
           
               12'd27:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
           
               12'd28:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
                   
               12'd29:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
              
               12'd30:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
                  
               12'd31:  VETO_COUNTER[INDEX] <= 12'd4+12'd1 -OFS;
               
               default: VETO_COUNTER[INDEX] <= 12'dx;
           
           endcase
                      
                    
	      PMT_TRIG[INDEX] <= 1;
                end
	    else 
	      PMT_TRIG[INDEX] <= 0;
	      
	      
	      
	    if (VETO_COUNTER[INDEX]!=0) VETO_COUNTER[INDEX]=VETO_COUNTER[INDEX]-1;
 
 

            WINDOW[INDEX] <= {WINDOW[INDEX][`WIDTH-2:0],PMT_TRIG[INDEX]};
            if (WINDOW[INDEX][`WIDTH-1] && !PMT_TRIG[INDEX])
              OCC_COUNTER[INDEX] <= OCC_COUNTER[INDEX]-1;
            else if (!WINDOW[INDEX][`WIDTH-1] && PMT_TRIG[INDEX])
              OCC_COUNTER[INDEX] <= OCC_COUNTER[INDEX]+1;
           

            if ((OCC_COUNTER[INDEX] > OCCUPANCY) &&
                (INTEGRAL[INDEX] > INT)) SB_TRIG[INDEX] <= 1;
            else SB_TRIG[INDEX] <= 0;
         end // for (INDEX=0; INDEX<3; INDEX=INDEX+1)
           end  // Downsampled loop
 
           
      YMIN[0] <= MIN0;
      YMIN[1] <= MIN1;
      YMIN[2] <= MIN2;

      YMAX[0] <= MAX0;
      YMAX[1] <= MAX1;
      YMAX[2] <= MAX2;

     
      ADC[0] <= ADC0;
      ADC[1] <= ADC1;
      ADC[2] <= ADC2;

      INTEGRAL[0] <= INTEGRAL0;
      INTEGRAL[1] <= INTEGRAL1;
      INTEGRAL[2] <= INTEGRAL2;
      
  /*    
      VETO[0] <= VETO_wire[0];
      VETO[1] <= VETO_wire[1];
      VETO[2] <= VETO_wire[2];
      
*/

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

     DEBUG[0] <= PMT_TRIG[1];
     DEBUG[1] <= SB_TRIG[1];
     DEBUG[2] <= TRIG;
     
end

endmodule
