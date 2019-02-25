
 #define TESTAPP_GEN
 
 int ReadJitterCleanerValue(void);        // file : init_xiicps_clock_generator.c
 int IicPsInitJitterCleaner(u16 DeviceId); // file : init_xiicps_clock_generator.c
 int IicPsInitI2C0(u16 DeviceId); 
 int IsJitterCleanerReady(void);          // file : init_xiicps_clock_generator.c
 int SendADCData(void);                   // file : iniit_xspips_ADC.c
 int TstDac7551(void);                    // file : init_xspi_ps_DAC.c
 int TstDacAD5316(void);                  // file : init_xiicps_slow_led.c
 int TstRamBasis();                       // file : memorytest.c
 int SendPassFail(int Status);            // file : testperiph.c

 #define UUB_STATE_REGISTER 0x43C00014  // state register of the new_uub Board
 #define UUB_TEST_TRIG_REG  0x43C00018  // reg. for the test of the trig signal
 #define IIC_SLAVE_CDCEL913       0x65  // The slave address Clock generator
 #define IIC_SLAVE_SI5347         0x6C  // The slave address Cleaner Jitter
 #define IIC_SLAVE_AD5316         0x0C  // The slave address Led controler
 #define IIC_SLAVE_MPS430         0x6C  // The slave address Slow control
 #define IIC_SCLK_RATE          100000  // tansfert frequency
 #define SPI_SELECT_DAC           0x06

 #define true  1
 #define false 0
 
