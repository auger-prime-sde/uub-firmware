// Process to control WATCHDOG on UUB
// written by Roberto Assiro december 2017
// this process controls ADC power down pin

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>

#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

int main()
{
	int ret = 0;

/////////////////////////////////////////////
// definitions to control external watchdog
    void *map_base, *virt_addr;
	unsigned long read_result, writeval;
	off_t target;
	int ft, file,i,j, Status;
    target = 0x43c00004; // register to control pin H17 ADC PWD
    if((ft = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
	map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, ft, target & ~MAP_MASK);
	if(map_base == (void *) -1) FATAL;
	virt_addr = map_base + (target & MAP_MASK);

//////////////////////////////////////////////////////

     		writeval = 0x002; //Bit 1 ADC power down
     		*((unsigned long *) virt_addr) = writeval;
     		usleep (500000);
     		writeval = 0x000;//Bit 0 ADC power down
     		*((unsigned long *) virt_addr) = writeval;


     	close(ft);
     	printf("PWD PIN changed (OFF/ON)...\n\r");
     	return;
}

