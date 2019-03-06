/*
  ************************************************************************
  *	pins_energia.h
  *
  *	Energia core files for MSP430
  *		Copyright (c) 2012 Robert Wessels. All right reserved.
  *
  *     Contribution: Rei VILO
  *
  ***********************************************************************
  Derived from:
  pins_arduino.h - Pin definition functions for Arduino
  Part of Arduino - http://www.arduino.cc/

  Copyright (c) 2007 David A. Mellis

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/
/*
	27/2/2013 Try make a port to MSP430F2618
	K.H. Becker for University Wuppertal
*/
#ifndef Pins_Arduino_h
#define Pins_Arduino_h
#ifndef BV
#define BV(x) (1 << (x))
#endif

#if defined(__MSP430_HAS_USCI__)
static const uint8_t SS      = 20;  /* P2.0 , not sure if it works`*/
static const uint8_t SCK     = 31;  /* P3.3 */
static const uint8_t MOSI    = 29; /* P3.1 */
static const uint8_t MISO    = 30; /* P3.2 */
static const uint8_t TWISDA  = 29;  /* P3.1 */
static const uint8_t TWISCL  = 30;  /* P3.2 */
static const uint8_t UARTRXD = 33;  /* Receive  Data (RXD) at P3.5 */
static const uint8_t UARTTXD = 32;  /* Transmit Data (TXD) at P3.4 */
#define TWISDA_SET_MODE  (PORT_SELECTION0 | PORT_SELECTION1 /* | INPUT_PULLUP*/) /* do not enable the pull ups for this device */
#define TWISCL_SET_MODE  (PORT_SELECTION0 | PORT_SELECTION1 /* | INPUT_PULLUP*/)
#define UARTRXD_SET_MODE (PORT_SELECTION0 | PORT_SELECTION1 | INPUT)
#define UARTTXD_SET_MODE (PORT_SELECTION0 | PORT_SELECTION1 | OUTPUT)
#endif

#if defined(__MSP430_HAS_USI__)
static const uint8_t SS   = 8;  /* P2.0 */
static const uint8_t SCK  = 7;  /* P1.5 */
static const uint8_t MOSI = 14; /* P1.6 */
static const uint8_t MISO = 15; /* P1.7 */
static const uint8_t TWISDA  = 14;  /* P1.7 */
static const uint8_t TWISCL  = 15;  /* P1.6 */
static const uint8_t UARTRXD = 4;  /* Receive  Data (RXD) at P1.2 */
static const uint8_t UARTTXD = 3;  /* Transmit Data (TXD) at P1.1 */
#define TWISDA_SET_MODE  (PORT_SELECTION0 | INPUT_PULLUP)
#define TWISCL_SET_MODE  (PORT_SELECTION0 | INPUT_PULLUP)
#define UARTRXD_SET_MODE (PORT_SELECTION0 | INPUT)
#define UARTTXD_SET_MODE (PORT_SELECTION0 | OUTPUT)
#endif

static const uint8_t A0  = 0;
static const uint8_t A1  = 1;
static const uint8_t A2  = 2;
static const uint8_t A3  = 3;
static const uint8_t A4  = 4;
static const uint8_t A5  = 5;
static const uint8_t A6  = 6;
static const uint8_t A7  = 7;
static const uint8_t A10 = 10; // special. This is the internal temp sensor

//                      +-\/-+
//               VCC   1|    |20  GND
//         (A0)  P1.0  2|    |19  XIN
//         (A1)  P1.1  3|    |18  XOUT
//         (A2)  P1.2  4|    |17  TEST
//         (A3)  P1.3  5|    |16  RST#
//         (A4)  P1.4  6|    |15  P1.7  (A7) (SCL) (MISO) depends on chip
//         (A5)  P1.5  7|    |14  P1.6  (A6) (SDA) (MOSI)
//               P2.0  8|    |13  P2.5
//               P2.1  9|    |12  P2.4
//               P2.2 10|    |11  P2.3
//                      +----+
//

// Pin names based on the silkscreen
//
static const uint8_t P1_0 = 12;
static const uint8_t P1_1 = 13;
static const uint8_t P1_2 = 14;
static const uint8_t P1_3 = 15;
static const uint8_t P1_4 = 16;
static const uint8_t P1_5 = 17;
static const uint8_t P2_0 = 20;
static const uint8_t P2_1 = 21;
static const uint8_t P2_2 = 22;
static const uint8_t P2_3 = 23;
static const uint8_t P2_4 = 24;
static const uint8_t P2_5 = 25;
static const uint8_t P1_6 = 18;
static const uint8_t P1_7 = 19;
static const uint8_t P2_7 = 27;
static const uint8_t P2_6 = 26;

