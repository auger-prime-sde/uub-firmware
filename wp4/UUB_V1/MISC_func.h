#define LED_PORT P4OUT
#define LED_PORT_DIR P4DIR
#define LED_PIN 0x08
#define TOGGLE_LED LED_PORT ^= LED_PIN
#define LED_OFF LED_PORT |= LED_PIN
#define LED_ON LED_PORT &= ~LED_PIN
void MISC_Config ();
