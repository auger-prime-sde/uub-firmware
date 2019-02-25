 
 //************************************************************************
 //
 // @file xspi_init_ADC.c
 //
 // @note
 //
 // None.
 //
 // MODIFICATION HISTORY:
 //
 //***********************************************************************
 
 //************************** Include Files ******************************
 
 #include "xparameters.h"  /* EDK generated parameters */
 #include "xspips.h"       /* SPI device driver */
 #include "xil_printf.h"
 #include "new_uub.h"
 
 //*********************** Constant Definitions ************************
  
 //**************************** Type Definitions ************************
 
 //***************** Macros (Inline Functions) Definitions **************
 
 XSpiPs Spi;
 
 #define read_dac_buffer_size  10                // size of the SPI read buffer
 #define write_dac_buffer_size 10                // size of the SPI write buffer
 u8 ReadDacBuffer[read_dac_buffer_size]   = {0x00}; // SPI read buffer initialize to 0
 u8 WriteDacBuffer[write_dac_buffer_size] = {0x00}; // SPI write buffer initialize to 0
 
 //************************************************************************
 // 
 //  This function initialize the DAC device throught the XSpiPs device driver
 //  The serial communication is made in polled mode. 
 // 
 //  @param  SpiInstancePtr is a pointer to the Spi Instance.
 //  @param  SpiDeviceId is the Device Id of Spi.
 // 
 //  @return XST_SUCCESS if successful else XST_FAILURE.
 // 
 //*************************************************************************
 int SpiPs_Init_SPI_DAC(u16 SpiDeviceId, int tst_enable)
 {
   int Status;
   
   XSpiPs_Config *SpiConfigDac;
 
   /* Initialize the SPI driver so that it's ready to use */
   SpiConfigDac = XSpiPs_LookupConfig(SpiDeviceId);
   if (NULL == SpiConfigDac) { return XST_FAILURE; }
 
   Status = XSpiPs_CfgInitialize(&Spi, SpiConfigDac, SpiConfigDac->BaseAddress);
   if (Status != XST_SUCCESS) { return XST_FAILURE; }
 
   // Perform a self-test to check hardware build
   Status = XSpiPs_SelfTest(&Spi);
   if (Status != XST_SUCCESS) { return XST_FAILURE; }
 
   // Set the SCLK frequency to SPI_REF_CLK / XSPIPS_CLK_PRESCALE_xx
   XSpiPs_SetClkPrescaler(&Spi, XSPIPS_CLK_PRESCALE_32);
 
 //***********************************************************************
 //                   Initialize the DAC component
 //***********************************************************************
 
   // Set the Spi device as a master ( is slave by default).
   XSpiPs_SetOptions(&Spi, XSPIPS_MASTER_OPTION |
 		                  XSPIPS_FORCE_SSELECT_OPTION |
 		                  XSPIPS_DECODE_SSELECT_OPTION |
 		                  XSPIPS_CLK_PHASE_1_OPTION);
   // Write value data into DAC "CLOCK Generator"
   WriteDacBuffer[0] = 0x08;
   WriteDacBuffer[1] = 0x00;
   XSpiPs_SetSlaveSelect(&Spi, SPI_SELECT_DAC);    // Assert the chip select
   XSpiPs_PolledTransfer(&Spi, WriteDacBuffer, ReadDacBuffer, 2);
 
   return XST_SUCCESS;
 }
   
 
 //**********************************************************************
 //                     Test the DAC (AD7551) output
 // a voltage rampe must be generate on the DAC output
 //**********************************************************************
 int TstDac7551(void)
 
 {
   int data_test, data_display;
   unsigned int *state_register;
   
   print("\n\r\n\r This test generate a Voltage ramp on the output Clock adustement DAC\n\r");
   print(" Look it with an Oscilloscope\n\r");
   print("   Channel : pin 5 of U69\n\r");
   
   state_register = UUB_STATE_REGISTER;
   data_display = *state_register;
   while( (data_display & 0xff) != 0x0 )
     {
       for ( data_test = 0x0; data_test < 0x0FFF; data_test++)  
         {
           WriteDacBuffer[0] = data_test >> 8;
           WriteDacBuffer[1] = data_test & 0xff ;
           XSpiPs_SetSlaveSelect(&Spi, SPI_SELECT_DAC);// Assert the chip select
           XSpiPs_PolledTransfer(&Spi, WriteDacBuffer, ReadDacBuffer, 2);
         }
      data_display = *state_register;
      }
   
   return XST_SUCCESS;
 }
   
