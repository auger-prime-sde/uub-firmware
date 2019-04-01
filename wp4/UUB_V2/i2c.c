#include "Energia.h"
#include "USCIAB0.h"
#include "i2c.h"
void I2C_Read_Reg ( unsigned char i2c_id, unsigned char reg, int size, unsigned char *data)
{ unsigned char field[1],nb;
//	__eint();
	field[0]=reg;
	nb= (unsigned char) size;
	USCI_I2C_transmitinit(i2c_id, (unsigned char) I2C_BR);
	while ( USCI_I2C_notready() );
	USCI_I2C_transmit(1, field);
	while ( USCI_I2C_notready() );
	USCI_I2C_receiveinit(i2c_id, (unsigned char) I2C_BR);
	while ( USCI_I2C_notready() );
	USCI_I2C_receive(nb, data);
	while ( USCI_I2C_notready() );

}
void I2C_Write_Reg ( unsigned char i2c_id, unsigned char reg, int size, unsigned char *data)
{
//	__eint();
        USCI_I2C_transmitinit(i2c_id, I2C_BR);
        while ( USCI_I2C_notready() );
        USCI_I2C_transmit(1, &reg);
        while ( USCI_I2C_notready() );
        USCI_I2C_transmitinit(i2c_id, I2C_BR);
        while ( USCI_I2C_notready() );
        USCI_I2C_transmit(size, data);
        while ( USCI_I2C_notready() );

}
void I2C_Write ( unsigned char i2c_id, int size, unsigned char *data)
{
//      __eint();
        USCI_I2C_transmitinit(i2c_id, I2C_BR);
        while ( USCI_I2C_notready() );
        USCI_I2C_transmit(size, data);
        while ( USCI_I2C_notready() );

}