static const uint8_t P3_0 = 28;
static const uint8_t P3_1 = 29;
static const uint8_t P3_2 = 30;
static const uint8_t P3_3 = 31;
static const uint8_t P3_4 = 32;
static const uint8_t P3_5 = 33;
static const uint8_t P3_6 = 34;
static const uint8_t P3_7 = 35;

static const uint8_t P4_0 = 36;
static const uint8_t P4_1 = 37;
static const uint8_t P4_2 = 38;
static const uint8_t P4_3 = 39;
static const uint8_t P4_4 = 40;
static const uint8_t P4_5 = 41;
static const uint8_t P4_6 = 42;
static const uint8_t P4_7 = 43;

static const uint8_t P5_0 = 44;
static const uint8_t P5_1 = 45;
static const uint8_t P5_2 = 46;
static const uint8_t P5_3 = 47;
static const uint8_t P5_4 = 48;
static const uint8_t P5_5 = 49;
static const uint8_t P5_6 = 50;
static const uint8_t P5_7 = 51;

static const uint8_t P6_0 = 59;
static const uint8_t P6_1 = 60;
static const uint8_t P6_2 = 61;
static const uint8_t P6_3 = 2;
static const uint8_t P6_4 = 3;
static const uint8_t P6_5 = 4;
static const uint8_t P6_6 = 5;
static const uint8_t P6_7 = 6;


static const uint8_t RED_LED = 59;
static const uint8_t GREEN_LED = 61; /* not really */
static const uint8_t PUSH2 = 60;
static const uint8_t TEMPSENSOR = 10; // depends on chip


#ifdef ARDUINO_MAIN

const uint16_t port_to_input[] = {
	NOT_A_PORT,
	(uint16_t) &P1IN,
	(uint16_t) &P2IN,
#ifdef __MSP430_HAS_PORT3_R__
	(uint16_t) &P3IN,
#endif
#ifdef __MSP430_HAS_PORT4_R__
        (uint16_t) &P4IN,
#endif
#ifdef __MSP430_HAS_PORT5_R__
        (uint16_t) &P5IN,
#endif
#ifdef __MSP430_HAS_PORT6_R__
        (uint16_t) &P6IN,
#endif
#ifdef __MSP430_HAS_PORT7_R__
        (uint16_t) &P7IN,
#endif
#ifdef __MSP430_HAS_PORT8_R__
        (uint16_t) &P8IN,
#endif

};

const uint16_t port_to_output[] = {
	NOT_A_PORT,
	(uint16_t) &P1OUT,
	(uint16_t) &P2OUT,
#ifdef __MSP430_HAS_PORT3_R__
	(uint16_t) &P3OUT,
#endif
#ifdef __MSP430_HAS_PORT4_R__
        (uint16_t) &P4OUT,
#endif
#ifdef __MSP430_HAS_PORT5_R__
        (uint16_t) &P5OUT,
#endif
#ifdef __MSP430_HAS_PORT6_R__
        (uint16_t) &P6OUT,
#endif
#ifdef __MSP430_HAS_PORT7_R__
        (uint16_t) &P7OUT,
#endif
#ifdef __MSP430_HAS_PORT8_R__
        (uint16_t) &P8OUT,
#endif

};

const uint16_t port_to_dir[] = {
	NOT_A_PORT,
	(uint16_t) &P1DIR,
	(uint16_t) &P2DIR,
#ifdef __MSP430_HAS_PORT3_R__
	(uint16_t) &P3DIR,
#endif
#ifdef __MSP430_HAS_PORT4_R__
        (uint16_t) &P4DIR,
#endif
#ifdef __MSP430_HAS_PORT5_R__
        (uint16_t) &P5DIR,
#endif
#ifdef __MSP430_HAS_PORT6_R__
        (uint16_t) &P6DIR,
#endif
#ifdef __MSP430_HAS_PORT7_R__
        (uint16_t) &P7DIR,
#endif
#ifdef __MSP430_HAS_PORT8_R__
        (uint16_t) &P8DIR,
#endif

};

