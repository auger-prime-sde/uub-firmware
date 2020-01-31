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
#include "DAC_led_func.h"
#include "eeprom.h"
#include "i2c.h"
// test for BME280
#include "bme280.h"
#define I2C_IF           0x06      // I2C bits
#define EnWDOG    WDTCTL = (WDTPW | WDTCNTCL) & ~WDTHOLD
#define DisWDOG   WDTCTL = WDTPW | WDTHOLD
#include "adc.h"
#include "ishan.h"
#include "DS28CM00_func.h"
//
#define FIELD 1 // uncomment if field version
void PON_SEQ();
void POR_FPGA();
void POR_B_FPGA();
void QSPI_RST();
void receive_cb(unsigned char receive);
void transmit_cb(unsigned char volatile *receive);
void start_cb();
void stop_cb();
void gencall_cb();
void Parse_UART();
void show_lifetime();
void show_button_t();
int check ( int v, int n, int t); // v= value, n= nominal, t= tolerance in %
unsigned char tb = 0;
unsigned char flag = 0;
unsigned char flag1 = 0;
unsigned char TXData[260];
unsigned char RXData[260];
unsigned char tSec[4];
unsigned char stop=0;
unsigned char start=0;
unsigned char nstrt=0;
unsigned char gencall=0;
unsigned char gcall=0;
unsigned char rcv_bytes=0;
unsigned char burst;
unsigned char direction,direction_r;
unsigned char reading;
unsigned char mTX[3];
//#define LSB_TO_5V 1.8814
#define CALADC12_15V_30C  *((unsigned int *)0x10e2)
#define CALADC12_15V_85C  *((unsigned int *)0x10e4)

#define LSB_TO_5V 1.868		// Vref*10.2/2/4095
#define LSB_TO_24V 8.88
#define LSB_TO_12V 4.43
#define LSB_TO_3V3 1.20
#define LSB_TO_1V8 0.674
#define LSB_TO_1V2 0.421
#define LSB_TO_1V0 0.366
#define CNV_TEMP 1.831
//
#define U_CRITICAL 0x5a0 	//crtical batterie state, switch PS off
#define U_WARN 0x5e5	//warn DAQ (Ux*1000/(LSB*7.8)) for TPCB 7.5 
#define U_HIGH 0x73d	//recover from critical state
// uncomment for TPCB
//#define U_CRITICAL 0x5da        //crtical batterie state, switch PS off
//#define U_WARN 0x622    //warn DAQ (Ux*1000/(LSB*7.8)) for TPCB 7.5 
//#define U_HIGH 0x787    //recover from critical state

#define U_BAT_CRIT 0x0004
#define U_BAT_WARN 0x0100
// TBC #define SLEEPING   0x0200
volatile extern unsigned long Second;
unsigned long WD_TIME;
unsigned long UpdateSensor;
#define DELTAUPDATE 10
#define PIN_ON                  P1OUT &=~0x02; P1DIR |= 0x02;
#define PIN_OFF                  P1OUT |= 0x02; P1DIR |= 0x02;
#define I2C_ADDRESS 0x0f	// I2C slave adress
#define PRESCALER 12
unsigned char x=0;
unsigned int  has_DS1820;
char buffer [80];
#define WD_INTERVAL 	5	// Watchdog Interval [sec]
#define T1		300	//Time delay after start powersupplies in ms
void SLEEP ()
{
// Take over watchdog
   SC_WD_ENABLE;
   WD_TIME = Second + 1;
// Set sleepmode

// Power down all power supplies


}
void Wake_Up ()
{
// Force watchdog reset

}
// BME280

int8_t user_i2c_read ( uint8_t id, uint8_t reg_addr, uint8_t *data, uint16_t len)
{
	I2C_Read_Reg ( id, reg_addr, len, data);
	return 0;
}
int8_t user_i2c_write ( uint8_t id, uint8_t reg_addr, uint8_t *data, uint16_t len)
{
uint8_t buff[2];
buff[0] = reg_addr;
buff[1] = *data;
        I2C_Write ( id, len+1, buff);
	return 0;
}

