//
// 03-Dec-2019 DFN Add SHWR_BUF_LATENCY register.
// 14-Mar-2021 DFN Add bank of TESTxx registers.

`timescale 1 ns / 1 ps

`include "sde_trigger_options.vh"
`include "sde_trigger_defs.vh"

module sde_trigger_S00_AXI #
  (
   // Users to add parameters here

   // User parameters ends
   // Do not modify the parameters beyond this line

   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH	= 32,
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH	= 10
   )
   (
    // Users to add ports here

    input [`ADC_WIDTH*2-1:0] ADC0,    // PMT signals
    input [`ADC_WIDTH*2-1:0] ADC1,    // PMT signals
    input [`ADC_WIDTH*2-1:0] ADC2,    // PMT signals
    input [`ADC_WIDTH*2-1:0] ADC3,    // PMT signals
    input [`ADC_WIDTH*2-1:0] ADC4,    // PMT signals
    input [`ADC_WIDTH+1:0] FILT_PMT0, // Filtered high gain PMT0
    input [`ADC_WIDTH+1:0] FILT_PMT1, // Filtered high gain PMT0
    input [`ADC_WIDTH+1:0] FILT_PMT2, // Filtered high gain PMT0
    input wire CLK120, // 120 MHz ADC clock
    input wire AXI_MEM_CLK, // AXI buffer memory clock
    input wire TRIG_IN,// External trigger input
    input wire ONE_PPS, // One pulse per second from GPS
    input wire LED_FLG, // External flag that LED pulsed
    input wire DBG_IN1, // Debug from external block
    input wire DBG_IN2, // Debug from external block
    input wire DBG_IN3, // Debug from external block
    input wire DBG_IN4, // Debug from external block
    input wire DBG_IN5, // Debug from external block
    
    output reg [`SHWR_MEM_WIDTH-1:0] SHWR_DATA0,     // Shower data to be stored
    output reg [`SHWR_MEM_WIDTH-1:0] SHWR_DATA1,     // Shower data to be stored
    output reg [`SHWR_MEM_WIDTH-1:0] SHWR_DATA2,     // Shower data to be stored
    output reg [`SHWR_MEM_WIDTH-1:0] SHWR_DATA3,     // Shower data to be stored
    output reg [`SHWR_MEM_WIDTH-1:0] SHWR_DATA4,     // Shower data to be stored
    output reg [`SHWR_MEM_ADDR_WIDTH-1:0] SHWR_ADDR, // Address to store it
    output reg SHWR_TRIGGER,  // Trigger (at end of trace)
    output reg SHWR_TRIG_FAST, // Trigger (when it happens)
    output reg DEAD,     // Dead time indicator
    output reg [`SHWR_BUF_NUM_WIDTH-1:0] SHWR_BUF_WNUM,
    output reg [`SHWR_BUF_NUM_WIDTH-1:0] SHWR_BUF_RNUM,
    output reg [`SHWR_EVT_CTR_WIDTH-1:0] SHWR_EVT_CTR,
    output reg [`SHWR_EVT_ID_WIDTH-1:0] SHWR_EVT_ID,

    output wire [`MUON_MEM_WIDTH-1:0] MUON_DATA0,     // Muon data to be stored
    output wire [`MUON_MEM_WIDTH-1:0] MUON_DATA1,     // Muon data to be stored
    output wire [`MUON_MEM_ADDR_WIDTH-1:0] MUON_ADDR, // Address to store it
    output wire MUON_ENB,
    output wire [`MUON_BUF_NUM_WIDTH-1:0] MUON_BUF_WNUM,
    output wire [`MUON_BUF_NUM_WIDTH-1:0] MUON_BUF_RNUM,
    output wire [`MUON_EVT_CTR_WIDTH-1:0] MUON_EVT_CTR,
    output wire MUON_TRIGGER,  // Pulse when a muon buffer is full
    output reg SHWR_INTR,      // Remains high until no full buffers
    output wire MUON_INTR,     // Remains high until no full buffers
    output wire TRIG_OUT,       // External trigger output
    //output reg TRIG_OUT,// "reg" for debug - restore to "wire" for std code
    output reg DBG1,       // Test point
    output reg DBG2,       // Test point
    output reg DBG3,       // Test point
    output reg DBG4,       // Test point
    output reg DBG5,       // Test point
    output wire LED,
                
    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire  S_AXI_RREADY
    );

   // AXI4LITE signals
   reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
   reg                            axi_awready;
   reg                            axi_wready;
   reg [1 : 0]                    axi_bresp;
   reg                            axi_bvalid;
   reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
   reg                            axi_arready;
   reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
   reg [1 : 0]                    axi_rresp;
   reg                            axi_rvalid;

   // Example-specific design signals
   // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
   // ADDR_LSB is used for addressing 32/64 bit registers/memories
   // ADDR_LSB = 2 for 32 bits (n downto 2)
   // ADDR_LSB = 3 for 64 bits (n downto 3)
   localparam integer             ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
   localparam integer             OPT_MEM_ADDR_BITS = 7;
   
//----------------------------------------------
   //-- Signals for user logic register space example
   //------------------------------------------------
   //-- Number of Slave Registers: up to 256
   // Register addresses are defined in sde_trigger_defs.vh
   
   reg [C_S_AXI_DATA_WIDTH-1:0]   SB_TRIG_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   SB_TRIG_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   SB_TRIG_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   SB_TRIG_SSD;
   reg [C_S_AXI_DATA_WIDTH-1:0]   SB_TRIG_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG1_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG1_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG1_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG1_SSD;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG1_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG2_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG2_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG2_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG2_SSD;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG2_ENAB;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG3_THR0;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG3_THR1;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG3_THR2;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG3_SSD;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG3_ENAB;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG4_THR0;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG4_THR1;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG4_THR2;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG4_SSD;
   // reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_TRIG4_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_AMIGA_TRIG;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_MIN0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_MIN1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_MIN2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_MAX0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_MAX1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_MAX2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_INT;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_OCC;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_MOPS_TRIG_OFS;
   wire [C_S_AXI_DATA_WIDTH-1:0]   MUON_BUF_TIME_TAG_A;
   wire [C_S_AXI_DATA_WIDTH-1:0]   MUON_BUF_TIME_TAG_B;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_BUF_TRIG_MASK;
   reg [C_S_AXI_DATA_WIDTH-1:0]   MUON_BUF_CONTROL;
   wire [C_S_AXI_DATA_WIDTH-1:0]   MUON_BUF_STATUS;
   wire [C_S_AXI_DATA_WIDTH-1:0]   MUON_BUF_WORD_COUNT;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TRIG_RATES;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_DELAYED_RATES;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_GLOBAL_CONTROL;
   reg [C_S_AXI_DATA_WIDTH-1:0]   ID_REG;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SB_TRIG_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SB_TRIG_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SB_TRIG_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SB_TRIG_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   RANDOM_TRIG_MODE;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOT_TRIG_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOT_TRIG_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOT_TRIG_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOT_TRIG_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOT_TRIG_OCC;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_UP0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_UP1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_UP2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_ENAB;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_OCC;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_FD;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_FN;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_TOTD_TRIG_INT;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_A_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_A_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_A_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_A_ENAB;
   wire [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_A_COUNT;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_B_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_B_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_B_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_B_ENAB;
   wire [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_B_COUNT;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_C_THR0;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_C_THR1;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_C_THR2;
   reg [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_C_ENAB;
   wire [C_S_AXI_DATA_WIDTH-1:0]   COMPATIBILITY_SCALER_C_COUNT;
   reg [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_TRIG_MASK;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_TRIG_ID;
   reg [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_CONTROL;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_STATUS;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_START;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_LATENCY;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_LATENCY0;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BUF_LATENCY1;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA0;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA1;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA2;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA3;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA4;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA5;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA6;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA7;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA8;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_PEAK_AREA9;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BASELINE0;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BASELINE1;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BASELINE2;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BASELINE3;
   wire [C_S_AXI_DATA_WIDTH-1:0]   SHWR_BASELINE4;

   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST0;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST1;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST2;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST3;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST4;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST5;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST6;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST7;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST8;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST9;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST10;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST11;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST12;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST13;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST14;
   wire [C_S_AXI_DATA_WIDTH-1:0]   TEST15;

   wire [C_S_AXI_DATA_WIDTH-1:0]   FILT_PMT0_TEST;
   wire [C_S_AXI_DATA_WIDTH-1:0]   FILT_PMT1_TEST;
   wire [C_S_AXI_DATA_WIDTH-1:0]   FILT_PMT2_TEST;

   wire [C_S_AXI_DATA_WIDTH-1:0]   ADC0_TEST;
   wire [C_S_AXI_DATA_WIDTH-1:0]   ADC1_TEST;
   wire [C_S_AXI_DATA_WIDTH-1:0]   ADC2_TEST;
   wire [C_S_AXI_DATA_WIDTH-1:0]   ADC3_TEST;
   wire [C_S_AXI_DATA_WIDTH-1:0]   ADC4_TEST;
   reg [C_S_AXI_DATA_WIDTH-1:0]   LED_CONTROL;
   
   wire                           slv_reg_rden;
   wire                           slv_reg_wren;
   reg [C_S_AXI_DATA_WIDTH-1:0]   reg_data_out;
   integer                        byte_index;

   // I/O Connections assignments

   assign S_AXI_AWREADY	= axi_awready;
   assign S_AXI_WREADY	= axi_wready;
   assign S_AXI_BRESP	= axi_bresp;
   assign S_AXI_BVALID	= axi_bvalid;
   assign S_AXI_ARREADY	= axi_arready;
   assign S_AXI_RDATA	= axi_rdata;
   assign S_AXI_RRESP	= axi_rresp;
   assign S_AXI_RVALID	= axi_rvalid;
   // Implement axi_awready generation
   // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
   // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
   // de-asserted when reset is low.

   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_awready <= 1'b0;
	  end 
	else
	  begin    
	     if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	       begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	       end
	     else           
	       begin
	          axi_awready <= 1'b0;
	       end
	  end 
     end       

   // Implement axi_awaddr latching
   // This process is used to latch the address when both 
   // S_AXI_AWVALID and S_AXI_WVALID are valid. 

   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_awaddr <= 0;
	  end 
	else
	  begin    
	     if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	       begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	       end
	  end 
     end       

   // Implement axi_wready generation
   // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
   // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
   // de-asserted when reset is low. 

   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_wready <= 1'b0;
	  end 
	else
	  begin    
	     if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	       begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	       end
	     else
	       begin
	          axi_wready <= 1'b0;
	       end
	  end 
     end       

   // Implement memory mapped register select and write logic generation
   // The write data is accepted and written to memory mapped registers when
   // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
   // select byte enables of slave registers while writing.
   // These registers are cleared when reset (active low) is applied.
   // 20-May-2015 DFN Add reset of registers on global reset command
   //
   // Slave register write enable is asserted when valid address and data are available
   // and the slave is ready to accept the write address and write data.
   assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

   always @( posedge S_AXI_ACLK )
     begin
	if ( (S_AXI_ARESETN == 1'b0) || 
             ((COMPATIBILITY_GLOBAL_CONTROL &
             `COMPATIBILITY_GLOBAL_CONTROL_RESET) != 0))
	  begin
	     SB_TRIG_THR0 <= 0;
	     SB_TRIG_THR1 <= 0;
	     SB_TRIG_THR2 <= 0;
	     SB_TRIG_SSD <= 0;
	     SB_TRIG_ENAB <= 0;
	     MUON_TRIG1_THR0 <= 0;
	     MUON_TRIG1_THR1 <= 0;
	     MUON_TRIG1_THR2 <= 0;
	     MUON_TRIG1_SSD <= 0;
	     MUON_TRIG1_ENAB <= 0;
	     MUON_TRIG2_THR0 <= 0;
	     MUON_TRIG2_THR1 <= 0;
	     MUON_TRIG2_THR2 <= 0;
	     MUON_TRIG2_SSD <= 0;
	     MUON_TRIG2_ENAB <= 0;
	     // MUON_TRIG3_THR0 <= 0;
	     // MUON_TRIG3_THR1 <= 0;
	     // MUON_TRIG3_THR2 <= 0;
	     // MUON_TRIG3_SSD <= 0;
	     // MUON_TRIG3_ENAB <= 0;
	     // MUON_TRIG4_THR0 <= 0;
	     // MUON_TRIG4_THR1 <= 0;
	     // MUON_TRIG4_THR2 <= 0;
	     // MUON_TRIG4_SSD <= 0;
	     // MUON_TRIG4_ENAB <= 0;
	     COMPATIBILITY_AMIGA_TRIG <= 0;
	     COMPATIBILITY_MOPS_TRIG_MIN0 <= 0;
	     COMPATIBILITY_MOPS_TRIG_MIN1 <= 0;
	     COMPATIBILITY_MOPS_TRIG_MIN2 <= 0;
	     COMPATIBILITY_MOPS_TRIG_MAX0 <= 0;
	     COMPATIBILITY_MOPS_TRIG_MAX1 <= 0;
	     COMPATIBILITY_MOPS_TRIG_MAX2 <= 0;
	     COMPATIBILITY_MOPS_TRIG_ENAB <= 0;
	     COMPATIBILITY_MOPS_TRIG_INT <= 0;
	     COMPATIBILITY_MOPS_TRIG_OCC <= 0;
	     COMPATIBILITY_MOPS_TRIG_OFS <= 0;
