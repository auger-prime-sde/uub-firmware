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



// system ("SiPM_control HPO");

// data from SiPM if connected
	#define BUFSIZE 128
    char *cmd = "SiPM_control HPO";
    char *buf[BUFSIZE];
    FILE *fg;
    if ((fg = popen(cmd, "r")) == NULL) {
        printf("Error opening pipe!\n");
        return -1;
    }


    char *string = buf;
//    printf("%c\n", string[1]);
    float dummy, voltage, current, temp;
    char string1[12],string2[10],string3[5],string4[7];

   while (fgets(buf, BUFSIZE, fg) != NULL) {
//    		printf("%s", buf);
    		sscanf (buf, "%s %s %s %s %f %f %f %f %f", string1,
    		   	  string2,string3,string4,&dummy,&voltage,&current,&temp);
    }

/*    int count;
	for (count = 0; count < 7; count++){
		printf("%s ", buf);
	}
*/

  char dac_ok;
  dac_ok = 0x0;
  sc_get_ADC_values (file);
// print reply
	 	 printf("{");
	 	 printf ("\"PMT1_HVM\":%.0f,",(float)adc_buffer[PMT1_HVM] *LSB_TO_5V/ 2.35);
	 	 printf ("\"PMT1_CM\":%.1f,",(float)adc_buffer[PMT1_CM] *LSB_TO_5V / 48);

	 	 printf ("\"PMT2_HVM\":%.0f,",(float)adc_buffer[PMT2_HVM] *LSB_TO_5V / 2.35);
	 	 printf ("\"PMT2_CM\":%.1f,",(float)adc_buffer[PMT2_CM] *LSB_TO_5V / 48);

	 	 printf ("\"PMT3_HVM\":%.0f,",(float)adc_buffer[PMT3_HVM] *LSB_TO_5V / 2.35);
	 	 printf ("\"PMT3_CM\":%.1f,",(float)adc_buffer[PMT3_CM] *LSB_TO_5V / 48);

	 	 printf ("\"PMT4_HVM\":%.0f,",(float)adc_buffer[PMT4_HVM] *LSB_TO_5V / 2.35);
	 	 printf ("\"PMT4_CM\":%.1f,",(float)adc_buffer[PMT4_CM] *LSB_TO_5V / 48);

	 	 printf ("\"PMT5_HVM\":%.0f,",(float)adc_buffer[PMT5_HVM] *LSB_TO_5V / 2.35);
	 	 printf ("\"PMT5_CM\":%.1f,",(float)adc_buffer[PMT5_CM] *LSB_TO_5V / 48);

	 	 printf ("\"PMT6_HVM\":%.0f,",voltage);
	 	 printf ("\"PMT6_CM\":%.1f,",current);
	 	 printf ("\"PMT6_TM\":%.1f",temp);
	 	printf("}");

