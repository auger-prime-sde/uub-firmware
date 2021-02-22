
// compat_totd
//
// Perform compatibility ToTd trigger.  This code can be used for UB traces
// as well as filtered UUB traces. 
//
// Arguments:
//  trace:       traces for the 3 WCD PMT, length is UB compatible
//  lowthres:    lower threshold for the PMTs
//  hithresh:    high threshold for the PMTs
//  enable:      enable flags for which PMTs to include in trigger
//  minPMT:      Minimum number of PMTs satisfying the PMT trigger
//  minOcc:      Minimum occupancy required for PMT trigger
//  fd:          Decay constant (normally 45)
//  fn:          Normalizer (normally 54)
//  minIntegral: Minimum integrated signal
//  maxADC:      Maximum ADC value - set to 1023 for UB, 4095 for UUB
//  dtraces:     Deconvoluted trace (diagnostic).  Pass NULL if not used
//  occs:        Occupancies for each PMT (diagnostic).  Pass NULL if not used
//  integrals:   Computed integralss for each PMT & bin.  Pass NULL if not used
//
//
//  07-Oct-2020 DFN Initial encapsulated version.  Default values of window,
//                  occupancy, coincidence level, etc. are hard coded.
//  29-Oct-2020 DFN Expanded arguments to include all values setable in the
//                  FPGA; added description of arguments
//  06-Nov-2020 DFN Add baseline input & apply same restriction as in FPGA
//                  (don't allow ADC value below baseline)
//  07-Dec-2020 DFN Remove baseline input -- not needed.
//  11-Dec-2020 DFN Add computaton of initial occupancy values.
//  22-Dec-2020 DFN Add delay to integral to better agree with FPGA.
//  23-Dec-2020 DFN Add delay to occupancy to better agree with FPGA.
//  27-Dec-2020 DFN Add delay to deconvolution to better agree with FPGA.
//  30-Dec-2020 DFN Modify integral calculation to be fixed point as in FPGA
//  06-Jan-2021 DFN There is a small problem to use data use data from end of
//                  as pseudo before trace in that filter phase will be
//                  different as 2048 is not evenly divisable by 3.  So modify
//                  Code to only require that occupancy and integral be valid
//                  by the trigger point.
//  29-Jan-2021 DFN Final tuning of delays (IDELAY, ODELEY, BASE_LOOKAHEAD) to
//                  match FPGA timing.
//  01-Feb-2021 DFN Adjust integral decay to work with UB also.
//  02-Feb-2021 DFN Initial baseline estimate fails for big pulses;
//                  add loop until it converges.
//  16-Feb-2021 DFN Fix error in baseline convergence check.

#include <stdio.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif

// Note that th integral and occupancy coincidence are in different
// time bins of the display. The display of the integral is adjusted to match
// the debug output of the FPGA.  The integral delay here is to get the
// correct coincidence bin. 

#define UUB_FILT_LEN 683  // Length of UUB trace after downsampling
#define NWINDOW 120       // Length of 3us window for ToTD occupancy
#define IWINDOW 122       // Length of integration window (overlaps occ window)
#define IDELAY 2          // Integral lag wrt deconvolution in FPGA
#define ODELAY 2          // Occupancy lag wrt deconvolution in FPGA
#define DDELAY 7          // Deconvolution lag wrt ADC in FPGA.
#define FRAC_BITS 6       // Value from sde_trigger_defs.h
#define BASE_BITS 6       // Value from sde_trigger_defs.h
#define BASE_LOOKAHEAD -1 // # bins to look into future to match FPGA delays.
#define ONE_HALF (1 << (BASE_BITS-1))
#define ONE (1 << (BASE_BITS))
#define DECAY (1 << (FRAC_BITS-1))

