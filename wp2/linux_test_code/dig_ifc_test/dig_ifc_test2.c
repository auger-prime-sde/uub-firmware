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
  int ext_number, write_bit_number, read_bit_number, read_bits;
  int read_mask;
  bool OK = 1;

  // Get arguments
  if (argc < 4)
    {
      printf("Usage: dig_ifc_test2 ext_number(0/1) write_bit_number(0-7) read_bit_number\n");
      exit(1);
        }
  ext_number = atoi(argv[1]);
  write_bit_number = atoi(argv[2]);
  read_bit_number = atoi(argv[3]);

  // Map registers
  map_dig_ifc();

  // Check for sane IDs
  dig_ifc_id = read_dig_ifc(DIG_IFC_ID_ADDR);
  printf("dig_ifc_test2: dig_ifc_id=%x\n", dig_ifc_id);
  sleep(1);

   write_control = 1 << write_bit_number;
    if (ext_number == 0) write_control = write_control << 8;
    read_mask = 1 << read_bit_number;
    if (ext_number == 0) read_mask = read_mask << 8;

    // Set which bits are output
    status = write_dig_ifc(DIG_IFC_CONTROL_ADDR,write_control);
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,0);  // Set default to 0
    sleep(1);  // Wait to separate control register write from data write/read


  // Loop forever
  while (OK) {

     // Write 1
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,write_control);
    read_bits = read_dig_ifc(DIG_IFC_INPUT_ADDR);
    if ((read_bits & read_mask) == 0)
      {
      printf("Error: Wrote 1, read 0\n");
      sleep(2);
      }
    // Write 0
    status = write_dig_ifc(DIG_IFC_OUTPUT_ADDR,0);
    read_bits = read_dig_ifc(DIG_IFC_INPUT_ADDR);
    if ((read_bits & read_mask) != 0)
      {   
        printf("Error: Wrote 0, read 1\n");
        sleep(2);
      }
  }
  
}
