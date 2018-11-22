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

#include "time_tagging_defs.h"
#include <sys/types.h>

#include <fcntl.h>

#include <unistd.h>

#include "shwr_evt_defs.h"
#include "xparameters.h"
#include "sde_trigger_defs.h"

#define SIG_WAKEUP SIGRTMIN+14
#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

static struct read_evt_global gl;

unsigned int shwr_addr[5]={
  TRIGGER_MEMORY_SHWR0_BASE,
  TRIGGER_MEMORY_SHWR1_BASE,
  TRIGGER_MEMORY_SHWR2_BASE,
  TRIGGER_MEMORY_SHWR3_BASE,
  TRIGGER_MEMORY_SHWR4_BASE
};


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

char filename[20];
static void pabort(const char *s)
{
	perror(s);
	abort();
}
int adc, offsetA, offsetB;
int fd, file,i,j, Status, data_trig, ord, width;
int ret = 0;
int offset = 205;
off_t target;
void *map_base, *virt_addr;
 unsigned long read_result, writeval;
int main(int argc, char *argv[])
{
	if (argc == 3) {
		offset = atoi (argv[2]);
		automatic();
		}
	else if (argc < 2 || argc > 5){
		automatic();
	}
	else {
		adc = atoi (argv[1]);
		offsetA = atoi (argv[2]);
		offsetB = atoi (argv[3]);

		printf("\n\rADC %d - Channel A =  %d - Channel B = %d\n\r",adc, offsetA, offsetB);
	}

//		int file,j, Status, data_trig, ord, width, time;
	    unsigned page_addr, page_offset;
	    void *ptr,*pt[5],*ptrt,*ptrt1;
	    unsigned page_size=sysconf(_SC_PAGESIZE);
	    page_offset = 16;
	    FILE *fp, *fp1, *fp2;

	    int nev = 4096;
	    int value = 0;
	    int aux;

	    page_offset = 16;

	    int nevt = 0;
	    char c;

	    i == 1;
		printf("Changing offset ADC %d... ",adc);
		spi();
		char ADC_AJAST[3] = {0x00,0x10,0x00} ; // ADC offset setting
		ADC_AJAST[2] = offsetB;
									if (write(fd, cmdchannelB, sizeof(cmdchannelB)) != sizeof(cmdchannelB)) {
										exit(3);
									}
									if (write(fd, ADC_AJAST, sizeof(ADC_AJAST)) != sizeof(ADC_AJAST)) {
										exit(3);
									}

									ADC_AJAST[2] = offsetA;

									if (write(fd, cmdchannelA, sizeof(cmdchannelA)) != sizeof(cmdchannelA)) {
										exit(3);
									}
									if (write(fd, ADC_AJAST, sizeof(ADC_AJAST)) != sizeof(ADC_AJAST)) {
										exit(3);
									}

	printf("OK\n\r");

}

void usage(void)
{
	printf("|    -- DIGITAL OFFSET MODIFICATION --\n\r");
	printf("|    example: offset adc number (0..4) offset chA offset chB\n\r");
	printf("|    example: offset 0 10 30 <manual setting>\n\r");
	printf("|    example: offset -a <auto setting>\n\r");
	exit(1);
}