//	     MUON_BUF_TIME_TAG_A <= 0;
//	     MUON_BUF_TIME_TAG_B <= 0;
	     MUON_BUF_TRIG_MASK <= 0;
	     MUON_BUF_CONTROL <= 0;
//	     MUON_BUF_STATUS <= 0;
//	     MUON_BUF_WORD_COUNT <= 0;
//             COMPATIBILITY_SHWR_BUF_TRIG_MASK <= 0;
//	     COMPATIBILITY_SHWR_BUF_STATUS <= 0;
	     COMPATIBILITY_TRIG_RATES <= 0;
	     COMPATIBILITY_DELAYED_RATES <= 0;
	     COMPATIBILITY_GLOBAL_CONTROL <= 0;
	     COMPATIBILITY_SB_TRIG_THR0 <= 0;
	     COMPATIBILITY_SB_TRIG_THR1 <= 0;
	     COMPATIBILITY_SB_TRIG_THR2 <= 0;
             COMPATIBILITY_SB_TRIG_ENAB <= 0;
	     RANDOM_TRIG_MODE <= 0;
	     COMPATIBILITY_TOT_TRIG_THR0 <= 0;
	     COMPATIBILITY_TOT_TRIG_THR1 <= 0;
	     COMPATIBILITY_TOT_TRIG_THR2 <= 0;
	     COMPATIBILITY_TOT_TRIG_ENAB <= 0;
	     COMPATIBILITY_TOT_TRIG_OCC <= 0;
	     COMPATIBILITY_TOTD_TRIG_THR0 <= 0;
	     COMPATIBILITY_TOTD_TRIG_THR1 <= 0;
	     COMPATIBILITY_TOTD_TRIG_THR2 <= 0;
	     COMPATIBILITY_TOTD_TRIG_UP0 <= 0;
	     COMPATIBILITY_TOTD_TRIG_UP1 <= 0;
	     COMPATIBILITY_TOTD_TRIG_UP2 <= 0;
	     COMPATIBILITY_TOTD_TRIG_ENAB <= 0;
	     COMPATIBILITY_TOTD_TRIG_OCC <= 0;
	     COMPATIBILITY_TOTD_TRIG_FD <= 0;
	     COMPATIBILITY_TOTD_TRIG_FN <= 0;
	     COMPATIBILITY_SCALER_A_THR0 <= 0;
	     COMPATIBILITY_SCALER_A_THR1 <= 0;
	     COMPATIBILITY_SCALER_A_THR2 <= 0;
	     COMPATIBILITY_SCALER_A_ENAB <= 0;
