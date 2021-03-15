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

#include <stdint.h>
#include "xparameters.h"
#include "xparameters_ps.h"
#include "sde_trigger_defs.h"
test(int argc,char *argv[])
{
  int fd,size,i;
  volatile uint32_t *regs;
  int reg,set;
  uint32_t val,prev;

  reg=atoi(argv[1]);
  if(argc>2){
    sscanf(argv[2],"%x",&val);
    set=1;
  } else {
    set=0;
  }
  /*open registers address for read/write */
  fd=open("/dev/mem",O_RDWR);
  if(fd<0){
    printf("Error - it was not possible to open the /dev/mem "
	   "for read/write regitsters\n");
    exit(1);
  }
  size=256*sizeof(uint32_t);
  if(size%sysconf(_SC_PAGE_SIZE)){
    size=(size/sysconf(_SC_PAGE_SIZE)+1)*sysconf(_SC_PAGE_SIZE);
  }
  regs=(uint32_t *)mmap(NULL, size,
			PROT_READ | PROT_WRITE, MAP_SHARED,
			fd,SDE_TRIGGER_BASE);
  if(regs==MAP_FAILED){
    printf("Error - while trying to map the Registers\n");
    exit(1);
  }
  close(fd); /*it is not needed to keep opened */
  prev=regs[reg];
  if(set){
    regs[reg]=val;
  }
  printf("reg: %d -- %08x ... %08x\n",reg,prev,regs[reg]);

}
//
//  }
//
//SHWR_BUF_TRIG_MASK_ADDR

//COMPATIBILITY_SHWR_BUF_TRIG_SB  ,


//  COMPATIBILITY_SB_TRIG_THR0_ADDR, 48 800
//  COMPATIBILITY_SB_TRIG_THR1_ADDR, 49 800
//  COMPATIBILITY_SB_TRIG_THR2_ADDR, 50 800
//  COMPATIBILITY_SB_TRIG_ENAB_ADDR, 52 f8
//  COMPATIBILITY_SB_TRIG_INCL_PMT0,
//  COMPATIBILITY_SB_TRIG_INCL_PMT1,
//  COMPATIBILITY_SB_TRIG_INCL_PMT2,
//  COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT,

//SHWR_BUF_TRIG_MASK_ADDR 128


//COMPATIBILITY_GLOBAL_CONTROL_ADDR 46

//./reg 46 1
//./reg 48 280
//./reg 49 280
//./reg 50 280
//./reg 52 78
//./reg 128 1
