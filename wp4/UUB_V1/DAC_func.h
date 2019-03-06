#ifndef DAC_FUNCS_H
#define DAC_FUNCS_H

#include "USCIAB0.h"
#define PRESCALER 12
void dac_init(void);
void dac_set (unsigned char, int);
#endif
