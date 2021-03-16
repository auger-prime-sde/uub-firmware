// read slowc control for web page
// november 2016 written by R.Assiro

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "sde_sc.h"
#define SC_ADDR		0x0f
char buf[160];
static const char *optString = "sStp:v:P::Aah?";
/* Read SlowControl serial Number */
void sc_serial ( int file, char *b)
{   char reg[] ={0x01, 0x00};

//	reg[0] = 0x01;
//  reg[2] = 0x00;
	  if (write(file, reg, 2) != 2) {
	          	 	exit(3);
	           	}
	  usleep (100000);
	  if (read(file,b,8)!= 8) {
		  	  	  	exit(4);
	  	  }
	  return ;
}
void sc_status (int file, char *b)
{   char reg[] ={0x02, 0x00};
     if (write(file, reg, 2) != 2) {
        	 	exit(3);
     }
     usleep (100000);
     if (read(file,b,2)!= 2) {
	  	  	  	exit(4);
	 }
     return ;
}
void sc_test_reg (int file, char *b)
{   char reg[] ={0x0a, 0x00};
     if (write(file, reg, 2) != 2) {
        	 	exit(3);
     }
     usleep (100000);
     if (read(file,b,2)!= 2) {
	  	  	  	exit(4);
	 }
     return ;
}
void sc_get_ADC_values (int file) //, char *b)
{   char reg[] ={0x09, 0x00};
     if (write(file, reg, 2) != 2) {
        	 	exit(3);
     }
     usleep (100000);
     if (read(file,(char *)adc_buffer,2*MAX_VARS)!= 2*MAX_VARS) {
	  	  	  	exit(4);
	 }

     return ;
}
void sc_powerControl_reg (int file, char *b)
{   char reg[] ={0x04, 0x00};
     if (write(file, reg, 2) != 2) {
        	 	exit(3);
     }
     usleep (100000);
     if (read(file,b,2)!= 2) {
	  	  	  	exit(4);
	 }
     return ;
}
void sc_powerControl_reg_w (int file, char *b)
{   char reg[4] ={0x04, 0x00, 0x0, 0x0};
	 reg [2] = *b++;
	 reg [3] = *b;
	 if (write(file, reg, 4) != 4) {
        	 	exit(3);
     }
     usleep (100000);
     return ;
}
void sc_set_dac (int file, int chan, int value)
{	char reg[4] ={0x05, 0x00, 0x0, 0x0};
	static char ch_msk[6] = {0x00, 0x20, 0x60, 0x30, 0x40, 0x50};
		chan = chan -1;
		if ( (chan >= 0 && chan <=5) &&
				(value >=0 && value <= 4095) ) {
		 reg [2] = (char) (value & 0xff);
		 reg [3] = ch_msk[chan] | (char) ((value >>8) & 0x0f);
		 printf ("DAC: 0x%.2x%.2x\n",reg[3],reg[2]);
		 if (write(file, reg, 4) != 4) {
	        	 exit(3);
	     	 	 }
	     usleep (100000);
		 } else printf ( "invalid value %d %d\n", chan+1, value);
	 return ;
}

void display_usage( char *s )
{
    puts( "Usage:" );
    printf ( "%s [-aAst] [-P[HEX]] [-p P_ARG -v V_ARG]\n", s);
    puts ("Options:");
    puts ("-a \t show a map of environment variables in human readable form");
    puts ("-A \t show a map of environment variables as hex raw data");
    puts ("-s \t show content of status register in hex");
    puts ("-t \t show content of test register [0x4321]");
    puts ("-P \t if [HEX] omitted show content of power control register in hex");
    puts ("   \t with [HEX] set power control register to [HEX]");
    puts ("   \t the program takes care that you cannot switch off power supplies used by FPGA");
    puts ("-p");
    puts ("-v \t -p -v are used to set the high voltage for PMT1-6 P_ARG=(1-6) ");
    puts ("   \t to value V_ARG(0x0....0x0fff)");
    puts ("   \t for further information refer to the slow control register map documentation");
    exit( EXIT_FAILURE );
}


