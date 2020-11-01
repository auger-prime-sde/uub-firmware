// map_registers
//
// Map the firmware registers
//
// 06-Feb-2017 DFN Original version based upon test0.c from Ricardo Sato

#include "trigger_test_options.h"
#include "trigger_test.h"

void map_registers()
{
  int fd;
  int size, imem;
  int i;

  shwr_mem_addr[0] = TRIGGER_MEMORY_SHWR0_BASE;
  shwr_mem_addr[1] = TRIGGER_MEMORY_SHWR1_BASE;
  shwr_mem_addr[2] = TRIGGER_MEMORY_SHWR2_BASE;
  shwr_mem_addr[3] = TRIGGER_MEMORY_SHWR3_BASE;
  shwr_mem_addr[4] = TRIGGER_MEMORY_SHWR4_BASE;
 
  muon_mem_addr[0] = TRIGGER_MEMORY_MUON0_BASE;
  muon_mem_addr[1] = TRIGGER_MEMORY_MUON1_BASE;

  fake_event_addr[0] = FAKE_EVENT0_BASE;
  fake_event_addr[1] = FAKE_EVENT1_BASE;

#ifdef STAND_ALONE
  for (imem=0; imem<5; imem++)
    shwr_mem_ptr[imem] = shwr_mem_addr[imem];
  for (imem=0; imem<2; imem++)
    muon_mem_ptr[imem] = muon_mem_addr[imem];
  for (imem=0; imem<2; imem++)
    fake_event_ptr[imem] = fake_event_addr[imem];

#else
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

  // This seems to have some conflict on linux.  Map disappers after
  // a short while.  14-Feb-2017 Seems to be OK now; not sure why.
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

 printf("trig_regs=%x ttag_regs=%x ifc_regs=%x tstctl_regs=%x\n", 
	(int) trig_regs, (int) ttag_regs, (int) ifc_regs, (int) tstctl_regs);
   
   printf("Finished mapping registers\n");

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

  size = MUON_MEM_DEPTH*MUON_MEM_NBUF;
  for (imem=0; imem<5; imem++)
    {
      muon_mem_ptr[imem] = (u32)mmap(NULL, size,
  					    PROT_READ, MAP_SHARED,
  					    fd,muon_mem_addr[imem]);
      if (muon_mem_ptr[imem] == (u32)MAP_FAILED){
  	printf("Error - while trying to map muon memory %d\n", imem);
  	exit(1);
      }
    }

  size = SHWR_MEM_DEPTH;
  for (imem=0; imem<2; imem++)
    {
      fake_event_ptr[imem] = (u32)mmap(NULL, size,
  					    PROT_WRITE|PROT_READ, MAP_SHARED,
  					    fd,fake_event_addr[imem]);
      if (fake_event_ptr[imem] == (u32)MAP_FAILED){
  	printf("Error - while trying to map fake event memory %d\n", imem);
  	exit(1);
      }
    }

  printf("Finished mapping shower/muon/fake-event buffers\n");
  close(fd); // Can close fd now
#endif
}
