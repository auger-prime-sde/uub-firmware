#ifndef IO_FUNCS_
#define IO_FUNCS_
//
// Port 1 bits
//
#define PS_AN_EN 	0x001
#define PS_5V_EN 	0x002
#define QSPI_RST_N 	0x004
// #define PS_USB_5V_EN	0x004
#define PS_3V3_EN	0x008
#define PS_1V8_EN	0x010
#define PS_1V_EN	0x020
#define PS_EXT1_24V_EN	0x040
#define PS_EXT2_24V_EN	0x080
#define FPGA_CORE_PS (PS_5V_EN | PS_1V8_EN | PS_3V3_EN | PS_1V_EN)
#define ADC_CORE_PS (PS_AN_EN)
#define EXT_CORE_PS (PS_EXT1_24V_EN | PS_EXT2_24V_EN) 
// Port 2 bits
//
#define PS_PMT_12V_EN	0x001
#define PS_RADIO_12V_EN	0x002
#define N_PW_FAULT	0x004
#define DONE		0x008
#define PS_SRST_B	0x010
#define LED_EN_PPS	0x020
#define PMT_CORE_PS PS_PMT_12V_EN
#define RADIO_CORE_PS PS_RADIO_12V_EN
// FPGA Powersupplies
//
// Port 4 bits
//
#define ONE_W0		0x01
#define ONE_W1		0x02
#define COMMS_RESET	0x04
#define LED		0x08
#define AD0		0x10
#define AD1		0x20
#define AD2		0x40
#define B3V3_QSPI_B	0x80
//
// Port 5 bits
//
#define PS_POR_B	0x01
// bits 0x02 and 0x04 managed by I2C 
#define QSPI_RST_N_old 	0x08
#define NMI_FPGA	0x10
#define RST_FPGA	0x20
//
// Functions
//
void IO_Config();
void IO_Set ( unsigned int pattern );
unsigned int IO_Get ();
void ADC_Mux (unsigned char);
#endif