const uint16_t port_to_ren[] = {
	NOT_A_PORT,
	(uint16_t) &P1REN,
	(uint16_t) &P2REN,
#ifdef __MSP430_HAS_PORT3_R__
	(uint16_t) &P3REN,
#endif
#ifdef __MSP430_HAS_PORT4_R__
        (uint16_t) &P4REN,
#endif
#ifdef __MSP430_HAS_PORT5_R__
        (uint16_t) &P5REN,
#endif
#ifdef __MSP430_HAS_PORT6_R__
        (uint16_t) &P6REN,
#endif
#ifdef __MSP430_HAS_PORT7_R__
        (uint16_t) &P7REN,
#endif
#ifdef __MSP430_HAS_PORT8_R__
        (uint16_t) &P8REN,
#endif

};

const uint16_t port_to_sel0[] = {  /* put this PxSEL register under the group of PxSEL0 */
	NOT_A_PORT,
	(uint16_t) &P1SEL,
	(uint16_t) &P2SEL,
#ifdef __MSP430_HAS_PORT3_R__
	(uint16_t) &P3SEL,
#endif
#ifdef __MSP430_HAS_PORT4_R__
        (uint16_t) &P4SEL,
#endif
#ifdef __MSP430_HAS_PORT5_R__
        (uint16_t) &P5SEL,
#endif
#ifdef __MSP430_HAS_PORT6_R__
        (uint16_t) &P6SEL,
#endif
#ifdef __MSP430_HAS_PORT7_R__
        (uint16_t) &P7SEL,
#endif
#ifdef __MSP430_HAS_PORT8_R__
        (uint16_t) &P8SEL,
#endif

};
#ifndef __msp430x26x
const uint16_t port_to_sel2[] = {
	NOT_A_PORT,
#ifdef P1SEL2_
	(uint16_t) &P1SEL2,
#else
        NOT_A_PORT,
#endif
#ifdef P2SEL2_
	(uint16_t) &P2SEL2,
#else 
        NOT_A_PORT,
#endif
#ifdef P3SEL2_
	(uint16_t) &P3SEL2,
#else
        NOT_A_PORT,
#endif
};


/* 
 * Defines for devices with 2x TA3 timers (e.g. MSP430g2553). On the 20pin devices, upto 3 analog outputs are available
 * T0A1, T1A1 and T1A2 
 */
const uint8_t digital_pin_to_timer[] = {
	NOT_ON_TIMER, /*  dummy */
	NOT_ON_TIMER, /*  1 - VCC */
	NOT_ON_TIMER, /*  2 - P1.0 */
	T0A0,         /*  3 - P1.1, note: A0 output cannot be used with analogWrite */
	T0A1,         /*  4 - P1.2 */
	NOT_ON_TIMER, /*  5 - P1.3 */
	NOT_ON_TIMER, /*  6 - P1.4 note: special case. Leaving as no timer due to difficulty determining if available */
	T0A0,         /*  7 - P1.5 note: A0 output cannot be used with analogWrite  */
#if defined(__MSP430_HAS_T1A3__) 
	T1A0,         /*  8 - P2.0 note: A0 output cannot be used with analogWrite */
	T1A1,         /*  9 - P2.1 */
	T1A1,         /* 10 - P2.2 */
	T1A0,         /* 11 - P2.3 note: A0 output cannot be used with analogWrite  */
	T1A2,         /* 12 - P2.4 */
	T1A2,         /* 13 - P2.5 */
#else
	NOT_ON_TIMER, /*  8 - P2.0 */
	NOT_ON_TIMER, /*  9 - P2.1 */
	NOT_ON_TIMER, /* 10 - P2.3 */
	NOT_ON_TIMER, /* 11 - P2.4 */
	NOT_ON_TIMER, /* 12 - P2.5 */
	NOT_ON_TIMER, /* 13 - P2.6 */
#endif
	T0A1,         /* 14 - P1.6 */
	NOT_ON_TIMER, /* 15 - P1.7 */
	NOT_ON_TIMER, /* 16 - /RESET */  
	NOT_ON_TIMER, /* 17 - TEST */  
	NOT_ON_TIMER, /* 18 - XOUT - P2.7 */
	T0A1,         /* 19 - XIN - P2.6: */
	NOT_ON_TIMER, /* 20 - GND */
};

