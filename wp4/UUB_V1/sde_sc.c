#include <stdio.h>
#include <stdlib.h>
#include "Energia.h"
#include "sde_sc.h"
#include "wiring.h"
#include "USCI_I2C_slave.h"
#include "USCIAB0.h"
#include "MISC_func.h"
#include "IO_func.h"
#include "DAC_func.h"
#include "ds18x20.h"
#define I2C_IF           0x06      // I2C bits
#define EnWDOG    WDTCTL = (WDTPW | WDTCNTCL) & ~WDTHOLD
#define DisWDOG   WDTCTL = WDTPW | WDTHOLD
#include "adc.h"
#include "ishan.h"
#include "DS28CM00_func.h"
#include "BMP180_func.h"
#define FIELD 1
//int T, TW;
//long P;
//unsigned long adc_upd_time;
//unsigned int temperatur=0;
void POR_FPGA();
void POR_B_FPGA();
void SRST_B_FPGA();
void QSPI_RST();
void receive_cb(unsigned char receive);
void transmit_cb(unsigned char volatile *receive);
void start_cb();
void stop_cb();
void gencall_cb();
void Parse_UART();
void show_lifetime();
unsigned char flag = 0;
unsigned char flag1 = 0;
unsigned char TXData[260];
unsigned char RXData[260];
unsigned char stop=0;
unsigned char start=0;
unsigned char gencall=0;
unsigned char gcall=0;
unsigned char rcv_bytes=0;
unsigned char burst;
unsigned char direction,direction_r;
unsigned char reading;
unsigned char mTX[3];
#define LSB_TO_5V 1.8814
//#define LSB_TO_5V 1.788
#define LSB_TO_24V 8.88
#define LSB_TO_12V 4.43
#define LSB_TO_3V3 1.20
#define LSB_TO_1V8 0.674
#define LSB_TO_1V2 0.421
#define LSB_TO_1V0 0.366
#define CNV_TEMP 1.831

volatile extern unsigned long Second;
unsigned long UpdateSensor;
#define DELTAUPDATE 10
#define PIN_ON                  P1OUT &=~0x02; P1DIR |= 0x02;
#define PIN_OFF                  P1OUT |= 0x02; P1DIR |= 0x02;
#define I2C_ADDRESS 0x0f	// I2C slave adress
#define PRESCALER 12
unsigned char x=0;
unsigned int  has_DS1820;
char buffer [80];
unsigned int status_reg;
#define FPGA_DONE_STAT 0x8000
#define PS_AN 	0x0001
#define PS_5V 	0x0002
#define PS_3V3 	0x0008
#define PS_1V8 	0x0010
#define PS_1V	0x0020
#define PS_EXT1	0x0040
#define PS_EXT2	0x0080
#define BAT_LOW	0x0100
#define CUR_ERR 0x0200
#define TMP_ERR 0x0400
#define PS_MAIN	0x0800
//void (*F) (char) = &UART_write;
//#define PF &UART_write
int main ()
{
init();
setup();
while (1) loop();
return 0;
}

