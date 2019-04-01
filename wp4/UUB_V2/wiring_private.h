
#ifndef WiringPrivate_h
#define WiringPrivate_h

#include "Energia.h"

#ifdef __cplusplus
extern "C"{
#endif

// TODO: This is a hack and needs cleaning up. Not all pins are available on the board
//.Change this to a more intelligent number of interrupt selection

#if defined(__MSP430_HAS_PORT1_R__)
#define EXTERNAL_NUM_INTERRUPTS 8
#elif defined(__MSP430_HAS_PORT2_R__)
#define EXTERNAL_NUM_INTERRUPTS 16
#else
#define EXTERNAL_NUM_INTERRUPTS 8
#endif

typedef void (*voidFuncPtr)(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif
