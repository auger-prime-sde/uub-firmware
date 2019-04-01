// map_dig_ifc
//
// Map the firmware registers
//
// 03-Nov-2018 DFN Original version

#include "dig_ifc_test.h"

void map_dig_ifc()
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

  printf("map_rd: Mapping dig_ifc_regs TO %X\n", DIG_IFC_BASE); 
 size=256*sizeof(u32);
  if (size%sysconf(_SC_PAGE_SIZE)){
    size=(size/sysconf(_SC_PAGE_SIZE)+1)*sysconf(_SC_PAGE_SIZE);
  }
  dig_ifc_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,DIG_IFC_BASE);
  if (dig_ifc_regs==MAP_FAILED){
    printf("Error - while trying to map digital interface registers\n");
    exit(1);
  }

  printf("Finished mapping everything\n");
  fflush(stdout);
  sleep(1);

  close(fd); // Can close fd now
}
