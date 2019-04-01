#include "Energia.h"
volatile extern uchar8_t Second, Minute, Hour, Day;
int led;
#define LED_ON                  P1OUT &= ~0x01; P1DIR |= 0x01;
#define LED_OFF                  P1OUT |= 0x01; P1DIR |= 0x01;
main ()
{
LED_OFF;
init();
led= P1_2;
setup();
while (1) loop();
}

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);     
}

// the loop routine runs over and over again forever:
void loop() {
  digitalWrite(led, LOW);   // turn the LED on (HIGH is the voltage level)
//  LED_ON;
  delay(30);               // wait for a second
  digitalWrite(led, HIGH);    // turn the LED off by making the voltage LOW
  delay(300);               // wait for a second
}