void automatic(void)
{
	  int nevt = 0;
	  int fd, width, time;
	  int aux;
	  time = 6200000; //width of pulse 100ns
	  width = 10; //number x 100ns

/*

	  for (adc = 0; adc < 5; adc++){ // setting all adc as default
	  			spi();
	  			if (write(fd, ADC_PDWN, sizeof(ADC_PDWN)) != sizeof(ADC_PDWN)) {
	  					exit(3);
	  			}

	  			if (write(fd, ADC_RESET, sizeof(ADC_RESET)) != sizeof(ADC_RESET)) {
	  					exit(3);
	  			}

	  			if (write(fd, ADC_LVDS_INV, sizeof(ADC_LVDS_INV)) != sizeof(ADC_LVDS_INV)) {	// ADC input inverted
	  			    	exit(3);
	  			}
	  			if (write(fd, ADC_VREF, sizeof(ADC_VREF)) != sizeof(ADC_VREF)) {
	  					exit(3);
	  			}
	  			if (write(fd, NormalMode, sizeof(NormalMode)) != sizeof(NormalMode)) {
	  					exit(3);
	  			}
	  		usleep (200);
	  	}
	  	sleep (2);
*/

	aux=read_evt_init();
	if(aux!=0){
	      printf("FeShwrRead: Problem in start the Front-End - (shower read) %d \n",aux);
	      return(0);
	}
	printf("   -- AUTO DIGITAL OFFSET SETTING --\n\r");

//	system ("trigger 300 300 300 120 65536");

    while(nevt<1)
    {

 /*   	if (gl.regs[SHWR_BUF_TRIG_MASK_ADDR] == 0x10000){
    	    		target = 0x43c203fc;
    	    		        	     if((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1);
    	    		        	     	map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, target & ~MAP_MASK);
    	    		        	     	virt_addr = map_base + (target & MAP_MASK);

    	    		        	     	writeval = (time * width);
    	    		        	     	*((unsigned long *) virt_addr) = writeval;
    	    		        	     	usleep (100);
    	    		        	     	 writeval = (time * width) +1;
    	    		        	     	*((unsigned long *) virt_addr) = writeval;
    	    		        	     	close(fd);

    	}
*/
    	FeShwrRead_test(1);
        nevt++;
    }

	printf("DONE...\n\r");
	exit(1);
}



FeShwrRead_test(int Nev)
{
  int aux, temp;
  struct shwr_evt_raw evt;
  int nevts,i,j,index;
  FILE *fp;
  int spread[10];
  int mod = 200;

	temp = (gl.regs[SHWR_BASELINE0_ADDR]&0xffff)>>4;
	spread[0] = (mod - temp);
	temp = (gl.regs[SHWR_BASELINE0_ADDR]>>20) & 0xFFF;
	spread[1] = (mod - temp);

	temp = (gl.regs[SHWR_BASELINE1_ADDR]&0xffff)>>4;
	spread[2] = (mod - temp);
	temp = (gl.regs[SHWR_BASELINE1_ADDR]>>20) & 0xFFF;
	spread[3] = (mod - temp);

	temp = (gl.regs[SHWR_BASELINE2_ADDR]&0xffff)>>4;
	spread[4] = (mod - temp);
	temp = (gl.regs[SHWR_BASELINE2_ADDR]>>20) & 0xFFF;
	spread[5] = (mod - temp);

	temp = (gl.regs[SHWR_BASELINE3_ADDR]&0xffff)>>4;
	spread[6] = (mod - temp);
	temp = (gl.regs[SHWR_BASELINE3_ADDR]>>20) & 0xFFF;
	spread[7] = (mod - temp);

	temp = (gl.regs[SHWR_BASELINE4_ADDR]&0xffff)>>4;
	spread[8] = (mod - temp);

	temp = (gl.regs[SHWR_BASELINE4_ADDR]>>20) & 0xFFF;
	spread[9] = (mod - temp);

	printf("offset adc0A : %d - offset adc0B : %d\n",((gl.regs[SHWR_BASELINE0_ADDR]&0xffff)>>4),(gl.regs[SHWR_BASELINE0_ADDR]>>20) & 0xFFF);
	printf ("Difference = %d ..  %d\n",spread[0],spread[1]);
	printf("offset adc1A : %d - offset adc1B : %d\n",((gl.regs[SHWR_BASELINE1_ADDR]&0xffff)>>4),(gl.regs[SHWR_BASELINE1_ADDR]>>20) & 0xFFF);
	printf ("Difference = %d ..  %d\n",spread[2],spread[3]);
	printf("offset adc2A : %d - offset adc2B : %d\n",((gl.regs[SHWR_BASELINE2_ADDR]&0xffff)>>4),(gl.regs[SHWR_BASELINE2_ADDR]>>20) & 0xFFF);
	printf ("Difference = %d ..  %d\n",spread[4],spread[5]);
	printf("offset adc3A : %d - offset adc3B : %d\n",((gl.regs[SHWR_BASELINE3_ADDR]&0xffff)>>4),(gl.regs[SHWR_BASELINE3_ADDR]>>20) & 0xFFF);
	printf ("Difference = %d ..  %d\n",spread[6],spread[7]);
	printf("offset adc4A : %d - offset adc4B : %d\n",((gl.regs[SHWR_BASELINE4_ADDR]&0xffff)>>4),(gl.regs[SHWR_BASELINE4_ADDR]>>20) & 0xFFF);
	printf ("Difference = %d ..  %d\n",spread[8],spread[9]);


	int var = 0;
	for (adc = 0; adc < 5; adc++){
		  spi();

		  char ADC_AJAST[3] = {0x00,0x10,0x00} ; // ADC offset setting
//if (spread[var] > 127) OR (spread[var] < -127){

		  ADC_AJAST[2] = spread[var];
		  if (write(fd, cmdchannelA, sizeof(cmdchannelA)) != sizeof(cmdchannelA)) {
			  	  exit(3);
		  }
		  if (write(fd, ADC_AJAST, sizeof(ADC_AJAST)) != sizeof(ADC_AJAST)) {
			  	  exit(3);
		  }


		  ADC_AJAST[2] = spread[var+1];
		  if (write(fd, cmdchannelB, sizeof(cmdchannelB)) != sizeof(cmdchannelB)) {
			  	  exit(3);
		  }
		  if (write(fd, ADC_AJAST, sizeof(ADC_AJAST)) != sizeof(ADC_AJAST)) {
			  	  exit(3);
		  }
		  var = var + 2;
	}

  while(read_evt_read(&evt)!=0);

 	 read_evt_end();
}


