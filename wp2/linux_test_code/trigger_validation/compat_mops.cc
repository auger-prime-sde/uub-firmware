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
//  27-Jan-2021 DFN Modify integral calculation to reference running baseline
//                  and use linear decay to avoid having to look back (much)
//                  before the beginning of the trace.
//  29-Jan-2021 DFN Tweak delays (SDELAY, IDELAY, BASE_LOOKAHEAD) to better
//                  match FPGA timing.
//  01-Feb-2021 DFN Adjust integral decay to work with UB also.
//  02-Feb-2021 DFN Initial baseline estimate fails for big pulses;
//                  add loop until it converges.
//  16-Feb-2021 DFN Update veto calculation for UB; Fix error in baseline
//                  convergence check.
//  19-Feb-2021 DFN Tweak veto calculation for UUB to be consistent with UB

#ifndef __cplusplus
#include <stdbool.h>
#endif

#include <math.h>
#include <stdio.h>

#define UUB_FILT_LEN 682  // Length of UUB trace after downsampling
#define NWINDOW 120       // Length of 3us window for MoPS occupancy
#define IWINDOW 122       // Length of integration window (overlaps occ window)
#define SDELAY 3          // Relative lag in step re FPGA
#define IDELAY 3          // Relative lag in integral re FPGA
#define FRAC_BITS 6       // Value from sde_trigger_defs.h
#define BASE_BITS 6       // Value from sde_trigger_defs.h
#define BASE_LOOKAHEAD -1 // # bins to look into future to match FPGA.
#define ONE_HALF (1 << (BASE_BITS-1))
#define ONE (1 << (BASE_BITS))
#define DECAY (1 << (FRAC_BITS-1))