//	     COMPATIBILITY_SCALER_A_COUNT <= 0;
	     COMPATIBILITY_SCALER_B_THR0 <= 0;
	     COMPATIBILITY_SCALER_B_THR1 <= 0;
	     COMPATIBILITY_SCALER_B_THR2 <= 0;
	     COMPATIBILITY_SCALER_B_ENAB <= 0;
//	     COMPATIBILITY_SCALER_B_COUNT <= 0;
	     COMPATIBILITY_SCALER_C_THR0 <= 0;
	     COMPATIBILITY_SCALER_C_THR1 <= 0;
	     COMPATIBILITY_SCALER_C_THR2 <= 0;
	     COMPATIBILITY_SCALER_C_ENAB <= 0;
//	     COMPATIBILITY_SCALER_C_COUNT <= 0;
	     SHWR_BUF_TRIG_MASK <= `COMPATIBILITY_SHWR_BUF_TRIG_EXT;
	     SHWR_BUF_CONTROL <= 0;
             LED_CONTROL <= 0;
	  end 
	else begin
	   if (slv_reg_wren)
	     begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          `SB_TRIG_THR0_ADDR :
	            SB_TRIG_THR0 <= S_AXI_WDATA;
	          `SB_TRIG_THR1_ADDR :
	            SB_TRIG_THR1 <= S_AXI_WDATA;
	          `SB_TRIG_THR2_ADDR :
	            SB_TRIG_THR2 <= S_AXI_WDATA;
	          `SB_TRIG_SSD_ADDR :
	            SB_TRIG_SSD <= S_AXI_WDATA;
	          `SB_TRIG_ENAB_ADDR :
	            SB_TRIG_ENAB <= S_AXI_WDATA;
	          `MUON_TRIG1_THR0_ADDR :
	            MUON_TRIG1_THR0 <= S_AXI_WDATA;
	          `MUON_TRIG1_THR1_ADDR :
	            MUON_TRIG1_THR1 <= S_AXI_WDATA;
	          `MUON_TRIG1_THR2_ADDR :
	            MUON_TRIG1_THR2 <= S_AXI_WDATA;
	          `MUON_TRIG1_SSD_ADDR :
	            MUON_TRIG1_SSD <= S_AXI_WDATA;
	          `MUON_TRIG1_ENAB_ADDR :
	            MUON_TRIG1_ENAB <= S_AXI_WDATA;
                  `MUON_TRIG2_THR0_ADDR :
	            MUON_TRIG2_THR0 <= S_AXI_WDATA;
	          `MUON_TRIG2_THR1_ADDR :
	            MUON_TRIG2_THR1 <= S_AXI_WDATA;
	          `MUON_TRIG2_THR2_ADDR :
	            MUON_TRIG2_THR2 <= S_AXI_WDATA;
	          `MUON_TRIG2_SSD_ADDR :
	            MUON_TRIG2_SSD <= S_AXI_WDATA;
	          `MUON_TRIG2_ENAB_ADDR :
	            MUON_TRIG2_ENAB <= S_AXI_WDATA;
	          // `MUON_TRIG3_THR0_ADDR :
	          //   MUON_TRIG3_THR0 <= S_AXI_WDATA;
	          // `MUON_TRIG3_THR1_ADDR :
	          //   MUON_TRIG3_THR1 <= S_AXI_WDATA;
	          // `MUON_TRIG3_THR2_ADDR :
	          //   MUON_TRIG3_THR2 <= S_AXI_WDATA;
	          // `MUON_TRIG3_SSD_ADDR :
	          //   MUON_TRIG3_SSD <= S_AXI_WDATA;
	          // `MUON_TRIG3_ENAB_ADDR :
	          //   MUON_TRIG3_ENAB <= S_AXI_WDATA;
	          // `MUON_TRIG4_THR0_ADDR :
	          //   MUON_TRIG4_THR0 <= S_AXI_WDATA;
	          // `MUON_TRIG4_THR1_ADDR :
	          //   MUON_TRIG4_THR1 <= S_AXI_WDATA;
	          // `MUON_TRIG4_THR2_ADDR :
	          //   MUON_TRIG4_THR2 <= S_AXI_WDATA;
	          // `MUON_TRIG4_SSD_ADDR :
	          //   MUON_TRIG4_SSD <= S_AXI_WDATA;
	          // `MUON_TRIG4_ENAB_ADDR :
	          //   MUON_TRIG4_ENAB <= S_AXI_WDATA;
	          `COMPATIBILITY_AMIGA_TRIG_ADDR :
	            COMPATIBILITY_AMIGA_TRIG <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_MIN0_ADDR :
	            COMPATIBILITY_MOPS_TRIG_MIN0 <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_MIN1_ADDR :
	            COMPATIBILITY_MOPS_TRIG_MIN1 <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_MIN2_ADDR :
	            COMPATIBILITY_MOPS_TRIG_MIN2 <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_MAX0_ADDR :
	            COMPATIBILITY_MOPS_TRIG_MAX0 <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_MAX1_ADDR :
	            COMPATIBILITY_MOPS_TRIG_MAX1 <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_MAX2_ADDR :
	            COMPATIBILITY_MOPS_TRIG_MAX2 <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_ENAB_ADDR :
	            COMPATIBILITY_MOPS_TRIG_ENAB <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_INT_ADDR :
	            COMPATIBILITY_MOPS_TRIG_INT <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_OCC_ADDR :
	            COMPATIBILITY_MOPS_TRIG_OCC <= S_AXI_WDATA;
	          `COMPATIBILITY_MOPS_TRIG_OFS_ADDR :
	            COMPATIBILITY_MOPS_TRIG_OFS <= S_AXI_WDATA;
	          `MUON_BUF_TRIG_MASK_ADDR :
	            MUON_BUF_TRIG_MASK <= S_AXI_WDATA;
	          `MUON_BUF_CONTROL_ADDR :
	            MUON_BUF_CONTROL <= S_AXI_WDATA;
	          `COMPATIBILITY_TRIG_RATES_ADDR :
	            COMPATIBILITY_TRIG_RATES <= S_AXI_WDATA;
	          `COMPATIBILITY_DELAYED_RATES_ADDR :
	            COMPATIBILITY_DELAYED_RATES <= S_AXI_WDATA;
	          `COMPATIBILITY_GLOBAL_CONTROL_ADDR :
	            COMPATIBILITY_GLOBAL_CONTROL <= S_AXI_WDATA;
	          `COMPATIBILITY_SB_TRIG_THR0_ADDR :
	            COMPATIBILITY_SB_TRIG_THR0 <= S_AXI_WDATA;
	          `COMPATIBILITY_SB_TRIG_THR1_ADDR :
	            COMPATIBILITY_SB_TRIG_THR1 <= S_AXI_WDATA;
	          `COMPATIBILITY_SB_TRIG_THR2_ADDR :
	            COMPATIBILITY_SB_TRIG_THR2 <= S_AXI_WDATA;
	          `COMPATIBILITY_SB_TRIG_ENAB_ADDR :
	            COMPATIBILITY_SB_TRIG_ENAB <= S_AXI_WDATA;
	          `RANDOM_TRIG_MODE_ADDR :
	            RANDOM_TRIG_MODE <= S_AXI_WDATA;
	          `COMPATIBILITY_TOT_TRIG_THR0_ADDR :
	            COMPATIBILITY_TOT_TRIG_THR0 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOT_TRIG_THR1_ADDR :
	            COMPATIBILITY_TOT_TRIG_THR1 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOT_TRIG_THR2_ADDR :
	            COMPATIBILITY_TOT_TRIG_THR2 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOT_TRIG_ENAB_ADDR :
	            COMPATIBILITY_TOT_TRIG_ENAB <= S_AXI_WDATA;
	          `COMPATIBILITY_TOT_TRIG_OCC_ADDR :
	            COMPATIBILITY_TOT_TRIG_OCC <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_THR0_ADDR :
	            COMPATIBILITY_TOTD_TRIG_THR0 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_THR1_ADDR :
	            COMPATIBILITY_TOTD_TRIG_THR1 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_THR2_ADDR :
	            COMPATIBILITY_TOTD_TRIG_THR2 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_UP0_ADDR :
	            COMPATIBILITY_TOTD_TRIG_UP0 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_UP1_ADDR :
	            COMPATIBILITY_TOTD_TRIG_UP1 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_UP2_ADDR :
	            COMPATIBILITY_TOTD_TRIG_UP2 <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_ENAB_ADDR :
	            COMPATIBILITY_TOTD_TRIG_ENAB <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_OCC_ADDR :
	            COMPATIBILITY_TOTD_TRIG_OCC <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_FD_ADDR :
	            COMPATIBILITY_TOTD_TRIG_FD <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_FN_ADDR :
	            COMPATIBILITY_TOTD_TRIG_FN <= S_AXI_WDATA;
	          `COMPATIBILITY_TOTD_TRIG_INT_ADDR :
	            COMPATIBILITY_TOTD_TRIG_INT <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_A_THR0_ADDR :
	            COMPATIBILITY_SCALER_A_THR0 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_A_THR1_ADDR :
	            COMPATIBILITY_SCALER_A_THR1 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_A_THR2_ADDR :
	            COMPATIBILITY_SCALER_A_THR2 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_A_ENAB_ADDR :
	            COMPATIBILITY_SCALER_A_ENAB <= S_AXI_WDATA;
//	          `COMPATIBILITY_SCALER_A_COUNT_ADDR :
//	            COMPATIBILITY_SCALER_A_COUNT <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_B_THR0_ADDR :
	            COMPATIBILITY_SCALER_B_THR0 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_B_THR1_ADDR :
	            COMPATIBILITY_SCALER_B_THR1 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_B_THR2_ADDR :
	            COMPATIBILITY_SCALER_B_THR2 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_B_ENAB_ADDR :
	            COMPATIBILITY_SCALER_B_ENAB <= S_AXI_WDATA;
