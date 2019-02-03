
`timescale 1 ns / 1 ps

module rd_interface_tb();
   

    reg SERIAL_DATA0_IN;
    reg SERIAL_DATA1_IN;
    reg SERIAL_CLK_IN;
    reg ENABLE_XFR_IN;
    reg[1:0] BUF_NUM;  // Buffer # to use (assume same as writing)
    reg TRIG_IN;
   reg AXI_CONTROL_WRITTEN;
   reg [31:0] AXI_CONTROL;
   
    
    wire[31:0] DATA_ADDR; // Address
    wire[31:0] DATA_TO_MEM;
    wire ENABLE_MEM_WRT;    
    wire DEBUG1;
    wire DEBUG2;
   wire [31:0] STATUS;
   

// Generate clock

    rd_interface rd_interface_inst
     (
      .SERIAL_DATA0_IN(SERIAL_DATA0_IN),
      .SERIAL_DATA1_IN(SERIAL_DATA1_IN),
      .SERIAL_CLK_IN(SERIAL_CLK_IN),
      .ENABLE_XFR_IN(ENABLE_XFR_IN),
      .BUF_NUM(BUF_NUM),
      .TRIG_IN(TRIG_IN),
      .AXI_CONTROL(AXI_CONTROL),
      .AXI_CONTROL_WRITTEN(AXI_CONTROL_WRITTEN),
      .STATUS(STATUS),
      .DATA_ADDR(DATA_ADDR),
      .DATA_TO_MEM(DATA_TO_MEM),
      .ENABLE_MEM_WRT(ENABLE_MEM_WRT),
      .DEBUG1(DEBUG1),
      .DEBUG2(DEBUG2)
      );

    // Generate clock
    always
    #5 SERIAL_CLK_IN <= ~SERIAL_CLK_IN;

   always
     begin
        #10 SERIAL_DATA0_IN <= ~SERIAL_DATA0_IN;
         SERIAL_DATA1_IN <= ~SERIAL_DATA1_IN;
     end

    initial
    begin
    BUF_NUM <= 0;
       SERIAL_CLK_IN <= 0;
       ENABLE_XFR_IN <= 0;
       SERIAL_DATA0_IN <= 0;
       SERIAL_DATA1_IN <= 1;
       TRIG_IN <= 0;
       
       #10 TRIG_IN<=1;
       
       #20 ENABLE_XFR_IN<=1;
       TRIG_IN<=0;
       
    
//       $finish;
       
    end

endmodule