//
void check_battery()
{ 
	if (adc_results[BAT_OUT] < U_CRITICAL ) status_reg |= U_BAT_CRIT;
	if (adc_results[BAT_OUT] < U_WARN ) status_reg |= U_BAT_WARN;
	if (adc_results[BAT_OUT] > U_WARN + 0xa0) status_reg &= ~U_BAT_WARN; //release warn at ~10% above
	if (adc_results[BAT_OUT] > U_HIGH) status_reg &= ~U_BAT_CRIT;
}
void SlowControl_WD_Enable ()
{
        pinMode(SL_WD_EN_PIN, OUTPUT);
        digitalWrite (SL_WD_EN_PIN,HIGH);

}
// bme280
struct bme280_dev bme280;
struct bme280_data comp_data;
int8_t rslt = BME280_OK;
uint8_t bme280_meas;
// end bme280
void EEProm_w( unsigned int page, char*p, int size)
{
//	uprintf (PF,"Page :  %d\r\n",page);
//	uprintf (PF,"Ident:  %s\r\n",p);
//	uprintf (PF,"Size :  %d\r\n",size);
	writeEEPROM ( page, p );

}
void EEProm_r( int page, char*p, int size)
{
//        uprintf (PF,"Page :  %d\r\n");
//        uprintf (PF,"Ident:  %s\r\n");
//        uprintf (PF,"Size :  %d\r\n");
	readEEPROM ( page, p, size );
}

int main ()
{
init();
setup();
bme280.dev_id = BME280_I2C_ADDR_SEC;
bme280.intf = BME280_I2C_INTF;
bme280.read = user_i2c_read;
bme280.write = user_i2c_write;
bme280.delay_ms = delay;
rslt = bme280_init( &bme280 ); 
if (rslt != BME280_OK ) uprintf ( PF, " Failed to initialize BME280 device \r\n");
  bme280.settings.osr_h = BME280_OVERSAMPLING_1X;
  bme280.settings.osr_p = BME280_OVERSAMPLING_1X;
  bme280.settings.osr_t = BME280_OVERSAMPLING_1X;
  bme280.settings.filter = BME280_FILTER_COEFF_OFF;
  rslt = bme280_set_sensor_settings(	(BME280_OSR_PRESS_SEL | 
					BME280_OSR_TEMP_SEL | 
					BME280_OSR_HUM_SEL | 
					BME280_FILTER_SEL), &bme280);
  rslt = bme280_set_sensor_mode(BME280_FORCED_MODE, &bme280);
  bme280.delay_ms (40);
  rslt = bme280_get_sensor_data(BME280_ALL, &comp_data, &bme280);
  adc_results[T_AIR] = (unsigned int) (comp_data.temperature/10);
  adc_results[P_AIR] = (unsigned int) (comp_data.pressure/10);
  adc_results[H_AIR] = (unsigned int) (comp_data.humidity/100);


  bme280_update_time = Second + UPD_BME280_Delta;
  while (1) loop();
  return 0;
}

