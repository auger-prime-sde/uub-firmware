// map_ttap
//
// Map the firmware registers
//
// 23-Feb-2019 DFN Original version

#include "pps_test.h"

void map_ttag()
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

  size=256*sizeof(u32);
  if (size%sysconf(_SC_PAGE_SIZE)){
    size=(size/sysconf(_SC_PAGE_SIZE)+1)*sysconf(_SC_PAGE_SIZE);
  }

  printf("map_ttag: Mapping trigger regs\n"); 
  trig_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,SDE_TRIGGER_BASE);
  if (trig_regs==MAP_FAILED){
    printf("Error - while trying to map trigger registers\n");
    exit(1);
  }


  printf("map_ttag: Mapping ttag intr regs\n"); 
  ttag_intr_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,TIME_TAGGING_INTR_BASE);
  if (ttag_intr_regs==MAP_FAILED){
    printf("Error - while trying to map time tagging intr registers\n");
    exit(1);
  }

  printf("map_ttag: Mapping tstctl_regs\n"); 
  tstctl_regs=(u32 *)mmap(NULL, size,
			    PROT_READ | PROT_WRITE, MAP_SHARED,
			    fd,TEST_CONTROL_BASE);
 if (tstctl_regs==MAP_FAILED){
   printf("Error - while trying to map test control registers\n");
   exit(1);
 }

  close(fd); // Can close fd now
}
