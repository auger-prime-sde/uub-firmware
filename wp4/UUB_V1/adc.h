#ifndef ADC_H_
#define ADC_H_
#define ADC_UPD_INTERVAL 300 		//300ms 
void adc_init();
void adc_start_conversion ();
void adc_update();
void adc_update_sgl(unsigned char chan);
void adc_dump();
void adc_get();
unsigned char adcctl;
#define ADC_MUXADR 0x07
#define ADC_DONE 0x10
#define ADC_DOCONV 0x20
#define ADC_WAITCONV 0x40
#endif