// the setup routine runs once when you press reset:
void setup() {                
 	MISC_Config();
 	IO_Config();
 	led_fblink (50);           //set LED1 blink 5Hz
 	UART_Config();
  	delay(1000);               // wait for a second
 
//
 	UART_sprint("Auger SD Slow Control system ready \n\r");
//
// Read DS28CM00 Serial Number
//
	uprintf (PF, "Software Version: %d.%d", VERSION>>8, VERSION & 0xff);
 	UART_sprint(" \r");
 	UART_sprint("Serial: ");
	Read_DS28CM00_ASCII ( buffer );
 	UART_sprint(buffer);
 	UART_sprint(" \n\r>");
	if (BMP180_IsConnected ()) {
		 BMP180_GetValues(&adc_results[T_AIR], &adc_results[P_AIR]);
		 uprintf (PF, "BMP180 is connected, T= %d *0.1K, P= %d mBar\r",adc_results[T_AIR],adc_results[P_AIR]);
		bmp180_update_time = Second + UPD_BMP180_Delta;	 
	}
	if ( ResetDS1820 () ) {
		adc_results[T_WAT] = GetData();
		uprintf (PF, "DS18x20 connected, data: %d\r>", adc_results[T_WAT]);
	}
	UART_sprint("Starting FPGA:");
	P5DIR |= B3V3_QSPI_B | NMI_FPGA | RST_FPGA; // 
#ifdef FIELD
	P1OUT =(FPGA_CORE_PS);	// Enable Powersupplies
	delay (200); // wait 200 ms
                        P1OUT |= (PS_AN_EN | PS_EXT1_24V_EN | PS_EXT2_24V_EN);  // Enable ADC Powersupplies 
                        P2OUT |= (PS_PMT_12V_EN | PS_RADIO_12V_EN);     // Enable ADC Powersupplies
	POR_FPGA ();	// Power on reset of FPGA
	UART_sprint(" ........ ");
#else 
               uprintf (PF,"Version TEST %d\r");
                P1OUT &= ~(FPGA_CORE_PS);
                P1OUT &= ~(PS_AN_EN | PS_EXT1_24V_EN | PS_EXT2_24V_EN);  // Enable ADC Powersupplies 
                P2OUT &= ~(PS_PMT_12V_EN | PS_RADIO_12V_EN);     // Enable ADC Powersupplies

#endif
// Wait for FPGA_DONE
//	while (1) {
//		if (P2IN & DONE) { 		// FPGA booted
// 			status_reg = FPGA_DONE;
//UART_sprint("done \r");

//			break;
//		}

//	}
 	UART_sprint("Initialize ADCs \r");

	dac_init();
	dac_set (1, 1640); // set dac chan 1 to 1V, reference for adc
	adc_init();

  TI_USCI_I2C_slaveinit(start_cb, stop_cb, gencall_cb, transmit_cb, receive_cb, I2C_ADDRESS);
  has_DS1820 = 0; //ResetDS1820();
  if ( has_DS1820 ) {
//	InitDS18B20();
//  	temperatur=GetData();
//  	UpdateSensor = Second + DELTAUPDATE;
  }
 led_fblink (0);           //set LED1 blink 5Hz
}
void check_stat()
{
                if (P2IN & DONE) {              // FPGA booted
			status_reg |= FPGA_DONE_STAT;
			led_fblink (0);
		} else {
			status_reg &= ~FPGA_DONE_STAT;
		}
}
// the loop routine runs over and over again forever:
void loop() {
char b[10];
#ifdef FIELD 
  
/*
  if (act_mask & QSPI_RST_N_IRQ ) {
long dt;	
	dt = millis();
	uprintf (PF, "P4DIR: 0x%x P4IN: 0x%x \r",P4DIR, P4IN);
	uprintf (PF, "P5DIR: 0x%x P5IN: 0x%x \r",P5DIR, P5IN);
  	uprintf (PF, "QSPI_RST_N ... " );
       // P4DIR |= B3V3_QSPI_B;   // release 3v3_QSPI (goes high)
        P4OUT |= B3V3_QSPI_B;
        P5DIR |= PS_POR_B;   // set PS_POR_B to OUPUT -> goes low
	P5OUT &= ~PS_POR_B;
        delayMicroseconds(6800);
        P4OUT &= ~B3V3_QSPI_B;
        delay (16);
        P5OUT |= PS_POR_B;   // B3V3_QSPI_B set to low
        P5DIR &= ~PS_POR_B;   // release 3v3_QSPI (goes high)
//  look on QSPI_RST_N == 0

	uprintf (PF, "P4DIR: 0x%x P4IN: 0x%x \r",P4DIR, P4IN);
	uprintf (PF, "P5DIR: 0x%x P5IN: 0x%x \r",P5DIR, P5IN);
// not needed generates irq on falling edge	while ((P5IN & QSPI_RST_N) == 0) {};
	dt = millis() -dt;
	uprintf (PF," time %d ms\n",dt);
        P1IE |= QSPI_RST_N;
        act_mask &= ~QSPI_RST_N_IRQ;

  }
*/
  if ( (P5IN & PS_POR_B) == 0x0 ) { // FPGA (hard) reset
	led_fblink (50);
  	uprintf (PF, "POR_B FPGA  reset ... " );
	POR_B_FPGA ();
// Wait for FPGA_DONE
//        while (1) {
//                if (P2IN & DONE) {              // FPGA booted
//                        UART_sprint("done \r");
//                        break;
//                }
//        }
//	led_fblink (0);

  }
  if ( (P4IN & COMMS_RESET) == 0x0 ) {  // COMMS reset
	led_fblink (50);
	uprintf (PF, "COMMS  FPGA  reset ... " );
	P1OUT =0;	// Disable  Powersupplies
//	P2OUT &= ~(PS_PMT_12V_EN | PS_RADIO_12V_EN);
	delay (1000);
        P1OUT =(FPGA_CORE_PS);  // Enable Powersupplies
        delay (200); // wait 200 ms
        P1OUT |= (PS_AN_EN | PS_EXT1_24V_EN | PS_EXT2_24V_EN);  // Enable ADC Powersupplies
        P2OUT |= (PS_PMT_12V_EN | PS_RADIO_12V_EN);     // Enable ADC Powersupplies
        POR_FPGA ();    // Power on reset of FPGA

  }   
/*
if ( P2IFG & PS_SRST_B ) { // FPGA soft reset request
	led_fblink (50);

  	uprintf (PF, "SRST_FPGA .....  " );
	P2IFG &=  ~PS_SRST_B;
	SRST_B_FPGA ();
// Wait for FPGA_DONE
//        while (1) {
//                if (P2IN & DONE) {              // FPGA booted
//                        UART_sprint("done \r");
//                        break;
//                }
//        }
	delay (1000); //wait a second before releasing SRST_B interrupt
	P2IE |= PS_SRST_B;
//	led_fblink (0);
 	}
*/
#endif
        if (BMP180_IsConnected () && ( Second == bmp180_update_time) ) {
		 BMP180_GetValues(&adc_results[T_AIR], &adc_results[P_AIR]);
		bmp180_update_time += UPD_BMP180_Delta;
		if ( ResetDS1820 () ) {
			adc_results[T_WAT] = GetData();
		}
	}
	check_stat ();
  if (EOT) Parse_UART();
  EOT = 0;
  adc_update();

if (act_mask & UPD_ADC ) {
                        act_mask &= ~UPD_ADC;
                        adcctl = ADC_DOCONV;
                        adc_start_conversion();
        }


  if ( stop == 1 ) {
unsigned char *cp;
int i;
unsigned int reg, mask;
	reg = RXData[1]<<8 | RXData[0];
//  	uprintf (PF, "I2C register: %x %d\r", reg,rcv_bytes );
    switch (reg) {  
      case 0x1:
	cp = Read_DS28CM00_BIN();
	for (i=0; i<=7; i++) TXData[i] = *cp++;
	
	break;
      case 0x2:
		TXData[0] = (char) (status_reg & 0xff);
		TXData[1] = (char) ((status_reg >> 8) & 0xff);
	break;
      case 0x4:
	if (rcv_bytes == 2 ) {
		TXData[0] = P1IN;
		TXData[1] = P2IN & 0x03; 
 	} else
	{
//  	uprintf (PF, "Data: %x %x\r",RXData[2],RXData[3]  );
		mask = 0x3a | RXData[2];
		P1OUT = mask; // make sure not to switch off FPGA
		if (rcv_bytes > 3 ) {
			mask = P2IN & 0xfc;
			P2OUT = mask | (RXData[3] & 0x3);
		}
	}	
	break;
      case 0x5: // DAC control
	if (rcv_bytes == 4 ) {
	long int li1, li2;
		li1 = (RXData[3] & 0x70)>>4;
                li2 = (RXData[3] & 0x0f)<<8 | RXData[2];
  //	uprintf (PF, "Data: %x %x\r",RXData[2],RXData[3]  );
  //	uprintf (PF, "chan, val: %x %x\r",li1, li2  );
                if ( (li1 >=0 && li1 <=7 ) && (li2 >=0 && li2 < 4096 ) ) {
                     dac_set ( li1, li2 );
                }

	}
	break;
      case 0x9: // ADC values
	cp = (char *) adc_results;
	for (i=0; i<2*MAX_VARS; i++) TXData[i] = *cp++;
	break;
     case 0xa:  // Test
	TXData[0] = 0x21;
        TXData[1] = 0x43;
      default:
	break;
   }
   rcv_bytes=0;
  }
  stop = 0;
  __bis_SR_register(LPM0_bits + GIE);     // Enter LPM0, enable interrupts
//   _EINT();
}
void start_cb(){
  flag1 = 0;
  flag = 0;
}

