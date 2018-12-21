// linux_rd_test

// Test program for rd interface

// 03-Nov-2018 DFN New original version

#include "rd_test.h"

volatile u32 *rd_regs;

volatile u32 rd_mem_ptr[1];
volatile u32 fake_rd_mem_ptr[1];
u32 rd_mem_addr[1];
u32 fake_rd_mem_addr[1];

// Mmemory buffers
u32 rd_mem[RD_MEM_NBUF][RD_MEM_WORDS] __attribute__((aligned(128)));
u32 fake_rd_mem[RD_MEM_NBUF][RD_MEM_WORDS] __attribute__((aligned(128)));

u32 *mem_addr, *mem_ptr;


int main()
{
  int fake_rd_data;
  int i, loop, status;
  int xfr_done;

  // Map registers & memory buffers
  map_rd();
  sleep(1);

  for (loop=0; loop<1000000; loop++)
    {
      // Load rd data into memory
      //printf("Loading fake data into memory\n");
      //fflush(stdout);
      mem_ptr = (u32*) fake_rd_mem_ptr[0];
      fake_rd_data = 0;
      for (i=0; i<RD_MEM_WORDS; i++)
        {
          fake_rd_data = rand();
          // fake_rd_data = 0x1f3c;
          mem_ptr[i] = fake_rd_data & 0x1fff;
          fake_rd_mem[0][i] = fake_rd_data & 0x1fff;
        }
      //printf("Finished loading fake data\n");
      //fflush(stdout);
      //      sleep(1);
 
      // Check data is written OK.
      /* for (i=0; i<RD_MEM_WORDS; i++) */
      /*    { */
      /*      printf("Fake event: i=%d  fake_rd_data=%x %x\n", */
      /*             i,  fake_rd_mem[0][i], mem_ptr[i]); */
      /*      fflush(stdout); */
      /*    } */

      // Do a fake transfer
      // Register usage: 
      //   Reg0 bit0 == ACK transfer done (set then reset)
      //   Reg0 bit1 == Start data transfer (set then reset)
      //   Reg1 bit0 == Transfer complete (read only)

      // Reset any previous transfer
      write_rd(0,1); // Tell module transfer is complete
      status = read_rd(0);
      if (status != 1) 
        printf("Error writing rd_interface, wrote %x read %x\n", 1, status);
      write_rd(0,0);
      status = read_rd(0);
      if (status != 0) 
        printf("Error writing rd_interface, wrote %x read %x\n", 0, status);

      //printf("Starting data transfer\n");
      //fflush(stdout);
      //      sleep(1);
      write_rd(0, 2);  // Tell module to start transfer
      status = read_rd(0);
      if (status != 2) 
        printf("Error writing rd_interface, wrote %x read %x\n", 2, status);
      write_rd(0, 0);  
      status = read_rd(0);
      if (status != 0) 
        printf("Error writing rd_interface, wrote %x read %x\n", 0, status);
      //printf("Waiting for transfer to complete\n");
      //fflush(stdout);
      xfr_done = 0;
      while (xfr_done == 0)  // Wait for transfer to complete
        {
        xfr_done = read_rd(1); 
        // printf("xfr_done = %x\n",xfr_done);
        // sleep(1);
          }
      write_rd(0,1); // Tell module transfer is complete
      status = read_rd(0);
      if (status != 1) 
        printf("Error writing rd_interface, wrote %x read %x\n", 1, status);
      write_rd(0,0);
      status = read_rd(0);
      if (status != 0) 
        printf("Error writing rd_interface, wrote %x read %x\n", 0, status);
      //printf("Finished data transfer\n");
      //fflush(stdout);
      // sleep(1);

      // Load received rd data into memory
      //printf("Reading data from memory\n");
      //fflush(stdout);
      // sleep(1);
      mem_ptr = (u32*) rd_mem_ptr[0];
      for (i=0; i<RD_MEM_WORDS; i++)
        {
          rd_mem[0][i] = mem_ptr[i];
        }
      //printf("Finished reading data from memory\n");
      //fflush(stdout);

      // Compare what was sent to what was received
// Starting at 1 is temporary kludge to compensate for 1 word offset
      for (i=1; i<RD_MEM_WORDS; i++)  
      //   for (i=0; i<RD_MEM_WORDS; i++)
        {
          //              if (fake_rd_mem[0][i] != rd_mem[0][i])
          if (fake_rd_mem[0][i-1] != rd_mem[0][i])
            {
              printf("Error: i=%d  fake_rd_data=%x %x\n",
                     i-1,  fake_rd_mem[0][i-1], rd_mem[0][i]);
              //                     i,  fake_rd_mem[0][i], rd_mem[0][i]);
              fflush(stdout);
              printf("Transfer error after %d buffer transfers\n", loop);
              sleep(10);
            }
        }
      if (loop%100 == 0) printf("Finished %d buffer transfers\n", loop);
    }
    
}
