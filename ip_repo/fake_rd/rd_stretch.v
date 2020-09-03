// Module to stretch logic high signal
//
// 26-May-2015 DFN Initial version
// 18-Sep-2018 DFN Change parameter name to SLEN
// 19-Sep-2018 DFN Remove ASYNC_REG, SHREG_EXTRACT, and initialization of
//                 stretch_regs because they are not needed; register output

module rd_stretch #( parameter SLEN = 5 )
   (
    input IN,
    input CLK,
    output reg OUT                          
    );

   reg [SLEN-1:0] stretch_regs;

   always @(posedge CLK)
     begin
        stretch_regs <= {stretch_regs[SLEN-2:0], IN};
        OUT <= | stretch_regs;     
     end
endmodule

