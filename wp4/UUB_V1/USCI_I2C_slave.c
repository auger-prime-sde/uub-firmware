//******************************************************************************
//   MSP430 USCI I2C Transmitter and Receiver (Slave Mode)
// Uli Kretzschmar
// Texas Instruments Deutschland GmbH
// November 2007
// Built with IAR Embedded Workbench Version: 3.42A
//******************************************************************************
//  A.Menshikov  IPE, FZK
//  The example of TI is extende/adapted for usct tas head elkectronics
//  15.07.2009  - enable stop interrupt ()
//

#include "msp430x26x.h"
#include "USCI_I2C_slave.h"

void (*TI_receive_callback)(unsigned char receive); 
void (*TI_transmit_callback)(unsigned char volatile *send_next); 
void (*TI_start_callback)(void);
void (*TI_stop_callback)(void);
void (*TI_gencall_callback)(void);


void TI_USCI_I2C_slaveinit(void (*StCallback)(), void (*SpCallback)(),
                           void (*GcCallback)(),
                           void (*TCallback)(unsigned char volatile *value),
                           void (*RCallback)(unsigned char value), 
                           unsigned char slave_address){
  P5SEL |= SDA_PIN + SCL_PIN;               // Assign I2C pins to USCI_B0
  UCB1CTL1 |= UCSWRST;                      // Enable SW reset
  UCB1CTL0 = UCMODE_3 + UCSYNC;             // I2C Slave, synchronous mode
  UCB1I2COA = slave_address;                // set own (slave) address
#ifdef GEN_CALL
  UCB1I2COA |= UCGCEN;
#endif
  UCB1CTL1 &= ~UCSWRST;                     // Clear SW reset, resume operation
  UCB1I2CIE = UCSTTIE + UCSTPIE;            // Enable STT & STP interrupt
  UC1IE = UCB1TXIE + UCB1RXIE;              // Enable TX and RX interrupt
  TI_start_callback = StCallback;
  TI_stop_callback = SpCallback;
  TI_receive_callback = RCallback;
  TI_transmit_callback = TCallback;
  TI_gencall_callback = GcCallback;
}

// USCI_B1 Data ISR
//#pragma vector = USCIAB1TX_VECTOR
//__interrupt void USCIAB1TX_ISR(void)
void __attribute__((interrupt(USCIAB1TX_VECTOR))) USCIAB1TX_ISR(void)
{
  if (UC1IFG & UCB1TXIFG)
    TI_transmit_callback(&UCB1TXBUF);
  else
    TI_receive_callback(UCB1RXBUF);
}

// USCI_B1 State ISR
//#pragma vector = USCIAB1RX_VECTOR
//__interrupt void USCIAB1RX_ISR(void)
void __attribute__((interrupt(USCIAB1RX_VECTOR))) USCIAB1RX_ISR(void)
{
  if (UCB1STAT & UCSTPIFG)
  {
    TI_stop_callback();
    UCB1STAT &= ~UCSTPIFG;
  }
    
  if (UCB1STAT & UCSTTIFG)
  {
    TI_start_callback();
    UCB1STAT &= ~UCSTTIFG;
  }

#ifdef GEN_CALL
  if (UCB1STAT & UCGC)
  {
    TI_gencall_callback();
    UCB1STAT &= ~UCGC;
  }  
#endif
}

