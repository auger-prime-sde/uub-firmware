// led shot generator
// script to control LED DAC 12 bit analog device AD5694
//
// ls -l /sys/bus/i2c/devices/
// i2cdetect -r 0

#include <fcntl.h>
#include <stdio.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>
#define DAC_ADDR		0x0C // DAC slave address DAC AD5695
int file, i, fd;
int dac_led1, dac_led2, dac_led3, dac_led4;
int fd, file,i,j, Status, data_trig;
char filename[20];
char buf[]={0x02,0x73,0x50};
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
	else if (atoi(argv[1]) > 4096){
					ramp();
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

	int int_trig =  0x55000000;
	int value = 0;
	unsigned page_addr, page_offset;
	void *ptrt;
	unsigned page_size=sysconf(_SC_PAGESIZE);
	page_offset = 16;



	i2c();

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


void ramp()
{
	printf("DAC TEST ON for 1 minute\n\r");
	char dac_write[2] = {0x00, 0x00} ;
	i2c();
	int t=0;
	while(t<1000){
		for (i = 0; i < 4096; i = i + 16) {
			buf[0] = 0x3F;	//Imposto byte di controllo   1111 tutti i canali
			buf[1] = (i >> 4);
			buf[2] = ((i & 0xF) << 4);
			if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
					exit(3);
			}
		}
		t=t+1;
	}
	i = 0;
	buf[0] = 0x3F;
	buf[1] = (i >> 4);
	buf[2] = ((i & 0xF) << 4);
	if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
		exit(3);
	}
	exit(3);
}


void i2c(){
	snprintf(filename, 19, "/dev/i2c-2");
	file = open(filename, O_RDWR);
	if (file < 0) {
			exit("no open file");
	}
	if (ioctl(file, I2C_SLAVE, DAC_ADDR) < 0) {
			exit("Fail to setup slave addr!");
	}
}
