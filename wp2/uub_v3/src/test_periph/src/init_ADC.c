//************************************************************************
//
// @file init_ADC.c
//
// @note
//
// None.
//
// MODIFICATION HISTORY:
//
// 06-Feb-2016 DFN Added more comments in English (starting from Robert
//                 Assiro's version.
// 24-Feb-2016 DFN Changed polarity of ADC output so negative pulses appear
//                 as positive signals, and baseline is near zero.
//                 Modified eye scan to go both positive and negative clock
//                 data offsets.  Changed output format of SendADCData to hex.
// 11-Mar-2016 DFN Bundled ADC SPI commands into function SpiADC
// 29-Jul-2016 DFN Rename to init_ADC.c to be more clear what it does
//
//***********************************************************************
 

//************************** Include Files ******************************
 
#include "xparameters.h"  /* EDK generated parameters */
#include "xspips.h"       /* SPI device driver */
#include "xil_printf.h"
#include "new_uub.h"
#include "stdio.h"
#include "test_periph.h"
#include "trigger_test_options.h"
#include "trigger_test.h"

//*********************** Constant Definitions ************************
 
// The following constant defines the slave select signal that is used to 
// select the ADC device on the SPI bus
  
#define SPI_SELECT_ADC0 0x00
#define SPI_SELECT_ADC1 0x01
#define SPI_SELECT_ADC2 0x02
#define SPI_SELECT_ADC3 0x03
#define SPI_SELECT_ADC4 0x04

#define SEARCH_EYE
#define MAXLOOP 100000
#define BASELINE_INCR (1./64.)
#define BASELINE_GOAL 300.
 
XSpiPs Spi;
 
#define read_buffer_size  10                // size of the SPI read buffer
#define write_buffer_size 10                // size of the SPI write buffer
u8 ReadBuffer[read_buffer_size]   = {0x00}; // SPI read buffer initialize to 0
u8 WriteBuffer[write_buffer_size] = {0x00}; // SPI write buffer initialize to 0

static u8 ADC_OFFSET[3] = {0x00,0x10,0x00} ; // ADC: Offset adjust
static u8 ADC_LVDS[3] = {0x00,0x14,0xA4} ; // ADC: LVDS interleave, binary, inverted 
static u8 ADC_RESET[3] = {0x00,0x00,0x3C} ; // ADC soft reset
static u8 ADC_DIGRESET[3] = {0x00,0x08,0x03} ; // ADC digital reset
static u8 ADC_VREF[3] = {0x00,0x18,0x04} ; // ADC VREF setting
static u8 ADC_OVERRANGE[3] = {0x00,0x2A,0x1} ; // Specify over range bit
static u8 ADC_DELAY[3] = {0x00,0x17,0x25} ; // ADC delay
static u8 TRANSFER[3] = {0x00,0xff,0x01} ; // ADC delay

// R/W = 0, W1-W0 = 0, @ high = 0 ; @ register = 0x14; data to write = A1
static u8 cmd2channel[3] = {0x00,0x05,0x03}; // Select both channels for next cmd
static u8 cmdchannelA[3] = {0x00,0x05,0x01}; // Select the channel A for next cmd
static u8 cmdchannelB[3] = {0x00,0x05,0x02}; // Select the channel B for next cmd

static u8 TestModeMS[3]  = {0x00,0x0D,0x01}; // ADC Test Mode Middle Scale
static u8 TestModeFS[3]  = {0x00,0x0D,0x02}; // ADC Test Mode Full Scale
static u8 TestModeNFS[3]  = {0x00,0x0D,0x03}; // ADC Test Mode Full Scale
static u8 TestModeOff[3] = {0x00,0x0D,0x00}; // ADC Test Mode Off
static u8 TestModeRM[3] = {0x00,0x0D,0x5F}; // ADC Test Mode Ramp
static u8 TestModeA5[3] = {0x00,0x0D,0x44}; // ADC Test Mode AAA555

