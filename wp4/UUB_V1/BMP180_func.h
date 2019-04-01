#ifndef BMP180_h
#define BMP180_h

#include <inttypes.h>
#include "i2c.h"

#define BMP180_Address 0x77

#define ChipIdData 0x55
#define ControlInstruction_MeasureTemperature 0x2E
#define ControlInstruction_MeasurePressure 0x34

#define Reg_ChipId 0xD0
#define Reg_Control 0xF4
#define Reg_CalibrationStart 0xAA
#define Reg_CalibrationEnd 0xBE
#define Reg_AnalogConverterOutMSB 0xF6
#define Reg_SoftReset 0xE0
#define SoftResetInstruction 0xB6

#define ErrorCode_1 "Entered sample resolution was invalid. See datasheet for details."
#define ErrorCode_1_Num 1

#define BMP180_Mode_UltraLowPower               0
#define BMP180_Mode_Standard                    1
#define BMP180_Mode_HighResolution              2
#define BMP180_Mode_UltraHighResolution 3

#define BMP_180_Mode BMP180_Mode_Standard
#define ConversionWaitTimeMs 8	// Mode 0,1,2,3 WaitTime 5, 8, 14, 26 ms
#define Oversample 0		// No Oversample TBD
#define OversamplingSetting 0
struct BMP_Cal {
        int AC1;
        int AC2;
        int AC3;
        unsigned int AC4;
        unsigned int AC5;
        unsigned int AC6;
        int B1;
        int B2;
        int MB;
        int MC;
        int MD;
        } Calibration;


//          BMP180();
	void BMP180_Init(void);
	void BMP180_GetCal ();  // soll pointer auf struct werden
          int BMP180_GetUncompensatedTemperature();
          int BMP180_CompensateTemperature(int uncompensatedTemperature);
          long BMP180_GetUncompensatedPressure();
          long BMP180_CompensatePressure(long uncompensatedPressure);
          void BMP180_GetValues(unsigned int *T, unsigned int *H);
//          float BMP180_GetAltitude(float currentSeaLevelPressureInPa);
          void BMP180_SoftReset();
//          uint8_t BMP180_SetResolution(uint8_t sampleResolution, bool oversample);
          void BMP180_PrintCalibrationData();
          uint8_t BMP180_IsConnected ();
          char* BMP180_GetErrorText(int errorCode);
//          void Write(int address, int byte);
//          uint8_t* Read(int address, int length);
//          void Read2(int address, int length, uint8_t buffer[]);
		int LastTemperatureData;
                int AcceptableTemperatureLatencyForPressure;
#endif

