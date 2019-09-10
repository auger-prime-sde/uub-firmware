// dig_ifc_test2

// Test program for digital interface

// 25-Mar-2019 DFN New original version
// 05-Sep-2019 DFN Modified version of original which just toggles one specified
//                 driver output

#include "dig_ifc_test.h"
#include "string.h"

volatile u32 *dig_ifc_regs;


int main(int argc, char*argv[])
{
  int status;
  int write_control;
  int dig_ifc_id;
  int ext_number, bit_number;
  bool OK = 1;

  // Get arguments
  if (argc < 3)
    {
      printf("Usage: dig_ifc_test2 ext_number(0/1) bit_number(0-7)\n");
      exit(1);
        }
  ext_number = atoi(argv[1]);
  bit_number = atoi(argv[2]);

  // Map registers
  map_dig_ifc();

  // Check for sane IDs
  dig_ifc_id = read_dig_ifc(DIG_IFC_ID_ADDR);
  printf("dig_ifc_test2: dig_ifc_id=%x\n", dig_ifc_id);
  sleep(5);



  // Loop forever
  while (OK) {

    // Set which bits are output
    write_control = 1 << bit_number;
    if (ext_number == 0) write_control = write_control << 8;
    status = write_dig_ifc(DIG_IFC_CONTROL_ADDR,write_control);

    // Write 1
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,write_control);
    // Write 0
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,0);
  }
  
}
