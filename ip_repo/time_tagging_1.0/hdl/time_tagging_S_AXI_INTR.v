// 20-Feb-2019 DFN Initial version derived from sde_triger_S_AXI_INTR

`timescale 1 ns / 1 ps

module time_tagging_S_AXI_INTR #
  (
   // Users to add parameters here

   // User parameters ends
   // Do not modify the parameters beyond this line

   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH	= 32,
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH	= 5,
   // Each bit corresponds to Sensitivity of interrupt :  0 - EDGE, 1 - LEVEL
   parameter  C_INTR_SENSITIVITY	= 32'hFFFFFFFF,
   // Each bit corresponds to Sub-type of INTR: [0 - FALLING_EDGE, 1 - RISING_EDGE : if C_INTR_SENSITIVITY is EDGE(0)] and [ 0 - LEVEL_LOW, 1 - LEVEL_LOW : if C_INTR_SENSITIVITY is LEVEL(1) ]
   parameter  C_INTR_ACTIVE_STATE	= 32'hFFFFFFFF,
   // Sensitivity of IRQ: 0 - EDGE, 1 - LEVEL
   parameter integer C_IRQ_SENSITIVITY	= 1,
   // Sub-type of IRQ: [0 - FALLING_EDGE, 1 - RISING_EDGE : if C_IRQ_SENSITIVITY is EDGE(0)] and [ 0 - LEVEL_LOW, 1 - LEVEL_LOW : if C_IRQ_SENSITIVITY is LEVEL(1) ]
   parameter integer C_IRQ_ACTIVE_STATE	= 1
   )
   (
    // Users to add ports here

    input wire INTR,

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
    input wire  S_AXI_RREADY,
    // interrupt out port
    output wire  irq
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
   //------------------------------------------------
   //-- Signals for Interrupt register space
   //------------------------------------------------
   //-- Number of Slave Registers 5
   reg [0 : 0] reg_global_intr_en;
   reg [0 :0] reg_intr_en;
   reg [0 :0] reg_intr_sts;
   reg [0 :0] reg_intr_ack;
   reg [0 :0] reg_intr_pending;
   reg [0 :0] intr;
   reg [0 :0] det_intr;
   wire                           intr_reg_rden;
   wire                           intr_reg_wren;
   reg [C_S_AXI_DATA_WIDTH-1:0]   reg_data_out;
   genvar                         i;
   integer                        j;
   reg intr_all;
   reg intr_ack_all;
   reg s_irq;

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
   // Slave register write enable is asserted when valid address and data are available
   // and the slave is ready to accept the write address and write data.
   assign intr_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
   
	   
	   // Global interrupt enable register
	   always @( posedge S_AXI_ACLK )
	     begin
	        if ( S_AXI_ARESETN == 1'b0)
	          begin
	             reg_global_intr_en[0] <= 1'b0;
	          end
	        else if (intr_reg_wren && axi_awaddr[4:2] == 3'h0)
	          begin
	             reg_global_intr_en[0] <= S_AXI_WDATA[0];
	          end
	     end
	   
	   // Interrupt enable register
	   always @( posedge S_AXI_ACLK )
	     begin
	        if ( S_AXI_ARESETN == 1'b0)
	          begin
	             reg_intr_en[0] <= 1'b0;
	          end
	        else if (intr_reg_wren && axi_awaddr[4:2] == 3'h1)
	          begin
	             reg_intr_en[0] <= S_AXI_WDATA[0];
	          end
	     end
	   
	   // Interrupt status register
	   always @( posedge S_AXI_ACLK )
	     begin
	        if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[0] == 1'b1)
	          begin
	             reg_intr_sts[0] <= 1'b0;
	          end
	        else
	          begin
	             reg_intr_sts[0] <= det_intr[0];
	          end
	     end
	   
	   // Interrupt acknowledgement register
	   always @( posedge S_AXI_ACLK )
	     begin
	        if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[0] == 1'b1)
	          begin
	             reg_intr_ack[0] <= 1'b0;
	          end
	        else if (intr_reg_wren && axi_awaddr[4:2] == 3'h3)
	          begin
	             reg_intr_ack[0] <= S_AXI_WDATA[0];
	          end
	     end
	   
	   // Interrupt pending register
	   always @( posedge S_AXI_ACLK )
	     begin
	        if ( S_AXI_ARESETN == 1'b0 || reg_intr_ack[0] == 1'b1)
	          begin
	             reg_intr_pending[0] <= 1'b0;
	          end
	        else
	          begin
	             reg_intr_pending[0] <= reg_intr_sts[0] & reg_intr_en[0];
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
   assign intr_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
   always @(*)
     begin
	if ( S_AXI_ARESETN == 1'b0 )
	  begin
	     reg_data_out <= 0;
	  end
	else
	  begin
	     // Address decoding for reading registers
	     case ( axi_araddr[4:2] )
	       3'h0   : reg_data_out <= reg_global_intr_en;
	       3'h1   : reg_data_out <= reg_intr_en;
	       3'h2   : reg_data_out <= reg_intr_sts;
	       3'h3   : reg_data_out <= reg_intr_ack; // Not useful to read
	       3'h4   : reg_data_out <= reg_intr_pending;
	       default : reg_data_out <= 0;
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
	     if (intr_reg_rden)
	       begin
	          axi_rdata <= reg_data_out;     // register read data
	       end
	  end
     end

`include "time_tagging_intr.vh"

endmodule
