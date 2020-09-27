
// Simple standalone test routine to interact with the sde_trigger PL.
//
//  17-Jul-2020 DFN Initial version that just records randoms.  Stripped down
//                  from trigger_test

#include "randoms.h"

volatile u32 *trig_regs;
volatile u32 *ttag_regs;
volatile u32 *ifc_regs;
volatile u32 *rd_regs;
volatile u32 *tstctl_regs;

volatile u32 shwr_mem_ptr[6];
u32 shwr_mem_addr[6];
volatile int nevents = 0;

// Shower memory buffers
u32 spacer  __attribute__((aligned(128)));
u32 shwr_mem[6][SHWR_MEM_WORDS];

u32 *mem_addr, *mem_ptr, *buf_ptr;
u32 start_offset;
int toread_shwr_buf_num;
int toread_muon_buf_num;
int status;
FILE *output_file;

int main(int argc, char *argv[]) 
{
    int cntrl_word = 0;
    int id;
    int i;
    int max_events;
  
    if (argc != 3)
      {
        printf("Usage: randoms #events output_filename\n"); 
        exit(0);
      } 

    i = 1;
    max_events = atoi(argv[i++]);

    output_file = fopen(argv[2],"w");
    if (output_file == 0) {
      printf("Unable to open output file\n");
      return 1;
    }

    // Map registers & memory buffers
    map_registers();

    // Select any special test options.
    int test_options = 0;

    // Select fake or true GPS for 1pps
#ifdef USE_FAKE_GPS
    test_options = 1<<USE_FAKE_PPS_BIT;
#endif

    if (test_options != 0)
      {
        write_tstctl(0, test_options);
        status = read_tstctl(0);

        if (status != test_options) 
          printf("randoms: Error setting test options, wrote %x read %x\n",
                 test_options, status);

        write_tstctl(1, 0);  // Mode=0 is used as RESET
        status = read_tstctl(1);
      }

    // Set up trigger

    // Check for sane ID
    id = read_trig(ID_REG_ADDR);
    printf("randoms: id=%x\n",id);

    // Reset trigger
    write_trig(COMPATIBILITY_GLOBAL_CONTROL_ADDR,1);

    // Disable all shower triggers
    write_trig(SHWR_BUF_TRIG_MASK_ADDR,0);
    status = read_trig(SHWR_BUF_TRIG_MASK_ADDR);
    if (status != 0) printf("randoms: Error reading TRIG_MASK %x\n",status);

    config_trigger();  // Configure triggers
             
    // Loop forever
    nevents = 0;
    while (nevents < max_events) {

      // Is an interrupt pending?
      status = read_trig(SHWR_BUF_STATUS_ADDR);
      if ((SHWR_INTR_PEND_MASK & (status >> SHWR_INTR_PEND_SHIFT)) != 0)
        {
          toread_shwr_buf_num = SHWR_BUF_RNUM_MASK & 
            (status >> SHWR_BUF_RNUM_SHIFT);
          read_shw_buffers();  // Read buffers to local memory

          cntrl_word = toread_shwr_buf_num;
          write_trig(SHWR_BUF_CONTROL_ADDR,cntrl_word);
        }
    }
    fclose(output_file);
    return 0;
  }


