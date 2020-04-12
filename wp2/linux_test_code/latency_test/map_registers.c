// map_registers
//
// Map the firmware registers
//
// 03-Nov-2018 DFN Original version

#include "map_registers.h"
#include "sde_trigger.h"
#include "time_tagging.h"

void map_registers()
{
  int fd;
  int size, imem;

  shwr_mem_addr[0] = TRIGGER_MEMORY_SHWR0_BASE;
  shwr_mem_addr[1] = TRIGGER_MEMORY_SHWR1_BASE;
  shwr_mem_addr[2] = TRIGGER_MEMORY_SHWR2_BASE;
  shwr_mem_addr[3] = TRIGGER_MEMORY_SHWR3_BASE;
  shwr_mem_addr[4] = TRIGGER_MEMORY_SHWR4_BASE;
  shwr_mem_addr[5] = RD_EVENT_BASE;

  // Open register addresses for read/write

  fd = open("/dev/mem",O_RDWR);
  if (fd < 0){
    printf("Error - /dev/mem open to read/write registers failed\n");
    exit(1);
  }

  printf("map_registers: Mapping trig_regs TO %X\n", SDE_TRIGGER_BASE); 
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

  printf("map_registers: Mapping ttag_regs to %x\n", TIME_TAGGING_BASE); 
  ttag_regs=(u32 *)mmap(NULL, size,
  			     PROT_READ | PROT_WRITE, MAP_SHARED,
  			     fd,TIME_TAGGING_BASE);
  if (ttag_regs==MAP_FAILED){
    printf("Error - while trying to map time tagging registers\n");
    exit(1);
  }

  printf("map_registers: Mapping ifc_regs to %x\n", INTERFACE_UUB_BASE); 
   ifc_regs=(u32 *)mmap(NULL, size,
   			    PROT_READ | PROT_WRITE, MAP_SHARED,
   			    fd,INTERFACE_UUB_BASE);
   if (ifc_regs==MAP_FAILED){ 
     printf("Error - while trying to map interface dfn registers\n");
     exit(1);
   }


   printf("map_registers: Mapping tstctl_regs to %x\n", TEST_CONTROL_BASE); 
  tstctl_regs=(u32 *)mmap(NULL, size,
			    PROT_READ | PROT_WRITE, MAP_SHARED,
			    fd,TEST_CONTROL_BASE);
 if (tstctl_regs==MAP_FAILED){
   printf("Error - while trying to map test control registers\n");
   exit(1);
 }

 printf("map_registers: Mapping rd_regs to %x\n", RD_BASE); 
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

  printf("map_registers: Mapping shower memory\n"); 
  size = SHWR_MEM_DEPTH*SHWR_MEM_NBUF;
  for (imem=0; imem<6; imem++)
    {
      printf("Mapping shower memory %d at address %x\n",
             imem, shwr_mem_addr[imem]);
      shwr_mem_ptr[imem] = (u32)mmap(NULL, size,
  					    PROT_READ, MAP_SHARED,
  					    fd,shwr_mem_addr[imem]);
      if (shwr_mem_ptr[imem] == (u32)MAP_FAILED){
  	printf("Error - while trying to map shower memory %d\n", imem);
  	exit(1);
      }
    }

  printf("Finished mapping everything\n");
  fflush(stdout);
  sleep(1);

  close(fd); // Can close fd now
}
