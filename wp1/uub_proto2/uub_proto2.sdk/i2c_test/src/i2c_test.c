// I2c-0 high traffic test

// UUB initialization file
#include <fcntl.h>



#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

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

int main()
{
	printf("Test I2C-0 is running... \n");
	while(1)	// infinite LOOP for watchdog
	{

/*		snprintf(filename, 19, "/dev/i2c-0");
		file = open(filename, O_RDWR);
		if (file < 0) {
			printf("error opening %s\n",filename);
			perror(" Error opening file");
				exit (1);
		}
		if (ioctl(file, I2C_SLAVE, SC_ADDR) < 0) {
				printf("Fail to setup slave addr!\n");
				exit (1);
		}
		sc_livetime (file, &lt);// check if slow control is dead or alive
//		printf("%d\n",lt);
//		printf("%d\n",last_life_time);

*/

		system ("slowc -a > /dev/null");

/*		if (lt != last_life_time){
				counter = 0;
		//		printf("different life time, it's ok, counter: %d\n",counter);
				last_life_time = lt;

				// external watchdog control - pulse on W11
				writeval = 0x0003; //Bit 0 - WATCHDOG output value  Bit 1 - Enable WATCHDOG output
				*((unsigned long *) virt_addr) = writeval;
				usleep (100000);
				writeval = 0x0002;
				*((unsigned long *) virt_addr) = writeval;

		}else{
				counter ++;
//				printf("No reply from slowc, counter: %d\n",counter);
				if (counter == 5){	// write event in log file
			  			system ("mountflash > /dev/null &");
			  			fp = fopen ("/flash/watchdog.log", "a" );
			  			current_time();
			  			fprintf(fp,"Slow control crash after up time: %d - UUB Killed\n\n",lt);
			  			fclose (fp);
			  			system ("umountflash > /dev/null &");

				//		printf("UUB will be killed... \n\r");
				//		exit (1);
				}


		}*/
	//	fclose (file);
		usleep (10000);
	}
}

/*

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
*/