/*
	 printf("PMT Stat: HVmon\tImon \t Tmon\n");
	            	 printf ("PMT1");
	            	 printf ("\t %.1f",(float)adc_buffer[PMT1_HVM] *LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT1_CM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT1_TM]*LSB_TO_5V);
	            	 printf ("\nPMT2");
	            	 printf ("\t %.1f",(float)adc_buffer[PMT2_HVM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT2_CM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT2_TM]*LSB_TO_5V);
	            	 printf ("\nPMT3");
	            	 printf ("\t %.1f",(float)adc_buffer[PMT3_HVM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT3_CM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT3_TM]*LSB_TO_5V);
	            	 printf ("\nPMT4");
	            	 printf ("\t %.1f",(float)adc_buffer[PMT4_HVM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT4_CM]*LSB_TO_5V);
	            	 printf ("\t %.1f",(float)adc_buffer[PMT4_TM]*LSB_TO_5V);
	            	 printf ("\nPower supplies");
	            	 printf ("\nNominal \t Actual \t Current");
	            	 printf ("\n1V \t");
	            	 printf ("\t %.1f %s",(float)adc_buffer[V_1V0]*LSB_TO_1V0,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_1V0]*LSB_TO_1V0/60.*41.67,"[mA] "); // 41.67=1/0.024
	            	 printf("\n1V2\t");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_1V2]*LSB_TO_1V2,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_1V2]*LSB_TO_1V0/60.*10.,"[mA] ");   // 10=1/.1
	            	 printf( "\n1V8\t");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_1V8]*LSB_TO_1V8,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_1V8]*LSB_TO_1V0/60.*30.3,"[mA] "); // 30.3 =1/0.033
	            	 printf("\n3V3\t");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_3V3]*LSB_TO_3V3,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_3V3]*LSB_TO_3V3/60.*16.13,"[mA] "); // 16.13 = 1/0.062
	            	 printf("\t %.1f %s",(float)adc_buffer[I_3V3_SC]*LSB_TO_1V0/60.*12.2,"[mA SC] "); // 12.2 = 1/0.082
	            	 printf("\nP3V3\t");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_AN_P5V]*LSB_TO_3V3,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_P5V_ANA]*LSB_TO_1V0/60.*12.2,"[mA] ");
	            	 printf("\nN3V3\t");
	          //  	 float Ua =(float)adc_buffer[V_AN_N5V]*LSB_TO_3V3;
//	            	 printf("\t %.1f %s",Ua*2.-(10./7.5 * (2500.-Ua)),"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_N5V_ANA]*LSB_TO_1V0/60.*12.2,"[mA] ");
	            	 printf("\n5V\t");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_GPS_5V]*LSB_TO_5V,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_GPS_5V]*LSB_TO_1V0/60.*10,"[mA] ");
	            	 printf("\n12V Radio");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_RADIO_12V]*LSB_TO_12V,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_RADIO_12V]*LSB_TO_1V0/60.*30.3,"[mA] ");
	            	 printf("\n12V PMTs");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_PMTS_12V]*LSB_TO_12V,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_PMTS_12V]*LSB_TO_1V0/60.*30.3,"[mA] ");
	            	 printf("\n24V EXT1/2");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_EXT1_24V]*LSB_TO_24V,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[V_EXT2_24V]*LSB_TO_24V,"[mV] ");
	            	 printf("\t %.1f %s",(float)adc_buffer[I_V_INPUTS]*LSB_TO_1V0/60.*21.28,"[mA] "); // 21.28=1/0.047
	            	 printf("\nTPCB \n");
	            	 printf("BAT1/2/EXT_TEMP \t%.2f %.2f %.2f\n",
	            			 adc_buffer[BAT1_TEMP]*LSB_TO_5V,
							 adc_buffer[BAT2_TEMP]*LSB_TO_5V,
							 adc_buffer[EXT_TEMP]*LSB_TO_5V);
	            	 printf("BAT_CENT/OUT\t%.2f %.2f [V]\n",
	            			 (float)adc_buffer[BAT_CENT]*LSB_TO_5V*18./5000.,
							 (float)adc_buffer[BAT_OUT]*LSB_TO_5V*36./5000.);
	            	 printf("LOADCURR    \t%.2f [A]\n",adc_buffer[LOADCURR]*LSB_TO_5V/48.);
	            	 printf("SP_VOLT/OUT \t%.2f [V] %.2f [A]\n",
	            			 (float)adc_buffer[SP_VOLT]*LSB_TO_5V*50./5000.,
							 (float)adc_buffer[SP_CURR]*LSB_TO_5V*5./1000.);
	            	 printf("P12V_LI P12V_HI1/2/3 \t %.2f %.2f %.2f %.2f\n",
	            			 (float)adc_buffer[P12V_LI],
							 (float)adc_buffer[P12V_HI_1],
							 (float)adc_buffer[P12V_HI_2],
							 (float)adc_buffer[P12V_HI_3]);
	            	 printf("\nSensors ");
	            	 printf ("\nT= %d *0.1K, P= %d mBar TW = ",adc_buffer[T_AIR],adc_buffer[P_AIR]);
	            	 printf ("%d *0.1K",adc_buffer[T_WAT]);


	            	 printf ("\n");

*/


  }
