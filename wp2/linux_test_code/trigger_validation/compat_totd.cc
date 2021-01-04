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

#include <stdio.h>

#ifndef __cplusplus
  #include <stdbool.h>
#endif

#define UUB_FILT_LEN 682  // Length of UUB trace after downsampling
#define NWINDOW 120       // Length of 3us window for ToTD occupancy
#define IWINDOW 251       // Length of integration window
#define IDELAY 3          // Relative lag in integral re FPGA
#define ODELAY 3          // Relative lag in occupancy re FPGA
#define DDELAY 7          // Relative lag in deconvolution re FPGA
#define FRAC_BITS 11      // Value from sde_trigger_defs.h
#define DECAY_BITS 11     // Value from sde_trigger_defs.h
#define TRIG_POINT 228    // Bin at which OCC is reset to 0 if trigger

bool compat_totd(int trace[3][768], int lothres[3],
                 int hithres[3], bool enable[3], int minPMT, int minOcc,
                 int fd, int fn, int minIntegral, int maxADC,
                 int dtraces[3][768], int occs[3][768], int integrals[3][768])
{
  int i, j, k, l, m, p; 
  int integral[3];
  int occ[3];
  int pmtTrig[3];
  int dtrace[3][768];
  int adci, adcj;
  long long integrala[3];
  long long decay[3];

  for (p=0; p<3; p++)
    {
      integrala[p] = 0;
      integral[p] = 0;
      occ[p]= 0;
      pmtTrig[p] = 0;
    }
  
  
  // Zero out debug occupancy array
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
        if (&occs[0][0] != 0) occs[p][i] = 0;

  // Generate deconvoluted traces
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
          dtrace[p][k] = ((adci*64-adcj*fd)*fn+512)>>10;
          if (dtrace[p][k] > maxADC) dtrace[p][k] = maxADC;
          if (dtrace[p][k] < 0) dtrace[p][k] = 0;
	  if (&dtraces[0][0] != 0) dtraces[p][i] = dtrace[p][i];
	  if (&integrals[0][0] != 0) integrals[p][i] = integral[p];
        }
    }
 
 // Compute initial integral value -- important for fake data loaded into
 // the UUB.
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
	  if (integrala[p] < 0) integrala[p] = 0;
	  integral[p] = integrala[p] >> FRAC_BITS;

	  if (&integrals[0][0] != 0) integrals[p][i] = integral[p];
	}
    }

  // Also compute initial occupancy value.  Here we start with an empty
  // window to get initial occupancy count
  for (i=UUB_FILT_LEN-NWINDOW; i<UUB_FILT_LEN; i++)
    {
      j = i - ODELAY;
      if (j < 0) j = j + UUB_FILT_LEN;
      m = j - NWINDOW;
      if (m < 0) m = m + UUB_FILT_LEN;
      for (p=0; p<3; p++)
	{
	  if ((dtrace[p][j] > lothres[p]) && (dtrace[p][j] <= hithres[p]))
	    occ[p]++;
	  //	  if ((dtrace[p][m] > lothres[p]) && (dtrace[p][m] <= hithres[p]))
	  //  occ[p]--;
	  //  if (occ[p] < 0) occ[p] = 0;
	  //  if (i == TRIG_POINT) occ[p] = 0;
	  if (&occs[0][0] != 0) occs[p][i] = occ[p];
	}
    }
  
  // Scan trace.  Note that we have a issue starting at bin 0 since we need
  // the previous 120 bins for the baseline reference.  To work around this
  // feature, we wrap from near the end of the trace, careful to not use
  // bins which would be beyond the end of a UUB trace.
  for (i=0; i<768; i++)
    {
      j = i - ODELAY;
      if (j < 0) j = j + UUB_FILT_LEN;
      m = j - NWINDOW;
      if (m < 0) m = m + UUB_FILT_LEN;

      k = i - IDELAY;
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
	      if (integrala[p] < 0) integrala[p] = 0;
	      integral[p] = integrala[p] >> FRAC_BITS;
	  
              if ((dtrace[p][j] > lothres[p]) && (dtrace[p][j] <= hithres[p]))
                occ[p]++;
              if ((dtrace[p][m] > lothres[p]) && (dtrace[p][m] <= hithres[p]))
                occ[p]--;
              if (occ[p] < 0 ) occ[p] = 0;
              if ((occ[p] > minOcc) && (integral[p] > minIntegral))
                pmtTrig[p] = 1;
              else pmtTrig[p] = 0;

              if (&occs[0][0] != 0) occs[p][i] = occ[p];
              if (&dtraces[0][0] != 0) dtraces[p][i] = dtrace[p][i];
              if (&integrals[0][0] != 0) integrals[p][i] = integral[p];
            }
        }
      if ((pmtTrig[0]+pmtTrig[1]+pmtTrig[2]) >= minPMT) return true;
    }
  return false;
}