//	          `COMPATIBILITY_SCALER_B_COUNT_ADDR :
//	            COMPATIBILITY_SCALER_B_COUNT <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_C_THR0_ADDR :
	            COMPATIBILITY_SCALER_C_THR0 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_C_THR1_ADDR :
	            COMPATIBILITY_SCALER_C_THR1 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_C_THR2_ADDR :
	            COMPATIBILITY_SCALER_C_THR2 <= S_AXI_WDATA;
	          `COMPATIBILITY_SCALER_C_ENAB_ADDR :
	            COMPATIBILITY_SCALER_C_ENAB <= S_AXI_WDATA;
//	          `COMPATIBILITY_SCALER_C_COUNT_ADDR :
//	            COMPATIBILITY_SCALER_C_COUNT <= S_AXI_WDATA;
	          `SHWR_BUF_TRIG_MASK_ADDR :
	            SHWR_BUF_TRIG_MASK <= S_AXI_WDATA;
	          `SHWR_BUF_CONTROL_ADDR :
	            SHWR_BUF_CONTROL <= S_AXI_WDATA;
                  `LED_CONTROL_ADDR :
                    LED_CONTROL <= S_AXI_WDATA;
                  
	          default : begin
	             SB_TRIG_THR0
                       <= SB_TRIG_THR0;
	             SB_TRIG_THR1 
                       <= SB_TRIG_THR1;
	             SB_TRIG_THR2 
                       <= SB_TRIG_THR2;
	             SB_TRIG_SSD 
                       <= SB_TRIG_SSD;
	             SB_TRIG_ENAB 
                       <= SB_TRIG_ENAB;
	             MUON_TRIG1_THR0
                       <= MUON_TRIG1_THR0;
	             MUON_TRIG1_THR1 
                       <= MUON_TRIG1_THR1;
	             MUON_TRIG1_THR2 
                       <= MUON_TRIG1_THR2;
	             MUON_TRIG1_SSD 
                       <= MUON_TRIG1_SSD;
	             MUON_TRIG1_ENAB 
                       <= MUON_TRIG1_ENAB;
	             MUON_TRIG2_THR0
                       <= MUON_TRIG2_THR0;
	             MUON_TRIG2_THR1 
                       <= MUON_TRIG2_THR1;
	             MUON_TRIG2_THR2 
                       <= MUON_TRIG2_THR2;
	             MUON_TRIG2_SSD 
                       <= MUON_TRIG2_SSD;
	             MUON_TRIG2_ENAB 
                       <= MUON_TRIG2_ENAB;
	             // MUON_TRIG3_THR0
                     //   <= MUON_TRIG3_THR0;
	             // MUON_TRIG3_THR1 
                     //   <= MUON_TRIG3_THR1;
	             // MUON_TRIG3_THR2 
                     //   <= MUON_TRIG3_THR2;
	             // MUON_TRIG3_SSD 
                     //   <= MUON_TRIG3_SSD;
	             // MUON_TRIG3_ENAB 
                     //   <= MUON_TRIG3_ENAB;
	             // MUON_TRIG4_THR0
                     //   <= MUON_TRIG4_THR0;
	             // MUON_TRIG4_THR1 
                     //   <= MUON_TRIG4_THR1;
	             // MUON_TRIG4_THR2 
                     //   <= MUON_TRIG4_THR2;
	             // MUON_TRIG4_SSD 
                     //   <= MUON_TRIG4_SSD;
	             // MUON_TRIG4_ENAB 
                     //   <= MUON_TRIG4_ENAB;
	             COMPATIBILITY_AMIGA_TRIG 
                       <= COMPATIBILITY_AMIGA_TRIG;
	             COMPATIBILITY_MOPS_TRIG_MIN0 
                       <= COMPATIBILITY_MOPS_TRIG_MIN0;
	             COMPATIBILITY_MOPS_TRIG_MIN1 
                       <= COMPATIBILITY_MOPS_TRIG_MIN1;
	             COMPATIBILITY_MOPS_TRIG_MIN2 
                       <= COMPATIBILITY_MOPS_TRIG_MIN2;
	             COMPATIBILITY_MOPS_TRIG_MAX0 
                       <= COMPATIBILITY_MOPS_TRIG_MAX0;
	             COMPATIBILITY_MOPS_TRIG_MAX1 
                       <= COMPATIBILITY_MOPS_TRIG_MAX1;
	             COMPATIBILITY_MOPS_TRIG_MAX2 
                       <= COMPATIBILITY_MOPS_TRIG_MAX2;
	             COMPATIBILITY_MOPS_TRIG_ENAB 
                       <= COMPATIBILITY_MOPS_TRIG_ENAB;
	             COMPATIBILITY_MOPS_TRIG_INT 
                       <= COMPATIBILITY_MOPS_TRIG_INT;
	             COMPATIBILITY_MOPS_TRIG_OCC 
                       <= COMPATIBILITY_MOPS_TRIG_OCC;
	             COMPATIBILITY_MOPS_TRIG_OFS 
                       <= COMPATIBILITY_MOPS_TRIG_OFS;
	             MUON_BUF_TRIG_MASK 
                       <= MUON_BUF_TRIG_MASK;
	             MUON_BUF_CONTROL 
                       <= MUON_BUF_CONTROL;
	             COMPATIBILITY_TRIG_RATES 
                       <= COMPATIBILITY_TRIG_RATES;
	             COMPATIBILITY_DELAYED_RATES 
                       <= COMPATIBILITY_DELAYED_RATES;
	             COMPATIBILITY_GLOBAL_CONTROL 
                       <= COMPATIBILITY_GLOBAL_CONTROL;
	             COMPATIBILITY_SB_TRIG_THR0 
                       <= COMPATIBILITY_SB_TRIG_THR0;
	             COMPATIBILITY_SB_TRIG_THR1 
                       <= COMPATIBILITY_SB_TRIG_THR1;
	             COMPATIBILITY_SB_TRIG_THR2 
                       <= COMPATIBILITY_SB_TRIG_THR2;
	             COMPATIBILITY_SB_TRIG_ENAB 
                       <= COMPATIBILITY_SB_TRIG_ENAB;
	             RANDOM_TRIG_MODE 
                       <= RANDOM_TRIG_MODE;
	             COMPATIBILITY_TOT_TRIG_THR0 
                       <= COMPATIBILITY_TOT_TRIG_THR0;
	             COMPATIBILITY_TOT_TRIG_THR1 
                       <= COMPATIBILITY_TOT_TRIG_THR1;
	             COMPATIBILITY_TOT_TRIG_THR2 
                       <= COMPATIBILITY_TOT_TRIG_THR2;
	             COMPATIBILITY_TOT_TRIG_ENAB 
                       <= COMPATIBILITY_TOT_TRIG_ENAB;
	             COMPATIBILITY_TOT_TRIG_OCC 
                       <= COMPATIBILITY_TOT_TRIG_OCC;
	             COMPATIBILITY_TOTD_TRIG_THR0 
                       <= COMPATIBILITY_TOTD_TRIG_THR0;
	             COMPATIBILITY_TOTD_TRIG_THR1 
                       <= COMPATIBILITY_TOTD_TRIG_THR1;
	             COMPATIBILITY_TOTD_TRIG_THR2 
                       <= COMPATIBILITY_TOTD_TRIG_THR2;
	             COMPATIBILITY_TOTD_TRIG_UP0 
                       <= COMPATIBILITY_TOTD_TRIG_UP0;
	             COMPATIBILITY_TOTD_TRIG_UP1 
                       <= COMPATIBILITY_TOTD_TRIG_UP1;
	             COMPATIBILITY_TOTD_TRIG_UP2 
                       <= COMPATIBILITY_TOTD_TRIG_UP2;
	             COMPATIBILITY_TOTD_TRIG_ENAB 
                       <= COMPATIBILITY_TOTD_TRIG_ENAB;
	             COMPATIBILITY_TOTD_TRIG_OCC 
                       <= COMPATIBILITY_TOTD_TRIG_OCC;
	             COMPATIBILITY_TOTD_TRIG_FD 
                       <= COMPATIBILITY_TOTD_TRIG_FD;
	             COMPATIBILITY_TOTD_TRIG_FN 
                       <= COMPATIBILITY_TOTD_TRIG_FN;
	             COMPATIBILITY_SCALER_A_THR0 
                       <= COMPATIBILITY_SCALER_A_THR0;
	             COMPATIBILITY_SCALER_A_THR1 
                       <= COMPATIBILITY_SCALER_A_THR1;
	             COMPATIBILITY_SCALER_A_THR2 
                       <= COMPATIBILITY_SCALER_A_THR2;
	             COMPATIBILITY_SCALER_A_ENAB 
                       <= COMPATIBILITY_SCALER_A_ENAB;
//	             COMPATIBILITY_SCALER_A_COUNT 
//                       <= COMPATIBILITY_SCALER_A_COUNT;
	             COMPATIBILITY_SCALER_B_THR0 
                       <= COMPATIBILITY_SCALER_B_THR0;
	             COMPATIBILITY_SCALER_B_THR1 
                       <= COMPATIBILITY_SCALER_B_THR1;
	             COMPATIBILITY_SCALER_B_THR2 
                       <= COMPATIBILITY_SCALER_B_THR2;
	             COMPATIBILITY_SCALER_B_ENAB 
                       <= COMPATIBILITY_SCALER_B_ENAB;
//	             COMPATIBILITY_SCALER_B_COUNT 
//                       <= COMPATIBILITY_SCALER_B_COUNT;
	             COMPATIBILITY_SCALER_C_THR0 
                       <= COMPATIBILITY_SCALER_C_THR0;
	             COMPATIBILITY_SCALER_C_THR1 
                       <= COMPATIBILITY_SCALER_C_THR1;
	             COMPATIBILITY_SCALER_C_THR2 
                       <= COMPATIBILITY_SCALER_C_THR2;
	             COMPATIBILITY_SCALER_C_ENAB 
                       <= COMPATIBILITY_SCALER_C_ENAB;
//	             COMPATIBILITY_SCALER_C_COUNT 
//                       <= COMPATIBILITY_SCALER_C_COUNT;
	             SHWR_BUF_TRIG_MASK 
                       <= SHWR_BUF_TRIG_MASK;
	             SHWR_BUF_CONTROL 
                       <= SHWR_BUF_CONTROL;
                     LED_CONTROL 
                       <= LED_CONTROL;
      	          end
	        endcase
	     end
	end
     end    

   // Implement write response logic generation
   // The write response and response valid signals are asserted by the slave 
   // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
   // This marks the acceptance of address and indicates the status of 
   // write transaction.

   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_bvalid  <= 0;
	     axi_bresp   <= 2'b0;
	  end 
	else
	  begin    
	     if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	       begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	       end                   // work error responses in future
	     else
	       begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	               axi_bvalid <= 1'b0; 
	            end  
	       end
	  end
     end   

   // Implement axi_arready generation
   // axi_arready is asserted for one S_AXI_ACLK clock cycle when
   // S_AXI_ARVALID is asserted. axi_awready is 
   // de-asserted when reset (active low) is asserted. 
   // The read address is also latched when S_AXI_ARVALID is 
   // asserted. axi_araddr is reset to zero on reset assertion.

   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_arready <= 1'b0;
	     axi_araddr  <= 32'b0;
	  end 
	else
	  begin    
	     if (~axi_arready && S_AXI_ARVALID)
	       begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	       end
	     else
	       begin
	          axi_arready <= 1'b0;
	       end
	  end 
     end       

   // Implement axi_arvalid generation
   // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
   // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
   // data are available on the axi_rdata bus at this instance. The 
   // assertion of axi_rvalid marks the validity of read data on the 
   // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
   // is deasserted on reset (active low). axi_rresp and axi_rdata are 
   // cleared to zero on reset (active low).  
   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_rvalid <= 0;
	     axi_rresp  <= 0;
	  end 
	else
	  begin    
	     if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	       begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	       end   
	     else if (axi_rvalid && S_AXI_RREADY)
	       begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	       end                
	  end
     end    

   // Implement memory mapped register select and read logic generation
   // Slave register read enable is asserted when valid address is available
   // and the slave is ready to accept the read address.
   assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
   always @(*)
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     reg_data_out <= 0;
	  end 
	else
	  begin    
	     // Address decoding for reading registers
	     case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	       `SB_TRIG_THR0_ADDR :
                 reg_data_out <= SB_TRIG_THR0;
	       `SB_TRIG_THR1_ADDR :
                 reg_data_out <= SB_TRIG_THR1;
	       `SB_TRIG_THR2_ADDR :
                 reg_data_out <= SB_TRIG_THR2;
	       `SB_TRIG_SSD_ADDR :
                 reg_data_out <= SB_TRIG_SSD;
	       `SB_TRIG_ENAB_ADDR :
                 reg_data_out <= SB_TRIG_ENAB;
	       `MUON_TRIG1_THR0_ADDR :
                 reg_data_out <= MUON_TRIG1_THR0;
	       `MUON_TRIG1_THR1_ADDR :
                 reg_data_out <= MUON_TRIG1_THR1;
	       `MUON_TRIG1_THR2_ADDR :
                 reg_data_out <= MUON_TRIG1_THR2;
	       `MUON_TRIG1_SSD_ADDR :
                 reg_data_out <= MUON_TRIG1_SSD;
	       `MUON_TRIG1_ENAB_ADDR :
                 reg_data_out <= MUON_TRIG1_ENAB;
	       `MUON_TRIG2_THR0_ADDR :
                 reg_data_out <= MUON_TRIG2_THR0;
	       `MUON_TRIG2_THR1_ADDR :
                 reg_data_out <= MUON_TRIG2_THR1;
	       `MUON_TRIG2_THR2_ADDR :
                 reg_data_out <= MUON_TRIG2_THR2;
	       `MUON_TRIG2_SSD_ADDR :
                 reg_data_out <= MUON_TRIG2_SSD;
	       `MUON_TRIG2_ENAB_ADDR :
                 reg_data_out <= MUON_TRIG2_ENAB;
	       // `MUON_TRIG3_THR0_ADDR :
               //   reg_data_out <= MUON_TRIG3_THR0;
	       // `MUON_TRIG3_THR1_ADDR :
               //   reg_data_out <= MUON_TRIG3_THR1;
	       // `MUON_TRIG3_THR2_ADDR :
               //   reg_data_out <= MUON_TRIG3_THR2;
	       // `MUON_TRIG3_SSD_ADDR :
               //   reg_data_out <= MUON_TRIG3_SSD;
	       // `MUON_TRIG3_ENAB_ADDR :
               //   reg_data_out <= MUON_TRIG3_ENAB;
	       // `MUON_TRIG4_THR0_ADDR :
               //   reg_data_out <= MUON_TRIG4_THR0;
	       // `MUON_TRIG4_THR1_ADDR :
               //   reg_data_out <= MUON_TRIG4_THR1;
	       // `MUON_TRIG4_THR2_ADDR :
               //   reg_data_out <= MUON_TRIG4_THR2;
	       // `MUON_TRIG4_SSD_ADDR :
               //   reg_data_out <= MUON_TRIG4_SSD;
	       // `MUON_TRIG4_ENAB_ADDR :
               //   reg_data_out <= MUON_TRIG4_ENAB;
	       `COMPATIBILITY_AMIGA_TRIG_ADDR :
                 reg_data_out <= COMPATIBILITY_AMIGA_TRIG;
	       `COMPATIBILITY_MOPS_TRIG_MIN0_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_MIN0;
	       `COMPATIBILITY_MOPS_TRIG_MIN1_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_MIN1;
	       `COMPATIBILITY_MOPS_TRIG_MIN2_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_MIN2;
	       `COMPATIBILITY_MOPS_TRIG_MAX0_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_MAX0;
	       `COMPATIBILITY_MOPS_TRIG_MAX1_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_MAX1;
	       `COMPATIBILITY_MOPS_TRIG_MAX2_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_MAX2;
	       `COMPATIBILITY_MOPS_TRIG_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_ENAB;
	       `COMPATIBILITY_MOPS_TRIG_INT_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_INT;
	       `COMPATIBILITY_MOPS_TRIG_OCC_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_OCC;
	       `COMPATIBILITY_MOPS_TRIG_OFS_ADDR :
                 reg_data_out <= COMPATIBILITY_MOPS_TRIG_OFS;
	       `MUON_BUF_TIME_TAG_A_ADDR :
                 reg_data_out <= MUON_BUF_TIME_TAG_A;
	       `MUON_BUF_TIME_TAG_B_ADDR :
                 reg_data_out <= MUON_BUF_TIME_TAG_B;
	       `MUON_BUF_TRIG_MASK_ADDR :
                 reg_data_out <= MUON_BUF_TRIG_MASK;
	       `MUON_BUF_CONTROL_ADDR :
                 reg_data_out <= MUON_BUF_CONTROL;
	       `MUON_BUF_STATUS_ADDR :
                 reg_data_out <= MUON_BUF_STATUS;
	       `MUON_BUF_WORD_COUNT_ADDR :
                 reg_data_out <= MUON_BUF_WORD_COUNT;
	       `COMPATIBILITY_TRIG_RATES_ADDR :
                 reg_data_out <= COMPATIBILITY_TRIG_RATES;
	       `COMPATIBILITY_DELAYED_RATES_ADDR :
                 reg_data_out <= COMPATIBILITY_DELAYED_RATES;
	       `COMPATIBILITY_GLOBAL_CONTROL_ADDR :
                 reg_data_out <= COMPATIBILITY_GLOBAL_CONTROL;
	       `ID_REG_ADDR :
                 reg_data_out <= ID_REG;
	       `COMPATIBILITY_SB_TRIG_THR0_ADDR :
                 reg_data_out <= COMPATIBILITY_SB_TRIG_THR0;
	       `COMPATIBILITY_SB_TRIG_THR1_ADDR :
                 reg_data_out <= COMPATIBILITY_SB_TRIG_THR1;
	       `COMPATIBILITY_SB_TRIG_THR2_ADDR :
                 reg_data_out <= COMPATIBILITY_SB_TRIG_THR2;
	       `COMPATIBILITY_SB_TRIG_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_SB_TRIG_ENAB;
	       `RANDOM_TRIG_MODE_ADDR :
                 reg_data_out <= RANDOM_TRIG_MODE;
	       `COMPATIBILITY_TOT_TRIG_THR0_ADDR :
                 reg_data_out <= COMPATIBILITY_TOT_TRIG_THR0;
	       `COMPATIBILITY_TOT_TRIG_THR1_ADDR :
                 reg_data_out <= COMPATIBILITY_TOT_TRIG_THR1;
	       `COMPATIBILITY_TOT_TRIG_THR2_ADDR :
                 reg_data_out <= COMPATIBILITY_TOT_TRIG_THR2;
	       `COMPATIBILITY_TOT_TRIG_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_TOT_TRIG_ENAB;
	       `COMPATIBILITY_TOT_TRIG_OCC_ADDR :
                 reg_data_out <= COMPATIBILITY_TOT_TRIG_OCC;
	       `COMPATIBILITY_TOTD_TRIG_THR0_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_THR0;
	       `COMPATIBILITY_TOTD_TRIG_THR1_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_THR1;
	       `COMPATIBILITY_TOTD_TRIG_THR2_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_THR2;
	       `COMPATIBILITY_TOTD_TRIG_UP0_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_UP0;
	       `COMPATIBILITY_TOTD_TRIG_UP1_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_UP1;
	       `COMPATIBILITY_TOTD_TRIG_UP2_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_UP2;
	       `COMPATIBILITY_TOTD_TRIG_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_ENAB;
	       `COMPATIBILITY_TOTD_TRIG_OCC_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_OCC;
	       `COMPATIBILITY_TOTD_TRIG_FD_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_FD;
	       `COMPATIBILITY_TOTD_TRIG_FN_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_FN;
	       `COMPATIBILITY_TOTD_TRIG_INT_ADDR :
                 reg_data_out <= COMPATIBILITY_TOTD_TRIG_INT;
	       `COMPATIBILITY_SCALER_A_THR0_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_A_THR0;
	       `COMPATIBILITY_SCALER_A_THR1_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_A_THR1;
	       `COMPATIBILITY_SCALER_A_THR2_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_A_THR2;
	       `COMPATIBILITY_SCALER_A_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_A_ENAB;
	       `COMPATIBILITY_SCALER_A_COUNT_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_A_COUNT;
	       `COMPATIBILITY_SCALER_B_THR0_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_B_THR0;
	       `COMPATIBILITY_SCALER_B_THR1_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_B_THR1;
	       `COMPATIBILITY_SCALER_B_THR2_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_B_THR2;
	       `COMPATIBILITY_SCALER_B_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_B_ENAB;
	       `COMPATIBILITY_SCALER_B_COUNT_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_B_COUNT;
	       `COMPATIBILITY_SCALER_C_THR0_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_C_THR0;
	       `COMPATIBILITY_SCALER_C_THR1_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_C_THR1;
	       `COMPATIBILITY_SCALER_C_THR2_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_C_THR2;
	       `COMPATIBILITY_SCALER_C_ENAB_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_C_ENAB;
	       `COMPATIBILITY_SCALER_C_COUNT_ADDR :
                 reg_data_out <= COMPATIBILITY_SCALER_C_COUNT;
	       `SHWR_BUF_TRIG_MASK_ADDR :
                 reg_data_out <= SHWR_BUF_TRIG_MASK;
	       `SHWR_BUF_TRIG_ID_ADDR :
                 reg_data_out <= SHWR_BUF_TRIG_ID;
	       `SHWR_BUF_CONTROL_ADDR :
                 reg_data_out <= SHWR_BUF_CONTROL;
	       `SHWR_BUF_STATUS_ADDR :
                 reg_data_out <= SHWR_BUF_STATUS;
	       `SHWR_BUF_START_ADDR :
                 reg_data_out <= SHWR_BUF_START;
	       `SHWR_BUF_LATENCY_ADDR :
                 reg_data_out <= SHWR_BUF_LATENCY;
	       `SHWR_BUF_LATENCY0_ADDR :
                 reg_data_out <= SHWR_BUF_LATENCY0;
	       `SHWR_BUF_LATENCY1_ADDR :
                 reg_data_out <= SHWR_BUF_LATENCY1;
	       `SHWR_PEAK_AREA0_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA0;
	       `SHWR_PEAK_AREA1_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA1;
	       `SHWR_PEAK_AREA2_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA2;
	       `SHWR_PEAK_AREA3_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA3;
	       `SHWR_PEAK_AREA4_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA4;
	       `SHWR_PEAK_AREA5_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA5;
	       `SHWR_PEAK_AREA6_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA6;
	       `SHWR_PEAK_AREA7_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA7;
	       `SHWR_PEAK_AREA8_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA8;
	       `SHWR_PEAK_AREA9_ADDR :
                 reg_data_out <= SHWR_PEAK_AREA9;
	       `SHWR_BASELINE0_ADDR :
                 reg_data_out <= SHWR_BASELINE0;
	       `SHWR_BASELINE1_ADDR :
                 reg_data_out <= SHWR_BASELINE1;
	       `SHWR_BASELINE2_ADDR :
                 reg_data_out <= SHWR_BASELINE2;
	       `SHWR_BASELINE3_ADDR :
                 reg_data_out <= SHWR_BASELINE3;
	       `SHWR_BASELINE4_ADDR :
                 reg_data_out <= SHWR_BASELINE4;
	       `TEST0_ADDR :
		 reg_data_out <= TEST0;
	       `TEST1_ADDR :
		 reg_data_out <= TEST1;
	       `TEST2_ADDR :
		 reg_data_out <= TEST2;
	       `TEST3_ADDR :
		 reg_data_out <= TEST3;
	       `TEST4_ADDR :
		 reg_data_out <= TEST4;
	       `TEST5_ADDR :
		 reg_data_out <= TEST5;
	       `TEST6_ADDR :
		 reg_data_out <= TEST6;
	       `TEST7_ADDR :
		 reg_data_out <= TEST7;
	       `TEST8_ADDR :
		 reg_data_out <= TEST8;
	       `TEST9_ADDR :
		 reg_data_out <= TEST9;
	       `TEST10_ADDR :
		 reg_data_out <= TEST10;
	       `TEST11_ADDR :
		 reg_data_out <= TEST11;
	       `TEST12_ADDR :
		 reg_data_out <= TEST12;
	       `TEST13_ADDR :
		 reg_data_out <= TEST13;
	       `TEST14_ADDR :
		 reg_data_out <= TEST14;
	       `TEST15_ADDR :
		 reg_data_out <= TEST15;
               `FILT_PMT0_TEST_ADDR :
                 reg_data_out <= FILT_PMT0_TEST;
               `FILT_PMT1_TEST_ADDR :
                 reg_data_out <= FILT_PMT1_TEST;
               `FILT_PMT2_TEST_ADDR :
                 reg_data_out <= FILT_PMT2_TEST;
               `ADC0_TEST_ADDR :
                 reg_data_out <= ADC0_TEST;
               `ADC1_TEST_ADDR :
                 reg_data_out <= ADC1_TEST;
               `ADC2_TEST_ADDR :
                 reg_data_out <= ADC2_TEST;
               `ADC3_TEST_ADDR :
                 reg_data_out <= ADC3_TEST;
               `ADC4_TEST_ADDR :
                 reg_data_out <= ADC4_TEST;
               `LED_CONTROL_ADDR :
                 reg_data_out <= LED_CONTROL;
	       default :
                 reg_data_out <= 0;
	     endcase
	  end   
     end

   // Output register or memory read data
   always @( posedge S_AXI_ACLK )
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     axi_rdata  <= 0;
	  end 
	else
	  begin    
	     // When there is a valid read address (S_AXI_ARVALID) with 
	     // acceptance of read address by the slave (axi_arready), 
	     // output the read dada 
	     if (slv_reg_rden)
	       begin
	          axi_rdata <= reg_data_out;     // register read data
	       end   
	  end
     end    

   // Add user logic here

`include "sde_trigger_code.vh"

   // User logic ends

endmodule
