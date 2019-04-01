#include "Energia.h"
#include <stdio.h>
#include "USCIAB0.h"
#include "BMP180_func.h"
#include "i2c.h"
#define debug 1
void BMP180_init (  )
{ 


}
uint8_t BMP180_IsConnected ()
{
uint8_t data;
	 I2C_Read_Reg ( BMP180_Address, Reg_ChipId, 1, &data );

	if (data == ChipIdData )
		return 1;
	else
		return 0;


}

void BMP180_GetValues( unsigned int *Temperature, unsigned int *Pressure) {
	BMP180_GetCal();
//	if (debug) BMP180_PrintCalibrationData();
	*Temperature = (unsigned int) BMP180_CompensateTemperature(BMP180_GetUncompensatedTemperature());
//	uprintf ( PF, "compensated Temp: "); pf ( ct );uprintf (PF, "\r");
	*Pressure = ( unsigned int) BMP180_CompensatePressure(BMP180_GetUncompensatedPressure());
//	uprintf ( PF, "compensated Press: %d \r", ch);

	return;
}
void BMP180_GetCal ()
{
uint8_t buffer[22];
	I2C_Read_Reg ( BMP180_Address, Reg_CalibrationStart, 22, buffer );
	Calibration.AC1 = (buffer[0] << 8) | buffer[1];
    	Calibration.AC2 = (buffer[2] << 8) | buffer[3];
    	Calibration.AC3 = (buffer[4] << 8) | buffer[5];
    	Calibration.AC4 = (buffer[6] << 8) | buffer[7];
   	Calibration.AC5 = (buffer[8] << 8) | buffer[9];
    	Calibration.AC6 = (buffer[10] << 8) | buffer[11];
    	Calibration.B1 = (buffer[12] << 8) | buffer[13];
    	Calibration.B2 = (buffer[14] << 8) | buffer[15];
    	Calibration.MB = (buffer[16] << 8) | buffer[17];
    	Calibration.MC = (buffer[18] << 8) | buffer[19];
    	Calibration.MD = (buffer[20] << 8) | buffer[21];
/*
        Calibration.AC1 = 408;
        Calibration.AC2 = -72;
        Calibration.AC3 = -14383;
        Calibration.AC4 = 32741;
        Calibration.AC5 = 32757;
        Calibration.AC6 = 23153;
        Calibration.B1 = 6190;
        Calibration.B2 = 4;
        Calibration.MB = -32768;
        Calibration.MC = -8711;
        Calibration.MD = 2868;
*/

//	BMP180_PrintCalibrationData();
}
void BMP180_PrintCalibrationData()
{       uprintf (PF, "AC1: %d\r",Calibration.AC1);
        uprintf (PF, "AC2: %d\r",Calibration.AC2);
        uprintf (PF, "AC3: %d\r",Calibration.AC3);
        uprintf (PF, "AC4: %d\r",Calibration.AC4);
        uprintf (PF, "AC5: %d\r",Calibration.AC5);
        uprintf (PF, "AC6: %d\r",Calibration.AC6);
        uprintf (PF, "B1: %d\r",Calibration.B1);
        uprintf (PF, "B2: %d\r",Calibration.B2);
        uprintf (PF, "MB: %d\r",Calibration.MB);
        uprintf (PF, "MC: %d\r",Calibration.MC);
        uprintf (PF, "MD: %d\r",Calibration.MD);
}
int BMP180_GetUncompensatedTemperature()
{
    // Instruct device to perform a conversion.
    uint8_t data[2];
	data[0] = Reg_Control;
	data[1] = ControlInstruction_MeasureTemperature;
    I2C_Write(BMP180_Address, 2, data);
    // Wait for the conversion to complete.
    delay(5);
    I2C_Read_Reg (BMP180_Address, Reg_AnalogConverterOutMSB, 2, data);
    int value = (data[0] << 8) | data[1];
// uprintf (PF, "get ut UT: %d\r",value);
    return value;
}
int BMP180_CompensateTemperature(int uncompensatedTemperature)
{
int temperature;
int x2;
long x1;
    x1 = (((long)uncompensatedTemperature - (long)Calibration.AC6) * (long)Calibration.AC5) >> 15;
    x2 = ((long)Calibration.MC << 11) / (x1 + Calibration.MD);
    int param_b5 = x1 + x2;
    temperature = (int)((param_b5 + 8) >> 4);  /* temperature in 0.1 deg C*/

    // Record this data because it is required by the pressure algorithem.
    LastTemperatureData = param_b5;

    return 2732+temperature; 
}

