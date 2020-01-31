#define eeprom_adr 0x57    //Address of 24LC256 eeprom chip
void writeEEPROM( unsigned int eeaddress, char* data);
void readEEPROM( unsigned int eeaddress,  
                 char* data, int num_chars); 
void dumpEEPROM( unsigned int eeaddress);
