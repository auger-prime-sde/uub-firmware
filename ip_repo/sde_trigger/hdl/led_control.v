// led_control.v
//
// This module implements the led controller functionality outlined in 
// the "WP1-UUB Led Controller Modifications" document and the 
// VP1_LED_Control.vhd Vivado IP by Roberto Assiro, INFN.  In this
// implementation the LED control is incorporated in the sde_trigger.
//
// 26-Jun-2016 DFN Initial version derived from sources above
// 20-Sep-2016 DFN Flip sign of LED output
// 27-Feb-2019 DFN Fix (possibly wrong) non-registered assignment of PULSE_WIDTH
 

`include "sde_trigger_defs.vh"

module led_control(
		   input ONE_PPS,
		   input CLK120,
                   //		   input ENAB_PPS,  // From slow control
		   input [31:0] LED_CONTROL,
                   input RESET,
		   output reg LED,
                   output reg TRG_FLAG,
                   output reg [4:0] DEBUG
		   );

   reg                              ENABLE_LED;
   reg                              ENABLE_DELAY;
   reg                              ENABLE_PULSE;
   wire                             LCL_ONE_PPS;
   reg                              PREV_ONE_PPS;
   reg                              LED_NOW, PREV_LED_NOW;
   reg [`LED_DELAY_WIDTH-1:0]       PULSE_DELAY;
   reg [`LED_PULSWID_WIDTH-1:0]     PULSE_WIDTH;
   reg [`LED_PULSWID_WIDTH-1:0]     TRG_FLAG_WIDTH;
   reg [7:0] 			    TRG_FLAG_DELAY;
   reg 				    ENABLE_TRG_FLAG;
   
   always @(posedge CLK120) begin
      if (RESET) begin
	 LED <= 0;
         PULSE_DELAY <= 0;
         PULSE_WIDTH <= 0;
         ENABLE_DELAY <= 0;
         ENABLE_PULSE <= 0;
         TRG_FLAG <= 0;
	 TRG_FLAG_DELAY <= 0;
	 LED_NOW <= 0;
         PREV_LED_NOW <=0;
         PREV_ONE_PPS <= 0;
      end
      else begin  // !RESET
         PREV_ONE_PPS <= LCL_ONE_PPS;
         LED_NOW <= LED_CONTROL & `LED_NOW;
         PREV_LED_NOW <= LED_NOW;
         ENABLE_LED <= (LED_CONTROL & `LED_ENAPPS) >> `LED_ENAPPS_SHIFT;
         if (LED_NOW && !PREV_LED_NOW && !ENABLE_PULSE) begin
            ENABLE_PULSE <= 1;
//            PULSE_WIDTH = (LED_CONTROL >> `LED_PULSWID_SHIFT) // Was this wrong?
            PULSE_WIDTH <= (LED_CONTROL >> `LED_PULSWID_SHIFT) 
              & `LED_PULSWID_MASK;
            TRG_FLAG_DELAY <= `LED_FLAG_DELAY;
            TRG_FLAG_WIDTH <= `LED_FLAG_DURATION;
	    ENABLE_TRG_FLAG <= 1;
         end
         else if (ENABLE_LED && LCL_ONE_PPS && !PREV_ONE_PPS
                  && !ENABLE_DELAY && !ENABLE_PULSE)
           begin
              ENABLE_DELAY <= 1;
              PULSE_DELAY <= (LED_CONTROL >> `LED_DELAY_SHIFT)
                & `LED_DELAY_MASK;
           end
         
         if (ENABLE_DELAY) begin
            PULSE_DELAY <= PULSE_DELAY - 1;
            if (PULSE_DELAY == 0) begin
               ENABLE_DELAY <= 0;
               ENABLE_PULSE <= 1;
// Was this wrong to have not registered?
//               PULSE_WIDTH = (LED_CONTROL >> `LED_PULSWID_SHIFT) 
               PULSE_WIDTH <= (LED_CONTROL >> `LED_PULSWID_SHIFT) 
                 & `LED_PULSWID_MASK;
               TRG_FLAG_DELAY <= `LED_FLAG_DELAY;
               TRG_FLAG_WIDTH <= `LED_FLAG_DURATION;
	       ENABLE_TRG_FLAG <= 1;
            end
         end  // ENABLE_DELAY == 1
         
         if (ENABLE_PULSE) begin  
            LED <= 1;
            PULSE_WIDTH <= PULSE_WIDTH - 1;
            if (PULSE_WIDTH == 0)
              ENABLE_PULSE <= 0;
         end
         else
           LED <= 0;

	 if (ENABLE_TRG_FLAG) begin
	    TRG_FLAG_DELAY <= TRG_FLAG_DELAY - 1;
	    if (TRG_FLAG_DELAY == 0) begin
	       ENABLE_TRG_FLAG <= 0;
	       TRG_FLAG <= 1;
	    end
	 end

         if (TRG_FLAG) begin
            TRG_FLAG_WIDTH <= TRG_FLAG_WIDTH - 1;
            if (TRG_FLAG_WIDTH == 0) begin
               TRG_FLAG <= 0;
            end
         end
      end  // RESET

      DEBUG[0] <= LCL_ONE_PPS;
      DEBUG[1] <= ENABLE_PULSE;
      DEBUG[2] <= TRG_FLAG;
      DEBUG[3] <= ENABLE_DELAY;
      DEBUG[4] <= LED;
      
   end // always @ (posedge CLK120)

   // The ONE_PPS signal is completely asynchronous.  Synchronize it before we
   // use it in logic.
   synchronizer_1bit one_pps_sync(.ASYNC_IN(ONE_PPS),
                                  .CLK(CLK120),
                                  .SYNC_OUT(LCL_ONE_PPS));
   
endmodule
