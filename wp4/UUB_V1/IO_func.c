#include "Energia.h"
#include "sde_sc.h"
#include "IO_func.h"
void IO_Config ()
{
// Configure port 1
	P1SEL = 0; // Set all pins to GPIO
	P1DIR = PS_AN_EN | PS_5V_EN | PS_3V3_EN | 
		PS_1V8_EN | PS_1V_EN | PS_EXT1_24V_EN | PS_EXT2_24V_EN; // Output bits
// QSPI_IRQ setup (High to Low transition)
	P1IE = QSPI_RST_N; 
	P1IES = QSPI_RST_N; 
	P1IFG &= ~QSPI_RST_N;                          
	P1OUT = 0; //PS_3V3_EN |PS_AN_EN ;
// Configure port 2
	P2SEL = 0;
	P2DIR = PS_PMT_12V_EN | PS_RADIO_12V_EN | LED_EN_PPS;	//INPUT
	P2OUT &= ~(PS_PMT_12V_EN | PS_RADIO_12V_EN | LED_EN_PPS); 
//	P2DIR &= ~DONE;					//OUTPUT and IRQ on high-to-low transition
//	P2DIR &= ~N_PW_FAULT;					//OUTPUT and IRQ on high-to-low transition
//	P2IE = DONE | N_PW_FAULT; // Never use PS_SRST_B, see note from Patric Allison | PS_SRST_B; solved
//	P2IES = DONE | N_PW_FAULT; 	// TBD:0 if irq on low-to-high transition
//	P2IES = DONE | N_PW_FAULT; 	// TBD:0 if irq on low-to-high transition
//	P2IFG = 0;

// Port 3 is managed by UART
// Port 4
	P4SEL = 0;	//GPIO Pins
	P4DIR =  ONE_W0| ONE_W1 | LED |AD0 | AD1 | AD2 | B3V3_QSPI_B ;
	P4OUT =  LED ;
// Port 5
	P5SEL &= ~(PS_POR_B | NMI_FPGA | RST_FPGA);
	P5DIR |= (RST_FPGA | NMI_FPGA);
	P5OUT &= ~(NMI_FPGA | RST_FPGA); 
}
// IO ISR   #UNUSED, can be removed
//#pragma vector=PORT2_VECTOR
//__interrupt void ISR_Port2 (void)
void __attribute__((interrupt(PORT1_VECTOR))) ISR_Port2 (void)
{

// exit low power mode
	P1IE &= ~QSPI_RST_N; 
 	P1IFG &= ~QSPI_RST_N;
	act_mask = QSPI_RST_N_IRQ;
//	__bic_SR_register_on_exit(LPM3_bits);     // Clear LPM3 bits from 0(SR)
}
void IO_Set ( unsigned int mask )
{
unsigned char bits;
	bits = mask & 0xff;
	P1OUT = bits;
	bits = (mask >> 8) & 0x03;
	P2OUT = bits;
}
unsigned int IO_Get ()
{
	return ( ((P2IN & 0x03) << 8) | P1IN );
}
void ADC_Mux ( unsigned char adr )
{unsigned char bits;
	adr &= 0x07;
	bits = (adr<<4);  // 
	P4OUT |= bits;
	

}
