
// Function to configure the triggers according to information in the
// header files.
//
// 07-Feb-2017 DFN Original version
// 17-May-2018 DFN Add compat_tot trigger
// 26-Jun-2018 DFN Add compat_totd trigger

#include "randoms.h"

void config_trigger()
{

  int status;
  int trigger_mask;
  int shwr_status, toread_shwr_buf_num, cur_shwr_buf_num;
  int full_shwr_bufs, num_full;
  int rndm_mode;

  write_trig(RANDOM_TRIG_MODE_ADDR, 0);
  write_trig(RANDOM_TRIG_MODE_ADDR,(int) (RNDM_MODE));
  rndm_mode = read_trig(RANDOM_TRIG_MODE_ADDR);
  if (rndm_mode != RNDM_MODE) 
    printf("trigger_test: Random mode error - wrote %d read %d\n",
	   RNDM_MODE, rndm_mode);
  trigger_mask = SHWR_BUF_TRIG_RNDM;


  // Flush any stale shower buffers
  shwr_status = read_trig(SHWR_BUF_STATUS_ADDR);
  while ((SHWR_INTR_PEND_MASK & (shwr_status >> SHWR_INTR_PEND_SHIFT)) != 0)
    {
      toread_shwr_buf_num = SHWR_BUF_RNUM_MASK & 
	(shwr_status >> SHWR_BUF_RNUM_SHIFT);
      cur_shwr_buf_num = SHWR_BUF_WNUM_MASK & 
	(shwr_status >> SHWR_BUF_WNUM_SHIFT);
      full_shwr_bufs = SHWR_BUF_FULL_MASK & 
	(shwr_status >> SHWR_BUF_FULL_SHIFT);
      num_full = 0x7 & (shwr_status >> SHWR_BUF_NFULL_SHIFT);
      printf("Shower buf writing %d  to read %d  full %x  num full=%d\n",
	     cur_shwr_buf_num,toread_shwr_buf_num,
	     full_shwr_bufs,num_full);
      write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);
      shwr_status = read_trig(SHWR_BUF_STATUS_ADDR);
    }
  write_trig(SHWR_BUF_TRIG_MASK_ADDR, trigger_mask);
  status = read_trig(SHWR_BUF_TRIG_MASK_ADDR);
  if (status != trigger_mask) 
    printf("trigger_test: Error setting trigger mask, wrote %x read %x\n",
	   trigger_mask, status);
}