int read_evt_read(struct shwr_evt_raw *shwr)
{
  uint32_t volatile *st;
  void *pt_aux;
  uint32_t aux;
  fd_set frds;
  int rd,sig,i;
  st=&(gl.regs[SHWR_BUF_STATUS_ADDR]);
  aux=SHWR_BUF_NFULL_MASK<<SHWR_BUF_NFULL_SHIFT;
  sig=SIG_WAKEUP;
  while( ((*st) & aux)==0 && sig==SIG_WAKEUP)
    sig=sigwaitinfo(&gl.sigset,NULL);

  if(sig==SIG_WAKEUP){
    rd=(((*st)>>SHWR_BUF_RNUM_SHIFT) & SHWR_BUF_RNUM_MASK);
    offset=rd*SHWR_NSAMPLES;
    for(i=0;i<5;i++){
      pt_aux=(void *)(gl.shwr_pt[i]+offset);
      memcpy(shwr->fadc_raw[i],
	     pt_aux,
	     sizeof(uint32_t)*SHWR_NSAMPLES);
    }
    shwr->id=gl.id_counter; /*just a internal counter */
    shwr->trace_start=gl.regs[SHWR_BUF_START_ADDR];
    shwr->Evt_type_1=gl.regs[SHWR_BUF_TRIG_ID_ADDR];
    shwr->Evt_type_2=0;
    shwr->ev_gps_info.second=gl.regs[TTAG_SHWR_SECONDS_ADDR];
//    shwr->ev_gps_info.ticks=gl.regs[TTAG_SHWR_NANOSEC_ADDR];
    gl.regs[SHWR_BUF_CONTROL_ADDR]=rd;
    gl.id_counter++;
    return(0);
  }
  return(1);
}


int read_evt_end()
{
  int i;
  void *aux;

  if(gl.regs!=NULL){
    aux=(void *)gl.regs;
    munmap(aux,gl.regs_size);
  }
  for(i=0;i<5;i++){
    if(gl.shwr_pt[i]!=NULL){
      aux=(void *)gl.shwr_pt[i];
      munmap(aux,gl.shwr_mem_size);
    }
  }
}


