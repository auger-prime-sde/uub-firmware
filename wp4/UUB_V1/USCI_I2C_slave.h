#ifndef USCT_USCI_I2C_SLAVE
#define USCT_USCI_I2C_SLAVE

#define SDA_PIN 0x02                                  // msp430x261x UCB0SDA pin
#define SCL_PIN 0x04                                  // msp430x261x UCB0SCL pin
#define GEN_CALL                                      // general call enable

void TI_USCI_I2C_slaveinit(void (*StCallback)(), void (*SpCallback)(),
                           void (*GcCallback)(),
                           void (*TCallback)(unsigned char volatile *value),
                           void (*RCallback)(unsigned char value), 
                           unsigned char slave_address);


#endif

