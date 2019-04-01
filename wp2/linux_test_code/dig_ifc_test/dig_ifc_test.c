// linux_dig_ifc_test

// Test program for digital interface

// 25-Mar DFN New original version

#include "dig_ifc_test.h"
#include "string.h"

volatile u32 *dig_ifc_regs;


int main()
{
  int i, status;
  int xfr_done;
  int read0, read1;
  int write0, write1;
  int writec, readc;
  int expected0, expected1;
  int dig_ifc_id;
  int nerrors = 0;
  bool OK;

  // Map registers
    printf("Calling map_dig_ifc\n");
  map_dig_ifc();
    printf("Return from map_dig_ifc\n");
  sleep(1);

 // Check for sane IDs
  dig_ifc_id = read_dig_ifc(DIG_IFC_ID_ADDR);
  printf("dig_ifc_test: dig_ifc_id=%x\n", dig_ifc_id);
  sleep(5);


   // Loop forever
  int nevents = 0;
  while (nevents < MAX_EVENTS) {
    nevents++;
    printf("Starting event %d\n", nevents);

    // Set which bits are output
    writec = CTL_SET0 | (CTL_SET0 <<8) | 0x10000;
    status = write_dig_ifc(DIG_IFC_CONTROL_ADDR,writec);
    readc = read_dig_ifc(DIG_IFC_CONTROL_ADDR);

    // Set which bits are 1
    write1 = CTL_SET0 | (CTL_SET0 <<8);
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,write1);
    read1 = read_dig_ifc(DIG_IFC_OUTPUT_ADDR);

    // Read values that are supposed to be looped back
    read0 = read_dig_ifc(DIG_IFC_INPUT_ADDR);

        OK = ( ((read0 >> 6) & 1) == ((write1 >> 1) & 1)
           && ((read0 >> 7) & 1) == ((write1 >> 0) & 1)
           && ((read0 >> 5) & 1) == ((write1 >> 2) & 1) );
     if (!OK)
      printf("Error: Event=%d   CTL=%x %x  WROTE=%x %x  READ=%x\n", 
             nevents , writec, readc, write1, read1, read0);

    // Now send all 0
    write1 = 0;
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,write1);
    read1 = read_dig_ifc(DIG_IFC_OUTPUT_ADDR);

    // Read values that are supposed to be looped back
    read0 = read_dig_ifc(DIG_IFC_INPUT_ADDR);

     OK = ( ((read0 >> 6) & 1) == ((write1 >> 1) & 1)
           && ((read0 >> 7) & 1) == ((write1 >> 0) & 1)
           && ((read0 >> 5) & 1) == ((write1 >> 2) & 1) );
    if (!OK)
      printf("Error: Event=%d   CTL=%x %x  WROTE=%x %x  READ=%x\n", 
             nevents , writec, readc, write1, read1, read0);

    // Set which bits are output -- flip order from above
    writec = CTL_SET1 | (CTL_SET1 <<8) | 0x10000;
    status = write_dig_ifc(DIG_IFC_CONTROL_ADDR,writec);
    readc = read_dig_ifc(DIG_IFC_CONTROL_ADDR);

    // Set which bits are 1
    write1 = CTL_SET1 | (CTL_SET1 << 8);
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,write1);
    read1 = read_dig_ifc(DIG_IFC_OUTPUT_ADDR);

    // Read values that are supposed to be looped back
    read0 = read_dig_ifc(DIG_IFC_INPUT_ADDR);

    OK = ( ((write1 >> 6) & 1) == ((read0 >> 1) & 1)
           && ((write1 >> 7) & 1) == ((read0 >> 0) & 1)
           && ((write1 >> 5) & 1) == ((read0 >> 2) & 1) );
     if (!OK)
      printf("Error: Event=%d   CTL=%x %x  WROTE=%x %x  READ=%x\n", 
             nevents , writec, readc, write1, read1, read0);

    // Now send all 0
    write1 = 0;
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,write1);
    read1 = read_dig_ifc(DIG_IFC_OUTPUT_ADDR);

    // Read values that are supposed to be looped back
    read0 = read_dig_ifc(DIG_IFC_INPUT_ADDR);

    OK = ( ((write1 >> 6) & 1) == ((read0 >> 1) & 1)
           && ((write1 >> 7) & 1) == ((read0 >> 0) & 1)
           && ((write1 >> 5) & 1) == ((read0 >> 2) & 1) );
    if (!OK)
      printf("Error: Event=%d   CTL=%x %x  WROTE=%x %x  READ=%x\n", 
             nevents , writec, readc, write1, read1, read0);
      sleep(10);
  }
  
}
