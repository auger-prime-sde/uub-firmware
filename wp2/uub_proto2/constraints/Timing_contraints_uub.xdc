
# Timing File contraints
# Version for use with source synchronous ADC clocks.

# ADC9628 DCO to data skew (LVDS) is -.20 to +.25 ns.




create_clock -period 8.333 -name IN_CK_ADC [get_ports FPGA_CK_P]
create_clock -period 8.333 -name ADC0_CK_P -waveform {3.449 7.616} [get_ports ADC0_CK_P]
create_clock -period 8.333 -name ADC1_CK_P -waveform {3.449 7.616} [get_ports ADC1_CK_P]
create_clock -period 8.333 -name ADC2_CK_P -waveform {3.449 7.616} [get_ports ADC2_CK_P]
create_clock -period 8.333 -name ADC3_CK_P -waveform {3.449 7.616} [get_ports ADC3_CK_P]
create_clock -period 8.333 -name ADC4_CK_P -waveform {3.449 7.616} [get_ports ADC4_CK_P]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks IN_CK_ADC] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC0_CK_P] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC1_CK_P] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC2_CK_P] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC3_CK_P] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC4_CK_P] -group [get_clocks -include_generated_clocks clk_fpga_0]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC0_CK_P] -group [get_clocks -include_generated_clocks IN_CK_ADC]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC1_CK_P] -group [get_clocks -include_generated_clocks IN_CK_ADC]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC2_CK_P] -group [get_clocks -include_generated_clocks IN_CK_ADC]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC3_CK_P] -group [get_clocks -include_generated_clocks IN_CK_ADC]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks ADC4_CK_P] -group [get_clocks -include_generated_clocks IN_CK_ADC]


# Note: Adding 1/2 clock period to the input delay is a kludge to force timing analysis to use next clock edge of same direction for both
# setup and hold analysis.  Otherwise setup/hold will use different clock edges, which will result in a timing violation.
# See avrum response of 2-Aug-2015 "Re: How to constraint Same-Edge capture edge-aligned DDR input properly?" in Vivado forum for an explaination.

set_input_delay -clock [get_clocks ADC0_CK_P] 5.267 [get_ports {adc0_n[*] adc0_p[*]}]
set_input_delay -clock [get_clocks ADC0_CK_P] -min 5.067 [get_ports {adc0_n[*] adc0_p[*]}]
set_input_delay -clock [get_clocks ADC0_CK_P] -clock_fall -add_delay 5.267 [get_ports {adc0_n[*] adc0_p[*]}]
set_input_delay -clock [get_clocks ADC0_CK_P] -clock_fall -min -add_delay 5.067 [get_ports {adc0_n[*] adc0_p[*]}]

set_input_delay -clock [get_clocks ADC1_CK_P] 5.267 [get_ports {adc1_n[*] adc1_p[*]}]
set_input_delay -clock [get_clocks ADC1_CK_P] -min 5.067 [get_ports {adc1_n[*] adc1_p[*]}]
set_input_delay -clock [get_clocks ADC1_CK_P] -clock_fall -add_delay 5.267 [get_ports {adc1_n[*] adc1_p[*]}]
set_input_delay -clock [get_clocks ADC1_CK_P] -clock_fall -min -add_delay 5.067 [get_ports {adc1_n[*] adc1_p[*]}]

set_input_delay -clock [get_clocks ADC2_CK_P] 5.267 [get_ports {adc2_n[*] adc2_p[*]}]
set_input_delay -clock [get_clocks ADC2_CK_P] -min 5.067 [get_ports {adc2_n[*] adc2_p[*]}]
set_input_delay -clock [get_clocks ADC2_CK_P] -clock_fall -add_delay 5.267 [get_ports {adc2_n[*] adc2_p[*]}]
set_input_delay -clock [get_clocks ADC2_CK_P] -clock_fall -min -add_delay 5.067 [get_ports {adc2_n[*] adc2_p[*]}]

set_input_delay -clock [get_clocks ADC3_CK_P] 5.267 [get_ports {adc3_n[*] adc3_p[*]}]
set_input_delay -clock [get_clocks ADC3_CK_P] -min 5.067 [get_ports {adc3_n[*] adc3_p[*]}]
set_input_delay -clock [get_clocks ADC3_CK_P] -clock_fall -add_delay 5.267 [get_ports {adc3_n[*] adc3_p[*]}]
set_input_delay -clock [get_clocks ADC3_CK_P] -clock_fall -min -add_delay 5.067 [get_ports {adc3_n[*] adc3_p[*]}]

set_input_delay -clock [get_clocks ADC4_CK_P] 5.267 [get_ports {adc4_n[*] adc4_p[*]}]
set_input_delay -clock [get_clocks ADC4_CK_P] -min 5.067 [get_ports {adc4_n[*] adc4_p[*]}]
set_input_delay -clock [get_clocks ADC4_CK_P] -clock_fall -add_delay 5.267 [get_ports {adc4_n[*] adc4_p[*]}]
set_input_delay -clock [get_clocks ADC4_CK_P] -clock_fall -min -add_delay 5.067 [get_ports {adc4_n[*] adc4_p[*]}]



set_clock_groups -name fake_rd_clks -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks clk_fpga_1]




set_clock_groups -asynchronous -group [get_clocks IN_CK_ADC] -group [get_clocks clk_out1_uub_proto2_clk_wiz_0_1]
