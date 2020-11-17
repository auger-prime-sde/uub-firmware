// Function to print accumulated events

// 03-Nov-2018 DFN New original version
// 15-Feb-2019 DFN Modified for use with real RD interface

#include "rd_test.h"
#include "string.h"

// Mmemory buffers
#ifdef SPACER
u32 spacer[1] __attribute__((aligned(128)));
u32 rd_mem[MAX_EVENTS+EXTRA_EVENTS][RD_MEM_WORDS];
#else
u32 rd_mem[MAX_EVENTS+EXTRA_EVENTS][RD_MEM_WORDS] __attribute__((aligned(128)));
#endif
u32 shw_mem0[MAX_EVENTS+EXTRA_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem1[MAX_EVENTS+EXTRA_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem2[MAX_EVENTS+EXTRA_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem3[MAX_EVENTS+EXTRA_EVENTS][SHWR_MEM_WORDS];
u32 shw_mem4[MAX_EVENTS+EXTRA_EVENTS][SHWR_MEM_WORDS];

int buf_start_offset[MAX_EVENTS+EXTRA_EVENTS];
int buf_num[MAX_EVENTS+EXTRA_EVENTS];
int buf_latency[MAX_EVENTS+EXTRA_EVENTS];
double buf_dt[MAX_EVENTS+EXTRA_EVENTS];
u32 buf_rd_status[MAX_EVENTS+EXTRA_EVENTS];

void print_events()
{
  int i, j, k;
  int start_offset, toread_shwr_buf_num;
  u32 rd_status;
  int latency;
  double dt;

  // Loop until MAX_EVENTS
  for (i=0; i < MAX_EVENTS; i++)
    {
      start_offset = buf_start_offset[i];
      rd_status = buf_rd_status[i];
      toread_shwr_buf_num = buf_num[i];
      latency = buf_latency[i];
      dt = buf_dt[i];
      rd_status = buf_rd_status[i];

      printf(">>>>>>>> EVENT HEADER >>>>>>>>\n");
      printf("%d %d %d %x %f\n", 
             i, toread_shwr_buf_num, latency, rd_status, dt);
      printf(">>>>>>>> START OF EVENT >>>>>>>>\n");
      for (j=0; j<SHWR_MEM_WORDS; j++)
        {
          k = j + start_offset;
          if (k > SHWR_MEM_WORDS) k = k - SHWR_MEM_WORDS;
          printf("%8x %8x %8x %8x %8x %8x\n",
                 shw_mem0[i][k], shw_mem1[i][k], shw_mem2[i][k],
                 shw_mem3[i][k], shw_mem4[i][k], rd_mem[i][j]);
        }
      printf(">>>>>>>> END OF EVENT >>>>>>>>\n");
    }
}
