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
#define VERSION_STRING " Version 3.1"
#define LSB_TO_5V 1.868
#define LSB_TO_24V 8.88
#define LSB_TO_12V 4.43
#define LSB_TO_3V3 1.20
#define LSB_TO_1V8 0.674
#define LSB_TO_1V2 0.421
#define LSB_TO_1V0 0.366
#define SC_ADDR		0x0f
char buf[160];
short int adc_buffer[MAX_VARS];
static const char *optString = "d:w:VW:klL:rsStp:v:P::I::Aah?";
float temp;
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
void sc_livetime (int file , int *l)
{char reg [6] = {0x03, 0x00, 0x0, 0x0, 0x0, 0x0};
 char b[4];
	if (write(file, reg, 2) != 2) {
        	 	exit(3);
    }
	usleep (100000);
	if (read(file,b,4)!= 4) {
		  	  	exit(4);
	}
//	printf("b: 0x%x 0x%x 0x%x 0x%x\n", b[0], b[1], b[2], b[3]);
	*l =  b[0]
		+ ( b[1] << 8 )
		+ ( b[2] << 16 )
		+ ( b[3] << 24 );
}
void sc_watchdog (int file, int value)
{	char reg [4] = {0x07, 0x00, 0x0, 0x0};
	reg [2] = (char) (value & 0xff);
	if (write (file, reg, 4) != 4) {
		exit (3);
	}

	return;
}
void sc_ADC_en (int file, int value)
{	char reg [4] = {0x0d, 0x00, 0x0, 0x0};
	reg [2] = (char) (value & 0xff);
	if (write (file, reg, 4) != 4) {
		exit (3);
	}

	return;
}
void sc_ANALOG ( int file, int value)
{	char reg [4] = {0x10, 0x00, 0x0, 0x0};
	reg [2] = (char) (value & 0xff);
	if (write (file, reg, 4) != 4) {
		exit (3);
	}
}
void kill( int file )
{
	char reg[2] = {0x0b, 0x00};
	if (write (file, reg, 2) != 2) {
		exit (3);
	}

}
void radio_rst (int file)
{
	char reg[2] = {0x0c, 0x00};
	if (write (file, reg, 2) != 2) {
		exit (3);
	}


}
void sc_version ( int file, char*b )
{ char reg[] = {0x0e,0x00};
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
void sc_ident_reg_w( int file, char*buf)
{
int i;
char reg[6] ={0x0f, 0x00, 0x0, 0x0, 0x0,0x0};
	for (i=0;i<4; i++) {
		reg[i+2] = buf[i];

	}
	 if (write(file, reg, 6) != 6) {
       	 	exit(3);
    }
	 return;
}
void sc_ident_reg( int file, char*buf)
{
char reg[5] ={0x0f, 0x00, 0x0, 0x0, 0x0};
	 if (write(file, reg, 2) != 2) {
       	 	exit(3);
    }
     usleep (100000);
     if (read(file,buf,4)!= 4) {
	  	  	  	exit(4);
	 }
     return;
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


int main( int argc, char *argv[] )
{

    int opt = 0;


	int file, i, j, ch, val;
	char filename[20];

	opt = getopt( argc, argv, optString );
  /* Geraetedatei oeffnen */

//  printf("Opening device... ");
  snprintf(filename, 19, "/dev/i2c-0");
  	file = open(filename, O_RDWR);
  	if (file < 0) {
//  			printf("error opening %s\n",filename);
  		perror(" Error opening file");
  			exit (1);
  	}
  	if (ioctl(file, I2C_SLAVE, SC_ADDR) < 0) {
  			printf("Fail to setup slave addr!\n");
  			exit (1);
  	}



	  int lt;


            	 sc_get_ADC_values (file);




         opt = getopt( argc, argv, optString );


     	FILE *in;
     	in = fopen ("/sys/bus/iio/devices/iio:device0/in_temp0_raw", "r");
     	fscanf (in, "%f", &temp);
     	fclose (in);
     	float zynq_temp = ((temp-2230)*123)/1000;

     	printf("{");	//json format
         printf("\"Zynq\": %.1f", zynq_temp);


         printf (",\"Temp\": %.1f ,\"Pres\": %.1f ,\"Hum\": %.1f",
        		 	 	 (float) adc_buffer[T_AIR]/10.,
            			 (float) adc_buffer[P_AIR]/10.,
            			 (float) adc_buffer[H_AIR]/10.);
         printf("}");


  return 0;
  }
