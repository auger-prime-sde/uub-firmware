// compat_mops
//
// Perform compatibility MoPS trigger.  This code can be used for UB traces
// as well as filtered UUB traces.
//
// Arguments:
//  trace:       traces for the 3 WCD PMT, length is UB compatible
//  lowthres:    lower threshold for the PMTs
//  hithresh:    high threshold for the PMTs
//  enable:      enable flags for which PMTs to include in trigger
//  minPMT:      Minimum number of PMTs satisfying the PMT trigger
//  minIntegral: Minimum integrated signal
//  minOcc:      Minimum occupancy required for PMT trigger
//  steps:       Computed steps (diagnostic).  Pass NULL if not used
//  totalsteps:  Computed positive steps (diagnostic).  Pass NULL if not used
//  occs:        Computed occupancy for each PMT & bin.  Pass NULL if not used
//  vetos:       Computed vetos for each PMT & bin.  Pass NULL if not used
//  integrals:   Computed integralss for each PMT & bin.  Pass NULL if not used
//
//
//  07-Oct-2020 DFN Initial encapsulated version.  Default values of window,
//                  occupancy, coincidence level, etc. are hard coded.
//  29-Oct-2020 DFN Expanded arguments to include all values setable in the
//                  FPGA; added description of argument.
//

#ifndef __cplusplus
#include <stdbool.h>
#endif

#include <math.h>
#include <stdio.h>

#define UUB_FILT_LEN 682  // Length of UUB trace after downsampling
#define NWINDOW 121       // Length of 3us window for MoPS occupancy
#define IWINDOW 251       // Length of integration window
#define IDECAY 0.9995     // Exponential integral decay per 25 ns bin

bool compat_mops(int trace[3][768], int lothres[3], int hithres[3], 
                 bool enable[3],  int minPMT, int minIntegral, int minOcc,
                 int ofs, int steps[3][768], int totalsteps[3][768],
                 int occs[3][768], int vetos[3][768], int integrals[3][768])
{
  int i, j, k, l, p;
  double integral[3] = {0., 0., 0.};
  int occ[3] = {0, 0, 0};
  int pmtTrig[3] = {0, 0, 0};
  int veto[3] = {0, 0, 0};
  bool history[3][768];
  int step[3];
  int totalstep[3] = {0, 0, 0};
 
  // Scan trace.  Note that we have a issue starting at bin 0 since we need
  // the previous 250 bins for the integral reference and previous 120
  // bins for the occupancy.  To work around this
  // feature, we wrap from the end of the trace, but being careful to not
  // pick bins beyond the end of the original trace.
  // First make sure history is reset.
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
      {
        history[p][i] = false;
        if (&occs[0][0] != 0) occs[p][i] = 0;
        if (&vetos[0][0] != 0) vetos[p][i] = 0;
        if (&steps[0][0] != 0) steps[p][i] = 0;
        if (&totalsteps[0][0] != 0) totalsteps[p][i] = 0;
      }

  // Compute initial integral value -- important for fake data loaded into
  // the UUB.  Should not be detrimental for other traces.
  for (i=0; i<UUB_FILT_LEN; i++)
    {
      l = i - IWINDOW;
      if (l < 0) l = l + UUB_FILT_LEN;
      for (p=0; p<3; p++)
        {
          if (enable[p])
            {
              integral[p] = integral[p] + trace[p][i] - trace[p][l]; 
              integral[p] = integral[p] * IDECAY;
              if (integral[p] < 0) integral[p] = 0.;
            }         
        }
    }

  // Now scan the trace
  for (i=0; i<768; i++)
    {
      j = i - NWINDOW;
      if (j < 0) j = j + UUB_FILT_LEN;
      k = i-1;
      if (k < 0) k = k + UUB_FILT_LEN;
      l = i - IWINDOW;
      if (l < 0) l = l + UUB_FILT_LEN;
      for (p=0; p<3; p++)
        {
          if (enable[p])
            { 
              integral[p] = integral[p] + trace[p][i] - trace[p][l]; 
              integral[p] = integral[p] * IDECAY;
              if (integral[p] < 0) integral[p] = 0.;         

              history[p][i] = false;
              step[p] = trace[p][i] - trace[p][k];

              if (veto[p] <= 0)
                {
                  // Accumulate total step
                  if (step[p] >= 0) totalstep[p] = step[p] + totalstep[p];
        
                  // Finished positive step  
                  if (step[p] < 0)
                    {
                      if ((totalstep[p] > lothres[p]) 
                          && (totalstep[p] <= hithres[p]))
                        {
                          history[p][i] = true;
                          occ[p]++;
                        }

                      // One bin behind here so use -2 instead of -1
                      if( totalstep[p] > 0)
                        veto[p] = (int) log2((double) totalstep[p]) -2 -ofs;
                        // veto[p] = (int) log2((double) totalstep[p]) -1 -ofs;
                    }
                }
              if (history[p][j]) occ[p]--;
              if (step[p] < 0) totalstep[p] = 0;
              if (veto[p] > 0) veto[p]--;

              if (&occs[0][0] != 0) occs[p][i] = occ[p];
              if (&vetos[0][0] != 0) vetos[p][i] = veto[p];
              if (&steps[0][0] != 0) steps[p][i] = step[p];
              if (&totalsteps[0][0] != 0) totalsteps[p][i] = totalstep[p];
              if (&integrals[0][0] != 0) integrals[p][i] = integral[p];

              if ((occ[p] > minOcc) && (integral[p] > minIntegral))
                pmtTrig[p] = 1;
              else pmtTrig[p] = 0;
            }
        }
      if ((pmtTrig[0]+pmtTrig[1]+pmtTrig[2]) >= minPMT) return true;
    }
  return false;
}
