
`timescale 1 ns / 1 ps

module rd_interface_tb();
   

    reg SERIAL_DATA0_IN;
    reg SERIAL_DATA1_IN;
    reg SERIAL_CLK_IN;
    reg ENABLE_XFR_IN;
    reg[1:0] WRT_BUF_NUM;
    reg[1:0] RD_BUF_NUM;
    reg TRIG_IN;
   reg AXI_CONTROL_WRITTEN;
   reg [31:0] AXI_CONTROL;
   reg        RST;
   reg [3:0]  BIT_COUNT;
   
   
   
    
    wire[31:0] DATA_ADDR; // Address
    wire[31:0] DATA_TO_MEM;
    wire ENABLE_MEM_WRT;    
    wire TRIG_OUT;
   wire [31:0] STATUS;
   

// Generate clock

    rd_interface rd_interface_inst
     (
      .SERIAL_DATA0_IN(SERIAL_DATA0_IN),
      .SERIAL_DATA1_IN(SERIAL_DATA1_IN),
      .SERIAL_CLK_IN(SERIAL_CLK_IN),
      .ENABLE_XFR_IN(ENABLE_XFR_IN),
      .WRT_BUF_NUM(WRT_BUF_NUM),
      .RD_BUF_NUM(RD_BUF_NUM),
      .TRIG_IN(TRIG_IN),
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
    #5 SERIAL_CLK_IN <= ~SERIAL_CLK_IN;

   always @(posedge SERIAL_CLK_IN)
     begin
        if (ENABLE_XFR_IN)
          begin
             #5 if (BIT_COUNT < 11)
               begin
                  SERIAL_DATA0_IN <= ~SERIAL_DATA0_IN;
                  SERIAL_DATA1_IN <= ~SERIAL_DATA1_IN;
                  BIT_COUNT <= BIT_COUNT+1;
               end
             else if (BIT_COUNT == 11)
               begin
                  SERIAL_DATA0_IN <= 1;
                  SERIAL_DATA1_IN <= 1;
                  BIT_COUNT <= BIT_COUNT+1;
               end
             else
               begin
                  SERIAL_DATA0_IN <= 1;
                  SERIAL_DATA1_IN <= 1;
                  BIT_COUNT <= 0;
               end // else: !if(BIT_COUNT < 12)
          end // if (ENABLE_XFR_IN)
        else
          BIT_COUNT <= 0;
     end

    initial
    begin
       WRT_BUF_NUM <= 0;
       RD_BUF_NUM <= 0;
       SERIAL_CLK_IN <= 0;
       ENABLE_XFR_IN <= 0;
       SERIAL_DATA0_IN <= 0;
       SERIAL_DATA1_IN <= 1;
       TRIG_IN <= 0;
       RST <= 1;
       BIT_COUNT <= 0;
       
       #10 RST <= 0;
       #100 TRIG_IN<=1;
       #30 TRIG_IN<=0;
           
       #200 ENABLE_XFR_IN <= 1;

       #100 TRIG_IN <= 1;
       WRT_BUF_NUM <= WRT_BUF_NUM+1;
       
       #25 TRIG_IN <= 0;
       #665 ENABLE_XFR_IN <= 0;

       #100 TRIG_IN<=1;
       WRT_BUF_NUM <= WRT_BUF_NUM+1;
       #30 TRIG_IN<=0;
           
       #200 ENABLE_XFR_IN <= 1;

       #100 TRIG_IN <= 1;
       WRT_BUF_NUM <= WRT_BUF_NUM+1;
       
       #25 TRIG_IN <= 0;
       #665 ENABLE_XFR_IN <= 0;
       
    
//       $finish;
       
    end

endmodule


