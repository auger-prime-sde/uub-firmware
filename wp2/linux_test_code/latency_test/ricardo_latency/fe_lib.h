
#include <stdint.h>
/* shower traces definition */
#define FE_NSAMPLES 2048
#define FE_NCH_MAX 5

enum{
  FE_OK=0,
  FE_ERROR,
  FE_PARAM_ERROR,
  FE_NOT_IMPLEMENTED
};

/*
  ID: shower_trigger         Begin
  every modification in the list below, remember to make the
  corresponding modification at the fe_lib.c (ID: shower_trigger_reg)

  This is the list of triggers which may be requested.
 */ 

enum{
  FE_SHWR_TRIG_SB=0,  //this is compatible single bin trigger.
  FE_SHWR_TRIG_TOT,
  FE_SHWR_TRIG_TOTD,
  FE_SHWR_TRIG_MOPS,
  FE_SHWR_TRIG_EXT,
  FE_SHWR_TRIG_RANDOM,
  FE_SHWR_TRIG_LED,
  FE_SHWR_TRIG_SB_FULL,
  FE_SCALER_A,     /*it has been included here because the   */
  FE_SCALER_B,     /*  definition is the same of many others */      
  FE_SCALER_C,
  FE_SHWR_TRIG_NTRIG   /*it is not a really a trigger ("no Trigger") */
};
/*the following parameters will be defined in the same way as in 
  the FPGA (programable logic). See "SDE Upgrade PLD Firmware Specifications"
  the parameter: SHWR_BUF_TRIG_ID 
*/
#define FE_SHWR_TRIG_MASK_SB      0x00000001
#define FE_SHWR_TRIG_MASK_TOT     0x00000002
#define FE_SHWR_TRIG_MASK_TOTD    0x00000004
#define FE_SHWR_TRIG_MASK_MOPS    0x00000008
#define FE_SHWR_TRIG_MASK_EXT     0x00000010
#define FE_SHWR_TRIG_MASK_RANDOM  0x00000020
#define FE_SHWR_TRIG_MASK_LED     0x00010000
#define FE_SHWR_TRIG_MASK_SB_FULL 0x00020000

#define FE_SHWR_TRIG_MASK_ALL     0x00FF00FF

/*  ID: shower_trigger         end*/
enum{
  FE_ADD_TRIG_MUON=0,
  FE_ADD_TRIG_SCALER,  
  FE_ADD_TRIG_NTRIG   /*it is not a really a trigger */
};
int FeInit(int use_UIO);

unsigned int FeGetReg( unsigned int reg );
void FeSetReg(unsigned int reg, uint32_t value );
void FeAndReg(unsigned int reg, uint32_t value );
void FeOrReg( unsigned int reg, uint32_t value);

int FeReset(); /*send the reset to the FrontEnd */

int FeShwrReset(); /*this would still keep many values to the FrontEnd */

int FeShwrEnableTrigger(int tr,int enable);
int FeShwrEnableTriggerMask(int mask,int enable);
int FeShwrSetThreshold(int tr,uint32_t th[3]);
int FeShwrEnablePMT(int tr,int pmt,int enable);
int FeShwrEnablePMT_trmask(int tr_mask,int pmt,int enable);
int FeShwrEnablePMT_trmask_pmtmask(int tr_mask,int pmt_mask,int enable);
int FeShwrEnablePMT_tr_set(int tr,int pmt_mask,int n_coincidenc);
int FeShwrNCoincidence(int trigger,unsigned int n);

int FeShwr_Compat_TOT(int Occupancy);
int FeShwr_Compat_TOTD(int up1,int up2,int up3,int Occupancy,double decay,int INT);
int FeShwr_Compat_MOPS(int up1,int up2,int up3,int Occupancy,int ofs,int integral);
int FeShwr_Random(uint32_t value);
int FeShwr_Full_SB_Trigger(uint32_t TH_ssd, int ssd_delay, int overlap, 
			   int consec_bins, int WCD_and_SSD);
