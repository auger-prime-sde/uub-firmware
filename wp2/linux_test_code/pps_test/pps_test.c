// linux_pps_test

// Test program for pps interrupt module

// 23-Feb-2019 DFN Original verison

#include "pps_test.h"

volatile u32 *ttag_intr_regs;
volatile u32 *tstctl_regs;
volatile u32 *trig_regs;


int main()
{
  int nevents;
  int status;
  int intr_status, intr_pending;
  int id, i;

  // Map registers
  printf("Calling map_ttag\n");
  map_ttag();
  printf("Return from map_ttag\n");
  sleep(1);

  // Select fake or true GPS for 1pps
  int test_options = 0;
#ifdef USE_FAKE_GPS
  test_options = 1<<USE_FAKE_PPS_BIT;
#endif
  if (test_options != 0)
    {
      write_tstctl(USE_FAKE_ADDR, test_options);
      status = read_tstctl(USE_FAKE_ADDR);
      if (status != test_options) 
	printf("ttag_test: Error setting test options, wrote %x read %x\n",
	       test_options, status);
    }


  // Check for sane ID
  id = read_trig(ID_REG_ADDR);
  printf("ttag_test: id=%x\n",id);


  // Loop through some events
  nevents = 0;

  // First monitor register without interrupt enabled
  while (nevents < MAX_EVENTS) {

    // Check if we have a PPS signal
    intr_status = read_ttag_intr(2);
    intr_pending = read_ttag_intr(4);
    if (intr_status != 0)
      {
        nevents++;
        printf("\npps_test: intr_status=%d  intr_pending=%d\n",
               intr_status, intr_pending);
        write_ttag_intr(3,1);  // Acknowledge PPS
        intr_status = read_ttag_intr(2);
        intr_pending = read_ttag_intr(4);
        printf("pps_test: intr_status=%d  intr_pending=%d\n",
               intr_status, intr_pending);
      }
  }

  // Now enable PPS interrupt
  printf("Enabling PPS interrupt\n");
  write_ttag_intr(1,1);

  nevents = 0;
  while (nevents < MAX_EVENTS) {

    // Check if we have a PPS signal
    intr_status = read_ttag_intr(2);
    intr_pending = read_ttag_intr(4);
    if (intr_status != 0)
      {
        nevents++;
        printf("\npps_test: intr_status=%d  intr_pending=%d\n",
               intr_status, intr_pending);
        write_ttag_intr(3,1);  // Acknowledge PPS
        intr_status = read_ttag_intr(2);
        intr_pending = read_ttag_intr(4);
        printf("pps_test: intr_status=%d  intr_pending=%d\n",
               intr_status, intr_pending);
      }
  }

  // Now enable Global PPS interrupt
  printf("Enabling Global PPS interrupt\n");
  write_ttag_intr(0,1);

  nevents = 0;
  while (nevents < MAX_EVENTS) {

    // Check if we have a PPS signal
    intr_status = read_ttag_intr(2);
    intr_pending = read_ttag_intr(4);
    if (intr_status != 0)
      {
        nevents++;
        printf("\npps_test: intr_status=%d  intr_pending=%d\n",
               intr_status, intr_pending);
        write_ttag_intr(3,1);  // Acknowledge PPS
        intr_status = read_ttag_intr(2);
        intr_pending = read_ttag_intr(4);
        printf("pps_test: intr_status=%d  intr_pending=%d\n",
               intr_status, intr_pending);
      }
  
  }
}
