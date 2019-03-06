// map_ifc
//
// Map the firmware registers for the interface module
//
// 29-Dec-2017 DFN  Extracted from map_registers.c

#include "trigger_test_options.h"
#include "trigger_test.h"

void map_ifc()
{
  int fd;
  int size;

#ifndef STAND_ALONE

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

  // This seems to have some conflict on linux.  Map disappers after
  // a short while.  14-Feb-2017 Seems to be OK now; not sure why.
   ifc_regs=(u32 *)mmap(NULL, size,
   			    PROT_READ | PROT_WRITE, MAP_SHARED,
   			    fd,INTERFACE_UUB_BASE);
   if (ifc_regs==MAP_FAILED){ 
     printf("Error - while trying to map interface dfn registers\n");
     exit(1);
   }
   //      int status = read_ifc(2);
   //printf("ifc_regs = %x  ifc_reg[2] = %x\n", ifc_regs, status);

  close(fd); // Can close fd now
#endif
}
