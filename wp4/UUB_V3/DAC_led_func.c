#include "stdio.h"
#include "DAC_led_func.h"
#include "i2c.h"
#include "USCIAB0.h"
void dac_led_init ()
{
//unsigned char i;
// set all channels to 0x00
//for (i=0; 8>i; i++) dac_set ( i, 0);
}
void dac_led_set ( unsigned char chan, int value )
{
// unsigned char  data[3], ch;
char  data[3], ch;
	ch = 1 << chan;
	data [0] = 0x30+(ch & 0xf);
//	value = value << 4;
//	data [1] = 0xff & (value >> 8);
//	data [2] = 0xf0 & value;
	data[1]=(value >> 4);
	data[2]=((value & 0x0f) << 4);
uprintf (PF,"data[1]= 0x%x; data[2]=0x%x\r", data[1], data[2]);
	I2C_Write (0x0c, 3, data);
}