u8 DataUserValueMsb = 0xAA;
u8 DataUserValueLsb = 0x55;
static u8 TstUser1LSB[3] = {0x00,0x19,0x55}; // User defined pattern 1 LSB
static u8 TstUser1MSB[3] = {0x00,0x1A,0xAA}; // User defined pattern 1 MSB
static u8 TestModeUM[3]  = {0x00,0x0D,0x08}; // ADC Test Mode USER1
static u8 AdcDelay[5]    = {0x00};           // Calculated ADC delay table
static u8 DelayCodes[17] = {0x87,0x86,0x85,0x84,0x83,0x82,0x81,0x80,0x00,
                            0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27};

void SpiADC(u8 select, u8 chanAB, u8 writebuf[3],u8 readbuf[3]);
void find_baseline(double baseline[]);
void adjust_baseline();
 
//************************************************************************
// 
//  This function initializes the five ADC chips throught the XSpiPs device 
//  driver configurated in polled mode. 
// 
//  @param  SpiInstancePtr is a pointer to the Spi Instance.
//  @param  SpiDeviceId is the Device Id of Spi.
// 
//  @return XST_SUCCESS if successful else XST_FAILURE.
// 
//  @note
// 
//*************************************************************************
int init_ADC(u16 SpiDeviceId, char valid_display)
{
  int Status,j;
  u8 k;   
  XSpiPs_Config *SpiConfig;
  int adc_address, adcfilt_addr;
  int data_display, data_prev;
  char channel_first,channel_second,channel_last;

  printf("\n");
 
  // Initialize the SPI driver so that it's ready to use
  SpiConfig = XSpiPs_LookupConfig(SpiDeviceId);
  if (NULL == SpiConfig) { return XST_FAILURE; }
 
  Status = XSpiPs_CfgInitialize(&Spi, SpiConfig, SpiConfig->BaseAddress);
  if (Status != XST_SUCCESS) { return XST_FAILURE; }
 
  // Perform a self-test to check hardware build
  Status = XSpiPs_SelfTest(&Spi);
  if (Status != XST_SUCCESS) { return XST_FAILURE; }
 
  // Set the SCLK frequency to SPI_REF_CLK / XSPIPS_CLK_PRESCALE_xx
  XSpiPs_SetClkPrescaler(&Spi, XSPIPS_CLK_PRESCALE_32);
  if (Status != XST_SUCCESS) { return XST_FAILURE; }
 
  // Set the Spi device as a master ( is slave by default).
  Status = XSpiPs_SetOptions(&Spi, XSPIPS_MASTER_OPTION |
			     XSPIPS_FORCE_SSELECT_OPTION |
			     XSPIPS_DECODE_SSELECT_OPTION);
  if (Status != XST_SUCCESS) { return XST_FAILURE; }
  usleep(10000); // Is wait necessary?
   
  //**********************************************************************
  //                    Initialize The ADC components  
  //**********************************************************************
 
  // ADC AD9628 configuration : * Output format : offset binary
  //                            * Output port logic : LVDS ANSI
  //                            * Output interleave
   
  // Cycle through all the ADCs
  for (k = SPI_SELECT_ADC0; k < (SPI_SELECT_ADC4 + 0x01); k++)
    {
      SpiADC(k, 3, ADC_RESET, ReadBuffer);// RESET
      SpiADC(k, 3, ADC_LVDS, ReadBuffer);// send bus configuration
      SpiADC(k, 3, ADC_OVERRANGE, ReadBuffer);// send overrange config
      SpiADC(k, 3, ADC_VREF, ReadBuffer);// send VREF configuration
 
      //******************************************************************
      //                 Search the middle of the eye
      //******************************************************************

#ifdef SEARCH_EYE
      SpiADC(k, 2, TestModeFS, ReadBuffer);  // A & B full Scale
      SpiADC(k, 1, TstUser1MSB, ReadBuffer); // User pattern MSB = 0x0A
      SpiADC(k, 1, TstUser1LSB, ReadBuffer);  // User pattern LSB = 0x55
      SpiADC(k, 1, TestModeUM, ReadBuffer);
      //      SpiADC(k, 3, TRANSFER, ReadBuffer);  // Not sure if this does anything
      //      usleep(10000);  // Wait a while??
       
      WriteBuffer[0] = 0x00;  // writing cycle
      WriteBuffer[1] = 0x17;  // @ register : Output Delay   
      adc_address = ADC0_TEST_ADDR + k; 
      channel_first = 0xff;
      channel_second = 0xff;
      channel_last = 0xff;
      data_prev = 0;
       
      if ( valid_display == 1 ) { print("\r\n"); } // Format the display
      for (j = 0; j<17;j++)
        {
          WriteBuffer[2] = DelayCodes[j];        // data to write
          SpiADC(k, 3, WriteBuffer, ReadBuffer); // send delay
          SpiADC(k, 3, TRANSFER, ReadBuffer);
          usleep(10000);  // Wait a while
          data_display = read_trig(adc_address);
	  if ((data_display & 0xfff) == 0x55A)  // Why AA5 and not A55?
	    { 
	      if (((data_display >> 16) & 0xfff) == 0x000)  // Also check channel B
		{
		  if ((channel_first != 0xff) && (channel_second == 0xff))
		    {
                      if (channel_first == j-1)
                        channel_second = j;
                      else
                        channel_first = 0xff;
                    }
		  if ( channel_first == 0xff)
		    channel_first = j ;
		  if ((channel_first != 0xff) && 
		      (channel_second != 0xff) && 
		      (data_prev == 0x55A))
		    channel_last = j;
		}
	    }
	  data_prev = data_display & 0xfff;
	  if (valid_display == 1)
	    {
	      printf( " Delay = %2d, data_delay = %2x, Ch A = %3x,  Ch B = %3x",
		      j,DelayCodes[j],data_display & 0xfff,
		      (data_display >>16) & 0xfff);
              if (k < 3)
                {
            	  adcfilt_addr = FILT_PMT0_TEST_ADDR+k;
                  data_display = read_trig(adcfilt_addr);
                  printf( ",  Ch B filt = %3x,  Ch B full filt = %4x\n",
                          data_display & 0xfff,
                          (data_display >>16) & 0x3fff);
                } else
                printf("\n");
	    }
        }
              
      // Set delay to average of first+last sighting of 55A.  But if don't
      // see desired pattern set delay to 0 as fallback.
      if ((channel_first == 255) || (channel_last == 255))
        WriteBuffer[2] = 0;
      else
        WriteBuffer[2] = DelayCodes[(channel_first + channel_last)>> 1];
      AdcDelay[k] = WriteBuffer[2];
      printf(" Selected delay for ADC %d = %x channel_first=%d channel_last=%d\n",
             k, AdcDelay[k], channel_first, channel_last);
      SpiADC(k, 3, WriteBuffer, ReadBuffer); // send delay
#ifdef RAMP
      SpiADC(k, 3, TestModeRM, ReadBuffer);  // Ramp test
#else
      SpiADC(k, 3, TestModeOff, ReadBuffer);  // Turn off test mode
#endif
#else
      // Check ADC in normal mode
      adc_address = ADC0_TEST_ADDR + k; 
      data_display = read_trig(adc_address);
      printf( " In normal mode ADC %d  Ch A = %4x,  Ch B = %4x\r\n",
              k, data_display & 0xfff, (data_display >>16) & 0xfff);
#endif


     }

#ifdef ADJUST_BASELINE
  // Adjust ADC baselines
  adjust_baseline();
#endif

  return XST_SUCCESS;
}  
   
