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
u32 rd_mem[RD_MEM_NBUF][RD_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem0[SHWR_MEM_NBUF][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem1[SHWR_MEM_NBUF][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem2[SHWR_MEM_NBUF][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem3[SHWR_MEM_NBUF][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 shw_mem4[SHWR_MEM_NBUF][SHWR_MEM_WORDS] __attribute__((aligned(128)));
u32 *mem_addr, *mem_ptr;


int main()
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
  int read0, read1;
  int expected0, expected1;
  int nerrors = 0;

#ifdef SHWR_TRIGGERS
  int trigger_mask;
  int thr0, thr1, thr2;
  #ifdef COMPAT_SB_TRIGGER
    int compat_sb_trig_enab;
  #endif
  #ifdef SB_TRIGGER
    int sb_trig_enab;
  #endif
#ifdef LED_TRIGGER
    int led_trig_enab;
#endif
#endif

  // Map registers & memory buffers
    printf("Calling map_rd\n");
  map_rd();
    printf("Return from map_rd\n");
  sleep(1);

  // Select fake or true GPS for 1pps
  int test_options = 0;
#ifdef USE_FAKE_GPS
  test_options = 1<<USE_FAKE_PPS_BIT;
#endif
#ifdef USE_FAKE_SIGNAL
  test_options = test_options | (1<< USE_FAKE_SHWR_BIT);
#endif
  test_options = test_options | (1<<USE_FAKE_RD_BIT) | (1<<USE_FAKE_RDCLK_BIT);

  if (test_options != 0)
    {
      write_tstctl(USE_FAKE_ADDR, test_options);
      status = read_tstctl(USE_FAKE_ADDR);
      if (status != test_options) 
	printf("trigger_test: Error setting test options, wrote %x read %x\n",
	       test_options, status);

      write_tstctl(1, 0);  // Mode=0 is used as RESET
      write_tstctl(1, FAKE_SIGNAL_MODE);
      status = read_tstctl(1);
      if (status != FAKE_SIGNAL_MODE)
	printf("trigger_test: Error setting test mode, wrote %x read %x\n",
	       FAKE_SIGNAL_MODE, status);
    }


 // Check for sane IDs
  trig_id = read_trig(ID_REG_ADDR);
  rd_id = read_rd(RD_IFC_ID_ADDR);
  printf("trigger_test: trigger id=%x   rd id=%x\n",trig_id, rd_id);

  // Reset trigger
  write_trig(COMPATIBILITY_GLOBAL_CONTROL_ADDR,1);

  // Disable all shower triggers
  write_trig(SHWR_BUF_TRIG_MASK_ADDR,0);
  status = read_trig(SHWR_BUF_TRIG_MASK_ADDR);
  if (status != 0) printf("trigger_test: Error reading TRIG_MASK %x\n",status);
  config_trigger();  // Configure triggers

   // Loop forever
  int nevents = 0;
  while (nevents < MAX_EVENTS) {

    // Check if we have a trigger
    shwr_status = read_trig(SHWR_BUF_STATUS_ADDR);
    //    printf("SHWR_BUF_STATUS=%x\n",shwr_status);
    // sleep(1);
    if ((SHWR_INTR_PEND_MASK & (shwr_status >> SHWR_INTR_PEND_SHIFT)) != 0)
      {
        nevents++;

        // Turn off fake RD data after MAX_RD events
        // if (nevents >= MAX_RD)
       // Turn off trigger output after MAX_RD events
        if (nevents == MAX_RD)
          {
            printf("Disabling trigger out\n");
            test_options = test_options | (1<<DISABLE_TRIG_OUT_BIT);
            write_tstctl(USE_FAKE_ADDR, test_options);
            status = read_tstctl(USE_FAKE_ADDR);
            if (status != test_options) 
              printf("trigger_test: Error setting test options, wrote %x read %x\n",
                     test_options, status);
          }

        // Which shower memory buffer to read, and which are full
        toread_shwr_buf_num = SHWR_BUF_RNUM_MASK & 
          (shwr_status >> SHWR_BUF_RNUM_SHIFT);
        cur_shwr_buf_num = SHWR_BUF_WNUM_MASK & 
          (shwr_status >> SHWR_BUF_WNUM_SHIFT);
        full_shwr_bufs = SHWR_BUF_FULL_MASK & 
          (shwr_status >> SHWR_BUF_FULL_SHIFT);
        num_full = 0x7 & (shwr_status >> SHWR_BUF_NFULL_SHIFT);
        //       printf("Shower mem: toread=%d  writing=%d  full=%x  num_full=%d\n",
        //     toread_shwr_buf_num, cur_shwr_buf_num, full_shwr_bufs,
        //     num_full);

        // Read Shower buffers to insert appropriate delay

        write_ifc(2, 1);  // Set P65

        mem_addr = (u32*) shwr_mem_ptr[0];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem0[toread_shwr_buf_num][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[1];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem1[toread_shwr_buf_num][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[2];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem2[toread_shwr_buf_num][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[3];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem3[toread_shwr_buf_num][0],mem_addr,4*SHWR_MEM_WORDS);

        mem_addr = (u32*) shwr_mem_ptr[4];
        mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
        memcpy(&shw_mem4[toread_shwr_buf_num][0],mem_addr,4*SHWR_MEM_WORDS);

        write_ifc(2, 0);  // Clear P65

        // Check if the same RD buffer is full
               busy_rd_bufs = 1;
        while (busy_rd_bufs != 0)
          {
            rd_status = read_rd(RD_IFC_STATUS_ADDR);
            toread_rd_buf_num = RD_BUF_RNUM_MASK & 
              (rd_status >> RD_BUF_RNUM_SHIFT);
            cur_rd_buf_num = RD_BUF_WNUM_MASK & 
              (rd_status >> RD_BUF_WNUM_SHIFT);
            full_rd_bufs = RD_BUF_FULL_MASK & 
              (rd_status >> RD_BUF_FULL_SHIFT);
            busy_rd_bufs = RD_BUF_BUSY_MASK &
              (rd_status >> RD_BUF_BUSY_SHIFT);
            parity0 = RD_PARITY0_MASK &
              (rd_status >> RD_PARITY0_SHIFT);
            parity1 = RD_PARITY1_MASK &
              (rd_status >> RD_PARITY1_SHIFT);
            // printf("RD mem: toread=%d  writing=%d  full=%x  busy=%x  parity=%x %x\n",
            //                   toread_rd_buf_num, cur_rd_buf_num, full_rd_bufs,
            //     busy_rd_bufs, parity0, parity1);

            // We should not satisfy this condition, because buffer should
            // not be busy when we get here, unless transfer was killed while
            // in progress, which can happen when USE_FAKE_RD is cleared.
            if (busy_rd_bufs != 0)
              {
                printf("RD mem: Transfer interrupted, clearing busy\n");
                write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);
              }
          }

        // Read RD buffer
        if ((full_rd_bufs & (1 << toread_rd_buf_num)) == 0)
          printf("RD mem: No full RD buffer to read\n");
        else
          {
            //            printf("RD mem: Reading RD buffer %d\n", toread_rd_buf_num);

            mem_addr = (u32*) rd_mem_ptr[0];
            mem_addr = mem_addr + toread_rd_buf_num * RD_MEM_WORDS;
            mem_ptr = mem_addr;
            for (i=0; i<RD_MEM_WORDS; i++)
              {
                rd_mem[toread_rd_buf_num][i] = *mem_ptr;
                mem_ptr++;
              }

            // Mark buffers as read
            write_rd(RD_IFC_CONTROL_ADDR, toread_rd_buf_num);
            write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);

            // Verify RD buffer for correctness

            expected0 = 0;
            expected1 = 0;
            for (i=0; i<RD_MEM_WORDS; i++)
              {  
                read0 = (rd_mem[toread_rd_buf_num][i]>>1) & 0xfff;
                read1 = (rd_mem[toread_rd_buf_num][i]>>17) & 0xfff;
                if ((read0 != expected0) || (read1 != expected1))
                  {
                    printf("word %d  read %x %x  expected %x %x\n",
                           i, read0, read1, expected0, expected1);
                    sleep(2);
                    nerrors = nerrors+1;
                  }
                expected0 = expected0 + 1;
                expected1 = (expected1 - 1) & 0xfff;
              }
            if (nevents%100 == 0) printf("Finished %d events, nerrors=%d\n",
                                         nevents, nerrors);
          }
      }
  }
  
}
