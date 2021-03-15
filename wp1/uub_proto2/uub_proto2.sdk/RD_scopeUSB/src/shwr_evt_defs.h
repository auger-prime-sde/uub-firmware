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


struct shwr_gps_info
{
  uint32_t second;
  uint32_t ticks;
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
  int trace_start;     /* The fadc_raw is just a copy the memory block,
			  but the element ...[0] is not when the ADC 
			  trace really starts. This parameter
			  will contain that information.
			*/
  struct shwr_gps_info ev_gps_info; 
  int32_t nsamples;
  uint32_t fadc_raw[SHWR_RAW_NCH_MAX][SHWR_NSAMPLES];
  uint32_t peak[10];

};

#endif /*_SHWR_EVT_DEFS_*/
