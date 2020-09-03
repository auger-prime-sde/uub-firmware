/* gcc FeShwrRead_test.c read_evt.c -I. -Ix -lrt */

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <time.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>

//#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>

#include <fe_lib.h> /*this include automatically the shwr_evt_defs.h */
//#include "fe_kernel_interface_defs.h"
#include <read_evt.h>

#include <xparameters.h>
#include <time_tagging_defs.h> 
#include <time_tagging.h>
#include <sde_trigger_defs.h>

#include <rd_interface.h>
#include <rd_interface_defs.h>

#include "linux_uio.h"
#include "sock_conn.h" //it is going to use for simulation.

#define SIG_WAKEUP SIGRTMIN+14

/* for possible different control and possible distinct implementations,
   the structure below is to be used internally by the functions these
   functions. As it would be only used for these functions, 
   it many keep as local variables.
*/

struct read_evt_uio_str
{
  int use_uio;
  int fd;  /*to use with uio driver */
  uint32_t *mem;
  int mem_size;
  fd_set fdset;
};

struct read_evt_global
{
    
  uint32_t id_counter;
  uint32_t volatile *shwr_pt[6];
  int shwr_mem_size;

  uint32_t volatile *regs,*radio,*ttag;
  uint32_t regs2[256];
  int regs_size,radio_size,ttag_size;

  struct read_evt_uio_str uio;

  sigset_t sigset;   
  
};

static struct read_evt_global gl;

/*please do not use the signal SIGRTMIN+15 because it will probaly be
  used in other part of the code ...*/

void *read_evt_map(char *device,uint32_t offset,int *size,int open_flag)
{
  int aux,fd;
  void *addr;
  fd=open(device,open_flag);
  if(fd<0){
    printf("Not possible to open the device: %s\n",device);
    *size=0;
    return(NULL);
  }
  aux=*size;
  if(aux%sysconf(_SC_PAGE_SIZE)){
    aux=((aux+sysconf(_SC_PAGE_SIZE)-1)/sysconf(_SC_PAGE_SIZE))*sysconf(_SC_PAGE_SIZE);
  }
  *size=aux;
  if(open_flag==O_RDWR){
    addr=(void *)mmap(NULL, aux,
		      PROT_READ | PROT_WRITE, MAP_SHARED,
		      fd,offset);
  } else {
    addr=(void *)mmap(NULL, aux,
		      PROT_READ , MAP_SHARED,
		      fd,offset);
  }
  if(addr==MAP_FAILED){
    printf("Error - while trying to map the Registers %08x %08x %d\n",offset,*size,fd);
    exit(1);
  }
  close(fd); /*it is not needed to keep opened */
  return addr;
}


void read_evt_devmem_init(struct read_evt_global *str)
{
  int i,size;
  unsigned int shwr_addr[6]={
    TRIGGER_MEMORY_SHWR0_BASE,
    TRIGGER_MEMORY_SHWR1_BASE,
    TRIGGER_MEMORY_SHWR2_BASE,
    TRIGGER_MEMORY_SHWR3_BASE,
    TRIGGER_MEMORY_SHWR4_BASE,
    RD_EVENT_BASE
  };

  /*open registers address for read/write */
  str->regs_size=256*sizeof(uint32_t);
  str->regs=read_evt_map("/dev/mem",SDE_TRIGGER_BASE,&(str->regs_size),O_RDWR);

  str->radio_size=3*sizeof(uint32_t);
  str->radio=read_evt_map("/dev/mem",RD_BASE,&(str->radio_size),O_RDWR);

  /*time tagging address */
  str->ttag_size=16*sizeof(uint32_t);
  str->ttag=read_evt_map("/dev/mem",TIME_TAGGING_BASE,&(str->regs_size),O_RDWR);  
  /*open shower buffers for read */

  for(i=0;i<6;i++){
    size=SHWR_MEM_DEPTH*SHWR_MEM_NBUF;
    str->shwr_pt[i]=read_evt_map("/dev/mem",shwr_addr[i],&(size),O_RDONLY);
  }
  str->shwr_mem_size=size;  
}

