
// Module to intject an internal digital fake signal before the filter and
// trigger modules.
//
// 14-Sep-2016 DFN Initial version
// 21-Sep-2016 DFN Modify to send a burst of 2 pulses.
// 05-Oct-2016 DFN Modify to send long bursts with 2 different spacings
//                 for checking muon buffers.
// 17-Jan-2017 DFN Modify to send square edged pulse for checking baseline
//                 corrections.
// 24-Apr-2018 DFN Modify add various random spacings selected by MODE;
//                 add RESET input
// 04-May-2018 DFN Add ramp mode (=6) to aid in data integrity checking.
// 24-May-2018 DFN Add random 22 and 23 modes
// 14-Jun-2018 DFN Add differential delay options
// 15-Jun-2018 DFN Add signal width options to MODE
// 25-Jun-2018 DFN Add exponential decay options to MODE
// 09-Jul-2018 DFN Add signal size options to MODE
// 28-Aug-2018 DFN Add read of test event from memory
//

`define CLOCK_FREQ 120        // Clock frequency in Mhz

`define MUON_DELAY 20000 // Desired pulse spacing in usec
`define MUON_DELAY2 10000 // 2nd pulse spacing
`define MUONS_PER_BUF 117
`define MUON_DLYCOUNT (`CLOCK_FREQ * `MUON_DELAY)
`define MUON_DLYCOUNT2 (`CLOCK_FREQ * `MUON_DELAY2)

`define PEDESTAL 200         // Signal pedestal

`define RANDOM_BITS 32 // Large to allow selection of duration
`define DELAY_BITS 32  // Overkill but saves changing if change delays
`define DECAY_60NS 891 // Decay constant for 60 ns exponential decay
`define DECAY_SHIFT1 7 // Shifts to produce 60 ns exponential decay
`define DECAY_SHIFT2 2
`define DECAY_BITS 10



//`define MUON_PULSES          // Generate muon pulse train instead of one
//                             // suitable for shower testing

