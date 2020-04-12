/* This header would consider the Event data structure to be exchanged
   between most of the process for the codes in the UUB softwares.
   
   The struct which refered to "RAW" or "raw" would be almost the data
   structure of the data for the communication between mostly directly
   with the code which communicate mostly with Front-End, but it would
   be not propagate to all the rest of the others code.

*/

#ifndef _SHWR_EVT_DEFS_
#define _SHWR_EVT_DEFS_


#include <stdint.h>
#define SHWR_RAW_NCH_MAX 5


#define SHWR_NCH_MAX 10
#define SHWR_NSAMPLES 2048

#define RADIO_VERSION 1

struct shwr_gps_info
{
  uint32_t second;
  uint32_t ticks;
  uint32_t ticks_prev_pps;
};


struct radio_add_str
{
  uint32_t fadc_raw[SHWR_NSAMPLES]; 
  uint32_t local_version;
  uint32_t status_flag;
  uint32_t extradata; //*it is mostly to send additional data to CDAS.
  uint32_t id;
};




struct shwr_evt
{
  uint32_t Evt_type_1; /* primary trigger event type (SB, TOT, ...).
			  which kind of trigger the event appeared.*/
  uint32_t Evt_type_2; /* secunday trigger event type (SB, ToT, ...),
			  Which list of trigger it might be considered */
  struct shwr_gps_info ev_gps_info;
  int32_t micro_off;
  int32_t nsamples;
  uint16_t fadcs[SHWR_NCH_MAX*SHWR_NSAMPLES];
};

struct shwr_evt_raw
{
  uint32_t id;
  uint32_t Evt_type_1; /* primary trigger event type (SB, TOT, ...).
			  which kind of trigger the event appeared.*/
  uint32_t Evt_type_2; /* secunday trigger event type (SB, ToT, ...),
			  Which list of trigger it might be considered */
  int32_t trace_start; /* The fadc_raw is just a copy the memory block,
			  but the element ...[0] is not when the ADC 
			  trace really starts. This parameter
			  will contain that information.
			*/
  struct shwr_gps_info ev_gps_info;
  int32_t micro_off;
  int32_t nsamples;
  uint32_t fadc_raw[SHWR_RAW_NCH_MAX][SHWR_NSAMPLES]; 
  uint32_t buffer_ev_status;

};



/*the idea of the following structure is to increase the flexibility 
  to exchange some parameters between processes inside the UUB, but
  it does not really need to change the structure in CDAS 
*/

struct trigger_compatibility_SBT
{
  uint32_t th0,th1,th2,enable;
};
struct trigger_compatibility_TOT
{
  uint32_t th0,th1,th2,enable,occ;
};
struct trigger_compatibility_TOTD
{
  uint32_t th0,th1,th2,up0,up1,up2,enable,occ,FD,FN,integral;
};
struct trigger_compatibility_MOPS
{
  uint32_t xx; //not implemented yet
};
struct Full_band_width_SBT
{
  uint32_t th0,th1,th2,thssd,enable;
};

struct trigger_parameters {
  uint32_t fpga_version; /* FPGA code version */
  uint32_t trig_mask;
  struct trigger_compatibility_SBT csbt;
  struct trigger_compatibility_TOT ctot;
  struct trigger_compatibility_TOTD ctotd;
  //struct trigger_compatibility_MOPS cmops;
  struct Full_band_width_SBT fsbt;
};


struct shwr_evt_extra
{
  uint32_t AREA_PEAK[10],BASELINE[5];

  struct trigger_parameters trigger;
  struct radio_add_str radio_info;

  /*shower buffer state related parameters - not tracked in other place */
  uint32_t buff_latency;/*time in us data ready to read to event
                          finished to read */
  uint32_t st_end;
};

struct shwr_evt_complete  
{
  struct shwr_evt_raw raw;
  struct shwr_evt_extra extra;
};


#endif /*_SHWR_EVT_DEFS_*/
