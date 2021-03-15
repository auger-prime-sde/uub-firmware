
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
  FE_SHWR_TRIG_SB=0, 
  FE_SHWR_TRIG_TOT,
  FE_SHWR_TRIG_TOTD,
  FE_SHWR_TRIG_MOPS,
  FE_SHWR_TRIG_EXT,
  FE_SHWR_TRIG_RANDOM,
  FE_SHWR_TRIG_LED,
  FE_SHWR_TRIG_NTRIG   /*it is not a really a trigger */
};
#define FE_SHWR_TRIG_MASK_SB      (1<<FE_SHWR_TRIG_SB)
#define FE_SHWR_TRIG_MASK_TOT     (1<<FE_SHWR_TRIG_TOT)
#define FE_SHWR_TRIG_MASK_TOTD    (1<<FE_SHWR_TRIG_TOTD)
#define FE_SHWR_TRIG_MASK_MOPS    (1<<FE_SHWR_TRIG_MOPS)
#define FE_SHWR_TRIG_MASK_EXT     (1<<FE_SHWR_TRIG_EXT)
#define FE_SHWR_TRIG_MASK_RANDOM  (1<<FE_SHWR_TRIG_RANDOM)
#define FE_SHWR_TRIG_MASK_LED     (1<<FE_SHWR_TRIG_LED)

/*  ID: shower_trigger         end*/

enum{
  FE_ADD_TRIG_MUON=0,
  FE_ADD_TRIG_SCALER,  
  FE_ADD_TRIG_NTRIG   /*it is not a really a trigger */
};

unsigned int FeGetReg( unsigned int reg );
void FeSetReg(unsigned int reg, uint32_t value );
void FeAndReg(unsigned int reg, uint32_t value );
void FeOrReg( unsigned int reg, uint32_t value);

int FeShwrReset();

int FeShwrEnableTrigger(int tr,int enable);
int FeShwrEnableTriggerMask(int mask,int enable);
int FeShwrSetThreshold(int tr,uint32_t th[3]);
int FeShwrEnablePMT(int tr,int pmt,int enable);
int FeShwrEnablePMT_trmask(int tr_mask,int pmt,int enable);
int FeShwrEnablePMT_trmask_pmtmask(int tr_mask,int pmt_mask,int enable);
int FeShwrEnablePMT_tr_set(int tr,int pmt_mask,int n_coincidenc);
int FeShwrNCoincidence(int trigger,unsigned int n);