module fake_signal 
  (
   input USE_FAKE_SHWR,
   input USE_FAKE_MUON,
   input [31:0] MODE,
   input[23:0] ADC0_IN,
   input[23:0] ADC1_IN,
   input[23:0] ADC2_IN,
   input[23:0] ADC3_IN,
   input[23:0] ADC4_IN,
   input[31:0] EVENT_IN0,
   input[31:0] EVENT_IN1,
   input CLK,
   output reg[23:0] ADC0_OUT,
   output reg[23:0] ADC1_OUT,
   output reg[23:0] ADC2_OUT,
   output reg[23:0] ADC3_OUT,
   output reg[23:0] ADC4_OUT,
   output reg[31:0] EVENT_ADR
   );

   reg [11:0]       FAKE_SIGNALHG;
   reg [11:0]       FAKE_SIGNALLG;
   reg [23:0]       FAKE_SIGNAL;
   reg [23:0]       FAKE_SIGNAL_DLYD1;
   reg [23:0]       FAKE_SIGNAL_DLYD2;
   reg [23:0]       FAKE_SIGNAL_DLYD3;
   
   reg [`DELAY_BITS-1:0] SHWR_PULSE_DELAY;
   reg [`DELAY_BITS-1:0] MUON_PULSE_DELAY;
   reg [`DELAY_BITS-1:0] THIS_DELAY;
   reg [`DELAY_BITS-1:0] FAKE_DELAY;
   reg [11:0]            SHWR_PULSE;
   reg [11+`DECAY_BITS:0] SHWR_PULSE1;
   reg [11:0]            MUON_PULSE;
   reg [11:0]            PULSE;
   reg [7:0]             MUON_COUNT;
   reg                   LOOP;
   reg                   EXP_DECAY;
   reg [11:0]            MAX_SIGNAL;
   reg [11:0]            SIGNAL_BINS;
   
   
   reg [`RANDOM_BITS-1:0] RANDOM_DONE;  // Generated random number
   reg [`RANDOM_BITS-1:0] RANDOM;
   reg [4:0]              COUNT;  // Big enough to count to RANDOM_BITS
   
   always @(posedge CLK)
     begin
        EXP_DECAY <= MODE[19];
        MAX_SIGNAL <= MODE >> 20;
        SIGNAL_BINS <= MAX_SIGNAL - `PEDESTAL;

        case (MODE[4:0])
          11,15,18,21,25,28,31: begin
             if (COUNT == MODE[4:0])
               begin
                  COUNT <= 0;
                  RANDOM_DONE <= RANDOM;
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
          end // case: 11,15,18,21,25,28,31
          0: begin  // Treat MODE=0 as a RESET
             SHWR_PULSE_DELAY <= 0;
             MUON_PULSE_DELAY <= 0;
             THIS_DELAY <= 1000;
             SHWR_PULSE <= 0;
             MUON_PULSE <= 0;
             LOOP <= 0;
             MUON_COUNT <= 0;
             PULSE <= 0;
             RANDOM <= 13'hf;
             RANDOM_DONE <= 13'hf;
             COUNT <= 0;
             EVENT_ADR <= 0;
          end
          1:  RANDOM_DONE <= `CLOCK_FREQ *10;      // 10us period
          2:  RANDOM_DONE <= `CLOCK_FREQ *1000;    // 1ms period
          3:  RANDOM_DONE <= `CLOCK_FREQ *10000;   // 10ms period
          4:  RANDOM_DONE <= `CLOCK_FREQ *100000;  // 100ms period
          5:  RANDOM_DONE <= `CLOCK_FREQ *1000000; // 1s period
          7:  RANDOM_DONE <= `CLOCK_FREQ *2000000; // 2s period
          default: RANDOM_DONE <= `CLOCK_FREQ *5000000;  // 5s period
        endcase

        // Pattern of pulses suitable for testing shower triggers
        if (USE_FAKE_SHWR) begin
           if (MODE[4:0] == 6)  begin // This is ramp mode
              SHWR_PULSE <= (SHWR_PULSE+1) & 12'h7ff;
           end
           else if (MODE[4:0] != 0) begin
	      if (SHWR_PULSE_DELAY >= THIS_DELAY) 
                begin
                   SHWR_PULSE_DELAY <= 0;
                   THIS_DELAY <= RANDOM_DONE;
                   FAKE_DELAY <= RANDOM_DONE - 2048;
                   SHWR_PULSE <= SIGNAL_BINS;
                   // SHWR_PULSE1 <= SIGNAL_BINS * `DECAY_60NS;
                   SHWR_PULSE1 <= (SIGNAL_BINS << `DECAY_SHIFT1) +
                                  (SIGNAL_BINS << `DECAY_SHIFT2);
                end
              else
	        SHWR_PULSE_DELAY <= SHWR_PULSE_DELAY+1;
              
  	      if (SHWR_PULSE_DELAY < MODE[18:11]) begin
                 if (!EXP_DECAY)
                   begin
	              SHWR_PULSE <= SIGNAL_BINS;
                   end
                 else begin
                    SHWR_PULSE <= SHWR_PULSE -
                                  SHWR_PULSE1[11+`DECAY_BITS:`DECAY_BITS];
                    SHWR_PULSE1 <= (SHWR_PULSE << `DECAY_SHIFT1) +
                                   (SHWR_PULSE << `DECAY_SHIFT2);
                 end      
              end
	      else if (SHWR_PULSE_DELAY < THIS_DELAY)
	        SHWR_PULSE <= 0;
           end // if (MODE != 6)
        end

        // Pattern of pulses suitable for testing muon triggers  
        if (USE_FAKE_MUON) begin
           // Keep one pattern for a full buffer.
           if (MUON_PULSE_DELAY == 0) begin
              if (MUON_COUNT < `MUONS_PER_BUF)
                MUON_COUNT <= MUON_COUNT+1;
              else begin
                 MUON_COUNT <= 0;
                 LOOP <= !LOOP;
              end
           end
           
           // Define basic pulse interval
           if (LOOP) begin
	      if (MUON_PULSE_DELAY >= `MUON_DLYCOUNT) 
	        MUON_PULSE_DELAY <= 0;
              else
	        MUON_PULSE_DELAY <= MUON_PULSE_DELAY+1;
           end 
           else begin
	      if (MUON_PULSE_DELAY >= `MUON_DLYCOUNT2) 
	        MUON_PULSE_DELAY <= 0;
              else
	        MUON_PULSE_DELAY <= MUON_PULSE_DELAY+1;
           end
           
	   if (MUON_PULSE_DELAY < 4)
	     MUON_PULSE <= SIGNAL_BINS;
	   else
	     MUON_PULSE <= 0;
        end
        
        if (USE_FAKE_SHWR & USE_FAKE_MUON) 
          PULSE <= SHWR_PULSE + MUON_PULSE;
        else if (USE_FAKE_SHWR & !USE_FAKE_MUON)
          PULSE <= SHWR_PULSE;
        else if (!USE_FAKE_SHWR & USE_FAKE_MUON)
          PULSE <= MUON_PULSE;
        else
          PULSE <= 0;

        FAKE_SIGNALHG <= PULSE + `PEDESTAL;
	FAKE_SIGNALLG <= (PULSE >> 5) + `PEDESTAL;
	FAKE_SIGNAL <= (FAKE_SIGNALHG << 12) | FAKE_SIGNALLG;
	
	// If USE_FAKE is set, replace signal from ADCs with a fake.
	if (USE_FAKE_SHWR || USE_FAKE_MUON) begin
           if (MODE[4:0] == 7) begin
// Hm..., commented out code does not seem to work.  Why not?
              if (SHWR_PULSE_DELAY > FAKE_DELAY) // Period set above
                EVENT_ADR <= EVENT_ADR+4;
              else
                EVENT_ADR <= 0;
//              EVENT_ADR <= EVENT_ADR+4;

              ADC0_OUT[11:0] <= (EVENT_IN0[11:0] >>5) +`PEDESTAL;
              ADC0_OUT[23:12] <= EVENT_IN0[11:0];
              ADC1_OUT[11:0] <= (EVENT_IN0[27:16] >>5) +`PEDESTAL;
              ADC1_OUT[23:12] <= EVENT_IN0[27:16];
              ADC2_OUT[11:0] <= (EVENT_IN1[11:0] >>5) +`PEDESTAL;
              ADC2_OUT[23:12] <= EVENT_IN1[11:0];
              ADC4_OUT[11:0] <= (EVENT_IN1[27:16] >>7) +`PEDESTAL;
              ADC4_OUT[23:12] <= EVENT_IN1[27:16];
           end
           else begin
              FAKE_SIGNAL_DLYD1 <= FAKE_SIGNAL;
              FAKE_SIGNAL_DLYD2 <= FAKE_SIGNAL_DLYD1;
              FAKE_SIGNAL_DLYD3 <= FAKE_SIGNAL_DLYD2;
              case (MODE[6:5])
                1: ADC0_OUT <= FAKE_SIGNAL_DLYD1;
                2: ADC0_OUT <= FAKE_SIGNAL_DLYD2;
                3: ADC0_OUT <= FAKE_SIGNAL_DLYD3;
                default: ADC0_OUT <= FAKE_SIGNAL;
              endcase             
              case (MODE[8:7])
                1: ADC1_OUT <= FAKE_SIGNAL_DLYD1;
                2: ADC1_OUT <= FAKE_SIGNAL_DLYD2;
                3: ADC1_OUT <= FAKE_SIGNAL_DLYD3;
                default: ADC1_OUT <= FAKE_SIGNAL;
              endcase             
              case (MODE[10:9])
                1: ADC2_OUT <= FAKE_SIGNAL_DLYD1;
                2: ADC2_OUT <= FAKE_SIGNAL_DLYD2;
                3: ADC2_OUT <= FAKE_SIGNAL_DLYD3;
                default: ADC2_OUT <= FAKE_SIGNAL;
              endcase             
              ADC3_OUT <= FAKE_SIGNAL;
              ADC4_OUT <= FAKE_SIGNAL;
	   end // else: !if(MODE[4:0] == 7)
        end

	// Otherwise just pass ADC signals through to output
	else begin
	   ADC0_OUT <= ADC0_IN;
	   ADC1_OUT <= ADC1_IN;
	   ADC2_OUT <= ADC2_IN;
	   ADC3_OUT <= ADC3_IN;
	   ADC4_OUT <= ADC4_IN;
	end
     end
endmodule