const uint8_t digital_pin_to_port[] = {
	NOT_A_PIN, /* dummy */
	NOT_A_PIN, /* 1 */
	P1, /* 2 */
	P1, /* 3 */
	P1, /* 4 */
	P1, /* 5 */
	P1, /* 6 */
	P1, /* 7 */
	P2, /* 8 */
	P2, /* 9 */
	P2, /* 10 */
	P2, /* 11 */
	P2, /* 12 */
	P2, /* 13 */
	P1, /* 14 */
	P1, /* 15 */
	NOT_A_PIN, /* 16 */
	NOT_A_PIN, /* 17 */
	P2, /* 18 */
	P2, /* 19 */
	NOT_A_PIN, /* 20 */
};

const uint8_t digital_pin_to_bit_mask[] = {
	NOT_A_PIN, /* 0,  pin count starts at 1 */
	NOT_A_PIN, /* 1,  VCC */
	BV(0),     /* 2,  port P1.0 */
	BV(1),     /* 3,  port P1.1 */
	BV(2),     /* 4,  port P1.2 */
	BV(3),     /* 5,  port P1.3*/
	BV(4),     /* 6,  port P1.4 */
	BV(5),     /* 7,  port P1.5 */
	BV(0),     /* 8,  port P2.0 */
	BV(1),     /* 9,  port P2.1 */
	BV(2),     /* 10, port P2.2 */
	BV(3),     /* 11, port P2.3 */
	BV(4),     /* 12, port P2.4 */
	BV(5),     /* 13, port P2.5 */
	BV(6),     /* 14, port P1.6 */
	BV(7),     /* 15, port P1.7 */
	NOT_A_PIN, /* 16, RST */
	NOT_A_PIN, /* 17, TEST */
	BV(7),     /* 18, XOUT */
	BV(6),     /* 19, XIN */
	NOT_A_PIN, /* 20, GND */
};
#else
/*
 * Defines for devices with 2x TA3 timers (e.g. MSP430g2553). On the 20pin devices, upto 3 analog outputs are available
 * T0A1, T1A1 and T1A2
 */
const uint8_t digital_pin_to_timer[] = {
        NOT_ON_TIMER, /*  dummy */
        NOT_ON_TIMER, /*  1 - VCC */
        NOT_ON_TIMER, /*  2 - P1.0 */
        T0A0,         /*  3 - P1.1, note: A0 output cannot be used with analogWrite */
        T0A1,         /*  4 - P1.2 */
        NOT_ON_TIMER, /*  5 - P1.3 */
        NOT_ON_TIMER, /*  6 - P1.4 note: special case. Leaving as no timer due to difficulty determining if available */
        T0A0,         /*  7 - P1.5 note: A0 output cannot be used with analogWrite  */
#if defined(__MSP430_HAS_T1A3__)
        T1A0,         /*  8 - P2.0 note: A0 output cannot be used with analogWrite */
        T1A1,         /*  9 - P2.1 */
        T1A1,         /* 10 - P2.2 */
        T1A0,         /* 11 - P2.3 note: A0 output cannot be used with analogWrite  */
        T1A2,         /* 12 - P2.4 */
        T1A2,         /* 13 - P2.5 */
#else
        NOT_ON_TIMER, /*  8 - P2.0 */
        NOT_ON_TIMER, /*  9 - P2.1 */
        NOT_ON_TIMER, /* 10 - P2.3 */
        NOT_ON_TIMER, /* 11 - P2.4 */
        NOT_ON_TIMER, /* 12 - P2.5 */
        NOT_ON_TIMER, /* 13 - P2.6 */
#endif
        T0A1,         /* 14 - P1.6 */
        NOT_ON_TIMER, /* 15 - P1.7 */
        NOT_ON_TIMER, /* 16 - /RESET */
        NOT_ON_TIMER, /* 17 - TEST */
        NOT_ON_TIMER, /* 18 - XOUT - P2.7 */
        T0A1,         /* 19 - XIN - P2.6: */
        NOT_ON_TIMER, /* 20 - GND */
};

