// Module to stretch logic high signal
//
// 26-May-2015 DFN Initial version
// 18-Sep-2018 DFN Change parameter name to SLEN
// 18-Sep-2018 DFN Alternate version of "stretch" since Vivado won't
//                 let me pass modified parameter value during instantation.

module stretch2
   (
    input CLK,
    input IN,
    output reg OUT                          
    );

   reg PREV_IN;

   always @(posedge CLK)
     begin
        PREV_IN <= IN;
        OUT <= IN | PREV_IN;
     end
endmodule

