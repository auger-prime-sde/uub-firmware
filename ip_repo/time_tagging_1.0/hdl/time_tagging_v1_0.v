//ttag identification register added 7_9_15
//added evtcntm[3:0] muon tags from trigger memory to  buffer added 4_12_2016
//address_wsb, rsb, wmb rmb, changed from 3 to 2 bits 4_12_2016
// 20-Feb-2019 DFN Added 1pps interrupt

`timescale 1 ns / 1 ps

	module time_tagging_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6,
      
     // Parameters of Axi Slave Bus Interface S_AXI_INTR
   parameter integer C_S_AXI_INTR_DATA_WIDTH	= 32,
   parameter integer C_S_AXI_INTR_ADDR_WIDTH	= 5,
   parameter  C_INTR_SENSITIVITY	= 32'hFFFFFFFF,
   parameter  C_INTR_ACTIVE_STATE	= 32'hFFFFFFFF,
   parameter integer C_IRQ_SENSITIVITY	= 1,
   parameter integer C_IRQ_ACTIVE_STATE	= 1
	)
	(
		// Users to add ports here
        input wire pps,//gps 1 pulse per second
        input wire clk_120m,// 120MHz external clock
        input wire evtclkf,// fast trigger
        input wire evtclks,// slow trigger
        input wire dead,// dead time
        input wire [3:0] evtcnt,//tags from trigger memory
        input wire [3:0] evtcntm,//muon tags from trigger memory to shower buffer added 4_12_2016
		input wire [1:0] address_wsb, // write address shower buffer,changed from 3 to 2 bits 4_12_2016
		input wire[1:0] address_rsb,// read address shower buffer,changed from 3 to 2 bits 4_12_2016
		input wire[1:0] address_wmb,// write address muon buffer,changed from 3 to 2 bits 4_12_2016
		input wire[1:0] address_rmb,// read address muon buffer,changed from 3 to 2 bits 4_12_2016
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

   // Ports of Axi Slave Bus Interface S_AXI_INTR
    input wire  s_axi_intr_aclk,
    input wire  s_axi_intr_aresetn,
    input wire [C_S_AXI_INTR_ADDR_WIDTH-1 : 0] s_axi_intr_awaddr,
    input wire [2 : 0] s_axi_intr_awprot,
    input wire  s_axi_intr_awvalid,
    output wire  s_axi_intr_awready,
    input wire [C_S_AXI_INTR_DATA_WIDTH-1 : 0] s_axi_intr_wdata,
    input wire [(C_S_AXI_INTR_DATA_WIDTH/8)-1 : 0] s_axi_intr_wstrb,
    input wire  s_axi_intr_wvalid,
    output wire  s_axi_intr_wready,
    output wire [1 : 0] s_axi_intr_bresp,
    output wire  s_axi_intr_bvalid,
    input wire  s_axi_intr_bready,
    input wire [C_S_AXI_INTR_ADDR_WIDTH-1 : 0] s_axi_intr_araddr,
    input wire [2 : 0] s_axi_intr_arprot,
    input wire  s_axi_intr_arvalid,
    output wire  s_axi_intr_arready,
    output wire [C_S_AXI_INTR_DATA_WIDTH-1 : 0] s_axi_intr_rdata,
    output wire [1 : 0] s_axi_intr_rresp,
    output wire  s_axi_intr_rvalid,
    input wire  s_axi_intr_rready,
    output wire  PPS_IRQ
         
	);
        wire  [31:0] teststatus;// teststatus register output
        wire  [31:0] c120mout_ps;// processor c120mout register output
        wire  [31:0] c120calout_ps;// processor c120calout register output
        wire  [31:0] c120deadout;// dead time register output
        wire  [31:0] timeseconds;// processor pps seconds register output
        wire  [31:0] onanosec; // shower buffer nanoseconds register
        wire  [31:0] oseconds;// shower buffer seconds register
        wire  [31:0] c120mout_sb;// shower buffer c120mout register
        wire  [31:0] c120calout_sb;//shower buffer c120calout register
        wire  [31:0] slowtriggersec;// muon buffer slowtriggersec register
        wire  [31:0] slowtriggerns;// muon buffer slowtriggerns register
        wire  [31:0] c120mout_mb;// muon buffer c120mout register
        wire  [31:0] c120calout_mb;// muon buffer c120calout register
        wire [31:0] ttagctrl; // time tag control register
        wire  [31:0] ttagid; //ttag identification register added 7_9_15
        wire  csel8r;//time tag address read decode for register 8
        wire csel8rr; // time tag address read decode return for register 8
		wire cseldfw; // time tag address write decode for default write registers
		wire cseldfwr; // time tag address write decode return for default write registers
		
// Instantiation of Axi Bus Interface S00_AXI
	time_tagging_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) time_tagging_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		.teststatus(teststatus),
        .c120mout_ps(c120mout_ps),
        .c120calout_ps(c120calout_ps),
        .c120deadout(c120deadout),
        .timeseconds(timeseconds),
        .onanosec(onanosec),
        .oseconds(oseconds),
        .c120mout_sb(c120mout_sb),
        .c120calout_sb(c120calout_sb),
        .slowtriggersec(slowtriggersec),
        .slowtriggerns(slowtriggerns),
        .c120mout_mb(c120mout_mb),
        .c120calout_mb(c120calout_mb),
        .ttagid(ttagid),//ttag identification register added 7_9_15
        .SLV_REG_13(ttagctrl),
        .CSEL_8R(csel8r),
        .csel8rr(csel8rr),
		.CSEL_DFW(cseldfw),
		.cseldfwr(cseldfwr)
	);

      // Instantiation of Axi Bus Interface S_AXI_INTR
   time_tagging_S_AXI_INTR # ( 
		              .C_S_AXI_DATA_WIDTH(C_S_AXI_INTR_DATA_WIDTH),
		              .C_S_AXI_ADDR_WIDTH(C_S_AXI_INTR_ADDR_WIDTH),
		              .C_INTR_SENSITIVITY(C_INTR_SENSITIVITY),
		              .C_INTR_ACTIVE_STATE(C_INTR_ACTIVE_STATE),
		              .C_IRQ_SENSITIVITY(C_IRQ_SENSITIVITY),
		              .C_IRQ_ACTIVE_STATE(C_IRQ_ACTIVE_STATE)
	                      ) 
   time_tagging_S_AXI_INTR_inst (
		                .S_AXI_ACLK(s_axi_intr_aclk),
		                .S_AXI_ARESETN(s_axi_intr_aresetn),
		                .S_AXI_AWADDR(s_axi_intr_awaddr),
		                .S_AXI_AWPROT(s_axi_intr_awprot),
		                .S_AXI_AWVALID(s_axi_intr_awvalid),
		                .S_AXI_AWREADY(s_axi_intr_awready),
		                .S_AXI_WDATA(s_axi_intr_wdata),
		                .S_AXI_WSTRB(s_axi_intr_wstrb),
		                .S_AXI_WVALID(s_axi_intr_wvalid),
		                .S_AXI_WREADY(s_axi_intr_wready),
		                .S_AXI_BRESP(s_axi_intr_bresp),
		                .S_AXI_BVALID(s_axi_intr_bvalid),
		                .S_AXI_BREADY(s_axi_intr_bready),
		                .S_AXI_ARADDR(s_axi_intr_araddr),
		                .S_AXI_ARPROT(s_axi_intr_arprot),
		                .S_AXI_ARVALID(s_axi_intr_arvalid),
		                .S_AXI_ARREADY(s_axi_intr_arready),
		                .S_AXI_RDATA(s_axi_intr_rdata),
		                .S_AXI_RRESP(s_axi_intr_rresp),
		                .S_AXI_RVALID(s_axi_intr_rvalid),
		                .S_AXI_RREADY(s_axi_intr_rready),
		                .irq(PPS_IRQ),
                                .INTR(pps)
	                        );


	// Add user logic here
    time_tagging_hw_v1_0 time_tagging_hw_v1_0_i
              (.clk_120m(clk_120m),
               .pps(pps),
               .evtcnt(evtcnt),
               .evtcntm(evtcntm),//muon tags from trigger memory to shower buffer added 4_12_2016
               .evtclkf(evtclkf),
               .evtclks(evtclks),
               .address_wsb(address_wsb),
               .address_rsb(address_rsb),
               .address_wmb(address_wmb),
               .address_rmb(address_rmb),
               .ttagctrl(ttagctrl),
               .teststatus(teststatus),
               .c120mout_ps(c120mout_ps),
               .c120calout_ps(c120calout_ps),
               .c120deadout(c120deadout),
               .timeseconds(timeseconds),
               .onanosec(onanosec),
               .oseconds(oseconds),
               .c120mout_sb(c120mout_sb),
               .c120calout_sb(c120calout_sb),
               .slowtriggersec(slowtriggersec),
               .slowtriggerns(slowtriggerns),
               .c120mout_mb(c120mout_mb),
               .c120calout_mb(c120calout_mb),
               .ttagid(ttagid),//ttag identification register added 7_9_15
               .dead(dead),
               .csel8r(csel8r),
               .csel8rr(csel8rr),
			   .cseldfw(cseldfw),
			   .cseldfwr(cseldfwr)
               );
	// User logic ends

	endmodule
