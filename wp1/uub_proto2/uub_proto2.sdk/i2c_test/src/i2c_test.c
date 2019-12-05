// I2c-0 high traffic test

// UUB initialization file
#include <fcntl.h>

#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include "sde_sc.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <linux/i2c-dev.h>
#include <time.h>;
#define SC_ADDR		0x0f
#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)
int file, i, j, ch, val, lt, counter;
char filename[20];
char* i2c_busy = "/home/root/i2c_busy";
char i2c_file[] = "/home/root/i2c_busy";
FILE *f_i2c;
int ret;
char buf[160];

int frequency;

int main()
{
	printf("Test I2C-0 is running... \n");


		f_i2c = fopen(i2c_file, "w");
		ret = remove(i2c_file);



	while(1)	// infinite LOOP for watchdog
	{


		if( access( i2c_busy, F_OK ) != -1 ) {
		    printf("Test: file exist\n");
		    frequency = 3000000;
		} else {
		  //  printf("file doesn't exists\n");
			frequency = 1500000;


				snprintf(filename, 19, "/dev/i2c-1");
				file = open(filename, O_RDWR);
				if (file < 0) {
					printf("error opening %s\n",filename);
					perror(" Error opening file");
						exit (1);
				}
				if (ioctl(file, I2C_SLAVE, SC_ADDR) < 0) {
						printf("Fail to setup slave addr!\n");
						exit (1);
				}





					f_i2c = fopen(i2c_file, "w");

		//		    system ("slowc -a > /dev/null");

					sc_get_ADC_values (file);


								//	 printf ("%d",adc_buffer[0]);
								//	 printf ("\t %.1f",adc_buffer[1]);
								//	 printf ("\n");
									 if((float)adc_buffer[0] > 100){
										 printf ("Test: ERROR!!!\n");
									 }

		/*			sc_serial(file, buf);
				  // printf("SN: ");
				   for (i=1; i<6; i++) printf("%.2x",buf[i]);
				   printf("\n", buf[i]);
				   char snumber =  buf[1];
		printf(snumber);
		if(snumber == "8f16190100"){
			printf("serial is ok\n");
		}
		*/
					usleep(10000);
					fclose(f_i2c);
				close(file);


				usleep(200000);
					ret = remove(i2c_file);
		}


	//	sleep(1);
		usleep (frequency);
	}
}





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

