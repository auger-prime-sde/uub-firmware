// scaler_test

// Test program for scalers

// 12-Apr-2019 DFN Original version

#include "scaler_test.h"
#include "string.h"

#define PRINT_INTERVAL 1000
#define RESET_INTERVAL 2000

volatile u32 *trig_regs;
volatile u32 *ttag_regs;
volatile u32 *ifc_regs;
volatile u32 *tstctl_regs;

int main()
{
  int i, status;
  int nerrors = 0;
  int scaler_a_count, scaler_b_count, scaler_c_count;
  int scaler_a_prev, scaler_b_prev, scaler_c_prev;
  int scaler_a_print, scaler_b_print, scaler_c_print;
  int trig_id;

  // Map registers
    printf("Calling map_scaler\n");
  map_scaler();
    printf("Return from map_scaler\n");
  sleep(1);

  // Select fake or true GPS for 1pps
  int test_options = 0;
#ifdef USE_FAKE_GPS
  test_options = 1<<USE_FAKE_PPS_BIT;
#endif
#ifdef USE_FAKE_SIGNAL
  test_options = test_options | (1<< USE_FAKE_SHWR_BIT);
#endif

  if (test_options != 0)
    {
      write_tstctl(USE_FAKE_ADDR, test_options);
      status = read_tstctl(USE_FAKE_ADDR);
      if (status != test_options) 
	printf("Scaler_test: Error setting test options, wrote %x read %x\n",
	       test_options, status);

      write_tstctl(1, 0);  // Mode=0 is used as RESET
      write_tstctl(1, FAKE_SIGNAL_MODE);
      status = read_tstctl(1);
      if (status != FAKE_SIGNAL_MODE)
	printf("Scaler_test: Error setting test mode, wrote %x read %x\n",
	       FAKE_SIGNAL_MODE, status);
    }


 // Check for sane IDs
  trig_id = read_trig(ID_REG_ADDR);
  printf("Scaler_test: trigger id=%x\n",trig_id);
  sleep(3);

  // Reset trigger
  write_trig(COMPATIBILITY_GLOBAL_CONTROL_ADDR,1);
  write_trig(COMPATIBILITY_GLOBAL_CONTROL_ADDR,0);

  // Disable all shower triggers
  write_trig(SHWR_BUF_TRIG_MASK_ADDR,0);
  status = read_trig(SHWR_BUF_TRIG_MASK_ADDR);
  if (status != 0) printf("Scaler_test: Error reading TRIG_MASK %x\n",status);

  config_scaler();  // Configure scalers

  scaler_a_print = 0;
  scaler_b_print = 0;
  scaler_c_print = 0;
  scaler_a_prev = 0;
  scaler_b_prev = 0;
  scaler_c_prev = 0;
  scaler_a_count = 0;
  scaler_b_count = 0;
  scaler_c_count = 0;

   // Loop forever
  int nloop = 0;
  while (1) {

    // Read scalers

#ifdef ENABLE_SCALER_A
    scaler_a_prev = scaler_a_count;
    scaler_a_count = read_trig(COMPATIBILITY_SCALER_A_COUNT_ADDR);
    if (scaler_a_count < scaler_a_prev)
      printf("Scaler_test: Error scaler_a_prev=%d  scaler_a_count=%d\n",
             scaler_a_prev, scaler_a_count);
    if (scaler_a_count - scaler_a_print >= PRINT_INTERVAL)
      {
        printf("Scaler_test: scaler_a_count=%d  prev_print=%d\n",
               scaler_a_count, scaler_a_print);
        scaler_a_print = scaler_a_count;
        if (scaler_a_count >= RESET_INTERVAL)
          { 
          write_trig(COMPATIBILITY_SCALER_A_COUNT_ADDR,1);
          scaler_a_prev = 0;
          scaler_a_count = 0;
          scaler_a_print = 0;
          }
      }
#endif

#ifdef ENABLE_SCALER_B
    scaler_b_prev = scaler_b_count;
    scaler_b_count = read_trig(COMPATIBILITY_SCALER_B_COUNT_ADDR);
    if (scaler_b_count < scaler_b_prev)
      printf("Scaler_test: Error scaler_b_prev=%d  scaler_b_count=%d\n",
             scaler_b_prev, scaler_b_count);
    if (scaler_b_count - scaler_b_print >= PRINT_INTERVAL)
      {
        printf("Scaler_test: scaler_b_count=%d  prev_print=%d\n",
               scaler_b_count, scaler_b_print);
        scaler_b_print = scaler_b_count;
        if (scaler_b_count >= RESET_INTERVAL) 
          {
            write_trig(COMPATIBILITY_SCALER_B_COUNT_ADDR,1);
            scaler_b_prev = 0;
            scaler_b_count = 0;
            scaler_b_print = 0;
          }
      }
#endif

#ifdef ENABLE_SCALER_C
    scaler_c_prev = scaler_c_count;
    scaler_c_count = read_trig(COMPATIBILITY_SCALER_C_COUNT_ADDR);
    if (scaler_c_count < scaler_c_prev)
      printf("Scaler_test: Error scaler_c_prev=%d  scaler_c_count=%d\n",
             scaler_c_prev, scaler_c_count);
    if (scaler_c_count - scaler_c_print >= PRINT_INTERVAL)
      {
        printf("Scaler_test: scaler_c_count=%d  prev_print=%d\n",
               scaler_c_count, scaler_c_print);
        scaler_c_print = scaler_c_count;
        if (scaler_c_count >= RESET_INTERVAL)
          { 
            write_trig(COMPATIBILITY_SCALER_C_COUNT_ADDR,1);
            scaler_c_prev = 0;
            scaler_c_count = 0;
            scaler_c_print = 0;
          }
      }
#endif

    write_ifc(2, 1);  // Set P65
    write_ifc(2, 0);  // Clear P65

    nloop++;
    //    if (nloop % 100000 == 0)
    //   printf("Scaler test: nloop=%d scaler_a_count=%d\n", 
    //          nloop, scaler_a_count);

  }
  
}
