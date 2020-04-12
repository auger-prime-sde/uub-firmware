// Function to print accumulated events

// 07-Apr-2020 DFN Original version

#include "latency_test.h"
#include "string.h"

// Mmemory buffers
u32 buf_mem[6][MAX_EVENTS][SHWR_MEM_WORDS+2]  __attribute__((aligned(128)));
int buf_start_offset[MAX_EVENTS];
int buf_latency[MAX_EVENTS];
int buf_latency0[MAX_EVENTS];
int buf_latency1[MAX_EVENTS];
int not_aligned;

void print_events()
{
  int i, j, k;
  int start_offset;
  int latency, latency0, latency1;
  int buf_offset;

  buf_offset = 0;
  if (not_aligned) buf_offset = 1;

  // Loop until MAX_EVENTS
  for (i=0; i < MAX_EVENTS; i++)
    {
      start_offset = buf_start_offset[i];
      latency = buf_latency[i];
      latency0 = buf_latency0[i];
      latency1 = buf_latency1[i];

      printf(">>>>>>>> EVENT HEADER >>>>>>>>\n");
      printf("%d %d %d %d\n", 
             start_offset, latency, latency0, latency1);
      printf(">>>>>>>> START OF EVENT >>>>>>>>\n");
      for (j=0; j<SHWR_MEM_WORDS; j++)
        {
          k = j + start_offset + buf_offset;
          if (k >= SHWR_MEM_WORDS+buf_offset) k = k - SHWR_MEM_WORDS;
          printf("%8x %8x %8x %8x %8x %8x\n",
                 buf_mem[0][i][k], buf_mem[1][i][k], buf_mem[2][i][k],
                 buf_mem[3][i][k], buf_mem[4][i][k], buf_mem[5][i][j]);
        }
      printf(">>>>>>>> END OF EVENT >>>>>>>>\n");
    }
}
