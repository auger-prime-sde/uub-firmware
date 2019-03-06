
`timescale 1 ns / 1 ps

module combined_rd_interface_tb();

   reg TRIGGER;
   reg ENABLE;
   reg CLK;
   reg RST;
   reg [1:0] RD_BUF_NUM;
   reg [1:0] WRT_BUF_NUM;

   wire SERIAL_OUT0;
   wire SERIAL_OUT1;
   wire ENABLE_XFR;
   wire [31:0] DATA_TO_MEM;
   wire [31:0] DATA_ADDR;
   wire [31:0] STATUS;
   wire        TRIG_OUT;
   
   
   fake_rd_interface fake_rd_inst(
                                  .ENABLE(ENABLE),
                                  .ENABLE_XFR(ENABLE_XFR),
                                  .LOCAL_CLK(CLK),
                                  .TRIGGER(TRIGGER),
                                  .SERIAL_OUT0(SERIAL_OUT0),
                                  .SERIAL_OUT1(SERIAL_OUT1)
                                  );

   rd_interface rd_interface_inst
     (
      .SERIAL_DATA0_IN(SERIAL_OUT0),
      .SERIAL_DATA1_IN(SERIAL_OUT1),
      .SERIAL_CLK_IN(CLK),
      .ENABLE_XFR_IN(ENABLE_XFR),
      .WRT_BUF_NUM(WRT_BUF_NUM),
      .RD_BUF_NUM(RD_BUF_NUM),
      .TRIG_IN(TRIGGER),
      .AXI_CONTROL(AXI_CONTROL),
      .AXI_CONTROL_WRITTEN(AXI_CONTROL_WRITTEN),
      .STATUS(STATUS),
      .DATA_ADDR(DATA_ADDR),
      .DATA_TO_MEM(DATA_TO_MEM),
      .ENABLE_MEM_WRT(ENABLE_MEM_WRT),
      .TRIG_OUT(TRIG_OUT),
      .RST(RST)
      );



   // Generate clock
   always
     #5 CLK <= ~CLK;

   initial
     begin
        CLK <= 0;
        TRIGGER <= 0;
        ENABLE <= 0;
        WRT_BUF_NUM <= 0;
        RD_BUF_NUM <= 0;
        RST <= 1;
        
        #10 RST <= 0;
        #20 ENABLE <= 1;
        #50 TRIGGER <= 1;
        #60 TRIGGER <= 0;

        #100 TRIGGER <= 1;
        WRT_BUF_NUM <= WRT_BUF_NUM+1;
        #25 TRIGGER <= 0;

        #5000 TRIGGER<=1;
        WRT_BUF_NUM <= WRT_BUF_NUM+1;
        #30 TRIGGER<=0;
     end

endmodule


