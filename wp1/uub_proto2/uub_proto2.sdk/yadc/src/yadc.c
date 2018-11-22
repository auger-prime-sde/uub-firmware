/*
 *  Created on: 17/feb/2017
 *  Author: Yann Aubert
 */

// ADC read and write utility
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

static void pabort(const char *s) {
	perror(s);
	abort();
}

int openspidev(int adc) {
	int fd;
	char filename[20];

	snprintf(filename, 19, "/dev/spidev32766.%d", adc);
	fd = open(filename, O_RDWR);
	if (fd < 0)
		pabort("can't open device");
	return fd;
}

void spi_init(int adcfd) {
	static uint8_t mode = 0;
	static uint8_t bits = 8;
	static uint32_t speed = 5000000;

	int ret;

	// spi mode
	ret = ioctl(adcfd, SPI_IOC_WR_MODE, &mode);
	if (ret == -1)
		pabort("can't set spi mode");

	ret = ioctl(adcfd, SPI_IOC_RD_MODE, &mode);
	if (ret == -1)
		pabort("can't get spi mode");

	// bits per word
	ret = ioctl(adcfd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't set bits per word");

	ret = ioctl(adcfd, SPI_IOC_RD_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't get bits per word");

	// max speed hz
	ret = ioctl(adcfd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't set max speed hz");

	ret = ioctl(adcfd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't get max speed hz");
}

int adc_read(int adcfd, int address) {
	struct spi_ioc_transfer xfer[2];
	unsigned char buf[32];
	int status;

	memset(xfer, 0, sizeof xfer);
	memset(buf, 0, sizeof buf);

	/* Read register 1 */
	buf[0] = 0x80 | ((address>>8) & 0xff);
	buf[1] = address & 0xff;

	xfer[0].tx_buf = (unsigned long) buf;
	xfer[0].len = 2;

	xfer[1].rx_buf = (unsigned long) buf;
	xfer[1].len = 1;

	status = ioctl(adcfd, SPI_IOC_MESSAGE(2), xfer);
	if (status < 0) {
		perror("SPI_IOC_MESSAGE");
		return (-1);
	}

	printf("Address value : %03x %02x\n", address, buf[0]);
	return ((int) buf[0]);
}

int adc_write(int adcfd, int address, int cmd) {
	char cmdstr[3];

	cmdstr[0] = (address>>8) & 0xff;
	cmdstr[1] = address & 0xff;
	cmdstr[2] = cmd;

	if (write(adcfd, cmdstr, sizeof(cmdstr)) != sizeof(cmdstr)) {
		exit(3);
	}
	return 1;
}

void adc_readall(int adcfd) {
	adc_read(adcfd,0x0);
	adc_read(adcfd,0x1);
	adc_read(adcfd,0x2);
	adc_read(adcfd,0x5);
	adc_read(adcfd,0xff);
	adc_read(adcfd,0x8);
	adc_read(adcfd,0x9);
	adc_read(adcfd,0xb);
	adc_read(adcfd,0xc);
	adc_read(adcfd,0x10);
	adc_read(adcfd,0x14);
	adc_read(adcfd,0x15);
	adc_read(adcfd,0x16);
	adc_read(adcfd,0x17);
	adc_read(adcfd,0x18);
	adc_read(adcfd,0x19);
	adc_read(adcfd,0x1a);
	adc_read(adcfd,0x1b);
	adc_read(adcfd,0x1c);
	adc_read(adcfd,0x2a);
	adc_read(adcfd,0x2e);
	adc_read(adcfd,0x3a);
	adc_read(adcfd,0x100);
	adc_read(adcfd,0x101);
	adc_read(adcfd,0x102);

}


void usage(void) {
	printf("|    ADC command help\n");
	printf("|    yadc -w <number> <command> <value>\n");
	printf("|    yadc -w <number> <command> <value> <channel>\n");
	printf("|    yadc address -- read adc address\n");
	printf("|    example: yadc -w 0 d f <ramp on adc 0>\n");
	printf("|    example: yadc -w 0 d f B <ramp on adc 0 channel B>\n");
	printf("|    example: \n");
	printf("|    commands list: \n");
	printf("|    example: \n");
	exit(1);
}

int main(int argc, char *argv[]) {
	int adc = 0;
	int address = 1;
	int cmd = 0;
	int channelsel = 3;
	int read = 1;
	int readall = 1;

	int ret, adcfd;

	if ((argc>1)&&(!strcmp(argv[1], "-w"))){
		/* Writing register */
		read = 0;
		if (argc<5) {
			usage();
		} else {
			adc = atoi(argv[2]);
			address =  strtol(argv[3], NULL, 16);
			cmd =  strtol(argv[4], NULL, 16);
			if (argc == 6) {
				if (!strcmp(argv[5], "A")){
					channelsel = 1;
				} else if (!strcmp(argv[5], "B")) {
					channelsel = 2;
				} else {
					usage();
				}
			}
		}
	} else {
		read = 1;
		if (argc>1) { adc = atoi(argv[1]);}
		if (argc>2) {
			address =  strtol(argv[2], NULL, 16);
			readall = 0;
		}
	}

	adcfd = openspidev(adc);
	spi_init(adcfd);
	if (read) {
		if (readall) {
			adc_readall(adcfd);
		} else {
			ret = adc_read(adcfd, address);
		}
	} else {
		ret = adc_write(adcfd, 5, channelsel);
		ret = adc_write(adcfd, address, cmd);
		ret = adc_write(adcfd, 5, 3);
	}
    close (adcfd);
    return 1;
}

