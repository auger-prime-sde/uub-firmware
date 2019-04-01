#include "Energia.h"
#include <stdio.h>
#include "USCIAB0.h"
#include "DS28CM00_func.h"
#include "i2c.h"
unsigned char DS28CM_data[8];
void Read_DS28CM00_ASCII ( char * buffer )
{unsigned char *cp; 
	cp = Read_DS28CM00_BIN();
	if (DS28CM_data[0] != 0x70 ) {
	sprintf ( buffer, "Error reading DS28CM00\r");
		return;
	}

	sprintf ( buffer, "%2x-%2x-%2x-%2x-%2x-%2x %2x",
				(int) DS28CM_data[1],
				DS28CM_data[2],
				DS28CM_data[3],
				DS28CM_data[4],
				DS28CM_data[5],
				DS28CM_data[6],
				DS28CM_data[7]);
}
unsigned char * Read_DS28CM00_BIN ( )
{	DS28CM_data[0]=0;
      I2C_Write_Reg ( DS28CM_ID, 8, 1, DS28CM_data);
      I2C_Read_Reg ( DS28CM_ID, 0, 8, DS28CM_data);
//	DS28CM_data[0]=0x70;
//	DS28CM_data[1]=0x01;
//	DS28CM_data[2]=0x02;
//	DS28CM_data[3]=0x03;
//	DS28CM_data[4]=0x04;
//	DS28CM_data[5]=0x05;
//	DS28CM_data[6]=0x06;
//	DS28CM_data[7]=0x07;
	return (DS28CM_data);
}
