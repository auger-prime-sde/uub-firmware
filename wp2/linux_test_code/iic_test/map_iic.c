// map_iic
//
// Map the firmware registers
//
// 03-Nov-2018 DFN Original version

#include "iic_test.h"

void map_iic()
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
  iic_regs=(u32 *)mmap(NULL, size,
                      PROT_READ | PROT_WRITE, MAP_SHARED,
                      fd, IIC_BASE);
  if (iic_regs==MAP_FAILED){
    printf("Error - while trying to map iic registers\n");
    exit(1);
  }

  printf("Finished mapping iic registers\n");
  fflush(stdout);
  sleep(1);

  close(fd); // Can close fd now
}
