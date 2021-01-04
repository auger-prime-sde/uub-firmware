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
//  27-Dec-2020 DFN Add delay to steps, integral, and occupancy to agree
//                  with FPGA.
//  30-Dec-2020 DFN Modify integral calculation to be fixed point as in FPGA
//

#ifndef __cplusplus
#include <stdbool.h>
#endif

#include <math.h>
#include <stdio.h>

#define UUB_FILT_LEN 682  // Length of UUB trace after downsampling
#define NWINDOW 120       // Length of 3us window for MoPS occupancy
#define IWINDOW 250       // Length of integration window
#define IDELAY 2          // Relative lag in integral re FPGA
#define SDELAY 3          // Relative lag in steps re FPGA
#define FRAC_BITS 11      // Value from sde_trigger_defs.h
#define DECAY_BITS 11     // Value from sde_trigger_defs.h

bool compat_mops(int trace[3][768], int lothres[3], int hithres[3], 
                 bool enable[3],  int minPMT, int minIntegral, int minOcc,
                 int ofs, int steps[3][768], int totalsteps[3][768],
                 int occs[3][768], int vetos[3][768], int integrals[3][768])
{
  int i, j, k, l, m, n, p;
  int integral[3];
  int occ[3];
  int pocc[3];
  int pmtTrig[3];
  int veto[3];
  bool history[3][768];
  int step[3];
  int totalstep[3];
  long long integrala[3];
  long long decay[3];
  
  for (p=0; p<3; p++)
    {
      integrala[p] = 0;
      integral[p] = 0;
      pocc[p]= 0;
      pmtTrig[p] = 0;
      veto[p] = 0;
      step[p] = 0;
      totalstep[p] = 0;
    }
  
  // Scan trace.  Note that we have a issue starting at bin 0 since we need
  // the previous 250 bins for the integral reference and previous 120
  // bins for the occupancy.  To work around this
  // feature, we wrap from the end of the trace, but being careful to not
  // pick bins beyond the end of the original trace.
  // First make sure history is reset.
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
      {
        history[p][i] = true;
        if (&occs[0][0] != 0) occs[p][i] = 0;
        if (&vetos[0][0] != 0) vetos[p][i] = 0;
        if (&steps[0][0] != 0) steps[p][i] = 0;
        if (&totalsteps[0][0] != 0) totalsteps[p][i] = 0;
	if (&integrals[0][0] != 0) integrals[p][i] = 0;
      }

  // Compute initial integral value -- important for fake data loaded into
  // the UUB.  Should not be detrimental for other traces.
  for (i=0; i<UUB_FILT_LEN; i++)
    {
      k = i - IDELAY;
      if (k < 0) k = k + UUB_FILT_LEN;
      l = k - IWINDOW;
      if (l < 0) l = l + UUB_FILT_LEN;
      for (p=0; p<3; p++)
        {
	  decay[p] = integrala[p] >> DECAY_BITS;
	  integrala[p] = integrala[p] + (trace[p][k] << FRAC_BITS);
	  integrala[p] = integrala[p] - (trace[p][l] << FRAC_BITS);
	  integrala[p] = integrala[p] - decay[p];
	  if (integrala[p] <0 ) integrala[p] = 0;
	  integral[p] = integrala[p] >> FRAC_BITS;

	  if (&integrals[0][0] != 0) integrals[p][i] = integral[p];
	}
    }

  //    Compute initial occupancies
  for (i=0; i<UUB_FILT_LEN; i++)
    {
      for (p=0; p<3; p++)
	{
	  j = i - SDELAY;
	  if (j < 0) j = j + UUB_FILT_LEN;
	  m = j - NWINDOW;
	  if (m < 0) m = j + UUB_FILT_LEN;
	  n = j - 1;
	  if (n < 0) n = n + UUB_FILT_LEN;
	    
	  history[p][j] = false;
	  step[p] = trace[p][j] - trace[p][n];
	  occ[p] = pocc[p];
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
		      history[p][j] = true;
		      pocc[p]++;
		    }
	      
		  // One bin behind here so use -2 instead of -1
		  if( totalstep[p] > 0)
		    veto[p] = (int) log2((double) totalstep[p]) -2 -ofs;
		}
	    }
	  if (history[p][m]) pocc[p]--;
	  if (pocc[p] < 0) pocc[p] = 0;
	  if (step[p] < 0) totalstep[p] = 0;
	  if (veto[p] > 0) veto[p]--;

	  if (&occs[0][0] != 0) occs[p][i] = occ[p];
	  if (&vetos[0][0] != 0) vetos[p][i] = veto[p];
	  if (&steps[0][0] != 0) steps[p][i] = step[p];
	  if (&totalsteps[0][0] != 0) totalsteps[p][i] = totalstep[p];
	}
    }
	    
  // Now scan the trace for triggers
  for (i=0; i<768; i++)
    {
      j = i - SDELAY;
      if (j < 0) j = j + UUB_FILT_LEN;
      m = j - NWINDOW;
      if (m < 0) m = j + UUB_FILT_LEN;
      n = j - 1;
      if (n < 0) n = n + UUB_FILT_LEN;
      k = i-IDELAY;
      if (k < 0) k = k + UUB_FILT_LEN;
      l = k - IWINDOW;
      if (l < 0) l = l + UUB_FILT_LEN;

      for (p=0; p<3; p++)
        {
          if (enable[p])
            {
	      decay[p] = integrala[p] >> DECAY_BITS;
	      integrala[p] = integrala[p] + (trace[p][k] << FRAC_BITS);
	      integrala[p] = integrala[p] - (trace[p][l] << FRAC_BITS);
	      integrala[p] = integrala[p] - decay[p];
	      if (integrala[p] <0 ) integrala[p] = 0;
	      integral[p] = integrala[p] >> FRAC_BITS;

              history[p][j] = false;
              step[p] = trace[p][j] - trace[p][n];
  	      occ[p] = pocc[p];
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
                          history[p][j] = true;
                          pocc[p]++;
                        }

                      // One bin behind here so use -2 instead of -1
                      if( totalstep[p] > 0)
                        veto[p] = (int) log2((double) totalstep[p]) -2 -ofs;
                    }
                }
              if (history[p][m]) pocc[p]--;
  	      if (pocc[p] < 0) pocc[p] = 0;
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
