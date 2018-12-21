// 13-Jul-15 DFN Added 3rd & 4th shower memory buffers.
// 26-Feb-16 DFN Add TRIG_IN input
// 29-Feb-16 DFN Add TRIG_OUT output; remove parameter C_NUM_OF_INTR -- too
//               many problems with it getting set to 1.
// 03-Apr-16 DFN Add EXT0_CTL & EXT1_CTL outputs (for debugging for now)
// 07-Apr-16 DFN Split 120 bit wide ADC bus into one each per physical ADC.
// 03-May-16 DFN Add 2nd muon data output to provide room for SSD data.
// 21-Jun-16 DFN Change EXTx_CTL to EXTx_DATA.
// 21-Jun-16 DFN Remove EXTx_DATA; add test point outputs
// 24-Jun-16 DFN Add externally filtered PMT inputs
// 22-Nov-17 DFN Add SHWR_TRIG_FAST
// 28-Apr-18 DFN Split shower & muon interrupt modules

`timescale 1 ns / 1 ps

`include "sde_trigger_options.vh"
`include "sde_trigger_defs.vh"

module sde_trigger #
  (
   // Users to add parameters here

   // User parameters ends
   // Do not modify the parameters beyond this line


   // Parameters of Axi Slave Bus Interfac S00_AXI
   parameter integer C_S00_AXI_DATA_WIDTH	= 32,
   parameter integer C_S00_AXI_ADDR_WIDTH	= 10,

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
   
    input wire [`ADC_WIDTH*2-1:0] ADC0,    // PMT signals
    input wire [`ADC_WIDTH*2-1:0] ADC1,    // PMT signals
    input wire [`ADC_WIDTH*2-1:0] ADC2,    // PMT signals
    input wire [`ADC_WIDTH*2-1:0] ADC3,    // PMT signals
    input wire [`ADC_WIDTH*2-1:0] ADC4,    // PMT signals
    input wire [`ADC_WIDTH+1:0] FILT_PMT0, // Filtered high gain PMT0
    input wire [`ADC_WIDTH+1:0] FILT_PMT1, // Filtered high gain PMT1
    input wire [`ADC_WIDTH+1:0] FILT_PMT2, // Filtered high gain PMT2
    input wire                           CLK120,  // 120 MHz ADC clock
    input wire                          TRIG_IN,  // External trigger input
    input wire ONE_PPS, // One pulse per second from GPS
    input wire LED_FLG, // Flag that LED pulsed

    output wire [`SHWR_MEM_WIDTH-1:0] SHWR_DATA0,  // Shower data to be stored
    output wire [`SHWR_MEM_WIDTH-1:0] SHWR_DATA1,  // Shower data to be stored
    output wire [`SHWR_MEM_WIDTH-1:0] SHWR_DATA2,  // Shower data to be stored
    output wire [`SHWR_MEM_WIDTH-1:0] SHWR_DATA3,  // Shower data to be stored
    output wire [`SHWR_MEM_WIDTH-1:0] SHWR_DATA4,  // Shower data to be stored
    output wire [`SHWR_MEM_ADDR_WIDTH-1:0] SHWR_ADDR, // Address to store it
    output wire SHWR_TRIGGER,  // Shower trigger signal at end of trace
    output wire SHWR_TRIG_FAST, // Shower trig signal when it happens (AMIGA)
    output wire DEAD,     // Dead time indicator
    output wire [`SHWR_BUF_NUM_WIDTH-1:0] SHWR_BUF_WNUM,
    output wire [`SHWR_BUF_NUM_WIDTH-1:0] SHWR_BUF_RNUM,
    output wire [`SHWR_EVT_CTR_WIDTH-1:0] SHWR_EVT_CTR,
    output wire [`SHWR_EVT_ID_WIDTH-1:0] SHWR_EVT_ID,

    output wire [`MUON_MEM_WIDTH-1:0] MUON_DATA0,  // Muon data to be stored
    output wire [`MUON_MEM_WIDTH-1:0] MUON_DATA1,  // Muon data to be stored
    output wire [`MUON_MEM_ADDR_WIDTH-1:0] MUON_ADDR, // Address to store it
    output wire MUON_ENB, // Enable for port B
    output wire MUON_TRIGGER,
    output wire [`MUON_BUF_NUM_WIDTH-1:0] MUON_BUF_WNUM,
    output wire [`MUON_BUF_NUM_WIDTH-1:0] MUON_BUF_RNUM,
    output wire [`MUON_EVT_CTR_WIDTH-1:0] MUON_EVT_CTR,
    output wire TRIG_OUT, // External trigger output
    output P61,  // Test point outputs
    output P62,  // Test point outputs
    output P63,  // Test point outputs
    output wire LED,
   
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
    output wire  SHWR_IRQ,

        // Ports of Axi Slave Bus Interface S1_AXI_INTR
    input wire  s1_axi_intr_aclk,
    input wire  s1_axi_intr_aresetn,
    input wire [C_S_AXI_INTR_ADDR_WIDTH-1 : 0] s1_axi_intr_awaddr,
    input wire [2 : 0] s1_axi_intr_awprot,
    input wire  s1_axi_intr_awvalid,
    output wire  s1_axi_intr_awready,
    input wire [C_S_AXI_INTR_DATA_WIDTH-1 : 0] s1_axi_intr_wdata,
    input wire [(C_S_AXI_INTR_DATA_WIDTH/8)-1 : 0] s1_axi_intr_wstrb,
    input wire  s1_axi_intr_wvalid,
    output wire  s1_axi_intr_wready,
    output wire [1 : 0] s1_axi_intr_bresp,
    output wire  s1_axi_intr_bvalid,
    input wire  s1_axi_intr_bready,
    input wire [C_S_AXI_INTR_ADDR_WIDTH-1 : 0] s1_axi_intr_araddr,
    input wire [2 : 0] s1_axi_intr_arprot,
    input wire  s1_axi_intr_arvalid,
    output wire  s1_axi_intr_arready,
    output wire [C_S_AXI_INTR_DATA_WIDTH-1 : 0] s1_axi_intr_rdata,
    output wire [1 : 0] s1_axi_intr_rresp,
    output wire  s1_axi_intr_rvalid,
    input wire  s1_axi_intr_rready,
    output wire  MUON_IRQ
    );

   wire          MUON_INTR;
   wire          SHWR_INTR;
   wire          P61A;
   wire          P62A;
   wire          P63A;
   
   
   // Instantiation of Axi Bus Interface S00_AXI
   sde_trigger_S00_AXI # ( 
		           .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		           .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	                   ) 
   sde_trigger_S00_AXI_inst (
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
                             .ADC0(ADC0),
                             .ADC1(ADC1),
                             .ADC2(ADC2),
                             .ADC3(ADC3),
                             .ADC4(ADC4),
                             .FILT_PMT0(FILT_PMT0),
                             .FILT_PMT1(FILT_PMT1),
                             .FILT_PMT2(FILT_PMT2),
                             .TRIG_IN(TRIG_IN),
                             .ONE_PPS(ONE_PPS),
                             .LED_FLG(LED_FLG),
                             .SHWR_DATA0(SHWR_DATA0),
                             .SHWR_DATA1(SHWR_DATA1),
                             .SHWR_DATA2(SHWR_DATA2),
                             .SHWR_DATA3(SHWR_DATA3),
                             .SHWR_DATA4(SHWR_DATA4),
                             .SHWR_ADDR(SHWR_ADDR),
                             .SHWR_TRIGGER(SHWR_TRIGGER),
			     .SHWR_TRIG_FAST(SHWR_TRIG_FAST),
                             .DEAD(DEAD),
                             .SHWR_BUF_WNUM(SHWR_BUF_WNUM),
                             .SHWR_BUF_RNUM(SHWR_BUF_RNUM),
                             .SHWR_EVT_CTR(SHWR_EVT_CTR),
                             .SHWR_EVT_ID(SHWR_EVT_ID),
                             .MUON_DATA0(MUON_DATA0),
                             .MUON_DATA1(MUON_DATA1),
                             .MUON_ADDR(MUON_ADDR),
                             .MUON_ENB(MUON_ENB),
                             .MUON_TRIGGER(MUON_TRIGGER),
                             .MUON_BUF_WNUM(MUON_BUF_WNUM),
                             .MUON_BUF_RNUM(MUON_BUF_RNUM),
                             .MUON_EVT_CTR(MUON_EVT_CTR),
                             .SHWR_INTR(SHWR_INTR),
                             .MUON_INTR(MUON_INTR),
                             .TRIG_OUT(TRIG_OUT),
			     .P61(P61A),
			     .P62(P62A),
			     .P63(P63A),
                             .LED(LED)
	                     );

   // Instantiation of Axi Bus Interface S_AXI_INTR
   sde_trigger_S_AXI_INTR # ( 
		              .C_S_AXI_DATA_WIDTH(C_S_AXI_INTR_DATA_WIDTH),
		              .C_S_AXI_ADDR_WIDTH(C_S_AXI_INTR_ADDR_WIDTH),
		              .C_INTR_SENSITIVITY(C_INTR_SENSITIVITY),
		              .C_INTR_ACTIVE_STATE(C_INTR_ACTIVE_STATE),
		              .C_IRQ_SENSITIVITY(C_IRQ_SENSITIVITY),
		              .C_IRQ_ACTIVE_STATE(C_IRQ_ACTIVE_STATE)
	                      ) 
   sde_trigger_S_AXI_INTR_shwr (
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
		                .irq(SHWR_IRQ),
                                .INTR(SHWR_INTR),
                                .CLK120(CLK120)
	                        );

      // Instantiation of Axi Bus Interface S_AXI_INTR
   sde_trigger_S_AXI_INTR # ( 
		              .C_S_AXI_DATA_WIDTH(C_S_AXI_INTR_DATA_WIDTH),
		              .C_S_AXI_ADDR_WIDTH(C_S_AXI_INTR_ADDR_WIDTH),
		              .C_INTR_SENSITIVITY(C_INTR_SENSITIVITY),
		              .C_INTR_ACTIVE_STATE(C_INTR_ACTIVE_STATE),
		              .C_IRQ_SENSITIVITY(C_IRQ_SENSITIVITY),
		              .C_IRQ_ACTIVE_STATE(C_IRQ_ACTIVE_STATE)
	                      ) 
   sde_trigger_S_AXI_INTR_muon (
		                .S_AXI_ACLK(s1_axi_intr_aclk),
		                .S_AXI_ARESETN(s1_axi_intr_aresetn),
		                .S_AXI_AWADDR(s1_axi_intr_awaddr),
		                .S_AXI_AWPROT(s1_axi_intr_awprot),
		                .S_AXI_AWVALID(s1_axi_intr_awvalid),
		                .S_AXI_AWREADY(s1_axi_intr_awready),
		                .S_AXI_WDATA(s1_axi_intr_wdata),
		                .S_AXI_WSTRB(s1_axi_intr_wstrb),
		                .S_AXI_WVALID(s1_axi_intr_wvalid),
		                .S_AXI_WREADY(s1_axi_intr_wready),
		                .S_AXI_BRESP(s1_axi_intr_bresp),
		                .S_AXI_BVALID(s1_axi_intr_bvalid),
		                .S_AXI_BREADY(s1_axi_intr_bready),
		                .S_AXI_ARADDR(s1_axi_intr_araddr),
		                .S_AXI_ARPROT(s1_axi_intr_arprot),
		                .S_AXI_ARVALID(s1_axi_intr_arvalid),
		                .S_AXI_ARREADY(s1_axi_intr_arready),
		                .S_AXI_RDATA(s1_axi_intr_rdata),
		                .S_AXI_RRESP(s1_axi_intr_rresp),
		                .S_AXI_RVALID(s1_axi_intr_rvalid),
		                .S_AXI_RREADY(s1_axi_intr_rready),
		                .irq(MUON_IRQ),
                                .INTR(MUON_INTR),
                                .CLK120(CLK120)
	                        );

 

   // Add user logic here

   assign P61 = P61A;
   assign P62 = P62A;
   assign P63 = P63A;
        
   // User logic ends

endmodule
