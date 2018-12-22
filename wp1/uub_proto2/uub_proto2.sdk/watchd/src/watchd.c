// Process to control WATCHDOG on UUB_V1
// written by Roberto Assiro december 2016
// this process controls internal and external watchdog
// feb 10th modification to use internal zynq's watchdog only for engineering array. External watchdog code was commented
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>

//#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

//#define MAP_SIZE 4096UL
//#define MAP_MASK (MAP_SIZE - 1)

int main()
{
// definitions for internal zynq watchdog
	int fd = open("/dev/watchdog", O_WRONLY);
	int ret = 0;
	if (fd == -1) {
		perror("watchdog failure");
		exit(EXIT_FAILURE);
	}
/////////////////////////////////////////////
// definitions to control external watchdog
/*    void *map_base, *virt_addr;
	unsigned long read_result, writeval;
	off_t target;
	int ft, file,i,j, Status;
    target = 0x43c0000c; // register to control pin W11 of the zynq (WATCHDOG)
    if((ft = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
	map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, ft, target & ~MAP_MASK);
	if(map_base == (void *) -1) FATAL;
	virt_addr = map_base + (target & MAP_MASK);
	*/
//////////////////////////////////////////////////////
     	while(1)	// LOOP for both watchdogs
     	{
     		// external watchdog control - pulse on W11 every 5 seconds
/*     		writeval = 0x0003; //Bit 0 - WATCHDOG output value  Bit 1 - Enable WATCHDOG output
     		*((unsigned long *) virt_addr) = writeval;
     		usleep (100000);
     		writeval = 0x0002;
     		*((unsigned long *) virt_addr) = writeval;
*/
/////////////////////////////////////////////////////////
     		// internal watchdog control - refresh every 5 seconds
     		ret = write(fd, "\0", 1);
     		if (ret != 1) {
     			ret = -1;
     		   	break;
     		}

     		sleep (5);
		}
     	close(fd);
  //   	close(ft);
     	return;
}

