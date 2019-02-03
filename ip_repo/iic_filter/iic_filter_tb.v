
`timescale 1 ns / 1 ps

module iic_filter_tb();
   
   reg Sysclk;
   reg Rst;
   reg Scl_noisy;
   wire Scl_clean;
   reg  Sda_noisy;
   wire Sda_clean;
   wire Scl_noisy_out;
   wire Scl_noisy_t;
   reg  Scl_clean_in;
   reg  Scl_clean_t;
   wire Sda_noisy_out;
   wire Sda_noisy_t;
   reg  Sda_clean_in;
   reg  Sda_clean_t;
   wire DBG1;
   wire DBG2;
   wire DBG3;
   


iic_filter iic_filter_inst
 (
.Sysclk(Sysclk),
.Rst(Rst),
.Scl_noisy(Scl_noisy),
.Scl_clean(Scl_clean),
.Sda_noisy(Sda_noisy),
.Sda_clean(Sda_clean),
.Scl_noisy_out(Scl_noisy_out),
.Scl_noisy_t(Scl_noisy_t),
.Scl_clean_in(Scl_clean_in),
.Scl_clean_t(Scl_clean_t),
.Sda_noisy_out(Sda_noisy_out),
.Sda_noisy_t(Sda_noisy_t),
.Sda_clean_in(Sda_clean_in),
.Sda_clean_t(Sda_clean_t),
.DBG1(DBG1),
.DBG2(DBG2),
.DBG3(DBG3)
  );

   
    // Generate clock
    always
    #4 Sysclk <= ~Sysclk;

   always
     begin
        #28 Scl_noisy <= ~Scl_noisy;
        Scl_clean_in <= ~Scl_clean_in;
        #28 Sda_noisy <= ~Sda_noisy;
        Sda_clean_in <= ~Sda_clean_in;
     end

    initial
    begin
       Sysclk <= 0;
       Rst <= 0;
       Scl_noisy <= 1;
       Sda_noisy <= 1;
       Scl_clean_in <= 0;
       Sda_clean_in <= 0;
       Scl_clean_t <= 0;
       Sda_clean_t <= 0;
       
       #10 Rst<=1;
       #30 Rst<=0;

       // Start with transmit from clean to noisy side
 #100  Scl_clean_t <= ~Scl_clean_t;
        Sda_clean_t <= ~Sda_clean_t;

       // Then to transmit from noisy to clean side
       #500 Sda_clean_t <= 0;
       Scl_clean_t <=0;
       
//       $finish;
       
    end

endmodule


