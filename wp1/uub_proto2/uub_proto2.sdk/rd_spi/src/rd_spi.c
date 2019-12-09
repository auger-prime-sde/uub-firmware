// DAC read and write utility
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <signal.h>
#include <time.h>
#include <sys/mman.h>
#include <string.h>

 static uint8_t mode = 1;
 static uint8_t bits = 8;
 static uint32_t speed = 5000000;

static void pabort(const char *s) {
	perror(s);
	abort();
}

int ret = 0;
char filename[20];
int dac, fd, i;


int main(int argc, char *argv[]){
	if (argc == 1) {
		 dac = 2690;  // valore dac a 1,97 volts
		 printf("Initialization of DAC7551... ");	//printf("Default DAC value %d.....\n",dac);
	}
	else if (argc < 1 || argc > 2){
		usage();
	}
	else {

		if (atoi(argv[1]) > 4096){
			wave();
		}

		dac = atoi (argv[1]);
		printf("DAC value %d ....",dac);
	}
	spi();
	char dac_write[2] = {0x0f, 0xff} ;

    dac_write[0] = (dac >> 8);
    dac_write[1] = (dac & 0xFF);

	if (write(fd, dac_write, sizeof(dac_write)) != sizeof(dac_write)) {
			exit(3);
	}
	close(fd);
	printf("OK\n\r");
}



void spi(void)
{
			snprintf(filename, 19, "/dev/spidev32764.0");
			fd = open(filename, O_RDWR);
			if (fd < 0)
				pabort("can't open device");
		// spi mode
			ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
			if (ret == -1)
				pabort("can't set spi mode");

			ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
			if (ret == -1)
				pabort("can't get spi mode");

		// bits per word
			ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
			if (ret == -1)
				pabort("can't set bits per word");

			ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
			if (ret == -1)
				pabort("can't get bits per word");

		// max speed hz
			ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
			if (ret == -1)
				pabort("can't set max speed hz");

			ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
			if (ret == -1)
				pabort("can't get max speed hz");
}


void usage(void)
{
	printf("|   DAC for clock frequency change\n");
	printf("|    DAC <val> (0 - 4095 12 bits)\n");
	printf("|    val is number of DAC counting <0...4095>\n");
	printf("|    example: dac7551 100\n");
	printf("|    example: dac7551 5000 (ramp output - TEST)\n");
	exit(1);
}

void wave()
{
	printf("DAC TEST ON for 1 minute\n\r");
	char dac_write[2] = {0x00, 0x00} ;
	spi();
	int t=0;
	while(t<1000){
		for (i = 0; i < 4096; i = i + 16) {
			dac_write[0] = (i >> 8);
			dac_write[1] = (i & 0xFF);
			if (write(fd, dac_write, sizeof(dac_write)) != sizeof(dac_write)) {
					exit(3);
			}
		}
		t=t+1;
	}
	exit(3);
}