const uint8_t digital_pin_to_port[] = {
        NOT_A_PIN, /* dummy */
        NOT_A_PIN, /* 1 */
        P6, /* 2 */
        P6, /* 3 */
        P6, /* 4 */
        P6, /* 5 */
        P6, /* 6 */
        NOT_A_PIN, /* 7 */
        NOT_A_PIN, /* 8 */
        NOT_A_PIN, /* 9 */
        NOT_A_PIN, /* 10 */
        NOT_A_PIN, /* 11 */
        P1, /* 12 */
        P1, /* 13 */
        P1, /* 14 */
        P1, /* 15 */
        P1, /* 16 */
        P1, /* 17 */
        P1, /* 18 */
        P1, /* 19 */
        P2, /* 20 */
        P2, /* 21 */
        P2, /* 22 */
        P2, /* 23 */
        P2, /* 24 */
        P2, /* 25 */
        P2, /* 26 */
        P2, /* 27 */
        P3, /* 28 */
        P3, /* 29 */
        P3, /* 30 */
        P3, /* 31 */
        P3, /* 32 */
        P3, /* 33 */
        P3, /* 34 */
        P3, /* 35 */
        P4, /* 36 */
        P4, /* 37 */
        P4, /* 38 */
        P4, /* 39 */
        P4, /* 40 */
        P4, /* 41 */
        P4, /* 42 */
        P4, /* 43 */
        P5, /* 44 */
        P5, /* 45 */
        P5, /* 46 */
        P5, /* 47 */
        P5, /* 48 */
        P5, /* 49 */
        P5, /* 50 */
        P5, /* 51 */
        NOT_A_PIN, /* 52 */
        NOT_A_PIN, /* 53 */
        NOT_A_PIN, /* 54 */
        NOT_A_PIN, /* 55 */
        NOT_A_PIN, /* 56 */
        NOT_A_PIN, /* 57 */
        NOT_A_PIN, /* 58 */
        P6, /* 59 */
        P6, /* 60 */
        P6, /* 61 */
        NOT_A_PIN, /* 62 */
        NOT_A_PIN, /* 63 */
        NOT_A_PIN /* 64 */
};

const uint8_t digital_pin_to_bit_mask[] = {
        NOT_A_PIN, /* 0,  pin count starts at 1 */
        NOT_A_PIN, /* 1,  VCC */
        BV(3),     /* 2,  port P6.3 */
        BV(4),     /* 3,  port P6.4 */
        BV(5),     /* 4,  port P6.5 */
        BV(6),     /* 5,  port P6.6*/
        BV(7),     /* 6,  port P6.7 */
        NOT_A_PIN, /* 7,  Vref+5 */
        NOT_A_PIN, /* 8,  XIN */
        NOT_A_PIN, /* 9,  XOUT */
        NOT_A_PIN, /* 10, Vref+ phi */
        NOT_A_PIN, /* 11, Vref-*/
        BV(0),     /* 12, port P1.0 */
        BV(1),     /* 13, port P1.1 */
        BV(2),     /* 14, port P1.2 */
        BV(3),     /* 15, port P1.3 */
        BV(4),     /* 16, port P1.4 */
        BV(5),     /* 17, port P1.5 */
        BV(6),     /* 18, port P1.6 */
        BV(7),     /* 19, port P1.7 */
        BV(0),     /* 20, port P2.0 */
	BV(1),     /* 21, port 2.0  */
	BV(2),/* 22 */
	BV(3),/* 23 */
	BV(4),/* 24 */
	BV(5),/* 25 */
	BV(6),/* 26 */
	BV(7),/* 27 */
	BV(0),/* 28 */
	BV(1),/* 29 */
	BV(2),/* 30 */
	BV(3),/* 31 */
	BV(4),/* 32 */
	BV(5),/* 33 */
	BV(6),/* 34 */
	BV(7),/* 35 */
	BV(0),/* 36 */
	BV(1),/* 37 */
	BV(2),/* 38 */
	BV(3),/* 39 */
	BV(4),/* 40 */
	BV(5),/* 41 */
	BV(6),/* 42 */
	BV(7),/* 43 */
	BV(0),/* 44 */
	BV(1),/* 45 */
	BV(2),/* 46 */
	BV(3),	/* 47 */
	BV(4),/* 48 */
	BV(5),/* 49 */
	BV(6),/* 50 */
	BV(7),/* 51 */
	NOT_A_PIN,/* 52 */
	NOT_A_PIN,/* 53 */
	NOT_A_PIN,/* 54 */
	NOT_A_PIN,/* 55 */
	NOT_A_PIN,/* 56 */
	NOT_A_PIN,/* 57 */
	NOT_A_PIN,/* 58 */
	BV(0),/* 59 */
	BV(1),/* 60 */
	BV(2),/* 61 */
	NOT_A_PIN,/* 62 */
	NOT_A_PIN,/* 63 */
	NOT_A_PIN,/* 64 */
};

#endif
#endif
#endif
