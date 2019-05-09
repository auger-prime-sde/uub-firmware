// 29-Apr-2019 DFN Change RD interface pinouts; Fix direction on AMIGA interface
// 09-May-2019 DFN Restore original RD interface pin assignments for current
//                 RD tests; swap ext0 and 1 so RD is nearest FPGA on V2/3 bd.
//                 This make RD farthest from FPGA on V1 bd

`timescale 1 ns / 1 ps
`include "digital_interface_defs.vh"
`include "digital_interface_options.vh"

	module digital_interface_v1_0_S00_AXI # (
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here

         input wire [7:0] DATA0_I,
         input wire [7:0] DATA1_I,
         output wire [7:0] DATA0_O,
         output wire [7:0] DATA1_O,
         output wire [7:0] DATA0_T,
         output wire [7:0] DATA1_T,
         output wire[7:0] CTL0,
         output wire[7:0] CTL1,

         input wire AMIGA_LTS_OUT,
         input wire AMIGA_CLOCK_OUT,
         input wire AMIGA_TX,
         output wire AMIGA_RX,
         
         input wire RD_TRIG,
         input wire RD_MISO,
         input wire RD_SCK,
         output wire RD_DATA_VALID,
         output wire RD_XFR_CLK,
         output wire RD_SER_DATA0,
         output wire RD_SER_DATA1,
         output wire RD_MOSI,

        output reg DBG1,
        output reg DBG2,
        output reg DBG3,
         // output wire DBG1,
         // output wire DBG2,
         // output wire DBG3,
         
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
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	DIG_IFC_CONTROL;
	reg [C_S_AXI_DATA_WIDTH-1:0]	DIG_IFC_OUT;
	wire [C_S_AXI_DATA_WIDTH-1:0]	DIG_IFC_IN;
	reg [C_S_AXI_DATA_WIDTH-1:0]	DIG_IFC_ID;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

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
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      DIG_IFC_CONTROL <= 0;
	      DIG_IFC_OUT <= 0;
	      // DIG_IFC_IN <= 0;
	      DIG_IFC_ID <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0:
	            DIG_IFC_CONTROL <= S_AXI_WDATA;
	          2'h2:
	            DIG_IFC_OUT <= S_AXI_WDATA;
//	          2'h1:
//	            DIG_IFC_IN <= S_AXI_WDATA;
//	          2'h3:
//	            DIG_IFC_ID <= S_AXI_WDATA;
	          default : begin
	                      DIG_IFC_CONTROL <= DIG_IFC_CONTROL;
	                      DIG_IFC_OUT <= DIG_IFC_OUT;
	                      // DIG_IFC_IN <= DIG_IFC_IN;
	                      // DIG_IFC_ID <= DIG_IFC_ID;
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
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= DIG_IFC_CONTROL;
	        2'h1   : reg_data_out <= DIG_IFC_IN;
	        2'h2   : reg_data_out <= DIG_IFC_OUT;
	        2'h3   : reg_data_out <= `DIG_IFC_COMPILE_DATE;
	        default : reg_data_out <= 0;
	      endcase
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

// Here we try to assign port direction based upon routing flag


   assign DATA1_T[0] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[0] :
                       0 ; // This is AMIGA_LTS_OUT, an output
   assign DATA1_T[1] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[1] :
                       0 ; // This is AMIGA_CLK_OUT, an output
   assign DATA1_T[2] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[2] :
                       1 ; // This is AMIGA_RX, an input
   assign DATA1_T[3] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[3] :
                       0 ; // This is AMIGA_TX, an output
   assign DATA1_T[4] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[4] :
                       0 ; // Not used, default 0
   assign DATA1_T[5] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[5] :
                       0 ; // Not used, default 0
   assign DATA1_T[6] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[6] :
                       0 ; // Not used, default 0
   assign DATA1_T[7] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[7] :
                       0 ; // Not used, default 0
    
   assign DATA0_T[0] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[8] :
                       1 ; //This is RD_SER_DATA1, an input
   assign DATA0_T[1] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[9] :
                       1 ; // This is RD_SER_DATA0, an input
   assign DATA0_T[2] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[10] :
                       1 ; // This is RD_XFR_CLK an input
   assign DATA0_T[3] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[11] :
                       0 ; // This is RD_TRIG, an output
   assign DATA0_T[4] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[12] :
                       1 ; // This is RD_DATA_VALID, an input
   assign DATA0_T[5] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[13] :
                       0 ; // This is RD_SCK, an output
   assign DATA0_T[6] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[14] :
                       1 ; // This is RD_MISO, an input
   assign DATA0_T[7] = (DIG_IFC_CONTROL[16] == 1) ? ~DIG_IFC_CONTROL[15] :
                       0 ; // This is RD_MOSI, an output
   assign CTL0[7:0] =  ~DATA0_T[7:0];
   assign CTL1[7:0] =  ~DATA1_T[7:0];

   // Here we try to assign outputs based upon routing flag
   
   assign DATA1_O[0] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[0] :
                       AMIGA_LTS_OUT; // This is AMIGA_LTS_OUT, pass to output
   assign DATA1_O[1] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[1] :
                       AMIGA_CLOCK_OUT; // Pass to output
   assign DATA1_O[2] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[2] :
                       0 ; // This is AMIGA_RX, an input
   assign DATA1_O[3] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[3] :
                       AMIGA_TX ; // Pass to output
   assign DATA1_O[4] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[4] :
                       0 ; // Not used
   assign DATA1_O[5] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[5] :
                       0 ; // Not used
   assign DATA1_O[6] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[6] :
                       0 ; // Not used
   assign DATA1_O[7] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[7] :
                       0 ; // Not used
    
   assign DATA0_O[0] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[8] :
                       0 ; // This is RD_SER_DATA1
   assign DATA0_O[1] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[9] :
                       0 ; // This is RD_SER_DATA0
   assign DATA0_O[2] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[10] :
                       0 ; // This is RD_XFR_CLK
   assign DATA0_O[3] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[11] :
                       RD_TRIG ; // This is RD_TRIG
   assign DATA0_O[4] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[12] :
                       0 ; // RD_DATA_VALID
   assign DATA0_O[5] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[13] :
                       RD_SCK ; // This is RD_SCK
   assign DATA0_O[6] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[14] :
                       0 ; // This is RD_MISO
   assign DATA0_O[7] = (DIG_IFC_CONTROL[16] == 1) ? DIG_IFC_OUT[5] :
                       RD_MOSI ; // This is RD_MOSI

  // Assign inputs when in factory test mode

   assign DIG_IFC_IN[0] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[0] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[1] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[1] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[2] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[2] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[3] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[3] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[4] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[4] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[5] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[5] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[6] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[6] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[7] = (DIG_IFC_CONTROL[16] == 1) ? DATA1_I[7] :
                       0 ; // 0 if not in factory test mode

   assign DIG_IFC_IN[8] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[0] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[9] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[1] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[10] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[2] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[11] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[3] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[12] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[4] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[13] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[5] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[14] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[6] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[15] = (DIG_IFC_CONTROL[16] == 1) ? DATA0_I[7] :
                       0 ; // 0 if not in factory test mode
   assign DIG_IFC_IN[31:16] = 0;

   // Assign inputs when not in factory test mode

   assign AMIGA_RX = (DIG_IFC_CONTROL[16] == 0) ? DATA1_I[2] : 0;

   assign RD_DATA_VALID = (DIG_IFC_CONTROL[16] == 0) ? DATA0_I[4] : 0;
   assign RD_XFR_CLK = (DIG_IFC_CONTROL[16] == 0) ? DATA0_I[2] : 0;
   assign RD_SER_DATA0 = (DIG_IFC_CONTROL[16] == 0) ? DATA0_I[1] : 0;
   assign RD_SER_DATA1 = (DIG_IFC_CONTROL[16] == 0) ? DATA0_I[0] : 0;
   assign RD_MISO = (DIG_IFC_CONTROL[16] == 0) ? DATA0_I[6] : 0;
   
// Some debug outputs -- Does this assign actually work?

   // assign DBG1 = DATA2_O[1];  // AMIGA CLK out
   // assign DBG2 = DATA0_O[7];  // RD trig out
   // assign DBG3 = DATA0_O[0];  // RD SCK out
 
    always @( posedge S_AXI_ACLK )
      begin
         DBG1 <= RD_TRIG;  // Trigger
         DBG2 <= AMIGA_CLOCK_OUT;  // RD trig out
         DBG3 <= RD_SCK;
       end // always @ ( posedge S_AXI_ACLK )

   
   // User logic ends

endmodule
