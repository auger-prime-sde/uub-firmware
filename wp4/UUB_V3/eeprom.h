#define eeprom_adr 0x57    //Address of 24LC256 eeprom chip
void writeEEPROM( unsigned int eeaddress, unsigned char* data);
void readEEPROM( unsigned int eeaddress,  
                 unsigned char* data, unsigned int num_chars); 
void dumpEEPROM( unsigned int eeaddress);
