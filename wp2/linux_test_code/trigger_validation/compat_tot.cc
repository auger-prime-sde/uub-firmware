// compat_tot
//
// Perform compatibility ToT trigger.  This code can be used for UB traces
// as well as filtered UUB traces. 
//
// Arguments:
//  trace:       traces for the 3 WCD PMT, length is UB compatible
//  thres:       lower threshold for the PMTs
//  enable:      enable flags for which PMTs to include in trigger
//  minPMT:      Minimum number of PMTs satisfying the PMT trigger
//  minOcc:      Minimum occupancy required for PMT trigger
//  occs:        Occupancy (diagnostic).  Pass NULL if not used
//
//  29-Sep-2020 DFN Initial encapsulated version.
//  06-Oct-2020 DFN Use trace wrap to improve speed.
//  29-Oct-2020 DFN Expanded arguments to include all values setable in the
//                  FPGA; added description of arguments

#ifndef __cplusplus
  #include <stdbool.h>
#endif

bool compat_tot(int trace[3][768], int thresh[3], bool enable[3],
                int minPMT, int minOcc, int occs[768])
{
  int i, j, p;
  int NWindow = 120;   // Size of window in 25ns bins

  int occ = 0;
  int nToT;
  int lToT;

  // Zero out debug occupancy array
  for (i=0; i<768; i++)
        if (&occs[0] != 0) occs[i] = 0;


  // Scan trace
  // We wrap from the near end of the trace if necessary, but be careful
  // not to include bins beyond the end of a UUB trace.
  for (i=0; i<768; i++)
    {
      j = i - NWindow;
      if (j < 0) j = j + 562;
      nToT = 0;
      lToT = 0;
      for (p = 0; p < 3; p++) // Loop  over all the PMTs
        if (enable[p])
          {
            {
              if (trace[p][i] > thresh[p]) nToT++;
              if (trace[p][j] > thresh[p]) lToT++;
            }
          }
      if (nToT >= minPMT) occ++;
      if (lToT >= minPMT) occ--;
      if (occ < 0 ) occ = 0;
      if (&occs[0] != 0) occs[i] = occ;

      if (occ > minOcc)
        return true;
    }
  return false;
}
