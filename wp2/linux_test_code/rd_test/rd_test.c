// linux_rd_test

// Test program for rd interface

// 03-Nov-2018 DFN New original version
// 15-Feb-2019 DFN Modified for use with real RD interface

#include "rd_test.h"
#include "string.h"

volatile u32 *rd_regs;
volatile u32 *trig_regs;
volatile u32 *ttag_regs;
volatile u32 *ifc_regs;
volatile u32 *tstctl_regs;

volatile u32 rd_mem_ptr[1];
volatile u32 shwr_mem_ptr[5];
u32 shwr_mem_addr[5];
u32 rd_mem_addr[1];

// Mmemory buffers
#ifdef SPACER
u32 spacer[1] __attribute__((aligned(128)));
u32 rd_mem[MAX_EVENTS][RD_MEM_WORDS];
#else
u32 rd_mem[MAX_EVENTS][RD_MEM_WORDS] __attribute__((aligned(128)));
#endif
u32 shw_mem0[MAX_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem1[MAX_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem2[MAX_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem3[MAX_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem4[MAX_EVENTS][SHWR_MEM_WORDS];
u32 *mem_addr, *mem_ptr;

int buf_start_offset[MAX_EVENTS];
int buf_num[MAX_EVENTS];
int buf_latency[MAX_EVENTS];
double buf_dt[MAX_EVENTS];
u32 buf_rd_status[MAX_EVENTS];

int main(int argc, char ** argv)
{
  int fake_rd_data;
  int i, status;
  int xfr_done;
  int cur_shwr_buf_num = 0;
  int full_shwr_bufs = 0;
  int toread_shwr_buf_num;
  int cur_muon_buf_num = 0;
  int toread_rd_buf_num;
  int cur_rd_buf_num = 0;
  int full_rd_bufs = 0;
  int busy_rd_bufs = 0;
  int cntrl_word = 0;
  int num_full;
  int shwr_status, rd_status;
  int trig_id, rd_id;
  int parity0, parity1;
  int buf_timeout;
  int read0, read1;
  int expected0, expected1;
  int nerrors = 0;
  int latency;
  int nevents = 0;
  int trigger_mask;
  int seconds, tics, delta_tics, pps_tics;
  double time, dt, prev_time;
  int mode;

 if (argc != 2)
    {
      printf("Usage: rd_test n (n=0 rd, n=1 fake rd & no xfr clk, n=2 fake rd & xfr)\n");
      exit(0);
    } 

  i = 1;
  mode = atoi(argv[i++]);


  // Map registers & memory buffers
    printf("Calling map_rd\n");
  map_rd();
    printf("Return from map_rd\n");
  sleep(1);

  // Select fake or true GPS for 1pps
  int test_options = 0;
  printf("Using options: ");
#ifdef USE_FAKE_GPS
  test_options = 1<<USE_FAKE_PPS_BIT;
  printf(" Fake GPS");
#endif

  // Select normal TRIG_OUT or pattern
#ifdef USE_TRIG_OUT_PATTERN
  test_options = test_options | (1<<TRIG_OUT_PATTERN_BIT);
  printf(", Trig out pattern");
#endif

  // Select fake or true signals
#ifdef USE_FAKE_SIGNAL
  test_options = test_options | (1<< USE_FAKE_SHWR_BIT);
  printf(", Fake signal");
#endif
  if (mode >= 1)
    {
    test_options = test_options | (1<<USE_FAKE_RD_BIT);
    printf(", Fake RD");
    }
  if (mode >= 2)
    {
    test_options = test_options | (1<<USE_FAKE_RDCLK_BIT);
    printf(", Fake RD XFR clk");
    }
  printf("\n");

  write_tstctl(USE_FAKE_ADDR, 0);
  if (test_options != 0)
    {
      write_tstctl(USE_FAKE_ADDR, test_options);
      status = read_tstctl(USE_FAKE_ADDR);
      if (status != test_options) 
	printf("Error setting test options, wrote %x read %x\n",
	       test_options, status);
    }


 // Check for sane IDs
  trig_id = read_trig(ID_REG_ADDR);
  rd_id = read_rd(RD_IFC_ID_ADDR);
  printf("trigger id=%x   rd id=%x\n",trig_id, rd_id);

  // Reset trigger
  write_trig(COMPATIBILITY_GLOBAL_CONTROL_ADDR,1);

  // Reset RD interface
  write_rd(RD_IFC_RESET_ADDR, 1);
  write_rd(RD_IFC_RESET_ADDR, 0);

  // Disable all shower triggers
  write_trig(SHWR_BUF_TRIG_MASK_ADDR,0);
  status = read_trig(SHWR_BUF_TRIG_MASK_ADDR);
  if (status != 0) printf("Error reading TRIG_MASK %x\n",status);
  config_trigger();  // Configure triggers

  // Could we have garbage events in buffers?  Should not, but flush anyway.
  // It seems at least the first RD event is a bit corrupt.
   for (i=0; i<3; i++)
     {
   shwr_status = read_trig(SHWR_BUF_STATUS_ADDR);
   if ((SHWR_INTR_PEND_MASK & (shwr_status >> SHWR_INTR_PEND_SHIFT)) != 0)
     {
      toread_shwr_buf_num = SHWR_BUF_RNUM_MASK & 
         (shwr_status >> SHWR_BUF_RNUM_SHIFT);
       write_rd(RD_IFC_CONTROL_ADDR, toread_shwr_buf_num);
       write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);
     }
   }

   // Loop until MAX_EVENTS
  while (nevents < MAX_EVENTS) {

    // Check if we have a trigger
    shwr_status = read_trig(SHWR_BUF_STATUS_ADDR);
    if ((SHWR_INTR_PEND_MASK & (shwr_status >> SHWR_INTR_PEND_SHIFT)) != 0)
      {
         // Which shower memory buffer to read, and which are full
        toread_shwr_buf_num = SHWR_BUF_RNUM_MASK & 
          (shwr_status >> SHWR_BUF_RNUM_SHIFT);
        cur_shwr_buf_num = SHWR_BUF_WNUM_MASK & 
          (shwr_status >> SHWR_BUF_WNUM_SHIFT);
        full_shwr_bufs = SHWR_BUF_FULL_MASK & 
          (shwr_status >> SHWR_BUF_FULL_SHIFT);
        num_full = 0x7 & (shwr_status >> SHWR_BUF_NFULL_SHIFT);

        // Read Shower buffers

        mem_addr = (u32*) shwr_mem_ptr[0];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem0[nevents][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[1];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem1[nevents][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[2];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem2[nevents][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[3];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem3[nevents][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[4];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem4[nevents][0],mem_addr,4*SHWR_MEM_WORDS);

        // We should be able to reset the shower memory buffers now if we
        // save the rd buffer number to read beforehand.  Note that the 
        // toread buf num in the RD status register will cease to be valid
        // after the shower buffers are reset.
        toread_rd_buf_num = toread_shwr_buf_num;
        write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);

         // This will be invalid if have already reset shower buffers
         //        toread_rd_buf_num = RD_BUF_RNUM_MASK & 
         // (rd_status >> RD_BUF_RNUM_SHIFT);

        // Wait for transfer from RD to FPGA to finish
        do
          { 
            rd_status = read_rd(RD_IFC_STATUS_ADDR);
            busy_rd_bufs = RD_BUF_BUSY_MASK &
              (rd_status >> RD_BUF_BUSY_SHIFT);
          }
        while ((busy_rd_bufs & (1 << toread_rd_buf_num)) != 0);

        cur_rd_buf_num = RD_BUF_WNUM_MASK & 
          (rd_status >> RD_BUF_WNUM_SHIFT);
        full_rd_bufs = RD_BUF_FULL_MASK & 
          (rd_status >> RD_BUF_FULL_SHIFT);
        busy_rd_bufs = RD_BUF_BUSY_MASK &
          (rd_status >> RD_BUF_BUSY_SHIFT);
        parity0 = (1 << toread_rd_buf_num) &
          (rd_status >> RD_PARITY0_SHIFT);
        parity1 =  (1 << toread_rd_buf_num) &
          (rd_status >> RD_PARITY1_SHIFT);
        if ((parity0 != 0) || (parity1 != 0))
          printf("Event %d Parity Error\n", nevents);
        buf_timeout = (1 << toread_rd_buf_num) &
          (rd_status >> RD_BUF_TIMEOUT_SHIFT);
        if (buf_timeout != 0) 
          printf("Event %d RD buffer timeout\n", nevents);

        // Read RD buffer
        if ((full_rd_bufs & (1 << toread_rd_buf_num)) != 0)
           {
            mem_addr = (u32*) rd_mem_ptr[0];
            mem_addr = mem_addr + toread_rd_buf_num * RD_MEM_WORDS;
            mem_ptr = mem_addr;
            memcpy(&rd_mem[nevents][0],mem_addr,4*RD_MEM_WORDS);
          }

        // Get latency
        latency = read_trig(SHWR_BUF_LATENCY_ADDR);

        // Get event trigger time
        // Does not yet account for rollover of seconds
        pps_tics = read_ttag(TTAG_SHWR_PPS_TICS_ADDR);
        seconds = read_ttag(TTAG_SHWR_SECONDS_ADDR);
        tics = read_ttag(TTAG_SHWR_TICS_ADDR);
        pps_tics = pps_tics & TTAG_TICS_MASK;
        seconds = seconds & TTAG_SECONDS_MASK;
        tics = tics & TTAG_TICS_MASK;
        delta_tics = tics-pps_tics;
        if (delta_tics < 0) delta_tics = delta_tics + TTAG_TICS_MASK +1;
        time = (double) seconds + 8.3333 * (double) delta_tics / 1.e9;
        dt = time - prev_time;
        prev_time = time;

        // Save the information for this event
        buf_start_offset[nevents] = read_trig(SHWR_BUF_START_ADDR);
        buf_num[nevents] = toread_shwr_buf_num;
        buf_latency[nevents] = latency;
        buf_dt[nevents] = dt;
        buf_rd_status[nevents]= rd_status;

        // Mark buffers as read
        write_rd(RD_IFC_CONTROL_ADDR, toread_rd_buf_num);
        //        write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);
        nevents++;
      }
  }
  print_events();
  
}
