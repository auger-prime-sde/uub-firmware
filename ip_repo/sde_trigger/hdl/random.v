// Module to generate a trigger at a "random" time.
//
// 01-Nov-2019 DFN Initial version
// 08-Nov-2019 DFN Add SLOW_CLK so counter can keep up

`define TR_CLOCK_FREQ 12 // Clock frequency in Mhz
`define TR_RANDOM_BITS 36 // Large to allow selection of duration
`define TR_DELAY_BITS 36  // Overkill but saves changing if change delays

module random 
  (
   input [31:0] MODE,
   input CLK,
   output reg TRIG,
   output reg [4:0] DEBUG
   );
   
   
   reg [`TR_DELAY_BITS-1:0] PULSE_DELAY;
   reg [`TR_DELAY_BITS-1:0] THIS_DELAY;
   reg [`TR_DELAY_BITS-1:0] NEXT_DELAY; 
   reg [`TR_RANDOM_BITS-1:0] RANDOM; // Generated random number
   reg [4:0]                 COUNT;  // Big enough to count to RANDOM_BITS
   reg [3:0]                 SLOW_CLK;
   
   
   always @(posedge CLK)
     begin
        SLOW_CLK <= SLOW_CLK + 1;
        if (SLOW_CLK >= 9) SLOW_CLK <= 0;
        
        case (MODE[4:0])
          0: begin  // Treat MODE=0 as a RESET
             PULSE_DELAY <= 0;
             THIS_DELAY <= 0;
             NEXT_DELAY <= 0;
             COUNT <= 0;
             RANDOM <= 13'hf;
          end
          11,15,18,21,25,28,31: begin
             if (SLOW_CLK == 0)
               begin
                  if (COUNT == MODE[4:0])
                    begin
                       COUNT <= 0;
                       NEXT_DELAY <= RANDOM;
                    end
                  else begin
                     case (MODE[4:0])
                       11: RANDOM <= {RANDOM[9:0], RANDOM[10]^RANDOM[8]};
                       15: RANDOM <= {RANDOM[13:0], RANDOM[14]^RANDOM[13]};
                       18: RANDOM <= {RANDOM[16:0], RANDOM[17]^RANDOM[10]};
                       21: RANDOM <= {RANDOM[19:0], RANDOM[20]^RANDOM[18]};
                       22: RANDOM <= {RANDOM[20:0], RANDOM[21]^RANDOM[20]};
                       23: RANDOM <= {RANDOM[21:0], RANDOM[22]^RANDOM[17]};
                       25: RANDOM <= {RANDOM[23:0], RANDOM[24]^RANDOM[21]};
                       28: RANDOM <= {RANDOM[26:0], RANDOM[27]^RANDOM[24]};
                       31: RANDOM <= {RANDOM[29:0], RANDOM[30]^RANDOM[27]};
                       default: RANDOM <= RANDOM;
                     endcase
                     COUNT <= COUNT+1;
                  end
               end
          end // case: 11,15,18,21,25,28,31
          1:  NEXT_DELAY <= `TR_CLOCK_FREQ *10000;     // 10ms period
          2:  NEXT_DELAY <= `TR_CLOCK_FREQ *100000;    // 100ms period
          3:  NEXT_DELAY <= `TR_CLOCK_FREQ *1000000;   // 1s period
          4:  NEXT_DELAY <= `TR_CLOCK_FREQ *10000000;  // 10s period
          5:  NEXT_DELAY <= `TR_CLOCK_FREQ *100000000; // 100s period
          6:  NEXT_DELAY <= `TR_CLOCK_FREQ *200000000; // 200s period
          7:  NEXT_DELAY <= `TR_CLOCK_FREQ *400000000; // 400s period
          default: NEXT_DELAY <= `TR_CLOCK_FREQ *800000000;  // 800s period
        endcase

        if (MODE[4:0] != 0) begin
           if (SLOW_CLK == 0)
             begin
	        if (PULSE_DELAY >= THIS_DELAY) 
                  begin
                     PULSE_DELAY <= 0;
                     THIS_DELAY <= NEXT_DELAY;
                    if (THIS_DELAY != 0) TRIG <= 1;
                  end
                else
                  begin
	             PULSE_DELAY <= PULSE_DELAY+1;
                  end // else: !if(PULSE_DELAY > THIS_DELAY)
             end
        end // if (MODE[4:0] != 0)
        if (TRIG != 0) TRIG <= 0;
        
        DEBUG[0] <= 0;
        DEBUG[1] <= 0;
        DEBUG[2] <= 0;
        DEBUG[3] <= 0;
        DEBUG[4] <= 0;

     end
endmodule

