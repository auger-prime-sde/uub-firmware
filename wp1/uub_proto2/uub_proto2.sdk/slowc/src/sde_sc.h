/*
SDE_Upgrade Slowcontrol
sde_sc.h
K.H. Becker
*/
// adc channel mapping

#define VERSION  " 1.2 "

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
#define ADC9      54
#define ADC8      62

#define V_USB_5V  7 // chan 7                 range 0-5V
#define I_V_INPUTS  15
#define I_3V3_SC    23
#define I_1V0       31
#define P12V_HI_1  39 // chan 0 subchan 0 range 0-5V (0-1V)
#define V_1V8     47 //                  range 0-1.8V
#define V_1V0     55 //                  range 0-1.2V
#define V_1V2     63 // chan 4 subchan 0 range 0-1V

#define P_AIR	  64	//Air pressure
#define T_AIR     65    //Air temperature
#define T_SCU     66    //SCU temperature
#define T_WAT     67    //Water temperatur (0xffff if not present)
#define MAX_VARS 68
short int adc_buffer[MAX_VARS];

// more to come .....
//#define LSB_TO_5V 1.8814
#define LSB_TO_5V 1.868
#define LSB_TO_24V 8.88
#define LSB_TO_12V 4.43
#define LSB_TO_3V3 1.20
#define LSB_TO_1V8 0.674
#define LSB_TO_1V2 0.421
#define LSB_TO_1V0 0.366



