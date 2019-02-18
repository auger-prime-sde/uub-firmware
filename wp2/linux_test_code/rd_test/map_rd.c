// map_rd
//
// Map the firmware registers
//
// 03-Nov-2018 DFN Original version

#include "rd_test.h"
#include "sde_trigger.h"
#include "time_tagging.h"

void map_rd()
{
  int fd;
  int size, imem;
  int i;

  shwr_mem_addr[0] = TRIGGER_MEMORY_SHWR0_BASE;
  shwr_mem_addr[1] = TRIGGER_MEMORY_SHWR1_BASE;
  shwr_mem_addr[2] = TRIGGER_MEMORY_SHWR2_BASE;
  shwr_mem_addr[3] = TRIGGER_MEMORY_SHWR3_BASE;
  shwr_mem_addr[4] = TRIGGER_MEMORY_SHWR4_BASE;
  rd_mem_addr[0] = RD_EVENT_BASE;

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
  trig_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,SDE_TRIGGER_BASE);
  if (trig_regs==MAP_FAILED){
    printf("Error - while trying to map trigger registers\n");
    exit(1);
  }

  ttag_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,TIME_TAGGING_BASE);
  if (ttag_regs==MAP_FAILED){
    printf("Error - while trying to map time tagging registers\n");
    exit(1);
  }

   ifc_regs=(u32 *)mmap(NULL, size,
   			    PROT_READ | PROT_WRITE, MAP_SHARED,
   			    fd,INTERFACE_UUB_BASE);
   if (ifc_regs==MAP_FAILED){ 
     printf("Error - while trying to map interface dfn registers\n");
     exit(1);
   }

 tstctl_regs=(u32 *)mmap(NULL, size,
			    PROT_READ | PROT_WRITE, MAP_SHARED,
			    fd,TEST_CONTROL_BASE);
 if (tstctl_regs==MAP_FAILED){
   printf("Error - while trying to map test control registers\n");
   exit(1);
 }

   rd_regs=(u32 *)mmap(NULL, size,
                      PROT_READ | PROT_WRITE, MAP_SHARED,
                      fd, RD_BASE);
  if (rd_regs==MAP_FAILED){
    printf("Error - while trying to map rd registers\n");
    exit(1);
  }

  printf("Finished mapping rd registers\n");
  fflush(stdout);
  sleep(1);

  // Now map shared memory buffers

  size = SHWR_MEM_DEPTH*SHWR_MEM_NBUF;
  for (imem=0; imem<5; imem++)
    {
      shwr_mem_ptr[imem] = (u32)mmap(NULL, size,
  					    PROT_READ, MAP_SHARED,
  					    fd,shwr_mem_addr[imem]);
      if (shwr_mem_ptr[imem] == (u32)MAP_FAILED){
  	printf("Error - while trying to map shower memory %d\n", imem);
  	exit(1);
      }
    }

  size =RD_MEM_DEPTH*RD_MEM_NBUF;
  rd_mem_ptr[0] = (u32)mmap(NULL, size,
                               PROT_WRITE|PROT_READ, MAP_SHARED,
                               fd,rd_mem_addr[0]);
  if (rd_mem_ptr[0] == (u32)MAP_FAILED){
    printf("Error - while trying to map rd memory %d\n", 0);
    exit(1);
  }

  printf("Finished mapping fake rd buffers\n");
  fflush(stdout);
  sleep(1);

  close(fd); // Can close fd now
}
