// 10-Feb-2019 DFN Add test switching of RD interface signals

`timescale 1 ns / 1 ps

module test_control_v1_0 #
  (
   // Users to add parameters here

   // User parameters ends
   // Do not modify the parameters beyond this line


   // Parameters of Axi Slave Bus Interface S00_AXI
   parameter integer C_S00_AXI_DATA_WIDTH	= 32,
   parameter integer C_S00_AXI_ADDR_WIDTH	= 4
   )
   (
    // Users to add ports here

    input wire CLK120,
    input wire FAKE_PPS,
    input wire TRUE_PPS,
    input wire TRIGGER,
    output wire PPS,
    output wire USE_FAKE_SHWR,
    output wire USE_FAKE_MUON,
    output wire[31:0] FAKE_MODE,
    output wire USE_FAKE_RD,
    input wire FAKE_RDCLK,
    input wire TRUE_RDCLK,
    output wire RDCLK,
    input wire FAKE_ENABLE_XFR,
    input wire TRUE_ENABLE_XFR,
    output wire ENABLE_XFR,
    input wire FAKE_RD_SERIAL0,
    input wire TRUE_RD_SERIAL0,
    output wire RD_SERIAL0,
    input wire FAKE_RD_SERIAL1,
    input wire TRUE_RD_SERIAL1,
    output wire RD_SERIAL1,
    output wire TRIG_OUT,
    
    
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
    input wire  s00_axi_rready
    );
   // Instantiation of Axi Bus Interface S00_AXI
   test_control_v1_0_S00_AXI # 
     ( 
       .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
       .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
       ) test_control_v1_0_S00_AXI_inst
       (
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
	.CLK120(CLK120),
        .TRIGGER(TRIGGER),
	.FAKE_PPS(FAKE_PPS),
	.TRUE_PPS(TRUE_PPS),
	.PPS(PPS),
	.USE_FAKE_SHWR(USE_FAKE_SHWR),
	.USE_FAKE_MUON(USE_FAKE_MUON),
        .FAKE_MODE(FAKE_MODE),
        .USE_FAKE_RD(USE_FAKE_RD),
        .FAKE_RDCLK(FAKE_RDCLK),
        .TRUE_RDCLK(TRUE_RDCLK),
        .RDCLK(RDCLK),
        .FAKE_ENABLE_XFR(FAKE_ENABLE_XFR),
        .TRUE_ENABLE_XFR(TRUE_ENABLE_XFR),
        .ENABLE_XFR(ENABLE_XFR),
        .FAKE_RD_SERIAL0(FAKE_RD_SERIAL0),
        .TRUE_RD_SERIAL0(TRUE_RD_SERIAL0),
        .RD_SERIAL0(RD_SERIAL0),
        .FAKE_RD_SERIAL1(FAKE_RD_SERIAL1),
        .TRUE_RD_SERIAL1(TRUE_RD_SERIAL1),
        .RD_SERIAL1(RD_SERIAL1),
        .TRIG_OUT(TRIG_OUT)
        );

   // Add user logic here

   // User logic ends

endmodule
