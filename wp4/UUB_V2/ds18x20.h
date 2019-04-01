#ifndef DS18X20_H_
#define DS18X20_H_
#include <inttypes.h>
#define DS1820_REN 					P4REN
#define DS1820_OUT 					P4OUT
#define DS1820_DIR 					P4DIR
#define DS1820_SEL					P4SEL
#define DS1820_IN					P4IN
#define DS1820_DATA_IN_PIN          BIT0

#define DS1820_RELEASE DS1820_DIR &= ~DS1820_DATA_IN_PIN;  
#define DS1820_SKIP_ROM 	    0xCC
#define DS1820_READ_SCRATCHPAD      0xBE
#define DS1820_CONVERT_T            0x44

void InitDS18B20(void);
uint8_t  ResetDS1820 ( void );
void DS1820_HI(void);
void DS1820_LO(void);
void WriteZero(void);
void WriteOne(void);
uint8_t ReadBit(void);
void WriteDS1820 (unsigned char,int );
uint16_t ReadDS1820 ( void );
int DS18x20_GetData(void);
#endif /*DS18X20_H_*/