int read_evt_init()
{
  int fd,i;
  int size;
  struct sigevent sev;
  timer_t t_alarm;

  for(i=0;i<5;i++){
    gl.shwr_pt[i]=NULL;
  }
  gl.regs=NULL;

  fd=open("/dev/mem",O_RDWR);
  if(fd<0){
    printf("Error - it was not possible to open the /dev/mem for read/write regitsters\n");
    exit(1);
  }
  size=256*sizeof(uint32_t);
  if(size%sysconf(_SC_PAGE_SIZE)){
    size=(size/sysconf(_SC_PAGE_SIZE)+1)*sysconf(_SC_PAGE_SIZE);
  }
  gl.regs_size=size;
  gl.regs=(uint32_t *)mmap(NULL, size,
				PROT_READ | PROT_WRITE, MAP_SHARED,
				fd,SDE_TRIGGER_BASE);
  if(gl.regs==MAP_FAILED){
    printf("Error - while trying to map the Registers\n");
    exit(1);
  }
  close(fd); //it is not needed to keep opened

  size=SHWR_MEM_DEPTH*SHWR_MEM_NBUF;
  if(size%sysconf(_SC_PAGE_SIZE)){
    size=(size/sysconf(_SC_PAGE_SIZE)+1)*sysconf(_SC_PAGE_SIZE);
  }
  gl.shwr_mem_size=size;
  for(i=0;i<5;i++){
    fd=open("/dev/mem",O_RDONLY);
    if(fd<0){
      printf("Error - open the /dev/mem for read shower buffers\n");
      exit(1);
    }
    gl.shwr_pt[i]=(uint32_t *)mmap(NULL,size,
				   PROT_READ,MAP_SHARED,
				   fd,shwr_addr[i]);
    if(gl.shwr_pt[i]==MAP_FAILED){
      printf("ERROR- failed to map the shower buffers: %d\n",i);
      exit(1);
    }
    close(fd);
  }

  //setting periodical process wakeup to check if there are event. It is ugly, but for now, it would work in this whay, until we figure a what to implement interruptions through the kernel
  //signal of alarm handler - it is going to be just blocked to be used with sigtimedwait system call.

  if(sigemptyset(&gl.sigset)!=0){
    printf("error while trying to set signals ... 1 \n");
    exit(1);
  }
  if(sigaddset(&gl.sigset,SIG_WAKEUP)!=0){
    printf("error while trying to set signals ... 2\n");
    exit(1);
  }
  if(sigprocmask(SIG_BLOCK,&gl.sigset,NULL)!=0){
    printf("error while trying to set signals ... 3 \n");
    exit(1);
  }

  // periodical signal generation
  sev.sigev_notify=SIGEV_SIGNAL;
  sev.sigev_signo=SIG_WAKEUP;
  if(timer_create(CLOCK_MONOTONIC,&sev,&t_alarm)!=0){
    printf("timer creation error\n");
    exit(1);
  } else {
    struct itimerspec ts;
    ts.it_interval.tv_sec=0;
    ts.it_interval.tv_nsec=100000; //.1 ms
    ts.it_value.tv_sec=0;
    ts.it_value.tv_nsec=100000;//the next interruption would appear in .1ms
    if(timer_settime(t_alarm, 0, &ts, NULL)!=0){
      exit(1);
    }
  }
  gl.id_counter=0;
  return(0);
}


void adc_setup (void)
{

if (write(fd, cmd2channel, sizeof(cmd2channel)) != sizeof(cmd2channel)) {
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

if (write(fd, ADC_LVDS_INV, sizeof(ADC_LVDS_INV)) != sizeof(ADC_LVDS_INV)) {	// ADC input inverted
//if (write(fd, ADC_LVDS, sizeof(ADC_LVDS)) != sizeof(ADC_LVDS)) {	// ADC input NOT inverted
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
}
