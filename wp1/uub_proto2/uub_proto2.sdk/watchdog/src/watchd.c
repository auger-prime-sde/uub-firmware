// Process to control WATCHDOG on UUB V2 by SLOW CONTROL
// written by Roberto Assiro february 2018
// this process controls watchdog logic on uub and slow-control
// if slowc doesn't reply after 5 times (every 5 seconds) zynq will write the message in log file and not updates the watchdog - uub will killed

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <linux/i2c-dev.h>
#include <time.h>;
#define SC_ADDR		0x0f
#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)
int file, i, j, ch, val, lt, counter;
char filename[20];
FILE *fp;

int main()
{
// definitions to control external watchdog by fpga pin W11
    void *map_base, *virt_addr;
	unsigned long read_result, writeval;
	off_t target;
	int ft, file,i,j, Status, last_life_time;
    target = 0x43c0000c; // register to control pin W11 of the zynq (WATCHDOG)
    if((ft = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
	map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, ft, target & ~MAP_MASK);
	if(map_base == (void *) -1) FATAL;
	virt_addr = map_base + (target & MAP_MASK);
    int opt = 0;

//  printf("Opening device... ");
  snprintf(filename, 19, "/dev/i2c-0");
  	file = open(filename, O_RDWR);
  	if (file < 0) {
  		//	printf("error opening %s\n",filename);
  		perror(" Error opening file");
  			exit (1);
  	}
  	if (ioctl(file, I2C_SLAVE, SC_ADDR) < 0) {
  		//	printf("Fail to setup slave addr!\n");
  			exit (1);
  	}


	while(1)	// infinite LOOP for watchdog
	{
		// check if slow control is dead or alive
		sc_livetime (file, &lt);
//		printf("%d\n",lt);
//		printf("%d\n",last_life_time);

		if (lt != last_life_time){
				counter = 0;
		//		printf("life time diverso ok, counter: %d\n",counter);
				last_life_time = lt;

		// external watchdog control - pulse on W11 every 5 seconds
				writeval = 0x0003; //Bit 0 - WATCHDOG output value  Bit 1 - Enable WATCHDOG output
				*((unsigned long *) virt_addr) = writeval;
				usleep (100000);
				writeval = 0x0002;
				*((unsigned long *) virt_addr) = writeval;

		}else{
				counter ++;
//				printf("Risposta non ricevuta da slowc, counter: %d\n",counter);
				if (counter == 5){	// scrivi l'evento nel file di log
			  			system ("mountflash > /dev/null &");
			  			fp = fopen ("/flash/watchdog.log", "a" );
			  			current_time();
			  			fprintf(fp,"Slow control crash after up time: %d - UUB Killed\n\n",lt);
			  			fclose (fp);
			  			system ("umountflash > /dev/null &");

				//		printf("UUB will be killed... \n\r");
				//		exit (1);
				}
		}

		sleep (5);
	}
}






current_time(void){
  	 time_t current_time;
  	    char* c_time_string;
  	    current_time = time(NULL);
  	    if (current_time == ((time_t)-1))
  	    {
  	        (void) fprintf(stderr, "Failure to obtain the current time.\n");
  	        exit(EXIT_FAILURE);
  	    }
  	    c_time_string = ctime(&current_time);
  	    if (c_time_string == NULL)
  	    {
  	        (void) fprintf(stderr, "Failure to convert the current time.\n");
  	        exit(EXIT_FAILURE);
  	    }
  	    fprintf(fp, c_time_string);
}



void sc_livetime (int file , int *l)
{char reg [6] = {0x03, 0x00, 0x0, 0x0, 0x0, 0x0};
 char b[4];
	if (write(file, reg, 2) != 2) {
		counter ++;//printf("no device reply!\n");

    }
	usleep (100000);
	if (read(file,b,4)!= 4) {
		counter ++;//printf("no device reply!\n");
	}

//	printf("b: 0x%x 0x%x 0x%x 0x%x\n", b[0], b[1], b[2], b[3]);
	*l =  b[0]
		+ ( b[1] << 8 )
		+ ( b[2] << 16 )
		+ ( b[3] << 24 );
}
