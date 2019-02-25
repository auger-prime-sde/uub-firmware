 /*
  *  Heavily modified program descended from LPSC Grenoble test program.
  * 
  */
  
 #include <stdio.h>
 #include "xparameters.h"
 #include "xil_cache.h"
 #include "xscugic.h"
 #include "xil_exception.h"
 #include "xiicps.h"
 #include "iicps_header.h"
 #include "init_xiicps_header.h"
 #include "xspips.h"
 #include "new_uub.h"
 
 #define true  1
 #define false 0
 
int init_ADC(u16 SpiDeviceId, char valid_display);
int SpiPs_Init_SPI_DAC(u16 SpiDeviceId, int tst_enable);
void trigger_test();

 int main() 
 {
    int Status;

    Xil_DCacheDisable();
    Xil_ICacheDisable();

  // Initialisation : 
  //        - du circuit clock generateur CDEL913   
  //        - des circuits ADC AD9628
  //        - du DAC AD7551 
  //        - du quad DAC AD5316 LED CONTROLER
    {
      int tst_enable ;
      
      // initialise le circuit clock generator CDEL913
      printf("\r\n Initialization of I2C clock generator ... : ");
      XIicPs_ResetHw(XPAR_XIICPS_1_BASEADDR);
      Status = IicPsInitClockGenerator(XPAR_PS7_I2C_1_DEVICE_ID);
      SendPassFail(Status);
  
      // initialise le cleaner Jitter
      printf(" Initialization of Jitter Cleaner ........ : ");
      Status = IicPsInitJitterCleaner(XPAR_PS7_I2C_1_DEVICE_ID);
      SendPassFail(Status);
      
      // initialise les circuits ADC9628
       printf(" Initialization of ADC 9628 .............. : ");
       Status = init_ADC(XPAR_PS7_SPI_0_DEVICE_ID, 1);
       SendPassFail(Status);
       
      // Initialize the DAC chip DAC7551
       tst_enable = false;
       printf(" Initialization of DAC 7551 .............. : ");
       Status = SpiPs_Init_SPI_DAC(XPAR_PS7_SPI_1_DEVICE_ID, tst_enable);
       SendPassFail(Status);
       tst_enable = false;
 
      // Initialize the Quad DAC chip AD5316
       
       printf(" Initialization of DAC AD5316 ............ : ");
       XIicPs_ResetHw(XPAR_XIICPS_0_BASEADDR);
       Status = IicPsInitI2C0(XPAR_PS7_I2C_0_DEVICE_ID);
       SendPassFail(Status);
    }
    
    printf("\n\r ***  THE END OF POWERUP INITIALIZATION ***\n\r\n");

    
     // Start trigger tests
    trigger_test();
    return 0;
 }
 
 //***********************************************************************
 //     Send PASSED or FAILLED to the console depend of STATUS value
 //***********************************************************************
 
 int SendPassFail(Status)
 {
   if (Status == 0) { printf("passed\r\n"); } else { printf("failed\r\n"); }
   return XST_SUCCESS;
 }
     
     
