
// Function to configure the scalers according to information in the
// header files.
//
// 12-Apr-2019 DFN Original version

#include "scaler_test.h"

void config_scaler()
{

  int status;
  int trigger_mask;
  int thr0, thr1, thr2;
  int shwr_status;
  int compat_sb_trig_enab;

  // Enable the  triggers for this test
  // Set scaler thresholds

#ifdef ENABLE_SCALER_A
  write_trig(COMPATIBILITY_SCALER_A_THR0_ADDR,(int) TRIG_THR0);
  write_trig(COMPATIBILITY_SCALER_A_THR1_ADDR,(int) TRIG_THR1);
  write_trig(COMPATIBILITY_SCALER_A_THR2_ADDR,(int) TRIG_THR2);
  thr0 = read_trig(COMPATIBILITY_SCALER_A_THR0_ADDR);
  thr1 = read_trig(COMPATIBILITY_SCALER_A_THR1_ADDR);
  thr2 = read_trig(COMPATIBILITY_SCALER_A_THR2_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("Scaler_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("Scaler_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("Scaler_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);

  // Define which PMTs to include & coincidence level required
  // Note the format of the registers is the same as that of the compat. SB
  // trigger, so we use the same definitions below.
  compat_sb_trig_enab = 0;
    if (TRIG_THR0 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT0;
    if (TRIG_THR1 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT1;
    if (TRIG_THR2 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT2;
    compat_sb_trig_enab |= 1 << COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT;
  write_trig(COMPATIBILITY_SCALER_A_ENAB_ADDR, compat_sb_trig_enab);
  status = read_trig(COMPATIBILITY_SCALER_A_ENAB_ADDR);
  if (status != compat_sb_trig_enab)
    printf("Scaler_test: Scaler enable error - wrote %x read %x\n", 
	   compat_sb_trig_enab, status);

  printf("Scaler_test: Scaler A trigger thresholds = %d %d %d\n",
	 (int) (TRIG_THR0), (int) (TRIG_THR1), (int) (TRIG_THR2));
#endif

#ifdef ENABLE_SCALER_B
  write_trig(COMPATIBILITY_SCALER_B_THR0_ADDR,(int) TRIG_THR0);
  write_trig(COMPATIBILITY_SCALER_B_THR1_ADDR,(int) TRIG_THR1);
  write_trig(COMPATIBILITY_SCALER_B_THR2_ADDR,(int) TRIG_THR2);
  thr0 = read_trig(COMPATIBILITY_SCALER_B_THR0_ADDR);
  thr1 = read_trig(COMPATIBILITY_SCALER_B_THR1_ADDR);
  thr2 = read_trig(COMPATIBILITY_SCALER_B_THR2_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("Scaler_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("Scaler_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("Scaler_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);

  // Define which PMTs to include & coincidence level required
  // Note the format of the registers is the same as that of the compat. SB
  // trigger, so we use the same definitions below.
  compat_sb_trig_enab = 0;
    if (TRIG_THR0 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT0;
    if (TRIG_THR1 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT1;
    if (TRIG_THR2 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT2;
    compat_sb_trig_enab |= 1 << COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT;
  write_trig(COMPATIBILITY_SCALER_B_ENAB_ADDR, compat_sb_trig_enab);
  status = read_trig(COMPATIBILITY_SCALER_B_ENAB_ADDR);
  if (status != compat_sb_trig_enab)
    printf("Scaler_test: Scaler enable error - wrote %x read %x\n", 
	   compat_sb_trig_enab, status);

  printf("Scaler_test: Scaler B trigger thresholds = %d %d %d\n",
	 (int) (TRIG_THR0), (int) (TRIG_THR1), (int) (TRIG_THR2));
#endif

#ifdef ENABLE_SCALER_C
  write_trig(COMPATIBILITY_SCALER_C_THR0_ADDR,(int) TRIG_THR0);
  write_trig(COMPATIBILITY_SCALER_C_THR1_ADDR,(int) TRIG_THR1);
  write_trig(COMPATIBILITY_SCALER_C_THR2_ADDR,(int) TRIG_THR2);
  thr0 = read_trig(COMPATIBILITY_SCALER_C_THR0_ADDR);
  thr1 = read_trig(COMPATIBILITY_SCALER_C_THR1_ADDR);
  thr2 = read_trig(COMPATIBILITY_SCALER_C_THR2_ADDR);
  if (thr0 != TRIG_THR0) 
    printf("Scaler_test: Trigger threshold 0 error - wrote %d read %d\n",
	   TRIG_THR0,thr0);
  if (thr1 != TRIG_THR1) 
    printf("Scaler_test: Trigger threshold 1 error - wrote %d read %d\n",
	   TRIG_THR1,thr1);
  if (thr2 != TRIG_THR2) 
    printf("Scaler_test: Trigger threshold 2 error - wrote %d read %d\n",
	   TRIG_THR2,thr2);

  // Define which PMTs to include & coincidence level required
  // Note the format of the registers is the same as that of the compat. SB
  // trigger, so we use the same definitions below.
  compat_sb_trig_enab = 0;
    if (TRIG_THR0 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT0;
    if (TRIG_THR1 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT1;
    if (TRIG_THR2 != 4095)
      compat_sb_trig_enab |=  COMPATIBILITY_SB_TRIG_INCL_PMT2;
    compat_sb_trig_enab |= 1 << COMPATIBILITY_SB_TRIG_COINC_LVL_SHIFT;
  write_trig(COMPATIBILITY_SCALER_C_ENAB_ADDR, compat_sb_trig_enab);
  status = read_trig(COMPATIBILITY_SCALER_C_ENAB_ADDR);
  if (status != compat_sb_trig_enab)
    printf("Scaler_test: Scaler enable error - wrote %x read %x\n", 
	   compat_sb_trig_enab, status);

  printf("Scaler_test: Scaler C trigger thresholds = %d %d %d\n",
	 (int) (TRIG_THR0), (int) (TRIG_THR1), (int) (TRIG_THR2));
#endif
}