void read_evt_uio_init(struct read_evt_global *str)
{
  int i,size;
  char *shwr_buff_dev[6]={
    UIO_BUFF_SHWR_SD_0,
    UIO_BUFF_SHWR_SD_1,
    UIO_BUFF_SHWR_SD_2,
    UIO_BUFF_SHWR_SD_3,
    UIO_BUFF_SHWR_SD_4,
    UIO_BUFF_SHWR_RD_0
  };
  /*open registers address for read/write */
  str->regs_size=256*sizeof(uint32_t);
  str->regs=read_evt_map(UIO_CTRL_SDE,0,&(str->regs_size),O_RDWR);

  str->radio_size=3*sizeof(uint32_t);
  str->radio=read_evt_map(UIO_CTRL_RD,0,&(str->radio_size),O_RDWR);

  /*time tagging address */
  str->ttag_size=16*sizeof(uint32_t);
  str->ttag=read_evt_map(UIO_CTRL_TTAG,0,&(str->regs_size),O_RDWR);  
  /*open shower buffers for read */

  for(i=0;i<6;i++){
    size=SHWR_MEM_DEPTH*SHWR_MEM_NBUF;
    str->shwr_pt[i]=read_evt_map(shwr_buff_dev[i],0,&(size),O_RDONLY);
  }
  str->shwr_mem_size=size;  
}