// the setup routine runs once when you press reset:
void setup() {                
 	MISC_Config();
 	IO_Config();
// Hold lines DONE, SLAVE_SDA, SLAVE_SCL low till FPGA 3V3 enabled
	pinMode(FPGA_DONE_PIN, OUTPUT);
	digitalWrite(FPGA_DONE_PIN, LOW);
	pinMode(SLAVE_SDA_PIN, OUTPUT);
	digitalWrite(SLAVE_SDA_PIN, LOW);
	pinMode(SLAVE_SCL_PIN, OUTPUT);
	digitalWrite(SLAVE_SCL_PIN, LOW);
//
// power down I2C slaves
//
	pinMode (SC_I2C_EN_PIN, OUTPUT);
	digitalWrite(SC_I2C_EN_PIN, HIGH);
 	led_fblink (50);           //set LED1 blink 5Hz
 	UART_Config();
  	delay(500);               // wait for a second
//
// Power up I2C slaves
//
	digitalWrite(SC_I2C_EN_PIN, LOW); 
//
  	delay(500);               // wait for a second
 	UART_sprint("Auger SD Slow Control system ready \n\r");
//
// Read DS28CM00 Serial Number
//
	uprintf (PF, "Software Version: %d.%d", VERSION>>8, VERSION & 0xff);
 	UART_sprint(" \r");
// DEBUG: comment out I2C comunication before FPGS initialized
 	UART_sprint("Serial: ");
	Read_DS28CM00_ASCII ( buffer );
 	UART_sprint(buffer);
 	UART_sprint(" \n\r>");
	UART_sprint("Starting FPGA:");
//	P5DIR |= B3V3_QSPI_B | NMI_FPGA | RST_FPGA; // 
	P5DIR |= NMI_FPGA | RST_FPGA; // 
#ifdef FIELD
	PON_SEQ ();	// New Power ON Sequence
	UART_sprint(" ........ ");
#else 
               uprintf (PF,"Version TEST %d\r");
//             
          P2OUT |= (PS_PMT_12V_EN | PS_RADIO_12V_EN);     // Enable ADC Powersupplies

                P1OUT &= ~(FPGA_CORE_PS);
                P1OUT &= ~(PS_AN_EN | PS_EXT1_24V_EN | PS_EXT2_24V_EN);  // Enable ADC Powersupplies 
                P2OUT &= ~(PS_PMT_12V_EN | PS_RADIO_12V_EN);     // Enable ADC Powersupplies

#endif
 	UART_sprint("Initialize ADCs \r");

	dac_init();
	adc_init();

  TI_USCI_I2C_slaveinit(start_cb, stop_cb, gencall_cb, transmit_cb, receive_cb, I2C_ADDRESS);
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
	if (SC_WD_STATE) {
			if ( WD_TIME == Second ) {
				digitalToggle ( SL_WD_PIN);
				WD_TIME = Second + WD_INTERVAL;
			}
	}
}
// the loop routine runs over and over again forever:
void loop() {
#ifdef FIELD 
  
  if (act_mask & QSPI_RST_N_IRQ ) {
long dt;	
	dt = millis();
	uprintf (PF, "P4DIR: 0x%x P4IN: 0x%x \r",P4DIR, P4IN);
	uprintf (PF, "P5DIR: 0x%x P5IN: 0x%x \r",P5DIR, P5IN);
  	uprintf (PF, "QSPI_RST_N ... " );
        digitalWrite (QSPI_3V3_B_PIN,LOW);
        pinMode(RST_FPGA_PIN, OUTPUT);
        digitalWrite (RST_FPGA_PIN,LOW);

        delayMicroseconds(6800);
        digitalWrite (QSPI_3V3_B_PIN,HIGH);
        delay (16);
        digitalWrite (RST_FPGA_PIN,HIGH);
        pinMode(RST_FPGA_PIN, INPUT);
	dt = millis() -dt;
	uprintf (PF," time %ld ms\n",dt);
        P1IE |= QSPI_RST_N;
        act_mask &= ~QSPI_RST_N_IRQ;

  }
#endif
        tSec[0] = (char) (Second & 0xff);
        tSec[1] = (char) ((Second >> 8) & 0xff);
        tSec[2] = (char) ((Second >> 16) & 0xff);
        tSec[3] = (char) ((Second >> 24) & 0xff);


        if ( Second == bme280_update_time ) {
		rslt = bme280_set_sensor_mode ( BME280_FORCED_MODE, &bme280);
		bme280.delay_ms (40);
		rslt = bme280_get_sensor_data(BME280_ALL, &comp_data, &bme280);
		bme280_update_time += UPD_BME280_Delta;
		adc_results[T_AIR] = (unsigned int) (comp_data.temperature/10);
		adc_results[P_AIR] = (unsigned int) (comp_data.pressure/10);
		adc_results[H_AIR] = (unsigned int) (comp_data.humidity/100);
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
// check if conversion pending
	if (0 == adcctl) { // conversion done
		check_battery ();
	}


  if ( stop == 1 ) {
unsigned char *cp;
int i;
unsigned char nb;
unsigned int reg, mask;
   	stop = 0;
	nb = rcv_bytes;
//                uprintf(PF,"STP =1; rcv_bytes= %d nb: %d  \r",rcv_bytes, nb);
	rcv_bytes = 0;
	reg = RXData[1]<<8 | RXData[0];
    switch (reg) {  
      case 0x1:   // Serial number
	cp = Read_DS28CM00_BIN();
	for (i=0; i<=7; i++) TXData[i] = *cp++;
	tb = 8;	
	break;
      case 0x2:  // Status Reg
		TXData[0] = (char) (status_reg & 0xff);
		TXData[1] = (char) ((status_reg >> 8) & 0xff);
	tb = 2;	
	break;
  //    case 0x3: // Livetime
  //              TXData[0] = (char) (Second & 0xff);
  //              TXData[1] = (char) ((Second >> 8) & 0xff);
  //              TXData[2] = (char) ((Second >> 16) & 0xff);
  //              TXData[3] = (char) ((Second >> 24) & 0xff);
  //	tb = 4;	
  //	break;
      case 0x4:           // Power ctrl
	if ( nb == 2 ) {  // read
		TXData[0] = P1IN;
		TXData[1] = P2IN & 0x03; 
	tb = 2;	
 	} else            // write
	{
//                uprintf(PF,"PWR: P1 0x%x P2: 0x%x\r",RXData[2],RXData[3]);
		mask = 0x3a | RXData[2];
		P1OUT = mask; // make sure not to switch off FPGA
		if (nb > 3 ) {
			mask = P2IN & 0xfc;
			P2OUT = mask | (RXData[3] & 0x3);
		}
	}	
	break;
      case 0x5: // DAC control
	if (nb  == 4 ) {
	long int li1, li2;
		li1 = (RXData[3] & 0x70)>>4;
                li2 = (RXData[3] & 0x0f)<<8 | RXData[2];
                if ( (li1 >=0 && li1 <=7 ) && (li2 >=0 && li2 < 4096 ) ) {
                     dac_set ( li1, li2 );
                }

	}
	break;
      case 0x8: // LED DAC control
        if (nb == 4 ) {
        long int li1, li2;
                li1 = (RXData[3] & 0x70)>>4;
                li2 = (RXData[3] & 0x0f)<<8 | RXData[2];
                if ( (li1 >=0 && li1 <=3 ) && (li2 >=0 && li2 < 4096 ) ) {
                     dac_led_set ( li1, li2 );
                }

        }
        break;

      case 0x6: // Watchdog Control ON
		 SlowControl_WD_Enable ();
	break;
      case 0x7: // SC_WD ON/OFF
	SlowControl_WD_Enable ();
	if ( RXData[2] ) {
		SC_WD_ENABLE;
                WD_TIME = Second + 1;
                uprintf(PF," SlowControl WD running \r");

	}
	else {
		SC_WD_DISABLE;

	}
	break;
      case 0x9: // ADC values
	cp = (char *) adc_results;
	for (i=0; i<2*MAX_VARS; i++) TXData[i] = *cp++;
	tb = 2*MAX_VARS;
	break;
     case 0xa:  // Test
	TXData[0] = 0x21;
        TXData[1] = 0x43;
	tb = 2;	
	break;
      case 0xb:
//	while (1); // Stop, wait for WD
	break;
      case 0xc:	   // Radio reset, pin 47 (P5_3) low for 300ms
	pinMode ( RAD_RST_OUT_PIN, OUTPUT );
	digitalWrite ( RAD_RST_OUT_PIN, LOW);
	delay (300);
	pinMode ( RAD_RST_OUT_PIN, INPUT );
	break;
      case 0xd: // temporary DAC reset
	if ( RXData[2] == 1 ) {
        	pinMode(EN_ADC_AN_1V8_PIN, OUTPUT);
        	digitalWrite (EN_ADC_AN_1V8_PIN,HIGH);
	}
	if ( RXData[2] == 3 ) {
        	pinMode(EN_ADC_DG_1V8_PIN, OUTPUT);
        	digitalWrite (EN_ADC_DG_1V8_PIN,HIGH);
	} 
	if ( RXData[2] == 0 ) {
                pinMode(EN_ADC_AN_1V8_PIN, OUTPUT);
                digitalWrite (EN_ADC_AN_1V8_PIN,LOW);
	}
	if ( RXData[2] == 2 ) {
                pinMode(EN_ADC_DG_1V8_PIN, OUTPUT);
                digitalWrite (EN_ADC_DG_1V8_PIN,LOW);
	}
	break;
      case 0xe: // Report version number

        TXData[0] = VERSION & 0xff;
        TXData[1] = VERSION >> 8;
	tb = 2;	

	break;
      case 0x0f: // Read/Write EEProm
//                uprintf(PF,"EEPROM nb: %d  ",nb);
        if (nb == 2 ) {
		EEProm_r ( 0 , TXData, 4);
	tb = 4;	
//                uprintf(PF," read: 0x%x 0x%x 0x%x 0x%x \r",TXData[0],TXData[1],TXData[2],TXData[3]);
        } else
        {
//                uprintf(PF," write: 0x%x 0x%x 0x%x 0x%x \r",RXData[2],RXData[3],RXData[4],RXData[5]);
                EEProm_w (0, &RXData[2], 4);
                
        }

	break;
      case 0x10: // special for linear 3V3 converters
	if ( RXData[2] == 1 ) {
		pinMode (PS_AN_EN_PIN, OUTPUT);
		digitalWrite (PS_AN_EN_PIN, HIGH);
	}
	else {
		pinMode (PS_AN_EN_PIN, OUTPUT);
		digitalWrite (PS_AN_EN_PIN, LOW);
	}
      default:
	break;
   }
//   rcv_bytes=0;
  }
  __bis_SR_register(LPM0_bits + GIE);     // Enter LPM0, enable interrupts
//   _EINT();
}
void start_cb(){
  flag1 = 0;
  flag = 0;
  nstrt++;
  rcv_bytes=0;
}
void stop_cb(){
  stop = direction;
  nstrt = 0;
if (direction ) {
//	uprintf (PF, "r %d \r",flag1);
	} else {
//	uprintf (PF, "s %d \r",flag);
	};
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
  if (nstrt > 1 ) {
        *byte  = tSec[flag++];
  } else {
  *byte = TXData[flag++];
  }	
}
char * pEnd;
int li1, li2, li3;
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
		case 'r': //status_reg
			if (status_reg & PS_AN)  uprintf (PF, "\r%s","PS_AN");
			if (status_reg & PS_5V)  uprintf (PF, "\r%s","PS_5V");
			if (status_reg & PS_3V3) uprintf (PF, "\r%s","PS_3V3");
			if (status_reg & PS_1V8) uprintf (PF, "\r%s","PS_1V8");
			if (status_reg & PS_1V)  uprintf (PF, "\r%s","PS_1V");
			if (status_reg & PS_EXT1) uprintf (PF, "\r%s","PS_EXT1");
			if (status_reg & PS_EXT2) uprintf (PF, "\r%s","PS_EXT2");
			if (status_reg & U_BAT_CRIT) uprintf (PF, "\r%s","U_BAT_CRIT");
			if (status_reg & BAT_LOW) uprintf (PF, "\r%s","BAT_WARN");
			if (status_reg & CUR_ERR) uprintf (PF, "\r%s","CUR_ERR");
			if (status_reg & TMP_ERR) uprintf (PF, "\r%s","TMP_ERR");
			if (status_reg & PS_MAIN) uprintf (PF, "\r%s","PS_MAIN");
			if (status_reg & WD_STAT) uprintf (PF, "\r%s","WD_STAT");
//			if (status_reg & SRST_B) uprintf (PF, "\r%s","SRST_B");
			if (status_reg & FPGA_DONE_STAT) uprintf (PF, "\r%s\r U_BAT:","FPGA_DONE");
		 uprintf (PF," adc: %d \r", adc_results[BAT_OUT]);

			break;
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
                        uprintf( PF, "\r 10V      ");
                        print_f((float)adc_results[V_10V]*LSB_TO_12V,"[mV] ");

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
                        print_f((float)adc_results[I_3V3_SC]*LSB_TO_1V0/60.*1.22,"[mA SC] "); // 1.22 = 1/0.82
			if (check (adc_results[V_3V3], 0xac6, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r P3V3     ");
                        print_f((float)adc_results[V_AN_P5V]*LSB_TO_3V3,"[mV] ");
                        print_f((float)adc_results[I_P5V_ANA]*LSB_TO_1V0/60.*12.2,"[mA] ");
			if (check (adc_results[V_3V3], 0xac6, 5)) uprintf (PF, "<----- ERROR");
                        uprintf( PF, "\r N3V3     ");
                        print_f(3500. - (float)(adc_results[V_AN_N5V]*LSB_TO_1V0),"[mV] ");
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
                        uprintf (PF, "\r T = %d *0.1K\r P = %d *0.1 mBar \r",adc_results[T_AIR],adc_results[P_AIR]);
                        uprintf (PF, " H = %d *0.1 %%\r",adc_results[H_AIR]);
                        uprintf (PF, " T_WAT = %d *0.1K\r",adc_results[T_WAT]);
				                        
			break;
		case 'A':
			adc_dump();
			break;
		case 'D':
                        pEnd = &uart_buffer[1];
                        li1 = strtol (pEnd, &pEnd, 10);
                        li2 = strtol (pEnd, &pEnd, 10);
                        if ( (li1 >=0 && li1 <=4 ) && (li2 >=0 && li2 < 4096 ) ) {
uprintf (PF,"li1: 0x%x, li2: 0x%d\r",li1,li2); 
                                dac_led_set ( li1, li2 );
                                }
                        else {
                                UART_sprint (" out of range");
                        }
                        break;
     
			break;
		case 'd':
			pEnd = &uart_buffer[1];
			li1 = strtol (pEnd, &pEnd, 10);
			li2 = strtol (pEnd, &pEnd, 10);
			if ( (li1 >=0 && li1 <=8 ) && (li2 >=0 && li2 < 4096 ) ) {
uprintf (PF,"li1: 0x%x, li2: 0x%x\r",li1,li2); 
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

			uprintf( PF,"p or P n - enable/disable power supplies\r");
			uprintf( PF,"       n =1 12V PMT\r");
			uprintf( PF,"       n =2 12V RADIO\r");
			uprintf( PF,"       n =3 24V EXT1/EXT2\r");
			uprintf( PF,"       n =4 +/- analog 3V3\r");
			uprintf( PF,"       n =5 +/- FPGA core power supplies (FPGA will not boot after disabling)\r");
			uprintf( PF,"d or D chan val - set DAC channnel chan [0..8] to value val [0..4095]\r");
			uprintf( PF,"a - show analog variables in physical units\r");
			uprintf( PF,"A - show analog variables as raw data in HEX\r");
			uprintf( PF,"w or W and X foe WD handling\r");
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
			break;
                case 'b':
		case 'B':
			show_button_t();
			break;
		case 'L':
                        pEnd = &uart_buffer[1];
                        li1 = strtol (pEnd, &pEnd, 10);
        		if (li1) { 
				P5OUT |= EN_ADC_AN_1V8_PIN;
				P5OUT |= EN_ADC_DG_1V8_PIN;
			}
			else {
				P5OUT &= ~EN_ADC_AN_1V8_PIN;
				P5OUT &= ~EN_ADC_DG_1V8_PIN;
			}
			break;
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
                                        P1OUT |= (FPGA_CORE1_PS );       // Enable EXT1/2 Powersupplies
                                        P1OUT |= (FPGA_CORE2_PS );       // Enable EXT1/2 Powersupplies
                                        uprintf(PF,"  1V0 1V8 3V3 FPGA ON \r");

                                default:
                                        break;
                        }

			break;
		case 'P':		// disable supplies
                        pEnd = &uart_buffer[1];
                        li1 = strtol (pEnd, &pEnd, 10);
                        switch (li1)  {
                               case 1:
                                        P2OUT &= ~(PMT_CORE_PS );        // PMT Powersupplies
                                        uprintf(PF," 12V PMT OFF \r");
                                        break;
                                case 2:
                                        P2OUT &= ~(RADIO_CORE_PS );      // RADIO Powersupplies
                                        uprintf(PF," 12V RADIO OFF \r");


                                        break;
                                case 3:
                                        P1OUT &= ~(EXT_CORE_PS );        // EXT1/2 Powersupplies
                                        uprintf(PF," 24V EXT1/2 OFF \r");

                                        break;
                                case 4:
                                        P1OUT &= ~(PS_AN_EN );        // ADC +-3V3 Powersupplies
                                        uprintf(PF," +/-3V3 ADC OFF \r");

                                        break;
                                case 5:
                                        P1OUT &= ~(FPGA_CORE1_PS );       // FPGA Powersupplies
                                        P1OUT &= ~(FPGA_CORE2_PS );       // Powersupplies
                                        uprintf(PF,"  1V0 1V8 3V3 FPGA OFF \r");

                                default:
                                        break;
                        }



			break;
		case 'w':
			SC_WD_ENABLE;
			WD_TIME = Second + 1;
                        uprintf(PF," SlowControl WD running \r");
			break;
		case 'W':
			SC_WD_DISABLE;
                        uprintf(PF," SlowControl WD stopped \r");
			break;
		case 'x':
		case 'X':
			SlowControl_WD_Enable (); 
                        uprintf(PF," SlowControl WD enabled \r");
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
void show_button_t()
{ char b[12];
        UART_sprint("Pressed [ms]: ");
        sprintf ( b, "%lu", t0_srst_b);
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

void QSPI_RST()
{
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
}
//  Power ON sequence for gen. II UUB
void PON_SEQ()
{
// RST_FPGA -> LOW
	pinMode(NMI_FPGA_PIN, OUTPUT);
	digitalWrite (NMI_FPGA_PIN,LOW); 
        P1OUT =(FPGA_CORE1_PS);  // Enable 1V PS
        P1OUT |=(PS_1V8_EN);  // Enable 1V8 Must be before 3V3 on V3
	delay (1);
        P1OUT |=(FPGA_CORE2_PS);  // Enable 1V2,  3V3 + 5V PS
//        delayMicroseconds(500);
	pinMode(FPGA_DONE_PIN, INPUT);
	pinMode(SLAVE_SDA_PIN, INPUT);
	pinMode(SLAVE_SCL_PIN, INPUT);
//	delay (4);
//        P1OUT |=(PS_1V8_EN);  // Enable 1V8 Must be after 3V3??

	pinMode(RST_FPGA_PIN, OUTPUT);
	digitalWrite (RST_FPGA_PIN,LOW); 
// NMI_FPGA -> HIGH
	pinMode(NMI_FPGA_PIN, OUTPUT);
	digitalWrite (NMI_FPGA_PIN,HIGH); 
// QSPI_3V3_B -> LOW
        pinMode(QSPI_3V3_B_PIN, OUTPUT);
        digitalWrite (QSPI_3V3_B_PIN,LOW);
// SL_WD -> LOW
        pinMode(SL_WD_PIN, OUTPUT);
        digitalWrite (SL_WD_PIN,LOW);

// Wait T1
	delay (T1);
// RST_FPGA -> HIGH
        digitalWrite (RST_FPGA_PIN,HIGH);
// QSPI_3V3_B -> HIGH
        digitalWrite (QSPI_3V3_B_PIN,HIGH);
//        delay (200); 	// wait 200 ms
        delay (200); // wait 200 ms
// Normal startup for V2 & V3 UUB
//        P1OUT |= (PS_AN_EN | PS_EXT1_24V_EN | PS_EXT2_24V_EN);  // Enable ADC Powersupplies 
// for V3 UUB with 3V3 linear 3V3 converters (Special request by Roberto)
         P1OUT |= ( PS_EXT1_24V_EN | PS_EXT2_24V_EN);  // Enable ADC Powersupplies 
        P2OUT |= (PS_PMT_12V_EN | PS_RADIO_12V_EN);     // Enable ADC Powersupplies
	SlowControl_WD_Enable ();
        SC_WD_ENABLE;
        WD_TIME = Second + 1;


}
