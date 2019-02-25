
#******
#**     Contraints set for the new UUB board (November 2014)
#**     Laboratoire de Physique Subatomique et de Cosmologie, Grenoble, FRANCE
#******

#******
#**    Technology level interface
#******

# 25-Feb-2016 DFN Remove adcX_p[12] - overflow from pins
# 21-Jun-2016 DFN Rename TP to P6X to correspond to board designations
# 11-Dec-2017 DFN Rename P6X[4] to ADC_PD, and P6X[5] to P65
# 19-Jun-2018 DFN Merge in AMIGA changes to ext0.
# 16-Oct-2018 DFN Modify ext1_dat ports for FAKE_RD tests
# 21-Oct-2018 DFN Vivado keeps renaming ext0_dat[*], so change to
#                 individual pins instead of a vector.
# 02-Nov-2018 DFN Change P6x[3:1] to P61 ... P63.  Vivado kept changing vector
#                 from [3:1] to [2:0] which then failed placement.
# 21-Dec-2018 DFN Steal pins from hconf for I2C.
# 22-Feb-2019 DFN Draft define pins for RD interface.

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets RD_XFR_CLK_IBUF]

set_property IOSTANDARD LVCMOS33 [get_ports TRIG_IN]
set_property IOSTANDARD LVCMOS33 [get_ports TRIG_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports GPS_PPS]
set_property IOSTANDARD LVCMOS33 [get_ports GPS_TX]
set_property IOSTANDARD LVCMOS33 [get_ports GPS_RX]
#set_property IOSTANDARD LVCMOS33 [get_ports {hconf[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports HCONF0]
set_property IOSTANDARD LVCMOS33 [get_ports HCONF1]
set_property IOSTANDARD LVCMOS33 [get_ports HCONF2]
set_property IOSTANDARD LVCMOS33 [get_ports HCONF3]
set_property IOSTANDARD LVCMOS33 [get_ports HCONF4]
set_property IOSTANDARD LVCMOS33 [get_ports HCONF5]
set_property IOSTANDARD LVCMOS33 [get_ports iic_rtl_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_rtl_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports WATCHDOG]
set_property IOSTANDARD LVCMOS33 [get_ports RADIO_RST_IN]
set_property IOSTANDARD LVCMOS33 [get_ports RADIO_RST_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports USB_IFAULT]

set_property IOSTANDARD LVCMOS33 [get_ports AMIGA_LTS_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports AMIGA_CLOCK_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports AMIGA_RX]
set_property IOSTANDARD LVCMOS33 [get_ports AMIGA_TX]

set_property IOSTANDARD LVCMOS33 [get_ports ENABLE_RD_XFR]
set_property IOSTANDARD LVCMOS33 [get_ports RD_XFR_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports RD_SER_DATA0]
set_property IOSTANDARD LVCMOS33 [get_ports RD_SER_DATA1]
set_property IOSTANDARD LVCMOS33 [get_ports RD_TRIG]
set_property IOSTANDARD LVCMOS33 [get_ports RD_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports RD_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports RD_SCK]

