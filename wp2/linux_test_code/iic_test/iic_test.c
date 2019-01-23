// linux_iic_test

// Test program for iic interface

// 17-Jan-2019 DFN New original version

#include "iic_test.h"

volatile u32 *iic_regs;

int main()
{
 
  int i, loop, status;
  int xfr_done;

  // Map registers
  map_iic();
  sleep(1);

  for (loop=0; loop<5; loop++)
    {
      status = write_iic(0x100/4,0x1); // Enable IIC
      status = write_iic(0x100/4,0x2); // Reset TX Fifo
      status = write_iic(0x100/4,0xC); // Master & TX mode

      status = read_iic(0x104/4);  // Read status register
      printf("initial iic status reg = %x\n");
      status = write_iic(0x40/4,0xA); // Try soft reset
      sleep(1); 
      status = write_iic(0x108/4,0x1D8);
      status = read_iic(0x104/4);  // Read status register
      printf("iic status reg after 1st TX_FIFO write = %x\n");
      status = write_iic(0x108/4,0x212);
      status = read_iic(0x104/4);  // Read status register
      printf("iic status reg after 2nd TX_FIFO write = %x\n");
}

}
