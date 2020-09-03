// linux_rd_test

// Test program for buffer read latency

// 07-Apr-2020 DFN New original version

#include "latency_test.h"
#include "string.h"
#include <sched.h>

volatile u32 *rd_regs;
volatile u32 *trig_regs;
volatile u32 *ttag_regs;
volatile u32 *ifc_regs;
volatile u32 *tstctl_regs;

volatile u32 shwr_mem_ptr[6];
u32 shwr_mem_addr[6];

// Mmemory buffers
u32 buf_mem[6][MAX_EVENTS][SHWR_MEM_WORDS+2]  __attribute__((aligned(128)));
int buf_start_offset[MAX_EVENTS];
int buf_latency[MAX_EVENTS];
int buf_latency0[MAX_EVENTS];
int buf_latency1[MAX_EVENTS];
int not_aligned;

int main(int argc, char ** argv)
{
  int i, status;
  int toread_shwr_buf_num;
  int shwr_status;
  int trig_id, rd_id;
  int nevents = 0;
  int ctr;
  int nbufs;
  int use_memcpy;
  int use_sched;
  int buf_offset;
  u32 *mem_addr, *buf_ptr;

  // Use Ricardo's scheduling scheme.
  struct sched_param sched_p;

  if (argc != 5)
    {
      printf("Usage: latency_test #_buf/evt[1-6] use_memcpy[0/1] use_sched[0/1] not_aligned[0/1]\n");
      exit(0);
    } 

  i = 1;
  nbufs = atoi(argv[i++]);
  use_memcpy = atoi(argv[i++]);
  use_sched = atoi(argv[i++]);
  not_aligned = atoi(argv[i++]);


  if (use_sched)
    {
      sched_p.sched_priority=50;
      sched_setscheduler(0,SCHED_FIFO, &sched_p);
    }

  buf_offset = 0;
  if (not_aligned) buf_offset = 1;

  // Map registers & memory buffers
  printf("Calling map_registers\n");
  map_registers();
  printf("Return from map_registers\n");
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
  test_options = test_options | (1<<USE_FAKE_RD_BIT);
  printf(", Fake RD");
  test_options = test_options | (1<<USE_FAKE_RDCLK_BIT);
  printf(", Fake RD XFR clk");

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

        // Read Shower buffers
        // Here we read from 1 to 6 of the buffers specified in the command
        // line.  That is 1-5 of the shower buffers, and the RD buffer if
        // 6 is specified.  However, if less than 4 are read there will be
        // no data for the trace histograms and if less than 6 no data
        // for the RD traces.

        for (i=0; i<nbufs; i++)
          {
            mem_addr = (u32*) shwr_mem_ptr[i];
            mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
            buf_ptr = (u32*) &buf_mem[i][nevents][buf_offset];
            if (use_memcpy)
              memcpy(buf_ptr,mem_addr,4*SHWR_MEM_WORDS);
            else
              {
                ctr = SHWR_MEM_WORDS;
                while (ctr--)
                  *buf_ptr++ = *mem_addr++;
              }
          }

        // Get start offset and latencies
        buf_latency[nevents]= read_trig(SHWR_BUF_LATENCY_ADDR);
        buf_latency0[nevents]= read_trig(SHWR_BUF_LATENCY0_ADDR);
        buf_latency1[nevents]= read_trig(SHWR_BUF_LATENCY1_ADDR);
        buf_start_offset[nevents] = read_trig(SHWR_BUF_START_ADDR);

        // Mark buffers as read
        write_rd(RD_IFC_CONTROL_ADDR, toread_shwr_buf_num);
        write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);
        nevents++;
      }
  }
  print_events();
  return(0);
}
