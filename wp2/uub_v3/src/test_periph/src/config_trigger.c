
// Function to configure the triggers according to information in the
// header files.
//
// 07-Feb-2017 DFN Original version
// 17-May-2018 DFN Add compat_tot trigger
// 26-Jun-2018 DFN Add compat_totd trigger

#include "trigger_test_options.h"
#include "trigger_test.h"

void config_trigger()
{

  int status;
#ifdef SHWR_TRIGGERS
  int trigger_mask;
  int thr0, thr1, thr2;
  int shwr_status, toread_shwr_buf_num, cur_shwr_buf_num;
  int full_shwr_bufs, num_full;

#ifdef COMPAT_SB_TRIGGER
  int compat_sb_trig_enab;
#endif
#ifdef COMPAT_TOT_TRIGGER
  int compat_tot_trig_enab, occ;
#endif
#ifdef COMPAT_TOTD_TRIGGER
  int compat_totd_trig_enab, occd, intd, fn, fd;
#endif
#ifdef SB_TRIGGER
  int sb_trig_enab, thrssd;
#endif
#endif

#ifdef MUON_TRIGGERS
  int muon_trig_enab, muon_trigger_mask;
  int muon_status, toread_muon_buf_num, cur_muon_buf_num;
#endif

#ifdef SHWR_TRIGGERS
  // Enable the shower triggers for this test
  // Set trigger thresholds
#ifdef COMPAT_SB_TRIGGER
  write_trig(COMPATIBILITY_SB_TRIG_THR0_ADDR,(int) TRIG_THR0);
  write_trig(COMPATIBILITY_SB_TRIG_THR1_ADDR,(int) TRIG_THR1);
  write_trig(COMPATIBILITY_SB_TRIG_THR2_ADDR,(int) TRIG_THR2);
  thr0 = read_trig(COMPATIBILITY_SB_TRIG_THR0_ADDR);
  thr1 = read_trig(COMPATIBILITY_SB_TRIG_THR1_ADDR);
  thr2 = read_trig(COMPATIBILITY_SB_TRIG_THR2_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("trigger_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("trigger_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("trigger_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);

  // Define which PMTs to include & coincidence level required
  compat_sb_trig_enab = 0;
    if (TRIG_THR0 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT0;
    if (TRIG_THR1 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT1;
    if (TRIG_THR2 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT2;
    compat_sb_trig_enab |= 1 << COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT;
  write_trig(COMPATIBILITY_SB_TRIG_ENAB_ADDR, compat_sb_trig_enab);
  status = read_trig(COMPATIBILITY_SB_TRIG_ENAB_ADDR);
  if (status != compat_sb_trig_enab)
    printf("trigger_test: Trigger enable error - wrote %x read %x\n", 
	   compat_sb_trig_enab, status);
#endif

#ifdef COMPAT_TOT_TRIGGER
  write_trig(COMPATIBILITY_TOT_TRIG_THR0_ADDR,(int) TRIG_THR0);
  write_trig(COMPATIBILITY_TOT_TRIG_THR1_ADDR,(int) TRIG_THR1);
  write_trig(COMPATIBILITY_TOT_TRIG_THR2_ADDR,(int) TRIG_THR2);
  thr0 = read_trig(COMPATIBILITY_TOT_TRIG_THR0_ADDR);
  thr1 = read_trig(COMPATIBILITY_TOT_TRIG_THR1_ADDR);
  thr2 = read_trig(COMPATIBILITY_TOT_TRIG_THR2_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("trigger_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("trigger_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("trigger_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);

  write_trig(COMPATIBILITY_TOT_TRIG_OCC_ADDR,(int) COMPAT_TOT_TRIG_OCC);
  occ = read_trig(COMPATIBILITY_TOT_TRIG_OCC_ADDR);
  if (occ != COMPAT_TOT_TRIG_OCC)
    printf("trigger_test: ToT trigger occupancy error - wrote %d read %d\n",
           COMPAT_TOT_TRIG_OCC,occ);

  // Define which PMTs to include & coincidence level required
  compat_tot_trig_enab = 0;
    if (TRIG_THR0 != 4095)
      compat_tot_trig_enab |=  COMPATIBILITY_TOT_TRIG_INCL_PMT0;
    if (TRIG_THR1 != 4095)
      compat_tot_trig_enab |=  COMPATIBILITY_TOT_TRIG_INCL_PMT1;
    if (TRIG_THR2 != 4095)
      compat_tot_trig_enab |=  COMPATIBILITY_TOT_TRIG_INCL_PMT2;
    compat_tot_trig_enab |= 1 << COMPATIBILITY_TOT_TRIG_COINC_LVL_SHIFT;
  write_trig(COMPATIBILITY_TOT_TRIG_ENAB_ADDR, compat_tot_trig_enab);
  status = read_trig(COMPATIBILITY_TOT_TRIG_ENAB_ADDR);
  if (status != compat_tot_trig_enab)
    printf("trigger_test: Trigger enable error - wrote %x read %x\n", 
	   compat_tot_trig_enab, status);
#endif
#ifdef COMPAT_TOTD_TRIGGER
  write_trig(COMPATIBILITY_TOTD_TRIG_THR0_ADDR,(int) TRIG_THR0);
  write_trig(COMPATIBILITY_TOTD_TRIG_THR1_ADDR,(int) TRIG_THR1);
  write_trig(COMPATIBILITY_TOTD_TRIG_THR2_ADDR,(int) TRIG_THR2);
  thr0 = read_trig(COMPATIBILITY_TOTD_TRIG_THR0_ADDR);
  thr1 = read_trig(COMPATIBILITY_TOTD_TRIG_THR1_ADDR);
  thr2 = read_trig(COMPATIBILITY_TOTD_TRIG_THR2_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("trigger_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("trigger_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("trigger_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);
 
 write_trig(COMPATIBILITY_TOTD_TRIG_UP0_ADDR,(int) COMPAT_TOTD_UP0);
  write_trig(COMPATIBILITY_TOTD_TRIG_UP1_ADDR,(int) COMPAT_TOTD_UP1);
  write_trig(COMPATIBILITY_TOTD_TRIG_UP2_ADDR,(int) COMPAT_TOTD_UP2);
  thr0 = read_trig(COMPATIBILITY_TOTD_TRIG_UP0_ADDR);
  thr1 = read_trig(COMPATIBILITY_TOTD_TRIG_UP1_ADDR);
  thr2 = read_trig(COMPATIBILITY_TOTD_TRIG_UP2_ADDR);
  if (thr0 != COMPAT_TOTD_UP0) 
    printf("trigger_test: Trigger up 0 error - wrote %d read %d\n",
	   COMPAT_TOTD_UP0,thr0);
  if (thr1 != COMPAT_TOTD_UP1) 
    printf("trigger_test: Trigger up 1 error - wrote %d read %d\n",
	   COMPAT_TOTD_UP1,thr1);
  if (thr2 != COMPAT_TOTD_UP2) 
    printf("trigger_test: Trigger up 2 error - wrote %d read %d\n",
	   COMPAT_TOTD_UP2,thr2);

  write_trig(COMPATIBILITY_TOTD_TRIG_OCC_ADDR,(int) COMPAT_TOTD_TRIG_OCC);
  occd = read_trig(COMPATIBILITY_TOTD_TRIG_OCC_ADDR);
  if (occd != COMPAT_TOTD_TRIG_OCC)
    printf("trigger_test: Totd trigger occupancy error - wrote %d read %d\n",
           COMPAT_TOTD_TRIG_OCC,occd);

 write_trig(COMPATIBILITY_TOTD_TRIG_INT_ADDR,(int) COMPAT_TOTD_INT);
  intd = read_trig(COMPATIBILITY_TOTD_TRIG_INT_ADDR);
  if (intd != COMPAT_TOTD_INT)
    printf("trigger_test: Totd trigger integral error - wrote %d read %d\n",
           COMPAT_TOTD_INT,intd);

  write_trig(COMPATIBILITY_TOTD_TRIG_FD_ADDR,(int) COMPAT_TOTD_FD);
  fd = read_trig(COMPATIBILITY_TOTD_TRIG_FD_ADDR);
  if (fd != COMPAT_TOTD_FD)
    printf("trigger_test: Totd trigger fd error - wrote %d read %d\n",
           COMPAT_TOTD_FD,fd);

  write_trig(COMPATIBILITY_TOTD_TRIG_FN_ADDR,(int) COMPAT_TOTD_FN);
  fn = read_trig(COMPATIBILITY_TOTD_TRIG_FN_ADDR);
  if (fn != COMPAT_TOTD_FN)
    printf("trigger_test: Totd trigger fn error - wrote %d read %d\n",
           COMPAT_TOTD_FN,fn);

  // Define which PMTs to include & coincidence level required
  compat_totd_trig_enab = 0;
    if (TRIG_THR0 != 4095)
      compat_totd_trig_enab |=  COMPATIBILITY_TOTD_TRIG_INCL_PMT0;
    if (TRIG_THR1 != 4095)
      compat_totd_trig_enab |=  COMPATIBILITY_TOTD_TRIG_INCL_PMT1;
    if (TRIG_THR2 != 4095)
      compat_totd_trig_enab |=  COMPATIBILITY_TOTD_TRIG_INCL_PMT2;
    compat_totd_trig_enab |= 1 << COMPATIBILITY_TOTD_TRIG_COINC_LVL_SHIFT;
  write_trig(COMPATIBILITY_TOTD_TRIG_ENAB_ADDR, compat_totd_trig_enab);
  status = read_trig(COMPATIBILITY_TOTD_TRIG_ENAB_ADDR);
  if (status != compat_totd_trig_enab)
    printf("trigger_test: Trigger enable error - wrote %x read %x\n", 
	   compat_totd_trig_enab, status);
#endif

#ifdef SB_TRIGGER
  write_trig(SB_TRIG_THR0_ADDR,(int) (TRIG_THR0));
  write_trig(SB_TRIG_THR1_ADDR,(int) (TRIG_THR1));
  write_trig(SB_TRIG_THR2_ADDR,(int) (TRIG_THR2));
  write_trig(SB_TRIG_SSD_ADDR,(int) (TRIG_SSD));
  thr0 = read_trig(SB_TRIG_THR0_ADDR);
  thr1 = read_trig(SB_TRIG_THR1_ADDR);
  thr2 = read_trig(SB_TRIG_THR2_ADDR);
  thrssd = read_trig(SB_TRIG_SSD_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("trigger_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("trigger_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("trigger_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);
  if (thrssd != TRIG_SSD) 
    printf("trigger_test: Trigger threshold ssd error - wrote %d read %d\n",
	   TRIG_SSD,thrssd);

  // Define which PMTs to include & coincidence level required
  sb_trig_enab = 0;
  if (TRIG_THR0 != 4095)
    sb_trig_enab =  SB_TRIG_INCL_PMT0;
  if (TRIG_THR1 != 4095)
    sb_trig_enab |=  SB_TRIG_INCL_PMT1;
  if (TRIG_THR2 != 4095)
    sb_trig_enab |=  SB_TRIG_INCL_PMT2;
  if (TRIG_SSD != 4095)
    sb_trig_enab |=  SB_TRIG_INCL_SSD;
  sb_trig_enab |=  SB_COINC_LVL << SB_TRIG_COINC_LVL_SHIFT;
  sb_trig_enab |=  SSD_DELAY << SB_TRIG_SSD_DELAY_SHIFT;
  sb_trig_enab |=  SB_COINC_OVLP << SB_TRIG_COINC_OVLP_SHIFT;
  sb_trig_enab |=  SB_CONSEC_BINS << SB_TRIG_CONSEC_BINS_SHIFT;
#ifdef SSD_AND
  sb_trig_enab |= 1 << SB_TRIG_SSD_AND_SHIFT; 
#endif
  write_trig(SB_TRIG_ENAB_ADDR, sb_trig_enab);
  status = read_trig(SB_TRIG_ENAB_ADDR);
  if (status != sb_trig_enab)
    printf("trigger_test: Error writing SB_TRIG_ENAB, wrote %x read %x\n",
	   sb_trig_enab, status);
#endif

  trigger_mask = 0;
#ifdef SB_TRIGGER
  trigger_mask = trigger_mask | SHWR_BUF_TRIG_SB;
#endif
#ifdef COMPAT_SB_TRIGGER
  trigger_mask = trigger_mask | COMPATIBILITY_SHWR_BUF_TRIG_SB;
#endif
#ifdef PRESCALE_COMPAT_SB_TRIG
  trigger_mask = trigger_mask | COMPAT_PRESCALE_SHWR_BUF_TRIG_SB;
#endif
#ifdef COMPAT_TOT_TRIGGER
  trigger_mask = trigger_mask | COMPATIBILITY_SHWR_BUF_TRIG_TOT;
#endif
#ifdef PRESCALE_COMPAT_TOT_TRIG
  trigger_mask = trigger_mask | COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT;
#endif
#ifdef COMPAT_TOTD_TRIGGER
  trigger_mask = trigger_mask | COMPATIBILITY_SHWR_BUF_TRIG_TOTD;
#endif
#ifdef PRESCALE_COMPAT_TOTD_TRIG
  trigger_mask = trigger_mask | COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD;
#endif
#ifdef EXT_TRIGGER
  trigger_mask = trigger_mask |  COMPATIBILITY_SHWR_BUF_TRIG_EXT;
#endif
#ifdef PRESCALE_EXT_TRIGGER
  trigger_mask = trigger_mask |  COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT;
#endif
#ifdef LED_TRIGGER
  trigger_mask = trigger_mask |  SHWR_BUF_TRIG_LED;
#endif

  printf("Trigger_test: Enabled triggers = ");
  if ((trigger_mask & SHWR_BUF_TRIG_SB) != 0) 
    printf(" SB");
  if ((trigger_mask & COMPATIBILITY_SHWR_BUF_TRIG_SB) != 0) 
    printf(" COMPAT_SB");
  if ((trigger_mask & COMPATIBILITY_SHWR_BUF_TRIG_TOT) != 0) 
    printf(" COMPAT_TOT");
  if ((trigger_mask & COMPATIBILITY_SHWR_BUF_TRIG_TOTD) != 0) 
    printf(" COMPAT_TOTD");
  if ((trigger_mask & COMPATIBILITY_SHWR_BUF_TRIG_EXT) != 0) 
    printf(" EXT");
  if ((trigger_mask & COMPAT_PRESCALE_SHWR_BUF_TRIG_SB) != 0) 
    printf(" PRESCALE_SB");
  if ((trigger_mask & COMPAT_PRESCALE_SHWR_BUF_TRIG_TOT) != 0) 
    printf(" PRESCALE_COMPAT_TOT");
  if ((trigger_mask & COMPAT_PRESCALE_SHWR_BUF_TRIG_TOTD) != 0) 
    printf(" PRESCALE_COMPAT_TOTD");
  if ((trigger_mask & COMPAT_PRESCALE_SHWR_BUF_TRIG_EXT) != 0) 
    printf(" PRESCALE_EXT");
  if ((trigger_mask & SHWR_BUF_TRIG_LED) != 0)
    printf(" LED");
  printf("\n");
#if defined(SB_TRIGGER)  || defined(COMPAT_SB_TRIGGER) || defined(COMPAT_TOT_TRIGGER) || defined(COMPAT_TOTD_TRIGGER)
  printf("Trigger_test: Shower trigger thresholds = %d %d %d %d\n",
	 (int) (TRIG_THR0), (int) (TRIG_THR1), (int) (TRIG_THR2), 
	 (int) (TRIG_SSD));
  #endif

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

#else
  write_trig(SHWR_BUF_TRIG_MASK_ADDR, 0);
  printf("Trigger_test: Shower trigger not enabled\n");
#endif

#ifdef MUON_TRIGGERS
  // Enable the muon triggers for this test
  // Set trigger thresholds
  write_trig(MUON_TRIG1_THR0_ADDR,(int) (TRIG_THR0));
  write_trig(MUON_TRIG1_THR1_ADDR,(int) (TRIG_THR1));
  write_trig(MUON_TRIG1_THR2_ADDR,(int) (TRIG_THR2));
  write_trig(MUON_TRIG1_SSD_ADDR,(int) (TRIG_SSD));
 
  // Define which PMTs to include & coincidence level required
    muon_trig_enab =  MUON_TRIG_INCL_PMT0 |
    MUON_TRIG_INCL_PMT1 |
    MUON_TRIG_INCL_PMT2 |
    MUON_TRIG_INCL_SSD |
    (1 << MUON_TRIG_COINC_LVL_SHIFT) |
    (1 << MUON_TRIG_SSD_DELAY_SHIFT) |
    (0 << MUON_TRIG_COINC_OVLP_SHIFT) |
    (0 << MUON_TRIG_CONSEC_BINS_SHIFT);
  write_trig(MUON_TRIG1_ENAB_ADDR, muon_trig_enab);

  //muon_trigger_mask =  MUON_BUF_TRIG_SB1 | MUON_BUF_TRIG_EXT;
  muon_trigger_mask =  MUON_BUF_TRIG_SB1;
#ifdef MUON_SIPM_CAL
  muon_trigger_mask |= MUON_BUF_SIPM_CAL;
#endif
  printf("Trigger_test: Enabled muon triggers = ");
  if ((muon_trigger_mask & MUON_BUF_TRIG_SB1) != 0) 
    printf(" SB1");
  if ((muon_trigger_mask & MUON_BUF_TRIG_SB2) != 0) 
    printf(" SB2");
  if ((muon_trigger_mask & MUON_BUF_TRIG_SB3) != 0) 
    printf(" SB3");
  if ((muon_trigger_mask & MUON_BUF_TRIG_SB4) != 0) 
    printf(" SB4");
  if ((muon_trigger_mask & MUON_BUF_TRIG_EXT) != 0) 
    printf(" EXT");
  if ((muon_trigger_mask & MUON_BUF_SIPM_CAL) != 0) 
    printf(" SIPM_CAL");
  printf("\n");
  printf("Trigger_test: Muon trigger thresholds = %d\n",(int) (TRIG_THR0));

  // Flush any stale muon buffers
  muon_status = read_trig(MUON_BUF_STATUS_ADDR);
  while ((MUON_INTR_PEND_MASK & (muon_status >> MUON_INTR_PEND_SHIFT)) != 0)
    {
      toread_muon_buf_num = MUON_BUF_RNUM_MASK & 
        (muon_status >> MUON_BUF_RNUM_SHIFT);
      write_trig(MUON_BUF_CONTROL_ADDR, toread_muon_buf_num);
      muon_status = read_trig(MUON_BUF_STATUS_ADDR);
    }

  write_trig(MUON_BUF_TRIG_MASK_ADDR, muon_trigger_mask);
#else
  write_trig(MUON_TRIG1_ENAB_ADDR, 0);
  printf("Trigger_test: Muon trigger not enabled\n");
#endif
}
