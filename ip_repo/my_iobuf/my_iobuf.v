module my_iobuf (
                 input        io_out,
                 input        io_tri,
                 output  wire io_in,
                 inout  wire  io_pad);
   
   bufif1 u0(io_pad, io_out, io_tri);
   buf u1(io_in,io_pad);

endmodule