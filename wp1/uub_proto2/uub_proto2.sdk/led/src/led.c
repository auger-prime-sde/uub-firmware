// led shot generator

#include <linux/i2c-dev.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>
#include <ctype.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/mman.h>

#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define DAC_ADDR		0x0C // DAC slave address DAC AD5326

int file, dac_led1, dac_led2, dac_led3, dac_led4, width, time;

int main(int argc, char *argv[])
{
    void *map_base, *virt_addr;
	unsigned long read_result, writeval;
	off_t target;
	time = 6200000; //width of pulse 100ns
	if (argc == 1) {
		 dac_led1 = 200;//argv[1];//valore canale 1 dac led
		 dac_led3 = 0;//argv[2];//valore canale 3 dac led
		// USCITA PX4
		 dac_led2 = 200;//argv[3];//valore canale 2 dac led
		 dac_led4 = 0;//argv[4];//valore canale 4 dac led
		 width = 10; //number x 100ns
		 printf("Default LED values %d  %d  %d  %d - width of pulse %d x 100ns\n",dac_led1,dac_led2,dac_led3,dac_led4, width);
	}
	else if (argc < 5 || argc > 7){
		usage();
	}
	else {
		dac_led1 = atoi (argv[1]);
		dac_led2 = atoi (argv[2]);
		dac_led3 = atoi (argv[3]);
		dac_led4 = atoi (argv[4]);
		width = atoi (argv[5]);
		printf("LED values %d  %d  %d  %d - width of pulse %d x 100ns\n",dac_led1,dac_led2,dac_led3,dac_led4, width);
	}

	int fd, file,i,j, Status, data_trig;
	int value = 0;
	void *ptrt;
	char buf[]={0x02,0x73,0x50};
	char filename[20];


  // 	printf("Initialization of I2C LED DAC..... ");
	snprintf(filename, 19, "/dev/i2c-2");
	file = open(filename, O_RDWR);
	if (file < 0) {
			exit("no open file");
	}
	if (ioctl(file, I2C_SLAVE, DAC_ADDR) < 0) {
			exit("Fail to setup slave addr!");
	}
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
    	printf("Done!\n");

     	target = 0x43c203fc;

     	if((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
     	map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, target & ~MAP_MASK);
     	if(map_base == (void *) -1) FATAL;

     	virt_addr = map_base + (target & MAP_MASK);
     	printf("LED Pulse is running...!\n ");

     	while(1)
     	        	{
     		   	   	   writeval = (time * width);
     		   	   	   *((unsigned long *) virt_addr) = writeval;
     		   	   	   writeval = (time * width) +1;
     		   	       *((unsigned long *) virt_addr) = writeval;
     		   	       usleep (100000);

     	        	}

     	       	    close(fd);

}

void usage(void)
{
	printf("|    led <val LED1> <val LED2> <val LED3> <val LED4> <pulse x 100ns>\n");
	printf("|    val is number of DAC counting <0...4095>\n");
	printf("|    pulse is a number (number x 10ns) - pulse = 10 (x 100ns) = 1ms\n");
	printf("|    example: led 500 500 300 300 10\n");
	printf("|    example: led PX3 PX4 PX3 PX4\n");
	exit(1);
}
