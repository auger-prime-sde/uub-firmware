/*
 *  Created on: 23/jan/2017
 *      Author: Roberto Assiro
 */

// UUB initialization file

#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <signal.h>
#include <time.h>
#include <sys/mman.h>
#include <string.h>
#include <ctype.h>
#include <termios.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include "shwr_evt_defs.h"
#include "xparameters.h"
#include "sde_trigger_defs.h"


 char ADC_LVDS[3] = {0x00,0x14,0xA0} ; // ADC bus configuration LVDS interleave
 char ADC_LVDS_INV[3] = {0x00,0x14,0xA4} ; // ADC bus configuration LVDS interleave and inverted inputs enabled
 char ADC_RESET[3] = {0x00,0x00,0x3C} ; // ADC reset
 char ADC_VREF[3] = {0x00,0x18,0x04} ; // ADC VREF setting
 char ADC_PDWN[3] = {0x00,0x08,0x00} ; // ADC PDWN setting normal operation
 char ADC_DIG_RES[3] = {0x00,0x08,0x03} ; // ADC PWRD reset setting
 char ADC_DELAY[3] = {0x00,0x17,0x25} ; // ADC delay

 char cmd2channel[3] = {0x00,0x05,0x03}; // Select the 2 channels for previous cmd
 char cmdchannelA[3] = {0x00,0x05,0x01}; // Select the channel A for previous cmd
 char cmdchannelB[3] = {0x00,0x05,0x02}; // Select the channel B for previous cmd

 char TestModeMS[3]  = {0x00,0x0D,0x01}; // ADC Test Mode Middle Scale
 char TestModeFS[3]  = {0x00,0x0D,0x02}; // ADC Test Mode Full Scale
 char NormalMode[3] = {0x00,0x0D,0x00}; // ADC Normal mode
 char TestModeRM[3] = {0x00,0x0D,0x5F}; // ADC Test Mode Ramp
 char TestModeA5[3] = {0x00,0x0D,0x44}; // ADC Test Mode AAA555

 char TstUser1LSB[3] = {0x00,0x19,0x55}; // User defined pattern 1 LSB
 char TstUser1MSB[3] = {0x00,0x1A,0xAA}; // User defined pattern 1 MSB
 char TestModeUM[3]  = {0x00,0x0D,0x08}; // ADC Test Mode USER1
 char AdcDelay[5]    = {0x00};           // Calculated ADC delay table

 static uint8_t mode = 0;
 static uint8_t bits = 8;
 static uint32_t speed = 5000000;

#define SIG_WAKEUP SIGRTMIN+14

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

struct read_evt_global
{
  uint32_t id_counter;
  uint32_t volatile *shwr_pt[5];
  int shwr_mem_size;

  uint32_t volatile *regs;
  int regs_size;

  sigset_t sigset; /*used to wake the process periodically */
};

static struct read_evt_global gl;

static void pabort(const char *s)
{
	perror(s);
	abort();
}
int adc = 0, adc_register, register_value;
FILE *fp, *fp1, *fp2;
int i, fd;
int ret = 0;
char filename[20];

int main(int argc, char *argv[])
{
	unsigned page_addr, page_offset;
	void *ptr,*pt[5],*ptrt,*ptrt1;
	unsigned page_size=sysconf(_SC_PAGESIZE);
	page_offset = 16;
	void *map_base, *virt_addr;
	unsigned long read_result, writeval;
	off_t target;

	// ADC POWER DOWN PIN
	system ("power_down > /dev/null &");	// attivo il pwd pin degli adc
	printf("Initialization of ADC PWD... OK\n\r");

	printf ("Setup for ADC begin\n");
	if (argc == 3) {
		printf ("Setup for ADC begin\n");
			if (!strcmp(argv[2],"-r")) {
					adc_read();
			}
			adc = atoi (argv[1]);
			printf ("Setup for ADC %d\n", adc);
			spi();
			adc_setup();
	}
	else if (argc <= 2 || argc > 5){
		usage();
	}
	else {
		adc = atoi (argv[1]);
		adc_register = atoi (argv[2]);
		register_value = atoi (argv[3]);

		printf("\n\rADC %d command: 0x00 register = 0x%x  value = 0x%x\n\r",adc, adc_register, register_value);
	}

/**/
	spi();

	if (write(fd, cmd2channel, sizeof(cmd2channel)) != sizeof(cmd2channel)) { //command sent for both channels
			exit(3);
	}

	char adc_write[3] = {0x00,0x00,0x00} ;
	adc_write[1] = adc_register;
	adc_write[2] = register_value;

	if (write(fd, adc_write, sizeof(adc_write)) != sizeof(adc_write)) {
			exit(3);
	}


	//close (fd); controllare




	printf("OK\n\r");

}