bool compat_mops(int trace[3][768], int lothres[3], int hithres[3], 
                 bool enable[3],  int minPMT, int minIntegral, int minOcc,
                 int ofs, bool isUUB, int steps[3][768], int totalsteps[3][768],
                 int occs[3][768], int vetos[3][768], int integrals[3][768],
		 int bases[3][768])
{
  int i, j, k, l, m, n, o, p;
  int integral[3];
  int occ[3];
  int pocc[3];
  int pmtTrig[3];
  int veto[3];
  int step[3];
  int totalstep[3];
  int base[3];
  int old_base[3];
  int integrala[3];
  int decay[3];
  int delta[3];
  int prev_integral[3][768];
  bool history[3][768];
  bool trig;
  int frac_bits;
  int base_bits;
  double eps = 1.e-4;
  
  // Adjust frac_bits if using UB
  frac_bits = FRAC_BITS;
  base_bits = BASE_BITS;
  if (!isUUB)
    {
    frac_bits = frac_bits + 2;
    base_bits = base_bits + 2;
    }
  
  for (p=0; p<3; p++)
    {
      integrala[p] = 0;
      integral[p] = 0;
      pocc[p]= 0;
      pmtTrig[p] = 0;
      veto[p] = 0;
      step[p] = 0;
      totalstep[p] = 0;
      base[p] = 0;
    }
  trig = false;

  // Zero out debug occupancy array
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
	prev_integral[p][i] = 0;

  // Get initial baseline.  A really big signal will mess up this initial
  // baseline calculation.
  for (p=0; p<3; p++)
    {
      for (i=0; i<768; i++)
	{
	  base[p] = base[p] + (trace[p][i] << frac_bits);
	}
      base[p] = base[p]/768;
      old_base[p] = 9999 << frac_bits;
      while ((old_base[p] - base[p]) >  (2 << (frac_bits - base_bits)))
	{
	  old_base[p] = base[p];
	  for (i=0; i<768; i++)
	    {
	      if ((trace[p][i] << frac_bits) > base[p])
		base[p] = base[p] + (2 << (frac_bits - base_bits));
	      else if ((trace[p][i] << frac_bits) < base[p])
		base[p] = base[p] - (2 << (frac_bits - base_bits));
	    }
	}
      // Try to ensure we start a bit below the real baseline.
      base[p] = base[p] - (4 << (frac_bits - base_bits));
    }
  
  // Scan trace. First make sure history is reset.
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
      {
        history[p][i] = false;
        if (&occs[0][0] != 0) occs[p][i] = 0;
        if (&vetos[0][0] != 0) vetos[p][i] = 0;
        if (&steps[0][0] != 0) steps[p][i] = 0;
        if (&totalsteps[0][0] != 0) totalsteps[p][i] = 0;
	if (&integrals[0][0] != 0) integrals[p][i] = 0;
	if (&bases[0][0] != 0) bases[p][i] = 0;
      }
	    
  // Now scan the trace for triggers
  for (i=0; i<768; i++)
    {
      j = i - SDELAY;
      if (j < 0) j = j + UUB_FILT_LEN;
      m = j - NWINDOW;
      if (m < 0) m = m + UUB_FILT_LEN;
      o = j - 1;
      if (o < 0) o = o + UUB_FILT_LEN;
      
      k = i - IDELAY;
      if (k < 0) k = k + UUB_FILT_LEN;
      l = k - IWINDOW;
      if (l < 0) l = 0;

      n = k + BASE_LOOKAHEAD;
      if (n > UUB_FILT_LEN) n = n - UUB_FILT_LEN;
      if (n < 0) n = n + UUB_FILT_LEN;

      // New algorithm for integrals.  Here we compare to
      // computed running baseline. 
      for (p=0; p<3; p++)
        {
          if (enable[p])
            {
	      decay[p] = DECAY;
	      delta[p] = (trace[p][k] << frac_bits) - base[p];

	      // Keep track of baseline
	      if ((trace[p][n] << frac_bits) > base[p] + ONE)
		base[p] = base[p] + (4 << (frac_bits - base_bits));
	      else if ((trace[p][n] << frac_bits) > base[p] + ONE_HALF)
		base[p] = base[p] + (2 << (frac_bits - base_bits));
	      else if ((trace[p][n] << frac_bits) > base[p])
		base[p] = base[p] + (1 << (frac_bits - base_bits));
	      else if ((trace[p][n] << frac_bits) < base[p] - ONE)
		base[p] = base[p] - (4 << (frac_bits - base_bits));
	      else if ((trace[p][n] << frac_bits) < base[p] - ONE_HALF)
		base[p] = base[p] - (2 << (frac_bits - base_bits));
	      else if ((trace[p][n] << frac_bits) < base[p])
		base[p] = base[p] - (1 << (frac_bits - base_bits));
		
	      integrala[p] = integrala[p] + delta[p];
	      integrala[p] = integrala[p] - decay[p];

	      // Need to be careful here if integrala is negative.
	      if (integrala[p] < 0)
		integrala[p] = 0;

	      // Cap integral a maximum allowed value
	      if (integrala[p] > ((2*minIntegral) <<  frac_bits))
		integrala[p] = (2*minIntegral) << frac_bits;

	      // Reset after integration period if integral enough for trig
	      if (prev_integral[p][l] > minIntegral)
		integrala[p] = 0;

	      // Extract integer portion of integral & save in history
	      integral[p] = integrala[p] >> frac_bits;
	      prev_integral[p][k] = integral[p];

	      // Process steps
	      history[p][j] = false;
              step[p] = trace[p][j] - trace[p][o];
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

                       if( totalstep[p] > 0)
			{
			  // -1 should work with THIS_OFS == OFS+3, but it does not. -2 seems
			  // to be required for OFS+3, and works far better than any other comb.
			  // if (isUUB) veto[p] = (int) (log2((double) totalstep[p]) +eps -1 -ofs);
			  if (isUUB) veto[p] = (int) (log2((double) totalstep[p]) +eps -2 -ofs);

			  // This works with THIS_OFS == OFS+2, at least for small sample of events
			  // It is a bit worriome that constant is not different by 2 from the UB
			  // case but that could be explained by a timing difference.  However,
			  // this combination is not nearly as good as the one above.
			  // if (isUUB) veto[p] = (int) (log2((double) totalstep[p]) +eps -0 -ofs);

			  // For UB need to account for different ADC range
			  if (!isUUB) veto[p] = (int) (log2((double) totalstep[p]) +eps +1 -ofs);
			}
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
              if (&bases[0][0] != 0) bases[p][i] = base[p] >> (frac_bits - 6);

              if ((occ[p] > minOcc) && (integral[p] > minIntegral))
                pmtTrig[p] = 1;
              else pmtTrig[p] = 0;
            }
        }
      if ((pmtTrig[0]+pmtTrig[1]+pmtTrig[2]) >= minPMT) trig = true;
    }
  return trig;
}
