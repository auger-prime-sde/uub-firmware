
`timescale 1 ns / 1 ps

module fake_rd_interface_tb();
   

    reg TRIGGER;
   reg  ENABLE;
   reg  CLK;
   wire SERIAL_OUT0;
   wire SERIAL_OUT1;
   wire ENABLE_XFR;
   
    fake_rd_interface rd_ifc(
                            .ENABLE(ENABLE),
                            .ENABLE_XFR(ENABLE_XFR),
                            .LOCAL_CLK(CLK),
                            .TRIGGER(TRIGGER),
                            .SERIAL_OUT0(SERIAL_OUT0),
                            .SERIAL_OUT1(SERIAL_OUT1)
                            );

    // Generate clock
    always
    #5 CLK <= ~CLK;

    initial
      begin
         CLK <= 0;
         TRIGGER <= 0;
         ENABLE <= 0;
          
         #20 ENABLE <= 1;
         #50 TRIGGER <= 1;
         #60 TRIGGER <= 0;
    end

endmodule


