#include "DAC_func.h"
#include "i2c.h"
#include "USCIAB0.h"
void dac_init ()
{
unsigned char i;
// set all channels to 0x00
for (i=0; 8>i; i++) dac_set ( i, 0);
}
void dac_set ( unsigned char chan, int value )
{
unsigned char  data[3];
	data [0] = 0x20 + (chan == 8 ? 0x0f :(chan & 0x07));
	value = value << 4;
	data [1] = 0xff & (value >> 8);
	data [2] = 0xf0 & value;
	I2C_Write (0x10, 3, data);
}
