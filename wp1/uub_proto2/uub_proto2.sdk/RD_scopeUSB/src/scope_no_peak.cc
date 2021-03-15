// UUB simple signals acquisition utility and store on json file
// written by R.Assiro and G. Marsella

#include <stdlib.h>
#include <sys/select.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <time.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>
//#include "fe_lib.h" /*this include automatically the shwr_evt_defs.h */
//#include "fe_kernel_interface_defs.h"
//#include "read_evt.h"
#include "shwr_evt_defs.h"
#include "xparameters.h"
#include "sde_trigger_defs.h"
#include "time_tagging.h"
//#include <ctype.h>
//#include <termios.h>
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

unsigned int shwr_addr[5]={
  TRIGGER_MEMORY_SHWR0_BASE,
  TRIGGER_MEMORY_SHWR1_BASE,
  TRIGGER_MEMORY_SHWR2_BASE,
  TRIGGER_MEMORY_SHWR3_BASE,
  TRIGGER_MEMORY_SHWR4_BASE
};

int main()
{
    int fd, file,i,j, Status, data_trig, ord, width, time;
    int nev = 4096;
    int value = 0;
    int aux;
    unsigned page_addr, page_offset;
    void *ptr,*pt[5],*ptrt,*ptrt1;
    unsigned page_size=sysconf(_SC_PAGESIZE);
    page_offset = 16;
    FILE *fp, *fp1, *fp2;
    int nevt = 0;
    char c;
    void *map_base, *virt_addr;
	unsigned long read_result, writeval;
	off_t target;
	time = 6200000; //width of pulse 100ns
	width = 10; //number x 100ns

    aux=read_evt_init();
    if(aux!=0){
      printf("FeShwrRead: Problem in start the Front-End - (shower read) %d \n",aux);
      return(0);
    }



    while(nevt<1)
    {
    	if (gl.regs[SHWR_BUF_TRIG_MASK_ADDR] == 0x10000){
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
    	FeShwrRead_test(1);
        nevt++;
    }

}


/*please do not use the signal SIGRTMIN+15 because it will probaly be
  used in other part of the code ...*/

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

int read_evt_read(struct shwr_evt_raw *shwr)
{
  uint32_t volatile *st;
  void *pt_aux;
  uint32_t aux;
  fd_set frds;
  int rd,sig,i;
  int offset;
  st=&(gl.regs[SHWR_BUF_STATUS_ADDR]);

  /*wait for the periodical signal and check if there is a
    event trigger
  */
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
    shwr->ev_gps_info.ticks=gl.regs[TTAG_SHWR_NANOSEC_ADDR];

    gl.regs[SHWR_BUF_CONTROL_ADDR]=rd;
    gl.id_counter++;
    return(0);
  }
  return(1);
}

FeShwrRead_test(int Nev)
{
  int aux;
  struct shwr_evt_raw evt;
  int nevts,i,j,index;
  FILE *fp;

  while(read_evt_read(&evt)!=0); /*wait for a available event */

    fp = fopen ("/srv/www/adc_data.json", "w" );    /* Open /dev/mem file */
    fprintf(fp,"[");
    printf("[");

    for(j=0;j<SHWR_NSAMPLES;j++){
      index=(j+evt.trace_start)%SHWR_NSAMPLES;
      fprintf(fp,"{");
      printf("{");
      for(i=0;i<SHWR_RAW_NCH_MAX;i++){
    	  fprintf  (fp,"\"adc%d\": \"%d\"",i*2, evt.fadc_raw[i][index] & 0xFFF);
    	  fprintf(fp,", \"adc%d\": \"%d\"",i*2+1,(evt.fadc_raw[i][index]>>16) & 0xFFF);

    	  printf  ("\"adc%d\": \"%d\"",i*2, evt.fadc_raw[i][index] & 0xFFF);
    	  printf(", \"adc%d\": \"%d\"",i*2+1,(evt.fadc_raw[i][index]>>16) & 0xFFF);

    	  if (i != 4) {fprintf(fp,", "); printf(", ");}
      }

      fprintf(fp,"}");
      printf("}");
      if (j!=SHWR_NSAMPLES-1)  {fprintf(fp,", "); printf(", ");}
    }
 	 fprintf(fp,"]\n");
 	 printf("]");
 	 fclose(fp);

 	 read_evt_end();
}


/*
int usage(void)
{
    printf("____________________________\n");
    printf("|   SCOPE (trigger option) |\n");
    printf("|   -e External SMA UUB    |\n");
    printf("|   -i internal trigger    |\n");
    printf("|   -t threshold trigger   |\n");
    printf("|   -l LED acquisition     |\n");
    printf("|                          |\n");
    printf("|    written by R.Assiro   |\n");
    printf("|      and G.Marsella      |\n");
    printf("|__________________________|\n");
    exit(0);
}
*/
