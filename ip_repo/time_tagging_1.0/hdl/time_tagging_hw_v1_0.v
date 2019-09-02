//added ttagid read only register 7_9_15
//Added sixteen additional registers on 7_16_2015, eight for shower buffer and eight for muon buffer
//Shower and Muon buffers increased in size from double to quad as a result
//Added evtcnt[3:0} tags from trigger memory to muon buffer register slowtriggerns 7_16_2015
//Replaced mux_8 with mux_4 on 4_7_2016
//Replaced decode_8 with decode_4 on 4_7_2016
//Instantiated dqff16,13,14,and 15 with reg 3 instead of dqff to correct timing warning 4_6_2016
//Replaced counter_28 with counter_28wce to correct timing warning 4_6_2016
//Added evtcntm[3:0} muon tags from trigger memory to muon buffer 4_12_2016
//Replaced evtcnt{3:0] from trigger memory with evtcntm[3:0] to muon buffer register slowtriggerns 4_12_2016
//address_wsb, rsb, wmb rmb, changed from 3 to 2 bits 4_12_2016
// corrected oseconds[31:0] register assigned bits[29:28] to 2'b00 4_12_2016
//changed wsb_ena[7:0] to [3:0] 4_12_2016
//changed wsb_ena[7:0] to [3:0] 4_12_2016
// The 8_10_2016 changes below were made to prevent the PS IP from hanging when accessing registers 8, 9 and 10
//The 8_10_2016 changes below were made to prevent the PS IP from hanging when writing to register 13 "ttagctrl"
//removed norg5 and norg6 on 8_10_2016 to increase duration of "csel8rr" and "cseldfwr" 
//Removed dqff26, dqff27, dqff24, dqff25 on 8_10_2016 to increase duration of "csel8rr" and "cseldfwr" 
`timescale 1 ns / 1 ps

module time_tagging_hw_v1_0
  (
  // ttag module I/O ports
     input clk_120m, // 120MHz external clock
  	 input pps, //gps 1 pulse per second
	 input [3:0] evtcnt, //tags from trigger memory for shower buffer
	 input [3:0] evtcntm, //tags from trigger memory for muon buffer,added 4_12_2016
	 input evtclkf, // fast trigger
	 input evtclks, // slow trigger
	 input [1:0] address_wsb,// write address shower buffer,changed from 3 to 2 bits 4_12_2016
	 input [1:0] address_rsb,// read address shower buffer,changed from 3 to 2 bits 4_12_2016
	 input [1:0] address_wmb,// write address muon buffer,changed from 3 to 2 bits 4_12_2016
	 input [1:0] address_rmb,// read address muon buffer,changed from 3 to 2 bits 4_12_2016
	 input [31:0] ttagctrl,// time tag control register input
	 output [31:0] teststatus,// teststatus register output
	 output [31:0] c120mout_ps,// processor c120mout register output
	 output [31:0] c120calout_ps,// processor c120calout register output
	 output [31:0] c120deadout,// dead time register output
	 output [31:0] timeseconds,// processor pps seconds register output
	 output [31:0] onanosec, // shower buffer nanoseconds register
	 output [31:0] oseconds,// shower buffer seconds register
	 output [31:0] c120mout_sb,// shower buffer c120mout register
	 output [31:0] c120calout_sb,//shower buffer c120calout register
	 output [31:0] slowtriggersec,// muon buffer slowtriggersec register
	 output [31:0] slowtriggerns,// muon buffer slowtriggerns register
	 output [31:0] c120mout_mb,// muon buffer c120mout register
	 output [31:0] c120calout_mb,// muon buffer c120calout register
	 output [31:0] ttagid,//register reads "ttag" in ascii, added 7_9_15
	 input dead,// dead time
	 input csel8r,// latch "timeseconds", "c120mout_ps", and "c120calout_ps"
	 output csel8rr, // returned delayed version of "csel8r" to create "rvalid"
	 input cseldfw, //time tag address write decode for default registers
	 output cseldfwr // time tag address write decode return to create "bvalid"
      );
	  
  // wires to connect internal modules together
  	wire [26:0] cnanosec;
	wire [31:0] onanosec_sb1;
	wire [31:0] onanosec_sb2;
	wire [31:0] onanosec_sb3;// added 7_15_2015
	wire [31:0] onanosec_sb4;// added 7_15_2015
  	wire [31:0] dffoutnanosec;
  	wire [31:0] nanosec;
  	wire [31:0] bnanosec;
  	wire [31:0] mnanosec; //added 4_12_2016
	wire [31:0] seconds;
	wire [27:0] cseconds;
	wire [31:0] dffoutseconds;
	wire [31:0] bseconds;
	wire [31:0] oseconds_sb1;
	wire [31:0] oseconds_sb2;
	wire [31:0] oseconds_sb3;// added 7_16_2015
	wire [31:0] oseconds_sb4;// added 7_16_2015
	wire [31:0] slowtriggerns_mb1;
	wire [31:0] slowtriggerns_mb2;
	wire [31:0] slowtriggerns_mb3;// added 7_16_2015
	wire [31:0] slowtriggerns_mb4;// added 7_16_2015
	wire [31:0] slowtriggersec_mb1;
	wire [31:0] slowtriggersec_mb2;
	wire [31:0] slowtriggersec_mb3;// added 7_16_2015
	wire [31:0] slowtriggersec_mb4;// added 7_16_2015
	wire [26:0] ccalnanosec;
	wire [31:0] calnanosec;
	wire [31:0] dffoutcalnanosec;
	wire [31:0] c120calout;
	wire [31:0] c120calout_sb1;
	wire [31:0] c120calout_sb2;
	wire [31:0] c120calout_sb3;// added 7_16_2015
	wire [31:0] c120calout_sb4;// added 7_16_2015
	wire [31:0] c120calout_mb1;
	wire [31:0] c120calout_mb2;
	wire [31:0] c120calout_mb3;// added 7_16_2015
	wire [31:0] c120calout_mb4;// added 7_16_2015
	wire [31:0] c120mout;
	wire [31:0] c120mout_sb1;
	wire [31:0] c120mout_sb2;
	wire [31:0] c120mout_sb3;// added 7_16_2015
	wire [31:0] c120mout_sb4;// added 7_16_2015
	wire [31:0] c120mout_mb1;
	wire [31:0] c120mout_mb2;
	wire [31:0] c120mout_mb3;// added 7_16_2015
	wire [31:0] c120mout_mb4;// added 7_16_2015
	wire [31:0] timems;
	wire [3:0] wsb_ena;//changed from [7:0] to 3:0] 4_12_2016
	wire [3:0] wmb_ena;//changed from [7:0] to 3:0] 4_12_2016
	wire [31:0] ttagctrl3;
	wire [26:0] cdeadnanosec;
	wire [31:0] deadnanosec;
	wire [31:0] dffoutdeadnanosec;
  	wire wrevents,wren_sb1,wren_sb2;
	wire wren_sb3,wren_sb4;// added 7_16_2015
	wire resdcnt;
	wire clr_evtclkf,clr_evtclks,clr_evtpps,clr_evtdead;
	wire clr_clkf,clr_evts,clr_pps,clr_dead;
	wire q1,q2,nq2,q3,nq5,q6,q7,nq8,q8,nq11,q12,q13,q14,q15,q16,q17,q18,nq18,q19,q20;
   wire      q20a, q20b, q20c, q20d, q20e;
   	wire nq20,q23,nq23;
	wire wrppsevent;
	wire wreventm,wren_mb1,wren_mb2;
	wire wren_mb3,wren_mb4;// added 7_16_2015
	wire address_wmb1,address_wmb2;
	wire address_wmb3,address_wmb4;// added 7_16_2015
	wire address_wsb1,address_wsb2;
	wire address_wsb3,address_wsb4;// added 7_16_2015
	wire wrenr_csel8;
	wire ttagres;
	wire wrdeadevent;
 // Instantiation of behavioral registers using ASYNC_REG property
 // ASYNC_REG property doesn't work for me with structural instantiation of registers	
    (* ASYNC_REG = "TRUE" *) reg q4,q5;
    (* ASYNC_REG = "TRUE" *) reg q10,q11;
    (* ASYNC_REG = "TRUE" *) reg q21,q22;
    (* ASYNC_REG = "TRUE" *) reg [31:0] ttagctrl1, ttagctrl2;
    
  	Counter_27 nanosecondcounter(clk_120m,cnanosec,ttagres);// 27-bit nanosecond counter
	Counter_28wce ttag_secondscounter(clk_120m,cseconds,ttagres,wrppsevent); //28-bit second counter, changed to Counter_28wce 4_6_2016
	Counter_27wld calnanosec_counter(clk_120m,ccalnanosec,ttagres,wrppsevent); // 27-bit oscillator calibration counter with load
	Counter_27 deadnanosec_counter(clk_120m,cdeadnanosec,resdcnt);// 27-bit nanosecond dead counter
	
  	reg1 lpm_ttagdff1(clk_120m,ttagres,nanosec,dffoutnanosec); // 32-bit register capturing nanosecond counter out
	reg1 lpm_ttagdff2(clk_120m,ttagres,seconds,dffoutseconds); // 32-bit register capturing second counter out
	reg1 lpm_ttagdff3(clk_120m,ttagres,calnanosec,dffoutcalnanosec); // 32-bit register capturing calnanoseconds counter out
	reg1 lpm_ttagdff4(clk_120m,ttagres,deadnanosec,dffoutdeadnanosec); // 32-bit register capturing deadnanoseconds counter out
	
	reg2 ttag_sbuffer1_n(clk_120m,ttagres,wren_sb1,bnanosec,onanosec_sb1); // shower buffer 1 nanosec
	reg2 ttag_sbuffer2_n(clk_120m,ttagres,wren_sb2,bnanosec,onanosec_sb2); // shower buffer 2 nanosec
	reg2 ttag_sbuffer3_n(clk_120m,ttagres,wren_sb3,bnanosec,onanosec_sb3); // shower buffer 3 nanosec, added 7_15_2015
	reg2 ttag_sbuffer4_n(clk_120m,ttagres,wren_sb4,bnanosec,onanosec_sb4); // shower buffer 4 nanosec, added 7_15_2015
	reg2 ttag_sbuffer1_s(clk_120m,ttagres,wren_sb1,bseconds,oseconds_sb1); // shower buffer 1 sec
	reg2 ttag_sbuffer2_s(clk_120m,ttagres,wren_sb2,bseconds,oseconds_sb2); // shower buffer 2 sec
	reg2 ttag_sbuffer3_s(clk_120m,ttagres,wren_sb3,bseconds,oseconds_sb3); // shower buffer 3 sec, added 7_16_2015
	reg2 ttag_sbuffer4_s(clk_120m,ttagres,wren_sb4,bseconds,oseconds_sb4); // shower buffer 4 sec, added 7_16_2015
	reg2 ttag_sbuffer1_rmout(clk_120m,ttagres,wren_sb1,c120mout,c120mout_sb1); // shower buffer 1 c120mout
	reg2 ttag_sbuffer2_rmout(clk_120m,ttagres,wren_sb2,c120mout,c120mout_sb2); // shower buffer 2 c120mout
	reg2 ttag_sbuffer3_rmout(clk_120m,ttagres,wren_sb3,c120mout,c120mout_sb3); // shower buffer 3 c120mout, added 7_16_2015
	reg2 ttag_sbuffer4_rmout(clk_120m,ttagres,wren_sb4,c120mout,c120mout_sb4); // shower buffer 4 c120mout, added 7_16_2015
	reg2 ttag_sbuffer1_calout(clk_120m,ttagres,wren_sb1,c120calout,c120calout_sb1); // shower buffer 1 c120calout
	reg2 ttag_sbuffer2_calout(clk_120m,ttagres,wren_sb2,c120calout,c120calout_sb2); // shower buffer 2 c120calout
	reg2 ttag_sbuffer3_calout(clk_120m,ttagres,wren_sb3,c120calout,c120calout_sb3); // shower buffer 3 c120calout, added 7_16_2015
	reg2 ttag_sbuffer4_calout(clk_120m,ttagres,wren_sb4,c120calout,c120calout_sb4); // shower buffer 4 c120calout, added 7_16_2015
	reg2 ttag_mbuffer1_n(clk_120m,ttagres,wren_mb1,mnanosec,slowtriggerns_mb1); // muon buffer 1 nanosec,changed dffoutnanosec to bnanosec 7_16_2015,changed bnanosec to mnanosec 4_12_2016 
	reg2 ttag_mbuffer2_n(clk_120m,ttagres,wren_mb2,mnanosec,slowtriggerns_mb2); // muon buffer 2 nanosec,changed dffoutnanosec to bnanosec 7_16_2015,changed bnanosec to mnanosec 4_12_2016
	reg2 ttag_mbuffer3_n(clk_120m,ttagres,wren_mb3,mnanosec,slowtriggerns_mb3); // muon buffer 3 nanosec, added 7_16_2015,changed bnanosec to mnanosec 4_12_2016
	reg2 ttag_mbuffer4_n(clk_120m,ttagres,wren_mb4,mnanosec,slowtriggerns_mb4); // muon buffer 4 nanosec, added 7_16_2015,changed bnanosec to mnanosec 4_12_2016
	reg2 ttag_mbuffer1_s(clk_120m,ttagres,wren_mb1,dffoutseconds,slowtriggersec_mb1); // muon buffer 1 sec
	reg2 ttag_mbuffer2_s(clk_120m,ttagres,wren_mb2,dffoutseconds,slowtriggersec_mb2); // muon buffer 2 sec
	reg2 ttag_mbuffer3_s(clk_120m,ttagres,wren_mb3,dffoutseconds,slowtriggersec_mb3); // muon buffer 3 sec, added 7_16_2015
	reg2 ttag_mbuffer4_s(clk_120m,ttagres,wren_mb4,dffoutseconds,slowtriggersec_mb4); // muon buffer 4 sec, added 7_16_2015
	reg2 ttag_mbuffer1_mout(clk_120m,ttagres,wren_mb1,c120mout,c120mout_mb1); // muon buffer 1 c120mout
	reg2 ttag_mbuffer2_mout(clk_120m,ttagres,wren_mb2,c120mout,c120mout_mb2); // muon buffer 2 c120mout
	reg2 ttag_mbuffer3_mout(clk_120m,ttagres,wren_mb3,c120mout,c120mout_mb3); // muon buffer 3 c120mout, added 7_16_2015
	reg2 ttag_mbuffer4_mout(clk_120m,ttagres,wren_mb4,c120mout,c120mout_mb4); // muon buffer 4 c120mout, added 7_16_2015
	reg2 ttag_mbuffer1_calout(clk_120m,ttagres,wren_mb1,c120calout,c120calout_mb1); // muon buffer 1 c120calout
	reg2 ttag_mbuffer2_calout(clk_120m,ttagres,wren_mb2,c120calout,c120calout_mb2); // muon buffer 2 c120calout
	reg2 ttag_mbuffer3_calout(clk_120m,ttagres,wren_mb3,c120calout,c120calout_mb3); // muon buffer 3 c120calout, added 7_16_2015
	reg2 ttag_mbuffer4_calout(clk_120m,ttagres,wren_mb4,c120calout,c120calout_mb4); // muon buffer 3 c120calout, added 7_16_2015
	reg2 ttag_dffenable1(clk_120m,ttagres,wrppsevent,dffoutcalnanosec,c120calout); // 120m oscillator calibration data register
	reg2 ttag_dffenable2(clk_120m,ttagres,wrppsevent,dffoutnanosec,c120mout); // 120m oscillator data register at pps time
	reg2 ttag_dffenable3(clk_120m,ttagres,wrenr_csel8,c120mout,c120mout_ps); // 120m oscillator data register at pps time when read by processor
	reg2 ttag_dffenable4(clk_120m,ttagres,wrenr_csel8,dffoutseconds,timeseconds); // pps seconds data register when read by processor
	reg2 ttag_dffenable5(clk_120m,ttagres,wrenr_csel8,c120calout,c120calout_ps); // 120m oscillator calibration data register when read by processor
	reg2 ttag_dffenable6(clk_120m,ttagres,wrdeadevent,dffoutdeadnanosec,c120deadout); // 120m oscillator data register dead time
	
	reg1 ttagdff5(clk_120m,ttagres,ttagctrl2,ttagctrl3); // extra register stage needed because of large fanout of "ttagres" which is ttagctrl[0}

	assign nanosec = {5'b00000,cnanosec[26:0]}; //concatenation of wires - extend "cnanosec" counter to 32 bits
	assign bnanosec = {evtcnt[3:0],1'b0,dffoutnanosec[26:0]}; //concatenation of wire inputs to shower buffer
	assign mnanosec = {evtcntm[3:0],1'b0,dffoutnanosec[26:0]}; //concatenation of wire inputs to muon buffer,added 4_12_2016
	assign LED = cnanosec[26];// blinking LED bit selection
	assign seconds = {4'b0000,cseconds[27:0]}; //concatenation of wires - extend "seconds' counter to 32 bits
	assign bseconds = {4'b0000,dffoutseconds[27:0]};//concatenation of wire inputs to shower buffer,correction assigned bits[29:28] to 2'b00 4_12_2016
	assign address_wsb1 = wsb_ena[0]; // shower buffer 1 write enable address 
	assign address_wsb2 = wsb_ena[1]; // shower buffer 2 write enable address
	assign address_wsb3 = wsb_ena[2]; // shower buffer 3 write enable address, added 7_15_2015
	assign address_wsb4 = wsb_ena[3]; // shower buffer 4 write enable address, added 7_16_2015
	assign address_wmb1 = wmb_ena[0];// muon buffer 1 write enable address
	assign address_wmb2 = wmb_ena[1];// muon buffer 2 write enable address
	assign address_wmb3 = wmb_ena[2]; // muon buffer 3 write enable address, added 7_16_2015
	assign address_wmb4 = wmb_ena[3]; // muon buffer 4 write enable address, added 7_16_2015
	assign ttagres = ttagctrl2[0];// time tag reset bit assignment to control register bit
	assign clr_pps = ttagctrl2[1];// clear pps status bit assignment to control register bit
	assign clr_clkf = ttagctrl2[2];// clear fast trigger rising status bit assignment to control register bit
	assign clr_clks = ttagctrl2[3];// clear slow trigger status bit assignment to control register bit
	assign clr_dead = ttagctrl2[4];// clear dead time status bit assignment to control register bit
	assign teststatus = {24'h000000,1'b0,1'b0,1'b0,1'b0,q16,q13,q14,q15}; //concatenation "teststatus" register output bits
	assign calnanosec = {5'b00000,ccalnanosec[26:0]}; //concatenation of wires
	assign deadnanosec = {5'b00000,cdeadnanosec[26:0]}; //concatenation of wires
	assign ttagid = {8'h74,8'h74,8'h61,8'h67}; //assignment to ascii representation for "ttag", added 7_9_15
// 29-Aug-2019 DFN following RS instructions ... extend handshake pipelin
//	assign csel8rr = q20; // circuit to create "csel8rr" - added 8_10_16 to correct zynq ps lock_up
	assign csel8rr = q20e; // circuit to create "csel8rr" - added 8_10_16 to correct zynq ps lock_up

	assign cseldfwr = q23; //circuit to create "cseldfwr" - added 8_10_16 to correct zynq ps lock_up
	
  	dff dqff1(clk_120m,evtclkf,q1,ttagres); // circuit to create "wrevents "
  	dff dqff2(clk_120m,q1,q2,ttagres); // circuit to create "wrevents"
  	dff dqff3(clk_120m,q2,q3,ttagres); // circuit to create "wrevents"
  	
	dff dqff6(clk_120m,q5,q6,ttagres); //circuit to create "wrppsevent"
	
	dff dqff7(clk_120m,evtclks,q7,ttagres); //circuit to create "wreventm"
	dff dqff8(clk_120m,q7,q8,ttagres); //circuit to create "wreventm"
	dff dqff12(clk_120m,q8,q12,ttagres); //circuit to create "wreventm"

	dff dqff20(clk_120m,q11,q20,ttagres); // circuit to create "wrenr_csel8"
	//dff dqff26(clk_120m,q20,q26,ttagres); // circuit to create "csel8rr" - removed 8_10_16 to correct zynq ps lock_up
	//dff dqff27(clk_120m,q26,q27,ttagres); // circuit to create "csel8rr"  - removed 8_10_16 to correct zynq ps lock_up

   // 29-Aug-2019 Added more delay here for csel8rr per Bob Sobin suggestion
	dff dqff20a(clk_120m,q20,q20a,ttagres); 
	dff dqff20b(clk_120m,q20a,q20b,ttagres); 
	dff dqff20c(clk_120m,q20b,q20c,ttagres); 
	dff dqff20d(clk_120m,q20c,q20d,ttagres); 
	dff dqff20e(clk_120m,q20d,q20e,ttagres); 

	dff dqff17(clk_120m,dead,q17,ttagres); //circuit to create "wrdeadevent"
	dff dqff18(clk_120m,q17,q18,ttagres); //circuit to create "wrdeadevent"
	dff dqff19(clk_120m,q18,q19,ttagres); //circuit to create "wrdeadevent"

	dff dqff23(clk_120m,q22,q23,ttagres); //circuit to create "cseldfwr"
	//dff dqff24(clk_120m,q23,q24,ttagres); //circuit to create "cseldfwr" - removed 8_10_16 to correct zynq ps lock_up
	//dff dqff25(clk_120m,q24,q25,ttagres); //circuit to create "cseldfwr" - removed 8_10_16 to correct zynq ps lock_up

	reg3 dqff13(clk_120m,clr_evtclkf,wrevents,1'b1,q13);//status bit for fast trigger event occurrence - test only, changed to reg3 4_6_2016
	reg3 dqff14(clk_120m,clr_evtpps,wrppsevent,1'b1,q14);//status bit for pps event occurrence - test only, changed to reg3 4_6_2016
  	reg3 dqff15(clk_120m,clr_evtclks,wreventm,1'b1,q15);//status bit for slow trigger event occurrence - test only, changed to reg3 4_6_2016
	reg3 dqff16(clk_120m,clr_evtdead,wrdeadevent,1'b1,q16);//status bit for dead time event occurrence - test only, changed to reg3 4_6_2016
  	
	inv invert1(nq2,q2); // inverter circuit
	inv invert2(nq5,q5); // invert circuit
	inv invert3(nq8,q8); // invert circuit
	inv invert5(nq11,q11); // invert circuit
	inv invert6(nq18,q18); //invert circuit
	//inv invert7(nq20,q20); //invert circuit - removed 8_10_16 to correct zynq ps lock_up
	//inv invert8(nq23,q23); //invert circuit - removed 8_10_16 to correct zynq ps lock_up
  	norg norg1(wrevents,nq2,q3); // nor gate to create "wrevents"
	norg norg2(wrppsevent,nq5,q6); // nor gate to create "wrppsevent"
	norg norg3(wreventm,nq8,q12); // nor gate to create "wreventm"
	norg norg4(wrenr_csel8,nq11,q20); // nor gate to create "wrenr_csel8"
	//norg norg5(csel8rr,nq20,q27); // nor gate to create "csel8rr" - changed 8_9_16 to correct zynq ps lock_up
	//norg norg6(cseldfwr,nq23,q25); // nor gate to create "cseldfwr" - changed 8_9_16 to correct zynq ps lock_up
	andg andg1(wren_sb1,wrevents,address_wsb1);// and gate to enable shower buffer 1 write 
	andg andg2(wren_sb2,wrevents,address_wsb2);// and gate to enable shower buffer 2 write
	andg andg3(wren_sb3,wrevents,address_wsb3);// and gate to enable shower buffer 3 write, added 7_15_2015
	andg andg4(wren_sb4,wrevents,address_wsb4);// and gate to enable shower buffer 4 write, added 7_15_2015
	andg andg6(wren_mb1,wreventm,address_wmb1);// and gate to enable muon buffer 1 write 
	andg andg7(wren_mb2,wreventm,address_wmb2);// and gate to enable muon buffer 2 write
	andg andg10(wren_mb3,wreventm,address_wmb3);// and gate to enable shower buffer 3 write, added 7_16_2015
	andg andg11(wren_mb4,wreventm,address_wmb4);// and gate to enable shower buffer 4 write, added 7_16_2015
	andg andg9(wrdeadevent,nq18,q19); // and gate to create "wrdeadevent"
	org org1(clr_evtclkf,ttagres,clr_clkf);//clear status bit
	org org3(clr_evtpps,ttagres,clr_pps);//clear status bit
	org org4(clr_evtclks,ttagres,clr_clks);//clear status bit
	org org5(resdcnt,nq18,ttagres); // or gate to reset 120m dead counter
	org org6(clr_evtdead,ttagres,clr_dead);//clear status bit

// behavioral synchronizing stage for "pps" input
// ASYNC_REG property doesn't work for me with structural instantiation of registers
	always @(posedge clk_120m or posedge ttagres)
      if (ttagres) begin
         q4 <= 1'b0;
         q5 <= 1'b0;
      end else begin
         q4 <= pps;
         q5 <= q4;
      end
 
 // behavioral synchronizing stage for "csel8r" input     
     always @(posedge clk_120m or posedge ttagres)
        if (ttagres) begin
           q10 <= 1'b0;
           q11 <= 1'b0;
        end else begin
           q10 <= csel8r;
           q11 <= q10;
        end

// behavioral synchronizing stage for "cseldfw" input        
	 always @(posedge clk_120m or posedge ttagres)
          if (ttagres) begin
             q21 <= 1'b0;
             q22 <= 1'b0;
          end else begin
             q21 <= cseldfw;
             q22 <= q21;
          end

 // behavioral synchronizatizing stage for "ttagctrl" register          
	 always @(posedge clk_120m or posedge ttagres)
           if (ttagres) begin
              ttagctrl1 <= 1'b0;
              ttagctrl2 <= 1'b0;
           end else begin
              ttagctrl1 <= ttagctrl;
              ttagctrl2 <= ttagctrl1;
           end
      	
	mux_4 mux2(			// multiplexer of shower quad buffer rising edge seconds counter,changed to mux_4 4_7_2016
		.in(address_rsb),
		.in0(oseconds_sb1),
		.in1(oseconds_sb2),
		.in2(oseconds_sb3),//added 7_16_2015
		.in3(oseconds_sb4),//added 7_16_2015
		.out(oseconds));
	
	mux_4 mux3(			// multiplexer of shower quad buffer rising edge nanoseconds counter,changed to mux_4 4_7_2016
		.in(address_rsb),
		.in0(onanosec_sb1),
		.in1(onanosec_sb2),
		.in2(onanosec_sb3),//added 7_15_2015
		.in3(onanosec_sb4),//added 7_15_2015
		.out(onanosec));
		
	mux_4 mux4(			// multiplexer of shower quad buffer falling edge seconds counter,changed to mux_4 4_7_2016
		.in(address_rsb),
		.in0(c120mout_sb1),
		.in1(c120mout_sb2),
		.in2(c120mout_sb3),// added 7_16_2015
		.in3(c120mout_sb4),// added 7_16_2015
		.out(c120mout_sb));
		
	mux_4 mux5(			// multiplexer of shower quad buffer falling edge nanoseconds counter,changed to mux_4 4_7_2016
		.in(address_rsb),
		.in0(c120calout_sb1),
		.in1(c120calout_sb2),
		.in2(c120calout_sb3),// added 7_16_2015
		.in3(c120calout_sb4),// added 7_16_2015
		.out(c120calout_sb));
		
	mux_4 mux6(			// multiplexer of muon quad buffer seconds counter,changed to mux_4 4_7_2016
		.in(address_rmb),
		.in0(slowtriggersec_mb1),
		.in1(slowtriggersec_mb2),
		.in2(slowtriggersec_mb3),// added 7_16_2015
		.in3(slowtriggersec_mb4),// added 7_16_2015
		.out(slowtriggersec));
		
	mux_4 mux7(			// multiplexer of muon quad buffer nanoseconds counter,changed to mux_4 4_7_2016
		.in(address_rmb),
		.in0(slowtriggerns_mb1),
		.in1(slowtriggerns_mb2),
		.in2(slowtriggerns_mb3),// added 7_16_2015
		.in3(slowtriggerns_mb4),// added 7_16_2015
		.out(slowtriggerns));
		
	mux_4 mux8(			// multiplexer of muon quad buffer nanoseconds counter,changed to mux_4 4_7_2016
		.in(address_rmb),
		.in0(c120mout_mb1),
		.in1(c120mout_mb2),
		.in2(c120mout_mb3),// added 7_16_2015
		.in3(c120mout_mb4),// added 7_16_2015
		.out(c120mout_mb));
		
	mux_4 mux9(			// multiplexer of muon quad buffer nanoseconds counter,changed to mux_4 4_7_2016
		.in(address_rmb),
		.in0(c120calout_mb1),
		.in1(c120calout_mb2),
		.in2(c120calout_mb3),// added 7_16_2015
		.in3(c120calout_mb4),// added 7_16_2015
		.out(c120calout_mb));
		
	decode_4 decode2(	// shower quad buffer write enable decoder,changed to quad 7_16_2015,changed to decode_4 4_7_2016
		.clk(clk_120m),
		.reset(ttagres),
		.in(address_wsb),
		.regout(wsb_ena));
		
	decode_4 decode3(	// muon quad buffer write enable decoder,changed to quad 7_16_2015,changed to decode_4 4_7_2016
		.clk(clk_120m),
		.reset(ttagres),
		.in(address_wmb),
		.regout(wmb_ena));
		
	
  endmodule