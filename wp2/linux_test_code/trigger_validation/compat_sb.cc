// compat_sb.c
//
// Compute compatibility single bin trigger.   This code can be used for UB
// traces as well as filtered UUB traces. 
//
// Arguments:
//  trace:       traces for the 3 WCD PMT, length is UB compatible
//  thres:       threshold for the PMTs
//  enable:      enable flags for which PMTs to include in trigger
//  minPMT:      Minimum number of PMTs satisfying the PMT trigger
//
//  31-Oct-2020 DFN Expanded arguments to include all values setable in the
//                  FPGA; added description of arguments


#ifndef __cplusplus
  #include <stdbool.h>
#endif

bool compat_sb(int trace[3][768], int thres[3], bool enable[3], int minPMT)
{
  int i, p;
  int nSB;

  for (i=0; i<768; i++)
    {
      nSB = 0;
      for (p=0; p<3; p++)
        if (enable[p])
          if (trace[p][i] > thres[p]) nSB++;
      if (nSB >= minPMT) return true;
    }
  return false;
}
