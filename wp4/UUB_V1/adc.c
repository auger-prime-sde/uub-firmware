#include "Energia.h"
#include "USCIAB0.h"
#include "sde_sc.h"
#include "IO_func.h"
#include "adc.h"
void adc_init()
{
P6SEL |= 0xff;                            // Enable A/D channel A0 - A7
  ADC12CTL0 = ADC12ON+MSC+SHT0_8+REFON; // Turn on and set up ADC12 
//  ADC12CTL0 = ADC12ON+MSC+SHT0_8; // Turn on and set up ADC12 external reference 
  ADC12CTL1 = SHP +CONSEQ_1;                          // Use sampling timer
  ADC12MCTL0 = INCH_0 + SREF_1;                      // SREF_1: Vr+=Vref+, cha. A0 ; SREF_2: Vr+ = VeREF+ (external)
  ADC12MCTL1 = INCH_1 + SREF_1;                      // Vr+=Vref+, cha. A1
  ADC12MCTL2 = INCH_2 + SREF_1;                      // Vr+=Vref+,      A2
  ADC12MCTL3 = INCH_3 + SREF_1;                      // Vr+=Vref+,      A3
  ADC12MCTL4 = INCH_4 + SREF_1;                      // Vr+=Vref+,      A4
  ADC12MCTL5 = INCH_5 + SREF_1;                      // Vr+=Vref+,      A5
  ADC12MCTL6 = INCH_6 + SREF_1;                      // Vr+=Vref+,      A6
  ADC12MCTL7 = INCH_7 + SREF_1;
  ADC12MCTL8 = INCH_10 + SREF_1 + EOS;                      // Vr+=Vref+, A7, End Of Sequence
 adcctl = ADC_DOCONV;	// Start initial conversion with Mux adress 0
  adc_start_conversion();

}
void adc_start_conversion()
{
	P4OUT &= ~LED;
  ADC12IE = 0x0100;					// Enable ADC12ifg.7
  ADC12CTL0 |= ENC + ADC12SC;                   // Start conversion
}
void adc_get() // OBSOLET
{
//  ADC12CTL0 |= ENC;
//  ADC12CTL0 |= ADC12SC;                   // Start conversion
//    while ((ADC12IFG & BIT7)==0);
//  ADC12IFG = 0;
//  adc_done=0;
}
//#pragma vector=ADC12_VECTOR
//__interrupt void ADC12ISR (void)
void __attribute__((interrupt(ADC12_VECTOR))) ADC12ISR (void)
{
	ADC12IE=0;
	if (ADC12IFG & 0x0080) adcctl |= ADC_DONE;
	LPM3_EXIT;
}
void adc_update_sgl(unsigned char chan)
{
}
void adc_update()
{
  int temp;
  unsigned char i=0, muxbits;
//
// - New 29/1/2016
//
	if ( adcctl & ADC_DOCONV ) { 		// Conversion ongoing
		if ( adcctl & ADC_DONE ) {	// Conversion finished
			adcctl &= ~ADC_DONE;
                        muxbits = adcctl & ADC_MUXADR;
                        i= muxbits * 8;
			adc_results[i++] = ADC12MEM0;                   // Move results, IFG is cleared
	  		adc_results[i++] = ADC12MEM1;                   // Move results, IFG is cleared
  			adc_results[i++] = ADC12MEM2;                   // Move results, IFG is cleared
  			adc_results[i++] = ADC12MEM3;                   // Move results, IFG is cleared
  			adc_results[i++] = ADC12MEM4;                   // Move results, IFG is cleared
  			adc_results[i++] = ADC12MEM5;                   // Move results, IFG is cleared
  			adc_results[i++] = ADC12MEM6;                   // Move results, IFG is cleared
  			adc_results[i++] = ADC12MEM7;                   // Move results, IFG is cleared
			temp = ADC12MEM8;
/*
                                UART_sprint(" adc7=");
                                UART_sprintx(adc_results[i-1]);
                                UART_sprint(" temp=");
                                UART_sprintx(temp);
        UART_sprint (" \r");
*/
			if ( muxbits < 7 ) {	// Last conversion?

                        	muxbits++;              // increment mux adress
                        	muxbits &= ADC_MUXADR;  // mask adress bits
				adcctl &= ~ADC_MUXADR;
				adcctl |= muxbits;
//                        	muxbits << 4;
				i = P4IN;		// read Port 4
				i &= 0x8f;		// zero bits 4,5,6
				i+= (muxbits<<4);		// set new MUX adress
				P4OUT = i;
//                                UART_sprint(" P4=");
//                                UART_sprintx(P4IN);
//        UART_sprint (" \r");
 
				delay (1);
				adc_start_conversion ();	// Start next conversion
				} 
			else 	{
				adcctl = 0;		//we are done
				P4OUT &= 0x8f;
				P4OUT |= LED;
				}
  			}			
	}
}		
void adc_dump()
{
int i,j;
	for (i=0; i<=7;i++) {
		UART_sprint (" \r");
		for (j=0; j<=7;j++) {
			UART_sprintx(adc_results[i*8+j]);
		UART_sprint (" ");
		}
	}
	UART_sprint (" \r");
	
}