long BMP180_GetUncompensatedPressure()
{
	int i;
    long pressure = 0;
    int loops = Oversample ? 3 : 1;
        uint8_t buffer[3];

    for (i = 0; i < loops; i++)
    {
        // Instruct device to perform a conversion, including the oversampling data.
        uint8_t CtrlByte = ControlInstruction_MeasurePressure + (OversamplingSetting << 6);
	buffer [0] = Reg_Control;
	buffer [1] = CtrlByte;
        I2C_Write(BMP180_Address, 2, buffer);
        // Wait for the conversion
        delay(ConversionWaitTimeMs);
        // Read the conversion data.
                I2C_Read_Reg(BMP180_Address, Reg_AnalogConverterOutMSB, 3, buffer);

        // Collect the data (and push back the LSB if we are not sampling them).
        pressure = ((((long)buffer[0] <<16) | ((long)buffer[1] <<8) | ((long)buffer[2])) >> (8-OversamplingSetting));
    }
//uprintf (PF, "get up UP: 0x%x \r",(int) (pressure));
//uprintf (PF, "get up buffer 0-2[hex]: %x %x %x\r", buffer[0], buffer[1], buffer[2]);
    return pressure / loops;
}
long BMP180_CompensatePressure(long uncompensatedPressure)
{

    // Algorithm taken from BMP180 datasheet.
//uprintf (PF, "LastTemperatureData: %d\r", LastTemperatureData);
    long b6 = LastTemperatureData - 4000;
//uprintf(PF,"CP:\r");
//uprintf(PF,"  B6: 0x%x%x\r",(int) (b6>>16 & 0xffff),(int)(b6 & 0xffff));
    long x1 = (Calibration.B2 * (b6 * b6) >> 12) >> 11;
//uprintf(PF,"  x1: 0x%x%x\r",(int) (x1>>16 & 0xffff),(int)(x1 & 0xffff));
    long x2 = (Calibration.AC2 * b6) >> 11;
//uprintf(PF,"  x2: 0x%x%x\r",(int) (x2>>16 & 0xffff),(int)(x2 & 0xffff));
    long x3 = x1 + x2;
//uprintf(PF,"  x3: 0x%x%x\r",(int) (x3>>16 & 0xffff),(int)(x3 & 0xffff));
    long b3 = (((((long)Calibration.AC1) * 4 + x3) << OversamplingSetting) + 2) >> 2;
//uprintf(PF,"  b3: 0x%x%x\r",(int) (b3>>16 & 0xffff),(int)(b3 & 0xffff));
    x1 = (Calibration.AC3 * b6) >> 13;
//uprintf(PF,"  x1: 0x%x%x\r",(int) (x1>>16 & 0xffff),(int)(x1 & 0xffff));
    x2 = (Calibration.B1 * (b6 * b6 >> 12)) >> 16;
//uprintf(PF,"  x2: 0x%x%x\r",(int) (x2>>16 & 0xffff),(int)(x2 & 0xffff));
    x3 = ((x1 + x2) + 2) >> 2;
//uprintf(PF,"  x3: 0x%x%x\r",(int) (x3>>16 & 0xffff),(int)(x3 & 0xffff));
    long b4 = (Calibration.AC4 * (unsigned long)((x3 + 32768))) >> 15;
//uprintf(PF,"  b4: 0x%x%x\r",(int) (b4>>16 & 0xffff),(int)(b4 & 0xffff));
    unsigned long b7;
	b7  = (unsigned long)(uncompensatedPressure - b3);
	b7 *= (50000 >> OversamplingSetting);
//uprintf(PF,"  b7: 0x%x%x\r",(int) (b7>>16 & 0xffff),(int)(b3 & 0xffff));
    long p;
    if (b7 < 0x80000000)
        {
                p = ((b7 * 2) / b4);
        }
    else
        {
        p = ((b7 / b4) << 1);
        }

//uprintf(PF,"   p: 0x%x%x\r",(int) ( p>>16 & 0xffff),(int)( p & 0xffff));
    x1 = (p >> 8) * (p >> 8);
    x1 = (x1 * 3038) >> 16;
//uprintf(PF,"  x1: 0x%x%x\r",(int) (x1>>16 & 0xffff),(int)(x1 & 0xffff));
    x2 = (-7357 * p) >> 16;
//uprintf(PF,"  x2: 0x%x%x\r",(int) (x2>>16 & 0xffff),(int)(x2 & 0xffff));
//uprintf(PF,"  b7: 0x%x%x\r",(int) (b7>>16 & 0xffff),(int)(b7 & 0xffff));
    p = p + ((x1 + x2 + 3791) >> 4);
//uprintf(PF,"   p: 0x%x%x\r",(int) ( p>>16 & 0xffff),(int)( p & 0xffff));
//uprintf(PF,"  b7: 0x%x%x\r",(int) (b7>>16 & 0xffff),(int)(b7 & 0xffff));

    return p/100;  // pressure in mBar
}
/*

unsigned char * Read_DS28CM00_BIN ( )
{	DS28CM_data[0]=1;
      I2C_Write_Reg ( DS28CM_ID, 8, 2, DS28CM_data);
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
*/
