/*
SDE_Upgrade Slowcontrol
sde_sc.h
K.H. Becker
*/
// adc channel mapping
#include <inttypes.h>
#define MAYOR_VERSION 3
#define MINOR_VERSION 1
#define VERSION (MAYOR_VERSION << 8 | MINOR_VERSION)
#define PMT4_HVM  0  // chan 0
#define PMT3_HVM  8
#define PMT2_HVM  16
#define PMT1_HVM  24
#define PMT4_CM   32 // chan 2 subchan 0 range 0-5V (0-1V)
#define PMT3_CM   40
#define PMT2_CM   48
#define PMT1_CM   56

#define BAT2_TEMP  1 // chan 1 subchan 0 range 0-5V (0-1V)
#define BAT1_TEMP  9
#define LOADCURR   17
#define BAT_CENT   25
#define EXT_TEMP   33
#define P12V_LI    41
#define P12V_HI_3  49
#define P12V_HI_2  57

#define V_RADIO_12V 2 // chan 2                range 0-12V
#define V_PMTS_12V  10 //                range 0-12V
#define V_EXT2_24V  18 //                range 0-12V
#define V_EXT1_24V  26 //                range 0-12V
#define SP_CURR   34
#define SP_VOLT   42
#define BAT_OUT   50
#define WAT_LVL   58

#define ADC7      3  //chan 3
#define ADC6      11
#define ADC5      19
#define ADC4      27
#define ADC0      35
#define ADC1      43
#define ADC2      51
#define ADC3      59

#define PMT1_TM   4  //chan 4
#define PMT2_TM   12
#define PMT3_TM   20
#define PMT4_TM   28
#define V_3V3     36
#define V_GPS_5V  44 //                  range 0-5V
#define V_AN_P5V  52 //                  range 0-5V
#define V_AN_N5V  60 //                  range 0- -5V (0-1V)

#define I_RADIO_12V  5 // chan 5 subchan 0 range 0-1V
#define I_PMTS_12V  13 // chan 5 subchan 0 range 0-1V
#define I_P5V_ANA   21
#define I_N5V_ANA   29 //                 range 0-1V
#define I_GPS_5V    37 
#define I_1V2       45
#define I_3V3       53
#define I_1V8       61

#define PMT6_HVM     6  //chan 6
#define PMT5_HVM    14
#define PMT6_CM     22
#define PMT5_CM     30
#define PMT6_TM     38
#define PMT5_TM     46
#define V_10V       54
#define ADC8      62

#define I_24V_LED  7 // chan 7                 range 0-5V
#define I_V_INPUTS  15
#define I_3V3_SC    23
#define I_1V0       31
#define P12V_HI_1  39 // chan 0 subchan 0 range 0-5V (0-1V)
#define V_1V8     47 //                  range 0-1.8V
#define V_1V0     55 //                  range 0-1.2V
#define V_1V2     63 // chan 4 subchan 0 range 0-1V

#define P_AIR	  64	//Air pressure in tens mBar
#define T_AIR     65    //Air temperature tens Degrees C
#define H_AIR     66    //Humidity tens %
#define T_WAT     67    //Water temperatur (0xffff if not present)
#define MAX_VARS 68
uint8_t act_mask;
#define UPD_PRESS 0x01
#define UPD_ADC   0x02
#define UPD_WAT	  0x04
#define QSPI_RST_N_IRQ 0x08
#define ADC_DELTA 300
#define UPD_BME280_Delta 60
uint32_t	bme280_update_time;
// more to come .....


// Port mapping


#define PS_AN_E P1_0
#define PS_GPS_E P1_1
#define PS_USB_E P1_2
#define PS_3V3_E P1_3
#define PS_1V8_E P1_4
#define PS_1V0_E P1_5
#define PS_EXT1_E P1_6
#define PS_EXT2_E P1_7

#define PS_PMT_E P2_0
#define PS_RADIO_E P2_1
#define FPGA_DONE P2_2
#define FPGA_PROG P2_3

#define FPGA_BOOT_WAIT 5
unsigned int status_reg;
#define FPGA_DONE_STAT 0x8000
#define PS_AN   0x0001
#define PS_5V   0x0002
#define PS_3V3  0x0008
#define PS_1V8  0x0010
#define PS_1V   0x0020
#define PS_EXT1 0x0040
#define PS_EXT2 0x0080
#define BAT_LOW 0x0100
#define CUR_ERR 0x0200
#define TMP_ERR 0x0400
#define PS_MAIN 0x0800
#define WD_STAT 0x1000  // SC Watchdog active
#define SRST_B  0x2000  // Reset Button released
#define SC_WD_ENABLE    status_reg |= WD_STAT
#define SC_WD_DISABLE   status_reg &= ~WD_STAT
#define SC_WD_STATE     status_reg & WD_STAT
#define SRST_B_STATE     status_reg & SRST_B

unsigned long t0_srst_b;
// Storage for adc_values
volatile unsigned int adc_results[MAX_VARS];