void SpiADC(u8 select, u8 chanAB, u8 writebuf[3],u8 readbuf[3])
{
  u8 readtmp[10];
  u8 writetmp[10];

  writetmp[0] = writebuf[0] | 0x80;
  writetmp[1] = writebuf[1];
  writetmp[2] = 0;
  readbuf[0] = 0;
  readbuf[1] = 0;
  readbuf[2] = 0;
  XSpiPs_SetSlaveSelect(&Spi, select);               // Assert the chip select
   if (chanAB == 1) 
    XSpiPs_PolledTransfer(&Spi, cmdchannelA, readtmp, 3); // Select channels
  if (chanAB == 2) 
    XSpiPs_PolledTransfer(&Spi, cmdchannelB, readtmp, 3); // Select channels
  if (chanAB == 3) 
    XSpiPs_PolledTransfer(&Spi, cmd2channel, readtmp, 3); // Select channels
  XSpiPs_PolledTransfer(&Spi, writebuf, readtmp, 3); // Do the command
  XSpiPs_PolledTransfer(&Spi, writetmp, readbuf, 3); // Readback register

  // Check register contents
  if ((readbuf[2] != writebuf[2]) && (writebuf[1] != 0) && (writebuf[1] != 0xff))
      printf("SPI error: wrote %x read %x from reg. %x\n",
             writebuf[2], readbuf[2], writebuf[1]);
}

