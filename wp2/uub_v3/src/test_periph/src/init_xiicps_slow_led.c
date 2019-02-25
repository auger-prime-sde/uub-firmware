 /***************************************************************************/
 /*
 * @file xiicps_polled_master_example.c
 *
 * A design example of using the device in polled mode as master.
 *
 * The example uses buffer size 132. Please set the send buffer of the
 * Aardvark device to be continuous 64 bytes from 0x00 to 0x3F.
  *
  **************************************************************************/
 
 /***************************** Include Files ******************************/
 #include "stdio.h"
 #include "xparameters.h"
 #include "xiicps.h"
 #include "new_uub.h"

 /************************** Constant Definitions **************************/
 
 /* The following constants map to the XPAR parameters created in the
  * xparameters.h file. They are defined here such that a user can easily
  * change all the needed parameters in one place. */
 #define IIC_DEVICE_ID    XPAR_XIICPS_0_DEVICE_ID
 
 #define BUF_SIZE                3 // Tansmit and receive buffer size 

 /**************************** Type Definitions ****************************/
 
 /************************** Variable Definitions **************************/

 XIicPs Iic;    /* Instance of the IIC Device */
 
 /* The following buffers are used to send and receive data with the IIC. */
 /* Buffer for Transmitting Data */
 static u8 SendBuffer[BUF_SIZE + 1 ]    = {0x00};
 
 /*************************************************************************
 *
 * This function sends data and expects to receive data from slave 
 *
 * This function uses interrupt-driven mode of the device.
 *
 * @param DeviceId is the Device ID of the IicPs Device and is the
 *    XPAR_<IICPS_instance>_DEVICE_ID value from xparameters.h
 *
 * @return  XST_SUCCESS if successful, otherwise XST_FAILURE.
 *
 * @note    None.
 *
 **************************************************************************/

 int IicPsInitI2C0(u16 DeviceId)
 {
  int Status;
  XIicPs_Config *Config;

  // Initialize the IIC driver so that it's ready to use Look up the 
  // configuration in the config table, then initialize it.
  Config = XIicPs_LookupConfig(DeviceId);
  if (NULL == Config) { return XST_FAILURE; }
 
  Status = XIicPs_CfgInitialize(&Iic, Config, Config->BaseAddress);
  if (Status != XST_SUCCESS) { return XST_FAILURE; }
 
  // Perform a self-test to ensure that the hardware was built correctly.
  Status = XIicPs_SelfTest(&Iic);
  if (Status != XST_SUCCESS) { return XST_FAILURE; }

  // Set the IIC serial clock rate.
  XIicPs_SetSClk(&Iic, IIC_SCLK_RATE);

  return XST_SUCCESS;
 }  
  
 //**********************************************************************
 //                Send data to each DAC AD5316 channel
 //**********************************************************************
 int TstDacAD5316(void)
 { 
   int Status, i;
   unsigned int *state_register;
   int data_display;
   int ValDacA, ValDacB, ValDacC, ValDacD;
   
   printf("\n\r\n\r This test generate a Voltage ramp on each output of the Led Controler DAC\n\r");
   printf(" Look them with an Oscilloscope\n\r");
   printf("   Channel A : pin 3 of M11\n\r");
   printf("   Channel B : pin 4 of M11\n\r");
   printf("   Channel C : pin 5 of M11\n\r");
   printf("   Channel D : pin 11 of M11\n\r");
   
   ValDacA = 0xCB;  // start value DACA
   ValDacB = 0x196; // start value DACB
   ValDacC = 0x261; // start value DACC
   ValDacD = 0x32c; // start value DACD
   
   state_register = UUB_STATE_REGISTER;
   data_display = *state_register;
   while( (data_display & 0xff) != 0x0 )
   {
	  i = 0;
      SendBuffer[0] = 0x01;
      SendBuffer[1] = 0x30 | ( ValDacA >> 6 );
      SendBuffer[2] = ( ValDacA << 2 ) & 0xff;
      Status = XIicPs_MasterSendPolled(&Iic, SendBuffer,3, IIC_SLAVE_AD5316);
      if (Status != XST_SUCCESS) { i++; }
      
      SendBuffer[0] = 0x02;
      SendBuffer[1] = 0x30 | ( ValDacB >> 6 );
      SendBuffer[2] = ( ValDacB << 2 ) & 0xff;
      Status = XIicPs_MasterSendPolled(&Iic, SendBuffer,3, IIC_SLAVE_AD5316);
      if (Status != XST_SUCCESS) { i++; }
      
      SendBuffer[0] = 0x04;
      SendBuffer[1] = 0x30 | ( ValDacC >> 6 );
      SendBuffer[2] = ( ValDacC << 2 ) & 0xff;
      Status = XIicPs_MasterSendPolled(&Iic, SendBuffer,3, IIC_SLAVE_AD5316);
      if (Status != XST_SUCCESS) { i++; }
      
      SendBuffer[0] = 0x08;
      SendBuffer[1] = 0x30 | ( ValDacD >> 6 );
      SendBuffer[2] = ( ValDacD << 2 ) & 0xff;
      Status = XIicPs_MasterSendPolled(&Iic, SendBuffer,3, IIC_SLAVE_AD5316);
      if (Status != XST_SUCCESS) { i++; }
      
      ValDacA = (ValDacA + 0x01 ) & 0x3ff;  // one increment limited to 10 bits
      ValDacB = (ValDacB + 0x01 ) & 0x3ff;  // one increment limited to 10 bits
      ValDacC = (ValDacC + 0x01 ) & 0x3ff;  // one increment limited to 10 bits
      ValDacD = (ValDacD + 0x01 ) & 0x3ff;  // one increment limited to 10 bits
     
      data_display = *state_register;
   }

   if (i != 0) { return XST_FAILURE; }
   else        { return XST_SUCCESS; }

 }

