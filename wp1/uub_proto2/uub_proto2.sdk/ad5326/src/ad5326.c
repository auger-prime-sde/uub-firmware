// led shot generator
// script to control LED DAC 12 bit analog device AD5326
#include <fcntl.h>
#include <stdio.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>
#define DAC_ADDR		0x0C // DAC slave address DAC AD5326
int file, i;
int dac_led1, dac_led2, dac_led3, dac_led4;
char filename[20];
char buf[]={0x02,0x73,0x50};
int channel, cicles;

int main(int argc, char *argv[])
{
	if (argc == 1) {
//		ramp(1, 100);
		usage();
	}
	else if (atoi(argv[1]) > 4096){
		channel = atoi (argv[2]);
		cicles = atoi (argv[3]);
		ramp(channel, cicles);
	}
	else if (argc < 5 || argc > 6){
		usage();
	}
	else {
		dac_led1 = atoi (argv[1]);
		dac_led2 = atoi (argv[2]);
		dac_led3 = atoi (argv[3]);
		dac_led4 = atoi (argv[4]);
		printf("LED values %d  %d  %d  %d\n\r",dac_led1,dac_led2,dac_led3,dac_led4);
	}


	int fd,j, Status, data_trig;
	int int_trig =  0x55000000;
	int value = 0;
	unsigned page_addr, page_offset;
	void *ptrt;
	unsigned page_size=sysconf(_SC_PAGESIZE);
	page_offset = 16;


	snprintf(filename, 19, "/dev/i2c-2");
	file = open(filename, O_RDWR);
	if (file < 0) {
			exit("no open file");
	}
	if (ioctl(file, I2C_SLAVE, DAC_ADDR) < 0) {
			exit("Fail to setup slave addr!");
	}
    // Preparo i byte da inviare in buf
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
     	buf[1] = (dac_led4/256) + 112; //primi 4 bit piu' significativi di val trasferiti nei meno 4 significativi di a e aggiungo ctrl_reg=112
     	buf[2] = dac_led4 & 0xFF;
     	if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
     	    exit(3);
     	}
     	printf("Done!\n");

}

void ramp(channel, cicles)
{
	printf("RAMP DAC TEST ON for %d cicles\n\r",cicles);

	char dac_write[2] = {0x00, 0x00} ;
	i2c();
	int t=0;
	while(t<cicles){
		for (i = 0; i < 4096; i = i + 64) {
			buf[0] = channel;
			buf[1] = (i/256) + 112;
			buf[2] = i & 0xFF;
			if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
					exit(3);
			}
		}
		t=t+1;
	}
	i = 0;
	buf[0] = channel;
	buf[1] = (i/256) + 112;
	buf[2] = i & 0xFF;
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


void usage(void)
{
	printf("|    ad5326 <val LED1> <val LED2> <val LED3> <val LED4>\n");
	printf("|    val is number of DAC counting <0...4095>\n");
	printf("|    example: led 500 500 300 300\n");
	printf("|    RAMP TEST:\n");
	printf("|    ad5326 5000 <channel> <cicles>\n");
	printf("|    example: ad5326 5000 1 1000\n");
	printf("|    -- written by R.Assiro --\n");
	exit(1);
}
