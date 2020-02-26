/*
 * uub_init.c
 *  Intitialization for UUB V2 layout
 *  Created on: may 2019
 *      Author: Roberto Assiro
 */

// UUB initialization file
#include <fcntl.h>
#include <stdio.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

#define nb_initData_SI5347    1560 // Nb init data for SI5347 componentchar ADC_LVDS[3] = { 0x00, 0x14, 0xA0 }; // ADC bus configuration LVDS interleave
char ADC_LVDS_INV[3] = { 0x00, 0x14, 0xA4 }; // ADC bus configuration LVDS interleave and inverted inputs enabled
char ADC_RESET[3] = { 0x00, 0x00, 0x3C }; // ADC reset
char ADC_VREF[3] = { 0x00, 0x18, 0x04 }; // ADC VREF setting
char ADC_PDWN[3] = { 0x00, 0x08, 0x00 }; // ADC PDWN setting normal operation
char ADC_DIG_RES[3] = { 0x00, 0x08, 0x03 }; // ADC PWRD reset setting
char ADC_DELAY[3] = { 0x00, 0x17, 0x25 }; // ADC delay

char cmd2channel[3] = { 0x00, 0x05, 0x03 }; // Select the 2 channels for previous cmd
char cmdchannelA[3] = { 0x00, 0x05, 0x01 }; // Select the channel A for previous cmd
char cmdchannelB[3] = { 0x00, 0x05, 0x02 }; // Select the channel B for previous cmd

char TestModeMS[3] = { 0x00, 0x0D, 0x01 }; // ADC Test Mode Middle Scale
char TestModeFS[3] = { 0x00, 0x0D, 0x02 }; // ADC Test Mode Full Scale
char NormalMode[3] = { 0x00, 0x0D, 0x00 }; // ADC Normal mode
char TestModeRM[3] = { 0x00, 0x0D, 0x5F }; // ADC Test Mode Ramp
char TestModeA5[3] = { 0x00, 0x0D, 0x44 }; // ADC Test Mode AAA555

char TstUser1LSB[3] = { 0x00, 0x19, 0x55 }; // User defined pattern 1 LSB
char TstUser1MSB[3] = { 0x00, 0x1A, 0xAA }; // User defined pattern 1 MSB
char TestModeUM[3] = { 0x00, 0x0D, 0x08 }; // ADC Test Mode USER1
char AdcDelay[5] = { 0x00 };           // Calculated ADC delay table

static uint8_t mode = 0;
static uint8_t bits = 8;
static uint32_t speed = 5000000;

static void pabort(const char *s) {
	perror(s);
	abort();
}

int verifyCommand(int fd, char *command) {
	struct spi_ioc_transfer xfer[2];
	unsigned char buf[3];
	int status, address;

	memset(xfer, 0, sizeof xfer);
	memset(buf, 0, sizeof buf);

	address = ((0x1f & command[0])<<16)|command[1];

	/* Read one byte register */
	buf[0] = 0x80 | (0x1f & command[0]);
	buf[1] = command[1];

	xfer[0].tx_buf = (unsigned long) buf;
	xfer[0].len = 2;

	xfer[1].rx_buf = (unsigned long) buf;
	xfer[1].len = 1;

	status = ioctl(fd, SPI_IOC_MESSAGE(2), xfer);
	if (status < 0) {
		perror("SPI_IOC_MESSAGE");
		return 1;
	}
	// printf("Address Written Read : %04x %02x %02x\n", address, command[2], buf[0]);
	return (buf[0] != command[2]);
}

int main() {
	int file, k;
	int adapter_nr = 1;
	char filename[20];

	// ADC POWER DOWN PIN
	system ("power_down > /dev/null &");	// attivo il pwd pin degli adc
	printf("Initialization of ADC PWD... OK\n\r");

//////////////////////// SPI CONFIGURATION ///////////////////////////////////////
	int i, fd;
	int ret = 0;
	int adc_ok = 1;
	printf("Initialization of ADC on SPI-0... ");
	for (i = 0; i < 5; i++) {
		snprintf(filename, 19, "/dev/spidev32766.%d", i);
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

		if (write(fd, cmd2channel, sizeof(cmd2channel))
				!= sizeof(cmd2channel)) {
			exit(3);
		}
		adc_ok &= verifyCommand(fd, cmd2channel);
		if (write(fd, ADC_DIG_RES, sizeof(ADC_DIG_RES))
				!= sizeof(ADC_DIG_RES)) {
			exit(3);
		}
		adc_ok &= verifyCommand(fd, ADC_DIG_RES);
		if (write(fd, ADC_PDWN, sizeof(ADC_PDWN)) != sizeof(ADC_PDWN)) {
			exit(3);
		}
		adc_ok &= verifyCommand(fd, ADC_PDWN);
		if (write(fd, ADC_RESET, sizeof(ADC_RESET)) != sizeof(ADC_RESET)) {
			exit(3);
		}
		ret = verifyCommand(fd, ADC_RESET);


		// inversion
	//	if (write(fd, ADC_LVDS, sizeof(ADC_LVDS)) != sizeof(ADC_LVDS)) {	// ADC input not inverted
		if (write(fd, ADC_LVDS_INV, sizeof(ADC_LVDS_INV))!= sizeof(ADC_LVDS_INV)) {	// ADC input inverted
			exit(3);
		}

	//	adc_ok &= verifyCommand(fd, ADC_LVDS);
		adc_ok &= verifyCommand(fd, ADC_LVDS_INV);

		if (write(fd, ADC_VREF, sizeof(ADC_VREF)) != sizeof(ADC_VREF)) {
			exit(3);
		}
		adc_ok &= verifyCommand(fd, ADC_VREF);
		if (write(fd, NormalMode, sizeof(NormalMode)) != sizeof(NormalMode)) {
			exit(3);
		}
		adc_ok = verifyCommand(fd, NormalMode);
	}
	close(fd);
	usleep(100);

	printf("OK\n\r");

system ("stty -F /dev/ttyUL1 9600");
system ("stty -F /dev/ttyUL2 115200");
system ("stty -F /dev/ttyPS0 38400");
printf("Initialization of UARTs... OK\n\r");

// Userspace I/O settings - november 2016
system ("modprobe uio");
system ("modprobe uio_pdrv_genirq");
printf("Initialization of UIO... OK\n\r");

// Clock setting - DAC7551 init - (removed on UUB_V3)
//system ("dac7551");

// WATCHDOG - february 2018 - NEW WATCHDOG SYSTEM UUB V2
system ("slowc -w 0 > /dev/null &");	// attivo il watchdog sullo slowc
system ("watchd > /dev/null &");		// lancio processo di gestione watchdog
printf("Initialization of Watchdog... OK\n\r");


}


