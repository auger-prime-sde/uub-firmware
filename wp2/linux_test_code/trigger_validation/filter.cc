// filter.c
//
// Apply FPGA "Compatibility filter to UUB data.  The output trace
// has a UB compatible 768 bin length so it can be feed to routines
// that simulate trigger on either UB or UUB.
//
// Arguements:
//   input:  Input traces of 3 PMTs
//   output: Filtered output traces
//   offset: Downsampling offset.  0 implies takings bins 0, 3, 6, etc,
//           while 1 implies taking bins 1, 4, 7, etc, and so on.
//
//  29-Sep-2020 DFN Initial encapsulated version
//  03-Oct-2020 DFN Modify to wrap end of trace to beginning for filter
//  31-Oct-2020 DFN Added description of arguments
//  23-Dec-2020 DFN Adjust delay to agree with with filtered data from FPGA

#include <stdio.h>

#define FDELAY 1

int filter(int input[3][2048], int output[3][768], int offset)
{
  int i, j, k, l, p;
  int filtered[3][2048];
  int fir[21] = {5,0,12,22,0,-61,-96,0,256,551,681,551,256,
                 0,-96,-61,0,22,12,0,5};
  int return_val = 1;

  for (p=0; p<3; p++)
    {
      for (k=0; k<2048; k++)
        {
          filtered[p][k] = 0;
          for (j=-10; j<=10; j++)
            {
              l = k-j;
              if (l < 0) l = l+2048;
              if (l > 2047) l = l-2048;
              filtered[p][k] = filtered[p][k] + input[p][l]*fir[j+10];
            }
          filtered[p][k] = (filtered[p][k] >> 11);
          if (filtered[p][k] > 4095) filtered[p][k] = 4095;
          if (filtered[p][k] < 0) filtered[p][k] = 0;
        }
      for (i=0; i<768; i++)
        {
          k = 3*(i-FDELAY) + offset;
          if (k < 0) k = k+2048;
          if (k > 2047) k = k-2048;
          output[p][i] = filtered[p][k];
        }

#ifndef __cplusplus
      // Debug - Sanity check
      for (i=0; i<768; i++)
        if (output[p][i] == 0)
          { 
            printf("Filter output p=%d i=%d offset=%d is zero!\n",
                   p, i, offset);
            return_val = 0;
          }
#endif

    }
  return return_val;
}
