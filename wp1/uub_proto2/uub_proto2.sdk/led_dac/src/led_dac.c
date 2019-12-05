// led shot generator
// relise jun 2019

// script to control LED DAC 12 bits analog device AD5694 and also the 12 bits ad5326
#include <fcntl.h>
#include <stdio.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>
#define DAC_5326_ADDR		0x0C // DAC slave address DAC AD5326
#define DAC_5694_ADDR		0x0C // DAC slave address DAC AD5694
int file;
int dac_led1, dac_led2, dac_led3, dac_led4;
int dac_led1_5326, dac_led2_5326, dac_led3_5326, dac_led4_5326;
int main(int argc, char *argv[])
{
	if (argc == 1) {
		 dac_led1 = 0;//argv[1];//valore canale 1 dac led
		 dac_led3 = 1100;//argv[2];//valore canale 3 dac led
		// USCITA PX4
		 dac_led2 = 0;//argv[3];//valore canale 2 dac led
		 dac_led4 = 1100;//argv[4];//valore canale 4 dac led
		 printf("Default LED values %d  %d  %d  %d.....",dac_led1,dac_led2,dac_led3,dac_led4);
	}
	else if (argc < 5 || argc > 6){
		usage();
	}
	else {
		dac_led1 = atoi (argv[1]);
		dac_led2 = atoi (argv[2]);
		dac_led3 = atoi (argv[3]);
		dac_led4 = atoi (argv[4]);
		printf("LED values %d  %d  %d  %d.....",dac_led1,dac_led2,dac_led3,dac_led4);
	}

	int fd, file,i,j, Status, data_trig;
	int int_trig =  0x55000000;
	int value = 0;
	unsigned page_addr, page_offset;
	void *ptrt;
	unsigned page_size=sysconf(_SC_PAGESIZE);
	page_offset = 16;
	char buf[]={0x02,0x73,0x50};
	char filename[20];

	snprintf(filename, 19, "/dev/i2c-2");
	file = open(filename, O_RDWR);
	if (file < 0) {
			exit("no open file");
	}
	if (ioctl(file, I2C_SLAVE, DAC_5326_ADDR) < 0) {
			exit("Fail to setup slave addr!");
	}
//////////////////// AD 5326 ///////////////////////////////////////
		dac_led1_5326 = dac_led1;// / 4;
		dac_led2_5326 = dac_led2;// / 4;
		dac_led3_5326 = dac_led3;// / 4;
		dac_led4_5326 = dac_led4;// / 4;

	     // calcolo canale 1
	     	buf[0] = 0x01;	//Seleziono canale del DAC
	     	buf[1] = (dac_led1/256) + 112; //primi 4 bit piu' significativi di val trasferiti nei meno 4 significativi di a e aggiungo ctrl_reg=112
	     	buf[2] = dac_led1 & 0xFF;
	    	if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
	        	 	exit(3);
	         	}
	     	usleep(500);
	     // calcolo canale 2
	     	buf[0] = 0x02;	//Seleziono canale del DAC
	     	buf[1] = (dac_led2/256) + 112; //primi 4 bit piu' significativi di val trasferiti nei meno 4 significativi di a e aggiungo ctrl_reg=112
	     	buf[2] = dac_led2 & 0xFF;
	     	if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
	     	       exit(3);
	     	}
	     	usleep(500);
	     // calcolo canale 3
	     	buf[0] = 0x04;	//Seleziono canale del DAC
	     	buf[1] = (dac_led3/256) + 112; //primi 4 bit piu' significativi di val trasferiti nei meno 4 significativi di a e aggiungo ctrl_reg=112
	     	buf[2] = dac_led3 & 0xFF;
	     	if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
	     	       exit(3);
	     	}
	     	usleep(500);
	     // calcolo canale 4
	     	buf[0] = 0x08;	//Seleziono canale del DAC
	     	buf[1] = (dac_led4/64) + 112; //primi 4 bit piu' significativi di val trasferiti nei meno 4 significativi di a e aggiungo ctrl_reg=112
	     	buf[2] = dac_led4 & 0xFF;
	     	if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
	     	    exit(3);
	     	}

/*
// DISPOSITIVO RIMOSSO IN UUB -V3
/////////////////////////// AD5694 ////////////////////////////////


	if (ioctl(file, I2C_SLAVE, DAC_5694_ADDR) < 0) {
			exit("Fail to setup slave addr!");
	}
    // Preparo i byte da inviare in buf

    	buf[0] = 0x31;	//Imposto byte di controllo   0011
    	buf[1] = (dac_led1 >> 4);
    	buf[2] = ((dac_led1 & 0xF) << 4);
		if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
				exit(3);
		}
     	usleep(500);

     // calcolo canale 2
     	buf[0] = 0x32;	//Imposto byte di controllo   0011
    	buf[1] = (dac_led2 >> 4);
    	buf[2] = ((dac_led2 & 0xF) << 4);
		if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
				exit(3);
		}
     	usleep(500);
     // calcolo canale 3
     	buf[0] = 0x34;	//Imposto byte di controllo   0011
    	buf[1] = (dac_led3 >> 4);
    	buf[2] = ((dac_led3 & 0xF) << 4);
		if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
				exit(3);
		}
     	usleep(500);
     // calcolo canale 4
     	buf[0] = 0x38;	//Imposto byte di controllo   0011
    	buf[1] = (dac_led4 >> 4);
    	buf[2] = ((dac_led4 & 0xF) << 4);
		if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
				exit(3);
		}
*/


     	printf("Done!\n");

}

void usage(void)
{
	printf("|    led <val LED1> <val LED2> <val LED3> <val LED4>\n");
	printf("|    val is number of DAC counting <0...4095>\n");
	printf("|    example: led 500 500 300 300\n");
	printf("|    example: led PX3 PX4 PX3 PX4\n");

	exit(1);
}
