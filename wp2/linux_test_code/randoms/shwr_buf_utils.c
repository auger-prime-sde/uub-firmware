// Utility routines for reading, unpacking, checking shower buffers.mem
//
// 25-May-2016 DFN Initial version extracted from trigger_test.c

#include "randoms.h"
#include <math.h>

// #define VERBOSE
#define PRINT_TIME

extern u32 *mem_addr, *mem_ptr, *buf_ptr;
extern u32 start_offset;
extern int toread_shwr_buf_num;
extern int status;
extern int nevents;

static int peak[10], area[10], baseline[10], saturated[10];
//static int secondsn[NUM_BUFFERS], delta_ticsn[NUM_BUFFERS];
static int secondsu;

static double prev_time = 0;
static int first_second = 0;

extern FILE *output_file;

// Read shower memory buffers from PL memory into PS memory
void read_shw_buffers()
{
  int pps_tics, v[10];
  int seconds, tics, delta_tics;
  double time;
  int i, j, k;

  pps_tics = read_ttag(TTAG_SHWR_PPS_TICS_ADDR);
  seconds = read_ttag(TTAG_SHWR_SECONDS_ADDR);
  tics = read_ttag(TTAG_SHWR_TICS_ADDR);

  pps_tics = pps_tics & TTAG_TICS_MASK;
  seconds = seconds & TTAG_SECONDS_MASK;
  tics = tics & TTAG_TICS_MASK;

  delta_tics = tics-pps_tics;
  if (delta_tics < 0) delta_tics = delta_tics + TTAG_TICS_MASK +1;

  // Does not yet account for rollover of seconds
  time = (double) seconds + 8.3333 * (double) delta_tics / 1.e9;
  prev_time = time;


  // Save trigger time for later print
  if (first_second == 0) first_second = seconds;
  secondsu = seconds-first_second;

  // Print time of event
  fwrite(&secondsu,sizeof(int),1,output_file);
  fwrite(&delta_tics,sizeof(int),1,output_file);


  // Read calculated peak, area, baseline.

  // Get FPGA calculated values of baseline, peak, and area.
  v[0] = read_trig(SHWR_PEAK_AREA0_ADDR);
  v[1] = read_trig(SHWR_PEAK_AREA1_ADDR);
  v[2] = read_trig(SHWR_PEAK_AREA2_ADDR);
  v[3] = read_trig(SHWR_PEAK_AREA3_ADDR);
  v[4] = read_trig(SHWR_PEAK_AREA4_ADDR);
  v[5] = read_trig(SHWR_PEAK_AREA5_ADDR);
  v[6] = read_trig(SHWR_PEAK_AREA6_ADDR);
  v[7] = read_trig(SHWR_PEAK_AREA7_ADDR);
  v[8] = read_trig(SHWR_PEAK_AREA8_ADDR);
  v[9] = read_trig(SHWR_PEAK_AREA9_ADDR);
  for (i=0; i<10; i++)
    {
      peak[i] = (v[i] >> SHWR_PEAK_SHIFT) & SHWR_PEAK_MASK;
      area[i] = (v[i] & SHWR_AREA_MASK);
      saturated[i] = (v[i] >> SHWR_SATURATED_SHIFT) & 1;
    }

  v[0] = read_trig(SHWR_BASELINE0_ADDR);
  v[1] = read_trig(SHWR_BASELINE1_ADDR);
  v[2] = read_trig(SHWR_BASELINE2_ADDR);
  v[3] = read_trig(SHWR_BASELINE3_ADDR);
  v[4] = read_trig(SHWR_BASELINE4_ADDR);
  for (i=0; i<5; i++)
    {
      baseline[2*i] = v[i] & 0xffff;
      baseline[2*i+1] = (v[i] >> 16) & 0xffff;
    }

  // Output a few lines header with the FPGA calculated area, peak, etc.
  for (i=0; i<10; i++)
    {
      fwrite(&i,sizeof(int),1,output_file);
      fwrite(&saturated[i],sizeof(int),1,output_file);
      fwrite(&baseline[i],sizeof(int),1,output_file);
      fwrite(&peak[i],sizeof(int),1,output_file);
      fwrite(&area[i],sizeof(int),1,output_file);
    }

  start_offset = read_trig(SHWR_BUF_START_ADDR);
    
  for (i=0; i<6; i++)
    {
      mem_addr = (u32*) shwr_mem_ptr[i];
      mem_addr = mem_addr + toread_shwr_buf_num * SHWR_MEM_WORDS;
      buf_ptr = (u32*) &shwr_mem[i][0];
      memcpy(buf_ptr,mem_addr,4*SHWR_MEM_WORDS);
    }

  for (i=0; i<SHWR_MEM_WORDS; i++)
    {
      fwrite(&i,sizeof(int),1,output_file);
      j = i + start_offset;
      if (j >= SHWR_MEM_WORDS) j = j - SHWR_MEM_WORDS;

      for (k=0; k<6; k++)
          fwrite(&shwr_mem[k][j],sizeof(u32),1,output_file);
    }

  // Mark buffers as read
  write_rd(RD_IFC_CONTROL_ADDR, toread_shwr_buf_num);
  write_trig(SHWR_BUF_CONTROL_ADDR, toread_shwr_buf_num);
  nevents++;
}

