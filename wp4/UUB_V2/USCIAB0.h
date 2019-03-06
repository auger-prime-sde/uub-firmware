#ifndef USCI_LIB
#define USCI_LIB

#define SDA_PIN 0x02                                  // msp430x261x UCB0SDA pin
#define SCL_PIN 0x04                                  // msp430x261x UCB0SCL pin
#define TXD_PIN 0x10				      //             UCA0TXD pin
#define RXD_PIN 0x20				      //	     UCA0RXD pin

#define UART_BUFFER_LENGTH 80
//unsigned char uart_buffer[UART_BUFFER_LENGTH];
char uart_buffer[UART_BUFFER_LENGTH];
unsigned char EOT;

void UART_Config ( void );
void UART_sprint ( char *field );			// send zero terminated string 
void UART_sprintx ( int i );			// send zero terminated string 
void UART_sprintd ( int i );			// send zero terminated string 
//void UART_write ( char c );			// send zero terminated string 
int UART_write ( int c );			// send zero terminated string 
unsigned char  UART_gets ( unsigned char *field ); 	// receive zero terminated string


void USCI_I2C_receiveinit(unsigned char slave_address, unsigned char prescale);
void USCI_I2C_transmitinit(unsigned char slave_address, unsigned char prescale);


void USCI_I2C_receive(unsigned char byteCount, unsigned char *field);
void USCI_I2C_transmit(unsigned char byteCount, unsigned char *field);


unsigned char USCI_I2C_slave_present(unsigned char slave_address);
unsigned char USCI_I2C_notready();
#define PF &UART_write
void pf ( float f);
#endif
