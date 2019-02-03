// Module to synchronize 1 bit between 2 clock domains using the ASYNC_REG
// attribute. Copied from Xilinx Ultrafast Methodolgy Guide, UG949
//
// 25-Sep-2014 DFN Initial version
// 07-Oct-2014 DFN Add SREG_EXTRACT="NO" option.
// 11-Nov-2014 DFN Change SYNC_STAGES from 4 to 2.
// 24-Mar-2015 DFN Change SYNC_STAGES from 2 to 3.  Code does not work for
//                 SYNC_STAGES = 2.
//

module rd_sync_1bit #( parameter SYNC_STAGES = 3 )
   (
    input ASYNC_IN,
    input CLK,
    output SYNC_OUT                          
    );

   (* ASYNC_REG = "TRUE", SHREG_EXTRACT="NO" *) 
    reg [SYNC_STAGES-1:0] sync_regs = {SYNC_STAGES{1'b0}};

    always @(posedge CLK)
    sync_regs <= {sync_regs[SYNC_STAGES-2:0], ASYNC_IN};

    assign SYNC_OUT = sync_regs[SYNC_STAGES-1];

    endmodule

