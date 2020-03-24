#include <stdio.h>
#include "Energia.h"
#include "USCIAB0.h"
#include "wiring.h"
#include "i2c.h"
#include "eeprom.h"
void readEEPROM( unsigned int eeaddress,  
                 char* data, int num_chars) 
{
  I2C_Read_Reg16( eeprom_adr, eeaddress, num_chars, data);

}
void writeEEPROM( unsigned int page,  char *data) 
{
  // Uses Page Write for 24LC256
  // Allows for 64 byte page boundary
  // Splits string into max 16 byte writes
  unsigned int  address;
  unsigned int  data_len=0;
  unsigned char u8_buffer [2+64];
  
  // Calculate length of data
  address = page *64;
  u8_buffer [0] = (unsigned char) ((address) & 0xFF);
  u8_buffer [1] = (unsigned char) ((address) >> 8);
   while(data[data_len]){
	u8_buffer[2+data_len] = (unsigned char) data[data_len]; 
	data_len++;
  }   
  I2C_Write ( eeprom_adr, 2+data_len, u8_buffer);

     
     delay(6);  // needs 5ms for page write
}
void dumpEEPROM ( unsigned int page)
{ int i;
  unsigned char data[64];	
  unsigned int start;
	start = page*64;
	readEEPROM ( start, data, 64);
	for (i=0; i<64; i++) 
	{
		if (i % 8 == 0) uprintf(PF, "\r\n%d: ",i);
		uprintf (PF, "0x%x ",data[i]);
	}
	uprintf (PF, "\r\n");
}