int read_evt_init(int UIO) 
{
  int fd,i;
  int size;
  struct sigevent sev;
  timer_t t_alarm;
  void *addr;
  uint32_t trig_enab;

  for(i=0;i<6;i++){
    gl.shwr_pt[i]=NULL;    
  }
  gl.regs=NULL;
  gl.ttag=NULL;

  gl.uio.use_uio=UIO;

  //open corresponding devices.
  if( gl.uio.use_uio ){
    read_evt_uio_init(&gl);     
  } else {
    read_evt_devmem_init(&gl);    
  }
  /*setting periodical process wakeup to check if there are event.
    It is ugly, but for now, it would work in this whay, until
    we figure a what to implement interruptions through the kernel */

  /*signal of alarm handler - it is going to be just blocked 
    to be used with sigtimedwait system call.
  */
  if(sigemptyset( &gl.sigset )!=0){
    printf("error while trying to set signals ... 1 \n");
    exit(1);
  }
  if(sigaddset(&gl.sigset,SIGRTMIN)!=0){
    printf("error while trying to set signals ... 2.1\n");
    exit(1);
  }
  if( ! gl.uio.use_uio ){
    //it is not needed when using UIO.
    if(sigaddset(&gl.sigset,SIG_WAKEUP)!=0){
      printf("error while trying to set signals ... 2\n");
      exit(1);
    }
  }
  if(sigprocmask(SIG_BLOCK,&gl.sigset,NULL)!=0){
    printf("error while trying to set signals ... 3 \n");
    exit(1);
  }
  if(gl.uio.use_uio){
    //open the UIO device to catch interruptions.
    gl.uio.fd=open(UIO_INTERRUPT_SHWR,O_RDWR);
    if(gl.uio.fd<0){
      printf("Not possible to open device: %s\n",UIO_INTERRUPT_SHWR);
    }
    gl.uio.mem_size=sysconf(_SC_PAGE_SIZE);
    addr=(void *)mmap(NULL,gl.uio.mem_size, PROT_READ | PROT_WRITE,
                      MAP_SHARED,gl.uio.fd,0);
    if(addr==MAP_FAILED){
      close(gl.uio.fd);
      exit(1);
    }
    if(gl.uio.use_uio & 0x100){ //it is for simulation.
      printf("It is going to work in simulation mode\n");
      close(gl.uio.fd);
      gl.uio.fd=sock_conn(AF_UNIX,SOCK_STREAM,1,UIO_SIMU_SHWR,"",NULL);
      if(gl.uio.fd>0){
	printf("Not possible to start the fpga_sim socket for simulation\n");
	exit(1);
      }
    }
    
    gl.uio.mem=(uint32_t *)addr;
    //need to enable the interrupt.
    gl.uio.mem[INTR_EN_ADDR]=1;
    gl.uio.mem[INTR_GLOBAL_EN_ADDR]=1;
    trig_enab=1;
    write(gl.uio.fd, &trig_enab, sizeof(uint32_t));
    FD_ZERO(&gl.uio.fdset);
    FD_SET(gl.uio.fd,&gl.uio.fdset);
  } else {
    /* periodical signal generation - NOT NEEDED FOR UIO */
    sev.sigev_notify=SIGEV_SIGNAL;
    sev.sigev_signo=SIG_WAKEUP;
    if(timer_create(CLOCK_MONOTONIC,&sev,&t_alarm)!=0){
      printf("timer creation error\n");
      exit(1);
    } else {
      struct itimerspec ts;
      ts.it_interval.tv_sec=0;
      ts.it_interval.tv_nsec=100000; /*.1 ms*/
      ts.it_value.tv_sec=0;
      ts.it_value.tv_nsec=100000;/*the next interruption would appear in .1ms*/
      if(timer_settime(t_alarm, 0, &ts, NULL)!=0){
        exit(1);
      }
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
  if(gl.radio!=NULL){
    aux=(void *)gl.radio;
    munmap(aux,gl.radio_size);
  }

  if(gl.ttag!=NULL){
    aux=(void *)gl.ttag;
    munmap(aux,gl.ttag_size);
  }
  for(i=0;i<6;i++){
    if(gl.shwr_pt[i]!=NULL){
      aux=(void *)gl.shwr_pt[i];
      munmap(aux,gl.shwr_mem_size);
    }
  }
  if(gl.uio.use_uio){
    if(gl.uio.mem!=NULL){
      aux=(void *)gl.uio.mem;
      munmap(aux,gl.uio.mem_size);
    }
    close(gl.uio.fd);
    FD_CLR(gl.uio.fd,&gl.uio.fdset);
  }
  return(0);
}

int read_evt_read(struct shwr_evt_complete *shwr)
{
  uint32_t volatile *st;
  int32_t ncl,ncl_pps;
  void *pt_aux;
  uint32_t aux;
  fd_set frds;
  int rd,sig,i,evid;
  int offset,Ok,timeout;
  int trigger;
  uint32_t trig_enab;
  fd_set fds_aux;
  struct timeval uio_timeout;

  /* the following parameters (trace_aux and trace_aux_pt) is used to
     solve a very strange issue: 
     
     if we try to make a copy from the Shower buffers from the FPGA to
     the CPU putting the receiving buffers as aligned in 8 bytes, the
     total time of tranference is of the order of 2000 micro seconds.
     However if it is alligned in 4 bytes, but not in 8 bytes, it
     spend around 800 micro seconds.

     It is not clear why it happen, but it looks to be the case.
     
     Making a copy between memory looks to not spend too much. Therefore,
     even making the following copy: FPGA -> RAM -> RAM (the last copy
     is internally in the code), it spend lesser time than just one 
     copy FPGA->RAM when the RAM allocation is alligned in 8 bytes. 
  */
  static uint64_t trace_aux[1030];  //it is 64 bits to make it alligned in 8 bytes.
  uint32_t *trace_aux_pt;
  
  
  //struct timespec time_begin1,time_begin2,time_end;
  int wait;

  trace_aux_pt=(uint32_t *)trace_aux;
  trace_aux_pt++;

  
  st=&(gl.regs[SHWR_BUF_STATUS_ADDR]);
  aux=SHWR_BUF_NFULL_MASK<<SHWR_BUF_NFULL_SHIFT;
  trigger=0;
  if( gl.uio.use_uio ){
    fds_aux=gl.uio.fdset;
    uio_timeout.tv_sec=1;
    uio_timeout.tv_usec=0;
    if(select( gl.uio.fd+1, &fds_aux, NULL,NULL, &uio_timeout ) > 0){
      if(FD_ISSET(gl.uio.fd, &fds_aux ) ){
        if(read(gl.uio.fd,&trig_enab,sizeof(uint32_t))>0){
          trigger=1;
        }
      }
    }
  } else {
    sig=SIG_WAKEUP;
    wait=0;
    //clock_gettime(CLOCK_REALTIME,&time_begin2);

    while( ((*st) & aux)==0 && sig==SIG_WAKEUP){
      //clock_gettime(CLOCK_REALTIME,&time_begin2);
      /*it need to check sig because the process may receive others signals */
      sig=sigwaitinfo(&gl.sigset,NULL);
      //wait=1;
    }
    if(sig==SIG_WAKEUP){
      trigger=1;
    }
  }
  if(trigger){
    //clock_gettime(CLOCK_REALTIME,&time_begin1);
    memcpy(gl.regs2,(uint32_t *)gl.regs,256*sizeof(uint32_t));
    /*the number of ticks need to be calulated by the difference of number
      of clock counts: "shwn counter" - "pps counter".
      As the counter starts from 0 when the counter is larger than 
      TTAG_NANOSEC_MASK+1, it need calculate according that problem 
    */
    shwr->raw.ev_gps_info.second=
      gl.ttag[TTAG_SHWR_SECONDS_ADDR] & TTAG_SECONDS_MASK;

    ncl=gl.ttag[TTAG_SHWR_NANOSEC_ADDR];
    evid = (ncl >> TTAG_EVTCTR_SHIFT ) & TTAG_EVTCTR_MASK;
    ncl &= TTAG_NANOSEC_MASK;

    ncl_pps=gl.ttag[TTAG_SHWR_PPS_NANOSEC_ADDR];
    if(ncl<ncl_pps){
      ncl+=TTAG_NANOSEC_MASK+1;
    }
    shwr->raw.ev_gps_info.ticks = ncl - ncl_pps ;
    /*get event identification (4 bits events counter)*/
    //evid=(gl.ttag[TTAG_SHWR_NANOSEC_ADDR] >> TTAG_EVTCTR_SHIFT ) & TTAG_EVTCTR_MASK;
    if(evid==0){
      gl.id_counter += 16;
    }
    shwr->raw.id = gl.id_counter+evid;
    shwr->raw.ev_gps_info.ticks_prev_pps = gl.ttag[TTAG_SHWR_PPS_SECONDS_ADDR];
    
    /*Get trace information ... */
    shwr->raw.buffer_ev_status = gl.regs2[SHWR_BUF_STATUS_ADDR];
    rd=(((gl.regs2[SHWR_BUF_STATUS_ADDR])>>SHWR_BUF_RNUM_SHIFT) & SHWR_BUF_RNUM_MASK);
    offset=rd*SHWR_NSAMPLES;
    for(i=0;i<5;i++){
      pt_aux=(void *)(gl.shwr_pt[i]+offset);
      memcpy(trace_aux_pt, pt_aux, sizeof(uint32_t)*SHWR_NSAMPLES );
      memcpy(shwr->raw.fadc_raw[i], trace_aux_pt, sizeof(uint32_t)*SHWR_NSAMPLES);          
    }
    shwr->raw.trace_start=gl.regs2[SHWR_BUF_START_ADDR];

    /* type1 means the event have been triggered as ...
       type2 means the event may be also considered as ...
       in The programable logic they are just shifted by 8 between
       these two types.
    */

    aux=gl.regs2[SHWR_BUF_TRIG_ID_ADDR];
    shwr->raw.Evt_type_1 = aux & FE_SHWR_TRIG_MASK_ALL;
    shwr->raw.Evt_type_2 = (aux>>8) & FE_SHWR_TRIG_MASK_ALL; 

    shwr->raw.nsamples=SHWR_NSAMPLES;

    /*signal features parameters (AREA, Peak and Baseline) */
    
    shwr->extra.AREA_PEAK[0]=gl.regs2[SHWR_PEAK_AREA0_ADDR];
    shwr->extra.AREA_PEAK[1]=gl.regs2[SHWR_PEAK_AREA1_ADDR];
    shwr->extra.AREA_PEAK[2]=gl.regs2[SHWR_PEAK_AREA2_ADDR];
    shwr->extra.AREA_PEAK[3]=gl.regs2[SHWR_PEAK_AREA3_ADDR];
    shwr->extra.AREA_PEAK[4]=gl.regs2[SHWR_PEAK_AREA4_ADDR];
    shwr->extra.AREA_PEAK[5]=gl.regs2[SHWR_PEAK_AREA5_ADDR];
    shwr->extra.AREA_PEAK[6]=gl.regs2[SHWR_PEAK_AREA6_ADDR];
    shwr->extra.AREA_PEAK[7]=gl.regs2[SHWR_PEAK_AREA7_ADDR];
    shwr->extra.AREA_PEAK[8]=gl.regs2[SHWR_PEAK_AREA8_ADDR];
    shwr->extra.AREA_PEAK[9]=gl.regs2[SHWR_PEAK_AREA9_ADDR];
    
    shwr->extra.BASELINE[0]=gl.regs2[SHWR_BASELINE0_ADDR];
    shwr->extra.BASELINE[1]=gl.regs2[SHWR_BASELINE1_ADDR];
    shwr->extra.BASELINE[2]=gl.regs2[SHWR_BASELINE2_ADDR];
    shwr->extra.BASELINE[3]=gl.regs2[SHWR_BASELINE3_ADDR];
    shwr->extra.BASELINE[4]=gl.regs2[SHWR_BASELINE4_ADDR];
    /*======================================================= */
    /*=========== get trigger parameters ==================== */
    /*======================================================= */
    shwr->extra.trigger.fpga_version=gl.regs2[ID_REG_ADDR];
    shwr->extra.trigger.trig_mask=gl.regs2[SHWR_BUF_TRIG_MASK_ADDR];

    //compatibility single bin trigger
    shwr->extra.trigger.csbt.th0=gl.regs2[COMPATIBILITY_SB_TRIG_THR0_ADDR];
    shwr->extra.trigger.csbt.th1=gl.regs2[COMPATIBILITY_SB_TRIG_THR1_ADDR];
    shwr->extra.trigger.csbt.th2=gl.regs2[COMPATIBILITY_SB_TRIG_THR2_ADDR];
    shwr->extra.trigger.csbt.enable=gl.regs2[COMPATIBILITY_SB_TRIG_ENAB_ADDR];

    //compatibility TOT
    shwr->extra.trigger.ctot.th0=gl.regs2[COMPATIBILITY_TOT_TRIG_THR0_ADDR];
    shwr->extra.trigger.ctot.th1=gl.regs2[COMPATIBILITY_TOT_TRIG_THR1_ADDR];
    shwr->extra.trigger.ctot.th2=gl.regs2[COMPATIBILITY_TOT_TRIG_THR2_ADDR];
    shwr->extra.trigger.ctot.enable=gl.regs2[COMPATIBILITY_TOT_TRIG_ENAB_ADDR];
    shwr->extra.trigger.ctot.occ=gl.regs2[COMPATIBILITY_TOT_TRIG_OCC_ADDR];
    
      //compatibility TOTD
    shwr->extra.trigger.ctotd.th0=gl.regs2[COMPATIBILITY_TOTD_TRIG_THR0_ADDR];
    shwr->extra.trigger.ctotd.th1=gl.regs2[COMPATIBILITY_TOTD_TRIG_THR1_ADDR];
    shwr->extra.trigger.ctotd.th2=gl.regs2[COMPATIBILITY_TOTD_TRIG_THR2_ADDR];
    shwr->extra.trigger.ctotd.up0=gl.regs2[COMPATIBILITY_TOTD_TRIG_UP0_ADDR];
    shwr->extra.trigger.ctotd.up1=gl.regs2[COMPATIBILITY_TOTD_TRIG_UP1_ADDR];
    shwr->extra.trigger.ctotd.up2=gl.regs2[COMPATIBILITY_TOTD_TRIG_UP2_ADDR];
    shwr->extra.trigger.ctotd.enable=gl.regs2[COMPATIBILITY_TOTD_TRIG_ENAB_ADDR];
    shwr->extra.trigger.ctotd.occ=gl.regs2[COMPATIBILITY_TOTD_TRIG_OCC_ADDR];
    shwr->extra.trigger.ctotd.FD=gl.regs2[COMPATIBILITY_TOTD_TRIG_FD_ADDR];
    shwr->extra.trigger.ctotd.FN=gl.regs2[COMPATIBILITY_TOTD_TRIG_FN_ADDR];
    shwr->extra.trigger.ctotd.integral=gl.regs2[COMPATIBILITY_TOTD_TRIG_INT_ADDR];
    //compatibility MOPS
    //shwr->extra.trigger.cmops....
    //Full Band Width SBT
    shwr->extra.trigger.fsbt.th0   =gl.regs2[SB_TRIG_THR0_ADDR];
    shwr->extra.trigger.fsbt.th1   =gl.regs2[SB_TRIG_THR1_ADDR];
    shwr->extra.trigger.fsbt.th2   =gl.regs2[SB_TRIG_THR2_ADDR];
    shwr->extra.trigger.fsbt.thssd =gl.regs2[SB_TRIG_SSD_ADDR];
    shwr->extra.trigger.fsbt.enable=gl.regs2[SB_TRIG_ENAB_ADDR];
    /* Begin to get the radio data */

    timeout=10;
    Ok=0;
    st=&(gl.radio[ RD_IFC_STATUS_ADDR ]);
    //check if the buffer is busy (transfering from radio to local FPGA)
    while(( *st & (1<<(rd + RD_BUF_FULL_SHIFT))) && 
          ( *st & (1<<(rd + RD_BUF_BUSY_SHIFT))) &&
          timeout>0){
      usleep(100);
      timeout--;
    }
    if( ( *st & (1<<(rd + RD_BUF_BUSY_SHIFT)))==0 && 
        (*st & (1<<(rd + RD_BUF_FULL_SHIFT)))){
      /*transfer radio data */
      shwr->extra.radio_info.local_version = RADIO_VERSION;
      shwr->extra.radio_info.status_flag = gl.radio[RD_IFC_STATUS_ADDR];
      shwr->extra.radio_info.extradata = 0 ;
      shwr->extra.radio_info.id = gl.radio[RD_IFC_ID_ADDR];
      
      pt_aux=(void *)(gl.shwr_pt[5]+offset);
      memcpy(trace_aux_pt, pt_aux, sizeof(uint32_t)*SHWR_NSAMPLES );
      memcpy(shwr->extra.radio_info.fadc_raw, trace_aux_pt,
             sizeof(uint32_t)*SHWR_NSAMPLES);
      Ok=1;
    }
    if( Ok==0 ){
      ///*no data from the radio - settting all */
      memset(&(shwr->extra.radio_info),0,sizeof(shwr->extra.radio_info));
      /*the value "0xFFFFFFFF for the FADC for the radio channels is 
        to indicate no data */
      memset(shwr->extra.radio_info.fadc_raw,
             0xFFFFFFFF,SHWR_NSAMPLES*sizeof(uint32_t));
    }
    shwr->extra.buff_latency = gl.regs[ SHWR_BUF_LATENCY_ADDR ];     
    gl.radio[ RD_IFC_CONTROL_ADDR ] = rd ; /*reset radio buffer */
    /* END RADIO data. */
    shwr->extra.st_end=gl.regs[SHWR_BUF_STATUS_ADDR];
    gl.regs [ SHWR_BUF_CONTROL_ADDR ] = rd;
    if( gl.uio.use_uio ){
      //re-enable the trigger.
      gl.uio.mem[INTR_ACK_ADDR]=1;
      trig_enab=1;
      write(gl.uio.fd, &trig_enab, sizeof(uint32_t));
    }
    return(0);
  } // end of if(trigger) - it had not found any related trigger.
  
  return(1);
}

int read_evt_read_basic_info(struct shwr_evt_complete *shwr)
{
  //get information of the event, but not the trace.
  
}


void read_evt_trig_def(uint32_t *buff)
{
  int i;
  //It is just a copy of all registers related with the trigger definition
  for(i=0;i<256;i++){
    buff[i]=gl.regs[i];
  }
}