int main( int argc, char *argv[] )
{





    int opt = 0;
	int file, i, j, ch, val;
	FILE *fp;
	char filename[20];
	char filename1[100];
	char namedate[20];

	time_t rawtime;
	struct tm *timeinfo;
 	char buffer[80];
	time ( &rawtime );
	timeinfo = localtime ( &rawtime );

	strftime(namedate,20,"%y%m%d%H%M%S",timeinfo);

//  printf("Settings Slow Control... ");
  snprintf(filename, 19, "/dev/i2c-0");
  	file = open(filename, O_RDWR);
  	if (file < 0) {
  			exit("no open file");
  	}
  	if (ioctl(file, I2C_SLAVE, SC_ADDR) < 0) {
  			exit("Fail to setup slave addr!");
  	}

  char dac_ok;
  dac_ok = 0x0;
  sc_get_ADC_values (file);


if (argc == 2) {
		 float Ua =(float)adc_buffer[V_AN_N5V]*LSB_TO_1V0;
		 if (((14.*((2400.-Ua)/8.2-Ua/10.)-Ua)/1000) < 3){
			 	 printf("ALARM! Power supply TRACO -3.3V wrong or missing\n\r");
		 }

		 if (((float)adc_buffer[V_AN_P5V]*LSB_TO_3V3/1000) < 3){
			 	 printf("ALARM! Power supply TRACO +3.3V wrong or missing\n\r");
		 }

		 if (((float)adc_buffer[V_PMTS_12V]*LSB_TO_12V/1000) < 11){
			 	 printf("ALARM! Power supply PMT 12V wrong or missing\n\r");
		 }

		 if (((float)adc_buffer[V_RADIO_12V]*LSB_TO_12V/1000) < 11){
			 	 printf("ALARM! Power supply RADIO 12V wrong or missing\n\r");
		 }

		 if (((float)adc_buffer[V_GPS_5V]*LSB_TO_5V/1000) < 4.5){
			 	 printf("ALARM! Power supply GPS 5V wrong or missing\n\r");
		 }

	}
	else {


// print reply with data for javascript request
  	  	  	  	 printf("{");
	 		 	 printf ("\"V_EXT1_24V\":%.1f,",(float)adc_buffer[V_EXT1_24V]*LSB_TO_24V/1000);
	 		     printf ("\"I_V_INPUTS\":%.1f,",(float)adc_buffer[I_V_INPUTS]*LSB_TO_1V0/60.*42);


	 		     printf ("\"SP_VOLT\":%.1f,",adc_buffer[SP_VOLT]*LSB_TO_5V*50./5000);
	 	//		 printf ("\"LOADCURR\":%.1f,",adc_buffer[LOADCURR]*LSB_TO_5V/48.);

	 			 printf ("\"SP_CURR\":%.1f,",adc_buffer[SP_CURR]*LSB_TO_5V*5./1000.);

	 //		     printf ("\"BAT_CENT\":%.1f,",adc_buffer[BAT_CENT]*LSB_TO_5V*18./5000.);
	 	//	     printf ("\"BAT_OUT\":%.1f,",adc_buffer[BAT_OUT]*LSB_TO_5V*36./5000.);

	 		     printf ("\"V_1V0\":%.2f,",(float)adc_buffer[V_1V0]*LSB_TO_1V0/1000);
	 		     printf ("\"I_1V0\":%.2f,",(float)adc_buffer[I_1V0]*LSB_TO_1V0/60.*41.67); // 41.67=1/0.024

	 		     printf ("\"V_1V2\":%.2f,",(float)adc_buffer[V_1V2]*LSB_TO_1V2/1000);
	 		     printf ("\"I_1V2\":%.2f,",(float)adc_buffer[I_1V2]*LSB_TO_1V0/60.*10.);   // 10=1/.1

	 		     printf ("\"V_1V8\":%.2f,",(float)adc_buffer[V_1V8]*LSB_TO_1V8/1000);
	 		     printf ("\"I_1V8\":%.2f,",(float)adc_buffer[I_1V8]*LSB_TO_1V0/60.*30.3); // 30.3 =1/0.033

	 		    printf ("\"V_3V3\":%.2f,",(float)adc_buffer[V_3V3]*LSB_TO_3V3/1000);

	 		    printf ("\"I_3V3_SC\":%.1f,",(float)adc_buffer[I_3V3_SC]*LSB_TO_1V0/60.*1.2);

	 		   	printf ("\"V_AN_P5V\":%.2f,",(float)adc_buffer[V_AN_P5V]*LSB_TO_3V3/1000);
	 		   	printf ("\"I_P5V_ANA\":%.2f,",(float)adc_buffer[I_P5V_ANA]*LSB_TO_1V0/60.*12.2);


	 		   	float Ua =(float)adc_buffer[V_AN_N5V]*LSB_TO_1V0;
	 		   	printf ("\"V_N5V_ANA\":%.2f,",(14.*((2400.-Ua)/8.2-Ua/10.)-Ua)/1000);

	 		   	printf ("\"I_N5V_ANA\":%.2f,",(float)adc_buffer[I_N5V_ANA]*LSB_TO_1V0/60.*12.2);

	 		    printf ("\"V_GPS_5V\":%.2f,",(float)adc_buffer[V_GPS_5V]*LSB_TO_5V/1000);
	 		   	printf ("\"I_GPS_5V\":%.2f,",(float)adc_buffer[I_GPS_5V]*LSB_TO_1V0/60.*10);

	 		 	printf ("\"V_RADIO_12V\":%.1f,",(float)adc_buffer[V_RADIO_12V]*LSB_TO_12V/1000);
	 		 	printf ("\"I_RADIO_12V\":%.1f,",(float)adc_buffer[I_RADIO_12V]*LSB_TO_1V0/60.*30.3);

	 			printf ("\"V_PMTS_12V\":%.1f,",(float)adc_buffer[V_PMTS_12V]*LSB_TO_12V/1000);
	 			printf ("\"I_PMTS_12V\":%.1f,",(float)adc_buffer[I_PMTS_12V]*LSB_TO_1V0/60.*30.3);

	 			printf ("\"LOADCURR\":%.1f,",adc_buffer[LOADCURR]*LSB_TO_5V/48.);
	 			printf ("\"SP_VOLT\":%.1f,",adc_buffer[SP_VOLT]*LSB_TO_5V*50./5000);
	 			printf ("\"SP_CURR\":%.1f,",adc_buffer[SP_CURR]*LSB_TO_5V*5./1000.);

	 		 	printf ("\"T_AIR\":%.1f",adc_buffer[T_AIR]);


	 	 printf("}");
	}


  }