bool compat_totd(int trace[3][768], int lothres[3],
                 int hithres[3], bool enable[3], int minPMT, int minOcc,
                 int fd, int fn, int minIntegral, bool isUUB,
                 int dtraces[3][768], int occs[3][768], int integrals[3][768],
		 int bases[3][768], int deltas[3][768])
{
  int i, j, k, l, m, n, p; 
  int dtr;
  int integral[3];
  int occ[3];
  int pmtTrig[3];
  int dtrace[3][768];
  int adci, adcj;
  int base[3];
  int old_base[3];
  int integrala[3];
  int decay[3];
  int delta[3];
  int prev_integral[3][768];
  bool trig;
  int frac_bits;
  int base_bits;
  int maxADC;
  
  // Adjust frac_bits if using UB
  frac_bits = FRAC_BITS;
  base_bits = BASE_BITS;
  maxADC = 4095;
  if (!isUUB)
    {
    frac_bits = frac_bits + 2;
    base_bits = base_bits + 2;
    maxADC = 1023;
    }
  
  for (p=0; p<3; p++)
    {
      integrala[p] = 0;
      integral[p] = 0;
      decay[p] = 0;
      delta[p] = 0;
      occ[p]= 0;
      pmtTrig[p] = 0;
      base[p] = 0;
    }
  trig = false;
  
  // Zero out debug occupancy array
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
	prev_integral[p][i] = 0;

  // Get initial baseline
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
      
  // Generate deconvoluted traces
  // Edge bins may not be fully valid
  for (i=0; i<768; i++)
    {
      j = i-1;
      if (j < 0) j = j+768;
      k = i + DDELAY;
      if (k > 767) k = k-768;
      for (p=0; p<3; p++)
        {
          adci = trace[p][i];
          adcj = trace[p][j];
          dtr = adci*64-adcj*fd;
	  if (dtr < 0) dtr = 0;
          dtrace[p][k] = (dtr*fn + (1<<9)) >> 10;
          if (dtrace[p][k] > maxADC) dtrace[p][k] = maxADC;
          if (dtrace[p][k] < 0) dtrace[p][k] = 0;

	  if (&dtraces[0][0] != 0) dtraces[p][i] = dtrace[p][i];
	  if (&integrals[0][0] != 0) integrals[p][i] = 0;
	  if (&bases[0][0] != 0) bases[p][i] = 0;
	  if (&deltas[0][0] != 0) deltas[p][i] = 0;
        }
    }

  // Scan through trace
  for (i=0; i<768; i++)
    {
      j = i - ODELAY;
      if (j < 0) j = j + UUB_FILT_LEN;
      m = j - NWINDOW;
      // if (m < 0) m = m + UUB_FILT_LEN;

      k = i - IDELAY - DDELAY;
      if (k < 0) k = k + UUB_FILT_LEN;
      l = k - IWINDOW;
      if (l < 0) l = 0;
      
      //      n = k + BASE_LOOKAHEAD + DDELAY;
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

	      // Compute occupancies
              if ((dtrace[p][j] > lothres[p]) && (dtrace[p][j] <= hithres[p]))
                occ[p]++;
	      if (m >= 0)
		if ((dtrace[p][m] > lothres[p]) && (dtrace[p][m] <= hithres[p]))
		  occ[p]--;
              if (occ[p] < 0 ) occ[p] = 0;

	      // (pre-)trigger for this PMT?
              if ((occ[p] > minOcc) && (integral[p] > minIntegral))
                pmtTrig[p] = 1;
              else pmtTrig[p] = 0;

	      // Return debugging information
              if (&occs[0][0] != 0) occs[p][i] = occ[p];
              if (&integrals[0][0] != 0) integrals[p][i] = integral[p];
              if (&bases[0][0] != 0) bases[p][i] = base[p] >> (frac_bits - 6);
              if (&deltas[0][0] != 0) deltas[p][i] = delta[p] >> 4;
            }
        }
      if ((pmtTrig[0]+pmtTrig[1]+pmtTrig[2]) >= minPMT) trig = true;
    }
  return trig;
}