set_property IOSTANDARD LVCMOS33 [get_ports {ENABLE_RD_XFR_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_XFR_CLK_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_SER_DATA0_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_SER_DATA1_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_TRIG_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_MISO_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_MOSI_CTL[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RD_SCK_CTL[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {EXT0_DAT4[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EXT0_DAT5[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EXT0_DAT6[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {EXT0_DAT7[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext0_ctl[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {ext1_dat[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {ext1_ctl[*]}]

set_property IOSTANDARD LVDS_25 [get_ports {adc0_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc1_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc2_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc3_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc4_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports ADC0_CK_P]
set_property IOSTANDARD LVDS_25 [get_ports ADC1_CK_P]
set_property IOSTANDARD LVDS_25 [get_ports ADC2_CK_P]
set_property IOSTANDARD LVDS_25 [get_ports ADC3_CK_P]
set_property IOSTANDARD LVDS_25 [get_ports ADC4_CK_P]
set_property IOSTANDARD LVDS_25 [get_ports FPGA_CK_P]

set_property IOSTANDARD LVCMOS25 [get_ports LED_FLG]
set_property IOSTANDARD LVCMOS25 [get_ports {LED_ASY[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports RADIO_RTS]
set_property IOSTANDARD LVCMOS25 [get_ports RADIO_CTS]

#set_property IOSTANDARD LVCMOS33 [get_ports {P6X[1]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {P6X[2]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {P6X[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports P61]
set_property IOSTANDARD LVCMOS25 [get_ports P62]
set_property IOSTANDARD LVCMOS25 [get_ports P63]
set_property IOSTANDARD LVCMOS25 [get_ports ADC_PWD]
set_property IOSTANDARD LVCMOS25 [get_ports P65]


#******
#**    FPGA Pinout
#******

set_property PACKAGE_PIN V13 [get_ports {adc0_p[0]}]
set_property PACKAGE_PIN P16 [get_ports {adc0_p[1]}]
set_property PACKAGE_PIN P17 [get_ports {adc0_p[2]}]
set_property PACKAGE_PIN M15 [get_ports {adc0_p[3]}]
set_property PACKAGE_PIN L17 [get_ports {adc0_p[4]}]
set_property PACKAGE_PIN W15 [get_ports {adc0_p[5]}]
set_property PACKAGE_PIN AB14 [get_ports {adc0_p[6]}]
set_property PACKAGE_PIN Y14 [get_ports {adc0_p[7]}]
set_property PACKAGE_PIN Y13 [get_ports {adc0_p[8]}]
set_property PACKAGE_PIN V14 [get_ports {adc0_p[9]}]
set_property PACKAGE_PIN U15 [get_ports {adc0_p[10]}]
set_property PACKAGE_PIN N15 [get_ports {adc0_p[11]}]
#set_property PACKAGE_PIN N17 [get_ports {adc0_p[12]}]

set_property PACKAGE_PIN R19 [get_ports {adc1_p[0]}]
set_property PACKAGE_PIN U17 [get_ports {adc1_p[1]}]
set_property PACKAGE_PIN W20 [get_ports {adc1_p[2]}]
set_property PACKAGE_PIN Y20 [get_ports {adc1_p[3]}]
set_property PACKAGE_PIN AA22 [get_ports {adc1_p[4]}]
set_property PACKAGE_PIN AA21 [get_ports {adc1_p[5]}]
set_property PACKAGE_PIN AA17 [get_ports {adc1_p[6]}]
set_property PACKAGE_PIN AB19 [get_ports {adc1_p[7]}]
set_property PACKAGE_PIN V18 [get_ports {adc1_p[8]}]
set_property PACKAGE_PIN T16 [get_ports {adc1_p[9]}]
set_property PACKAGE_PIN Y19 [get_ports {adc1_p[10]}]
set_property PACKAGE_PIN AA16 [get_ports {adc1_p[11]}]
#set_property PACKAGE_PIN W16 [get_ports {adc1_p[12]}]

set_property PACKAGE_PIN K19 [get_ports {adc2_p[0]}]
set_property PACKAGE_PIN M21 [get_ports {adc2_p[1]}]
set_property PACKAGE_PIN J16 [get_ports {adc2_p[2]}]
set_property PACKAGE_PIN J15 [get_ports {adc2_p[3]}]
set_property PACKAGE_PIN K16 [get_ports {adc2_p[4]}]
set_property PACKAGE_PIN N22 [get_ports {adc2_p[5]}]
set_property PACKAGE_PIN P20 [get_ports {adc2_p[6]}]
set_property PACKAGE_PIN R20 [get_ports {adc2_p[7]}]
set_property PACKAGE_PIN N19 [get_ports {adc2_p[8]}]
set_property PACKAGE_PIN T22 [get_ports {adc2_p[9]}]
set_property PACKAGE_PIN R18 [get_ports {adc2_p[10]}]
set_property PACKAGE_PIN U20 [get_ports {adc2_p[11]}]
#set_property PACKAGE_PIN V22 [get_ports {adc2_p[12]}]

set_property PACKAGE_PIN D22 [get_ports {adc3_p[0]}]
set_property PACKAGE_PIN E19 [get_ports {adc3_p[1]}]
set_property PACKAGE_PIN E21 [get_ports {adc3_p[2]}]
set_property PACKAGE_PIN F21 [get_ports {adc3_p[3]}]
set_property PACKAGE_PIN F18 [get_ports {adc3_p[4]}]
set_property PACKAGE_PIN G20 [get_ports {adc3_p[5]}]
set_property PACKAGE_PIN G19 [get_ports {adc3_p[6]}]
set_property PACKAGE_PIN H22 [get_ports {adc3_p[7]}]
set_property PACKAGE_PIN H19 [get_ports {adc3_p[8]}]
set_property PACKAGE_PIN J21 [get_ports {adc3_p[9]}]
set_property PACKAGE_PIN J20 [get_ports {adc3_p[10]}]
set_property PACKAGE_PIN J18 [get_ports {adc3_p[11]}]
#set_property PACKAGE_PIN L21 [get_ports {adc3_p[12]}]

set_property PACKAGE_PIN G15 [get_ports {adc4_p[0]}]
set_property PACKAGE_PIN E15 [get_ports {adc4_p[1]}]
set_property PACKAGE_PIN D16 [get_ports {adc4_p[2]}]
set_property PACKAGE_PIN C15 [get_ports {adc4_p[3]}]
set_property PACKAGE_PIN B16 [get_ports {adc4_p[4]}]
set_property PACKAGE_PIN G17 [get_ports {adc4_p[5]}]
set_property PACKAGE_PIN A21 [get_ports {adc4_p[6]}]
set_property PACKAGE_PIN C17 [get_ports {adc4_p[7]}]
set_property PACKAGE_PIN A18 [get_ports {adc4_p[8]}]
set_property PACKAGE_PIN D20 [get_ports {adc4_p[9]}]
set_property PACKAGE_PIN A16 [get_ports {adc4_p[10]}]
set_property PACKAGE_PIN B21 [get_ports {adc4_p[11]}]
#set_property PACKAGE_PIN F16 [get_ports {adc4_p[12]}]

# Note ports not in same order in V1 and V2
set_property PACKAGE_PIN AA12 [get_ports HCONF0]
set_property PACKAGE_PIN AB12 [get_ports HCONF1]
set_property PACKAGE_PIN V12 [get_ports iic_rtl_sda_io]
set_property PACKAGE_PIN W12 [get_ports iic_rtl_scl_io]
set_property PACKAGE_PIN U9 [get_ports HCONF2]
set_property PACKAGE_PIN U11 [get_ports HCONF3]
set_property PACKAGE_PIN U12 [get_ports HCONF4]
set_property PACKAGE_PIN U10 [get_ports HCONF5]

set_property PACKAGE_PIN AB10 [get_ports AMIGA_LTS_OUT]
set_property PACKAGE_PIN Y11 [get_ports AMIGA_CLOCK_OUT]
set_property PACKAGE_PIN AA9 [get_ports AMIGA_RX]
set_property PACKAGE_PIN Y9 [get_ports AMIGA_TX]
#set_property PACKAGE_PIN AB10 [get_ports {ext0_dat[0]}]
#set_property PACKAGE_PIN Y11 [get_ports {ext0_dat[1]}]
#set_property PACKAGE_PIN AA9 [get_ports {ext0_dat[2]}]
#set_property PACKAGE_PIN Y9 [get_ports {ext0_dat[3]}]

set_property PACKAGE_PIN Y6 [get_ports {EXT0_DAT4[0]}]
set_property PACKAGE_PIN AA7 [get_ports {EXT0_DAT5[0]}]
set_property PACKAGE_PIN AB2 [get_ports {EXT0_DAT6[0]}]
set_property PACKAGE_PIN AB5 [get_ports {EXT0_DAT7[0]}]
set_property PACKAGE_PIN AB9 [get_ports {ext0_ctl[0]}]
set_property PACKAGE_PIN Y10 [get_ports {ext0_ctl[1]}]
set_property PACKAGE_PIN AA8 [get_ports {ext0_ctl[2]}]
set_property PACKAGE_PIN Y8 [get_ports {ext0_ctl[3]}]
set_property PACKAGE_PIN Y5 [get_ports {ext0_ctl[4]}]
set_property PACKAGE_PIN AA6 [get_ports {ext0_ctl[5]}]
set_property PACKAGE_PIN AB1 [get_ports {ext0_ctl[6]}]
set_property PACKAGE_PIN AB4 [get_ports {ext0_ctl[7]}]

#set_property PACKAGE_PIN AB7 [get_ports {ext1_dat[0]}]
#set_property PACKAGE_PIN Y4 [get_ports {ext1_dat[1]}]
#set_property PACKAGE_PIN R6 [get_ports {ext1_dat[2]}]
#set_property PACKAGE_PIN T4 [get_ports {ext1_dat[3]}]
#set_property PACKAGE_PIN V5 [get_ports {ext1_dat[4]}]
#set_property PACKAGE_PIN U6 [get_ports {ext1_dat[5]}]
#set_property PACKAGE_PIN V7 [get_ports {ext1_dat[6]}]
#set_property PACKAGE_PIN W6 [get_ports {ext1_dat[7]}]
#set_property PACKAGE_PIN AB6 [get_ports {ext1_ctl[0]}]
#set_property PACKAGE_PIN AA4 [get_ports {ext1_ctl[1]}]
#set_property PACKAGE_PIN T6 [get_ports {ext1_ctl[2]}]
#set_property PACKAGE_PIN U4 [get_ports {ext1_ctl[3]}]
#set_property PACKAGE_PIN V4 [get_ports {ext1_ctl[4]}]
#set_property PACKAGE_PIN U5 [get_ports {ext1_ctl[5]}]
#set_property PACKAGE_PIN W7 [get_ports {ext1_ctl[6]}]
#set_property PACKAGE_PIN W5 [get_ports {ext1_ctl[7]}]

set_property PACKAGE_PIN AB7 [get_ports ENABLE_RD_XFR]
set_property PACKAGE_PIN Y4 [get_ports RD_XFR_CLK]
set_property PACKAGE_PIN R6 [get_ports RD_SER_DATA0]
set_property PACKAGE_PIN T4 [get_ports RD_SER_DATA1]
set_property PACKAGE_PIN V5 [get_ports RD_TRIG]
set_property PACKAGE_PIN U6 [get_ports RD_MISO]
set_property PACKAGE_PIN V7 [get_ports RD_MOSI]
set_property PACKAGE_PIN W6 [get_ports RD_SCK]
set_property PACKAGE_PIN AB6 [get_ports {ENABLE_RD_XFR_CTL[0]}]
set_property PACKAGE_PIN AA4 [get_ports {RD_XFR_CLK_CTL[0]}]
set_property PACKAGE_PIN T6 [get_ports {RD_SER_DATA0_CTL[0]}]
set_property PACKAGE_PIN U4 [get_ports {RD_SER_DATA1_CTL[0]}]
set_property PACKAGE_PIN V4 [get_ports {RD_TRIG_CTL[0]}]
set_property PACKAGE_PIN U5 [get_ports {RD_MISO_CTL[0]}]
set_property PACKAGE_PIN W7 [get_ports {RD_MOSI_CTL[0]}]
set_property PACKAGE_PIN W5 [get_ports {RD_SCK_CTL[0]}]

set_property PACKAGE_PIN Y18 [get_ports ADC0_CK_P]
set_property PACKAGE_PIN W17 [get_ports ADC1_CK_P]
set_property PACKAGE_PIN M19 [get_ports ADC2_CK_P]
set_property PACKAGE_PIN D18 [get_ports ADC3_CK_P]
set_property PACKAGE_PIN B19 [get_ports ADC4_CK_P]
set_property PACKAGE_PIN L18 [get_ports FPGA_CK_P]

set_property PACKAGE_PIN V10 [get_ports GPS_TX]
set_property PACKAGE_PIN V9 [get_ports GPS_RX]
set_property PACKAGE_PIN R7 [get_ports GPS_PPS]

set_property PACKAGE_PIN V8 [get_ports TRIG_IN]
set_property PACKAGE_PIN W8 [get_ports TRIG_OUT]

set_property PACKAGE_PIN W11 [get_ports WATCHDOG]
set_property PACKAGE_PIN AB11 [get_ports RADIO_RST_IN]
set_property PACKAGE_PIN AA11 [get_ports RADIO_RST_OUT]
set_property PACKAGE_PIN U7 [get_ports USB_IFAULT]

set_property PACKAGE_PIN U21 [get_ports LED_FLG]
set_property PACKAGE_PIN U14 [get_ports {LED_ASY[0]}]

set_property PACKAGE_PIN T21 [get_ports RADIO_RTS]
set_property PACKAGE_PIN U19 [get_ports RADIO_CTS]

#set_property PACKAGE_PIN W10 [get_ports {P6X[1]}]
#set_property PACKAGE_PIN H15 [get_ports {P6X[2]}]
#set_property PACKAGE_PIN R15 [get_ports {P6X[3]}]
set_property PACKAGE_PIN W10 [get_ports P61]
set_property PACKAGE_PIN H15 [get_ports P62]
set_property PACKAGE_PIN R15 [get_ports P63]
set_property PACKAGE_PIN H17 [get_ports ADC_PWD]
set_property PACKAGE_PIN H18 [get_ports P65]

create_clock -period 2500.000 -name IIC_SCL_CLOCK [get_ports iic_rtl_scl_io]
#create_clock -name IIC_SCL_CLOCK -period 2500 [get_ports iic_rtl_sda_io]