void stop_cb(){
  stop = direction;
  gencall = gcall;
  burst = RXData[0]+2;
  direction = 0;
  gcall = 0;
}

void gencall_cb(){
  gcall = 1;
}

void receive_cb(unsigned char receive){
  direction = 1;
  RXData[flag1++] = receive;
  rcv_bytes++;
}

void transmit_cb(unsigned char volatile *byte){
  direction = 0;
  *byte = TXData[flag++];
}
char * pEnd;
long int li1, li2, li3;
char str[24];
void print_f ( float f, char *str) 
{
int fi;
	fi = f;
  	uprintf (PF, "%d %s ", fi, str); 
}
void Parse_UART()
{
 	UART_sprint ("\r");
	switch (uart_buffer[0])
	{
		case 'R': // test
			UART_sprint("Port1:");
			UART_sprintx(P1IN);
 	UART_sprint ("\r");
			UART_sprint(" Port2:");
			UART_sprintx(P2IN);
 	UART_sprint ("\r");
			UART_sprint(" Port4:");
			UART_sprintx(P4IN);
 	UART_sprint ("\r");
			UART_sprint(" Port5:");
			UART_sprintx(P5IN);
			break;

		case 'a':
			UART_sprint("PMT Stat:  HVmon   Imon   Tmon\r");
			uprintf( PF, "\r%s     ","PMT1"); 
				pf ((float)adc_results[PMT1_HVM] *LSB_TO_5V); 
				pf ((float)adc_results[PMT1_CM]*LSB_TO_5V);
				pf ((float)adc_results[PMT1_TM]*CNV_TEMP);
                        uprintf( PF, "\r%s     ","PMT2");
                                pf ((float)adc_results[PMT2_HVM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT2_CM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT2_TM]*CNV_TEMP);
                        uprintf( PF, "\r%s     ","PMT3");
                                pf ((float)adc_results[PMT3_HVM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT3_CM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT3_TM]*CNV_TEMP);

                        uprintf( PF, "\r%s     ","PMT4");
                                pf ((float)adc_results[PMT4_HVM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT4_CM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT4_TM]*CNV_TEMP);
                        uprintf( PF, "\r%s     ","PMT5");
                                pf ((float)adc_results[PMT5_HVM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT5_CM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT5_TM]*CNV_TEMP);

                        uprintf( PF, "\r%s     ","PMT6");
                                pf ((float)adc_results[PMT6_HVM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT6_CM]*LSB_TO_5V);
                                pf ((float)adc_results[PMT6_TM]*CNV_TEMP);

                        uprintf( PF, "\r%s     ","Power supplies");
                        uprintf( PF, "\r Nominal Actual Current");
			uprintf( PF, "\r 1V      "); 
			print_f((float)adc_results[V_1V0]*LSB_TO_1V0,"[mV] ");
			print_f((float)adc_results[I_1V0]*LSB_TO_1V0/60.*41.67,"[mA] "); // 41.67=1/0.024
			if (check (adc_results[V_1V0], 0xaaa, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r 1V2     ");
                        print_f((float)adc_results[V_1V2]*LSB_TO_1V2,"[mV] ");
			print_f((float)adc_results[I_1V2]*LSB_TO_1V0/60.*10.,"[mA] ");   // 10=1/.1
			if (check (adc_results[V_1V2], 0xb21, 5) ) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r 1V8     ");
                        print_f((float)adc_results[V_1V8]*LSB_TO_1V8,"[mV] ");
                        print_f((float)adc_results[I_1V8]*LSB_TO_1V0/60.*30.3,"[mA] "); // 30.3 =1/0.033
			if (check (adc_results[V_1V8], 0xa70, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r 3V3     ");
                        print_f((float)adc_results[V_3V3]*LSB_TO_3V3,"[mV] ");
                        print_f((float)adc_results[I_3V3]*LSB_TO_3V3/60.*16.13,"[mA] "); // 16.13 = 1/0.062
                        print_f((float)adc_results[I_3V3_SC]*LSB_TO_1V0/60.*12.2,"[mA SC] "); // 12.2 = 1/0.082
			if (check (adc_results[V_3V3], 0xac6, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r P3V3     ");
                        print_f((float)adc_results[V_AN_P5V]*LSB_TO_3V3,"[mV] ");
                        print_f((float)adc_results[I_P5V_ANA]*LSB_TO_1V0/60.*12.2,"[mA] ");
			if (check (adc_results[V_3V3], 0xac6, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r N3V3     ");
                        print_f((float)adc_results[V_AN_N5V]*LSB_TO_3V3,"[mV] ");
                        print_f((float)adc_results[I_N5V_ANA]*LSB_TO_1V0/60.*12.2,"[mA] ");
			uprintf( PF, "\r 5V       ");
                        print_f((float)adc_results[V_GPS_5V]*LSB_TO_5V,"[mV] ");
                        print_f((float)adc_results[I_GPS_5V]*LSB_TO_1V0/60.*10,"[mA] ");
			if (check (adc_results[V_GPS_5V], 0xac6, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r12V Radio ");
                        print_f((float)adc_results[V_RADIO_12V]*LSB_TO_12V,"[mV] ");
                        print_f((float)adc_results[I_RADIO_12V]*LSB_TO_1V0/60.*30.3,"[mA] ");
			if (check (adc_results[V_RADIO_12V], 0xa94, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r12V PMTs  ");
                        print_f((float)adc_results[V_PMTS_12V]*LSB_TO_12V,"[mV] ");
                        print_f((float)adc_results[I_PMTS_12V]*LSB_TO_1V0/60.*30.3,"[mA] ");
			if (check (adc_results[V_PMTS_12V], 0xa94, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r24V EXT1/2  ");
                        print_f((float)adc_results[V_EXT1_24V]*LSB_TO_24V,"[mV] ");
                        print_f((float)adc_results[V_EXT2_24V]*LSB_TO_24V,"[mV] ");
                        print_f((float)adc_results[I_V_INPUTS]*LSB_TO_1V0/60.*21.28,"[mA] "); // 21.28=1/0.047
			if (check (adc_results[V_EXT1_24V], 0xa8d, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\rSensors ");
                        uprintf (PF, " \rT= %d *0.1K, P= %d mBar TW = ",adc_results[T_AIR],adc_results[P_AIR]);
                        uprintf (PF, "%d *0.1K",adc_results[T_WAT]);
				                        
			break;
		case 'A':
			adc_dump();
			break;
		case 'd':
		case 'D':
			pEnd = &uart_buffer[1];
			li1 = strtol (pEnd, &pEnd, 10);
			li2 = strtol (pEnd, &pEnd, 10);
			if ( (li1 >=0 && li1 <=8 ) && (li2 >=0 && li2 < 4096 ) ) {
				dac_set ( li1, li2 );
				}
			else {
				UART_sprint (" out of range");
			}	
			break;
		case 'h':
		case 'H':
			uprintf( PF,"s or S - show serial number\r");
			uprintf( PF,"v or V - show software version\r");
			uprintf( PF,"l or L - show Lifetime\r");
			uprintf( PF,"p or P - set power supplies (12V, 24V) Off/On\r");
			uprintf( PF,"d or D chan val - set DAC channnel chan [0..8] to value val [0..4095]\r");
			uprintf( PF,"a - show analog variables in physical units\r");
			uprintf( PF,"A - show analog variables as raw data in HEX\r");
			uprintf( PF,"h or H - show this help");
			break;
		case 'v':
		case 'V':
#ifdef FIELD
				uprintf (PF, "Software Version: %d.%d", VERSION>>8, VERSION & 0xff);
#else
				uprintf (PF, "TEST Software Version: %d.%d", VERSION>>8, VERSION & 0xff);

#endif
			break;
		case 's':
		case 'S':
			Read_DS28CM00_ASCII ( buffer );
        		uprintf(PF, "SN: %s",buffer);
      //  		UART_sprint("SN: ");UART_sprint(buffer);
			break;
                case 'b':
                        led_fblink (100);
                        break;
		case 'B':
			led_fblink (1000);
			break;
		case 'L':
		case 'l':
			show_lifetime();
			break;
		case 'p':
                        pEnd = &uart_buffer[1];
                        li1 = strtol (pEnd, &pEnd, 10);
                        switch (li1) {
                                case 1:
                                        P2OUT |= (PMT_CORE_PS );        // Enable PMT Powersupplies
                                        uprintf(PF," 12V PMT ON \r");
                                        break;
                                case 2:
                                        P2OUT |= (RADIO_CORE_PS );      // Enable RADIO Powersupplies
                                        uprintf(PF," 12V RADIO ON \r");


                                        break;
                                case 3:
                                        P1OUT |= (EXT_CORE_PS );        // Enable EXT1/2 Powersupplies
                                        uprintf(PF," 24V EXT1/2 ON \r");

                                        break;
                                case 4:
                                        P1OUT |= (PS_AN_EN);        // Enable ADC +-3V3 Powersupplies
                                        uprintf(PF," +/-3V3 ADC ON \r");

                                        break;
                                case 5:
                                        P1OUT |= (FPGA_CORE_PS );       // Enable EXT1/2 Powersupplies
                                        uprintf(PF,"  1V0 1V8 3V3 FPGA ON \r");

                                default:
                                        break;
                        }

			break;
		case 'P':
                        pEnd = &uart_buffer[1];
                        li1 = strtol (pEnd, &pEnd, 10);
                        switch (li1)  {
                               case 1:
                                        P2OUT &= ~(PMT_CORE_PS );        // Enable PMT Powersupplies
                                        uprintf(PF," 12V PMT OFF \r");
                                        break;
                                case 2:
                                        P2OUT &= ~(RADIO_CORE_PS );      // Enable RADIO Powersupplies
                                        uprintf(PF," 12V RADIO OFF \r");


                                        break;
                                case 3:
                                        P1OUT &= ~(EXT_CORE_PS );        // Enable EXT1/2 Powersupplies
                                        uprintf(PF," 24V EXT1/2 OFF \r");

                                        break;
                                case 4:
                                        P1OUT &= ~(PS_AN_EN );        // Enable ADC +-3V3 Powersupplies
                                        uprintf(PF," +/-3V3 ADC OFF \r");

                                        break;
                                case 5:
                                        P1OUT &= ~(FPGA_CORE_PS );       // Enable EXT1/2 Powersupplies
                                        uprintf(PF,"  1V0 1V8 3V3 FPGA OFF \r");

                                default:
                                        break;
                        }



			break;
		default:
			break;
	}
 	UART_sprint ("\r>");

}
void show_lifetime()
{ char b[12];
	UART_sprint("Lifetime [s]: ");
	sprintf ( b, "%lu", Second);
	UART_sprint (b);
}

int check ( int v, int n, int t) // v= value, n= nominal, t= tolerance in %
{
float min, max;
int ret;
 min = (float) n * (1.- (float) t/100.); 
 max = (float) n * (1.+ (float) t/100.); 
 ret = 0;
 if ( v < (int) min ) ret =1;
 if ( v > (int) max ) ret =1;
 return (ret);

}
void POR_FPGA()
{
	delay (200); // to do: wait for 3V3 exceeds 2.7 V
// drive RST_FPGA low
//drive 3V3_QSPI_B high
	P4DIR |= B3V3_QSPI_B;	// B3V3_QSPI_B set to low
	delay (15);		// wait 15 ms
	P5DIR &= ~NMI_FPGA; 	// release NMI_FPGA
	delay (175);		// wait 175 ms (total 200)
	P5DIR &= ~RST_FPGA; 	// release NMI_FPGA
	
}	 
void POR_B_FPGA()
{
// drive RST_FPGA low
	delay (500);		// to be changed later for interrupt
	P5DIR |= RST_FPGA;	// B3V3_QSPI_B set to low
//drive 3V3_QSPI_B high
        P4DIR &= ~B3V3_QSPI_B;   // release 3v3_QSPI 
        delay (10);             // wait 15 ms
	P4DIR |= B3V3_QSPI_B;	// B3V3_QSPI_B set to low
        delay (200);             // wait 15 ms
        P5DIR &= ~RST_FPGA;     // release NMI_FPGA

}

void SRST_B_FPGA()
{
// drive RST_FPGA low
        P5DIR |= NMI_FPGA;      // B3V3_QSPI_B set to low
//drive 3V3_QSPI_B high
        P4DIR &= ~B3V3_QSPI_B;   // release 3v3_QSPI
        delay (10);             // wait 15 ms
        P4DIR |= B3V3_QSPI_B;   // B3V3_QSPI_B set to low
        delay (100);             // wait 15 ms
        P5DIR &= ~NMI_FPGA;     // release NMI_FPGA

}


/*
//drive 3V3_QSPI_B low
	P4OUT &= ~B3V3_QSPI_B; 
//wait for PS_POR_B to be high
 	while ( (P5IN & PS_POR_B) == 0 );
  delay(1000);               // wait for a second

// drive RST_FPGA high
	P5OUT |= RST_FPGA; 

// start watching QSPI_RST_N
*/

void QSPI_RST()
{
/*
// drive NMI_FPGA low
	P5DIR |= NMI_FPGA;   // allow to be pulled to low
	P5OUT &= ~NMI_FPGA;
//drive 3V3_QSPI_B high
        P4OUT |= B3V3_QSPI_B;

//	drive 3V3_QSPI_B low
        P4OUT &= ~B3V3_QSPI_B;  
// release NMI_FPGA (define pin to be input)
	P5DIR &= ~NMI_FPGA;
*/
//drive 3V3_QSPI_B high
        P4DIR &= ~B3V3_QSPI_B;   // release 3v3_QSPI (goes high)
        P4OUT |= B3V3_QSPI_B;
        P5DIR |= PS_POR_B;   // set PS_POR_B to OUPUT -> goes low
	delay (4);	
        P4OUT &= ~B3V3_QSPI_B;  
	delay (4);	
	P4DIR |= B3V3_QSPI_B;	// B3V3_QSPI_B set to low
        P5DIR &= ~PS_POR_B;   // release 3v3_QSPI (goes high)
//  look on QSPI_RST_N == 0
//	while ((P5IN & QSPI_RST_N) == 0) {};
}
