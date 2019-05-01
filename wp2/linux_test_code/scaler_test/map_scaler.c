// map_scaler
//
// Map the firmware registers
//
// 12-Apr-2019 DFN Original version

#include "scaler_test.h"
#include "sde_trigger.h"
#include "time_tagging.h"

void map_scaler()
{
  int fd;
  int size, imem;
  int i;


  // Open register addresses for read/write

  fd = open("/dev/mem",O_RDWR);
  if (fd < 0){
    printf("Error - /dev/mem open to read/write registers failed\n");
    exit(1);
  }

  printf("map_rd: Mapping trig_regs TO %X\n", SDE_TRIGGER_BASE); 
 size=256*sizeof(u32);
  if (size%sysconf(_SC_PAGE_SIZE)){
    size=(size/sysconf(_SC_PAGE_SIZE)+1)*sysconf(_SC_PAGE_SIZE);
  }
  trig_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,SDE_TRIGGER_BASE);
  if (trig_regs==MAP_FAILED){
    printf("Error - while trying to map trigger registers\n");
    exit(1);
  }

  printf("map_rd: Mapping ttag_regs to %x\n", TIME_TAGGING_BASE); 
  ttag_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,TIME_TAGGING_BASE);
  if (ttag_regs==MAP_FAILED){
    printf("Error - while trying to map time tagging registers\n");
    exit(1);
  }

  printf("map_rd: Mapping ifc_regs to %x\n", INTERFACE_UUB_BASE); 
   ifc_regs=(u32 *)mmap(NULL, size,
   			    PROT_READ | PROT_WRITE, MAP_SHARED,
   			    fd,INTERFACE_UUB_BASE);
   if (ifc_regs==MAP_FAILED){ 
     printf("Error - while trying to map interface dfn registers\n");
     exit(1);
   }


   printf("map_rd: Mapping tstctl_regs to %x\n", TEST_CONTROL_BASE); 
  tstctl_regs=(u32 *)mmap(NULL, size,
			    PROT_READ | PROT_WRITE, MAP_SHARED,
			    fd,TEST_CONTROL_BASE);
 if (tstctl_regs==MAP_FAILED){
   printf("Error - while trying to map test control registers\n");
   exit(1);
 }


  printf("Finished mapping registers\n");
  fflush(stdout);
  sleep(1);

  close(fd); // Can close fd now
}
