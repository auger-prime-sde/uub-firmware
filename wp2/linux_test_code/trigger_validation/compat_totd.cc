// compat_totd
//
// Perform compatibility ToTd trigger.  This code can be used for UB traces
// as well as filtered UUB traces. 
//
// Arguments:
//  trace:       traces for the 3 WCD PMT, length is UB compatible
//  baseline:    baselines for the PMTs
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

#ifndef __cplusplus
  #include <stdbool.h>
#endif

#define UUB_FILT_LEN 682  // Length of UUB trace after downsampling
#define NWINDOW 121       // Length of 3us window for MoPS occupancy
#define IWINDOW 251       // Length of integration window
#define IDECAY 0.9995     // Exponential integral decay per 25 ns bin

bool compat_totd(int trace[3][768], double baseline[3], int lothres[3],
                 int hithres[3], bool enable[3], int minPMT, int minOcc,
                 int fd, int fn, int minIntegral, int maxADC,
                 int dtraces[3][768], int occs[3][768], int integrals[3][768])
{
  int i, j, l, p; 
  double integral[3] = {0, 0, 0};
  int occ[3] = {0, 0, 0};
  int pmtTrig[3] = {0, 0, 0};
  int dtrace[3][768];
  int adci, adcj;


  // Zero out debug occupancy array
  for (i=0; i<768; i++)
    for (p=0; p<3; p++)
        if (&occs[0][0] != 0) occs[p][i] = 0;

  // Generate deconvoluted traces
  for (i=0; i<768; i++)
    {
      j = i-1;
      if (j < 0) j = j+768;
      for (p=0; p<3; p++)
        {
          adci = trace[p][i];
          adcj = trace[p][j];
          // Is this limiting necessary??
          //          if (adci < baseline[p]) adci = baseline[p];
          // if (adcj < baseline[p]) adcj = baseline[p];
          dtrace[p][i] = ((adci*64-adcj*fd)*fn+512)>>10;
          if (dtrace[p][i] > maxADC) dtrace[p][i] = maxADC;
          if (dtrace[p][i] < 0) dtrace[p][i] = 0;
        }
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
              integral[p] = integral[p] + trace[p][i] - trace[p][l]; 
              integral[p] = integral[p] * IDECAY;
              if (integral[p] < 0) integral[p] = 0.;         
        }
    }
  // Scan trace.  Note that we have a issue starting at bin 0 since we need
  // the previous 120 bins for the baseline reference.  To work around this
  // feature, we wrap from near the end of the trace, careful to not use
  // bins which would be beyond the end of a UUB trace.

  for (i=0; i<768; i++)
    {
      j = i - NWINDOW;
      if (j < 0) j = j + UUB_FILT_LEN;
      l = i - IWINDOW;
      if (l < 0) l = l + UUB_FILT_LEN;
      for (p=0; p<3; p++)
        {
          if (enable[p])
            {
              integral[p] = integral[p] + trace[p][i] - trace[p][l]; 
              integral[p] = integral[p] * IDECAY;
              if (integral[p] < 0) integral[p] = 0.;   

              if ((dtrace[p][i] > lothres[p]) && (dtrace[p][i] <= hithres[p]))
                occ[p]++;
              if ((dtrace[p][j] > lothres[p]) && (dtrace[p][j] <= hithres[p]))
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