// adjust_baseline.c
//
// Routine to track & try to adjust the baseline of all the ADCs to be the
// same value.  Note: The ADC & ADC SPI must have been previously initialized
// by Init_ADC.
//
// 12-Dec-2016 DFN Initial version
//

void adjust_baseline()
{
  int k;
  int ilg, ihg;
  int offset;
  double baseline[10];

  for (k=0; k<10; k++)
    baseline[k] = BASELINE_GOAL;

  // Find the current baselines
  find_baseline(baseline);

  // After measuring baseline, now try to add digital offset to bring back to 
  // nominal value.

  // Cycle through all the ADCs
  for (k = 0; k < 5; k++)
    {
      ilg = 2*k;
      ihg = 2*k+1;

      offset = (baseline[ilg] - BASELINE_GOAL + .5);
      if (offset < -128) offset = -128;
      if (offset > 127) offset = 127;
      WriteBuffer[0] = ADC_OFFSET[0];
      WriteBuffer[1] = ADC_OFFSET[1];
      WriteBuffer[2] = offset;
      SpiADC(k, 1, WriteBuffer,ReadBuffer);

      offset = (baseline[ihg] - BASELINE_GOAL + .5);
      if (offset < -128) offset = -128;
      if (offset > 127) offset = 127;
      WriteBuffer[0] = ADC_OFFSET[0];
      WriteBuffer[1] = ADC_OFFSET[1];
      WriteBuffer[2] = offset;
      SpiADC(k, 2, WriteBuffer,ReadBuffer);
    }
  printf("Digital offset added to baselines\n\n");

  // Check adjusted baselines
  for (k=0; k<10; k++)
     baseline[k] = BASELINE_GOAL;
  find_baseline(baseline);
} 

void find_baseline(double baseline[10])
{
  int i, k;
  int ilg, ihg, reg_addr;
  int high_gain[5], low_gain[5];
  int value;

  // Measure current baseline
  for (i=0; i<MAXLOOP; i++)
    {   

      // Cycle through all the ADCs
      for (k = 0; k < 5; k++)
        {
          ilg = 2*k;
          ihg = 2*k+1;
          reg_addr = ADC0_TEST_ADDR + k;
          value = read_trig(reg_addr);
          high_gain[k] = (value >>16) & 0xfff;
          low_gain[k] = value & 0xfff;
          if (low_gain[k] > baseline[ilg])
            baseline[ilg] = baseline[ilg] + BASELINE_INCR;
          else
            baseline[ilg] = baseline[ilg] - BASELINE_INCR;

          if (high_gain[k] > baseline[ihg])
            baseline[ihg] = baseline[ihg] + BASELINE_INCR;
          else
            baseline[ihg] = baseline[ihg] - BASELINE_INCR;
        }

      if (i%10000 == 0) {
          printf("Instant Baselines  = %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d\n",
                 low_gain[0], high_gain[0], low_gain[1], high_gain[1], low_gain[2],
                 high_gain[2], low_gain[3], high_gain[3], low_gain[4], high_gain[4]);

    	  printf("Computed Baselines = %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f\n\n",
               baseline[0], baseline[1], baseline[2], baseline[3], baseline[4],
               baseline[5], baseline[6], baseline[7], baseline[8], baseline[9]); 
    }
    }
}  