void adc_setup (void)
{

if (write(fd, cmd2channel, sizeof(cmd2channel)) != sizeof(cmd2channel)) {
	printf("error opening adc_setup\n");
		exit(3);
}

if (write(fd, ADC_DIG_RES, sizeof(ADC_DIG_RES)) != sizeof(ADC_DIG_RES)) {
		exit(3);
}

if (write(fd, ADC_PDWN, sizeof(ADC_PDWN)) != sizeof(ADC_PDWN)) {
		exit(3);
}

if (write(fd, ADC_RESET, sizeof(ADC_RESET)) != sizeof(ADC_RESET)) {
		exit(3);
}

//if (write(fd, ADC_LVDS_INV, sizeof(ADC_LVDS_INV)) != sizeof(ADC_LVDS_INV)) {	// ADC input inverted
if (write(fd, ADC_LVDS, sizeof(ADC_LVDS)) != sizeof(ADC_LVDS)) {	// ADC input not inverted
    	exit(3);
}


if (write(fd, ADC_VREF, sizeof(ADC_VREF)) != sizeof(ADC_VREF)) {
		exit(3);
}
if (write(fd, NormalMode, sizeof(NormalMode)) != sizeof(NormalMode)) {
		exit(3);
}
return (1);
}


void spi(void)
{
									snprintf(filename, 19, "/dev/spidev32766.%d",adc);
									printf("filename %s\n",filename);
									fd = open(filename, O_RDWR);
									if (fd < 0)
										pabort("can't open device");
								// spi mode
									ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
									if (ret == -1)
										pabort("can't set spi mode");

									ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
									if (ret == -1)
										pabort("can't get spi mode");

								// bits per word
									ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
									if (ret == -1)
										pabort("can't set bits per word");

									ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
									if (ret == -1)
										pabort("can't get bits per word");

								// max speed hz
									ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
									if (ret == -1)
										pabort("can't set max speed hz");

									ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
									if (ret == -1)
										pabort("can't get max speed hz");
						//			close (fd);
}


void adc_read(void)
{
	printf("ADC read function\n");
	adc = 2;
	spi();

#define ARRAY_SIZE(array) sizeof(array)/sizeof(array[0])
	int i;
	char wr_buf[]={0x01,0x01,0x01};
	char rd_buf[10]={0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01};
//	rd_buf[0]=0x01;

	printf("input reg:\n");
	for (i=0;i<ARRAY_SIZE(rd_buf);i++) {
	printf("0x%02X ", rd_buf[i]);
	if (i%2)
		printf("\n");
}

		char adc_read[3] = {0x00,0x01,0x00} ;
		adc_read[1] = 8;
		adc_read[2] = 0;

/*
		if (write(fd, ADC_VREF, sizeof(ADC_VREF)) != sizeof(ADC_VREF)) {
				exit(3);
		}
*/

	if (write(fd, wr_buf, ARRAY_SIZE(wr_buf)) != ARRAY_SIZE(wr_buf))
		perror("Write Error!");
	if (read(fd, rd_buf, ARRAY_SIZE(rd_buf)) != ARRAY_SIZE(rd_buf))
		perror("Read Error!!");
	else{
		printf("input reg:\n");
		for (i=0;i<ARRAY_SIZE(rd_buf);i++) {
		printf("0x%02X ", rd_buf[i]);
		if (i%2)
			printf("\n");
		}
	}



printf("\n\rADC %d command: 0x00 register = 0x%x  value = 0x%x\n\r",adc, adc_read[1], adc_read[2]);

	exit(1);


	close(fd);
}

void usage(void)
{
	printf("|    ADC command help\n");
	printf("|    adc <number> <command> <value>\n");
	printf("|    adc -r add -- read adc address\n");
	printf("|    example: adc 0 13 15 <ramp on adc 0>\n");
	printf("|    example: \n");
	printf("|    commands list: \n");
	printf("|    example: \n");
	exit(1);
}
