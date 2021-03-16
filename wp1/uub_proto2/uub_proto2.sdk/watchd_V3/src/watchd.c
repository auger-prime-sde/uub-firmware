// Process to control WATCHDOG on UUB V3 by SLOW CONTROL
// written by Roberto Assiro june 2019
// this process controls watchdog logic on uub and slow-control
// if slowc doesn't reply after 5 times (every 5 seconds) zynq will write the message in log file and not updates the watchdog - uub will killed
// on present version is not present the log file into the /flash partition used for debugging
// 17/01/2020 added K.H. modification for lifetime request

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
FILE *f_i2c;
int ret;
int frequency;

//char* i2c_busy = "/home/root/i2c_busy";

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
/*		snprintf(filename, 19, "/dev/i2c-0");
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
*/
		char i2c_file[] = "/home/root/i2c_busy";

//system("rm /home/root/i2c_busy");

	while(1)	// infinite LOOP for watchdog
	{
		if( access( i2c_file, F_OK ) != -1 ) {
			printf("WathcDog: file exist... I wait!\n");
			frequency = 2000000;
		} else {

			//  printf("Opening device... ");
					snprintf(filename, 19, "/dev/i2c-0");
					file = open(filename, O_RDWR);
					if (file < 0) {
						perror(" Error opening file");
						exit (1);
					}
					if (ioctl(file, I2C_SLAVE, SC_ADDR) < 0) {
							exit (1);
					}

		  //  printf("file doesn't exist\n");
			frequency = 1000000;
			f_i2c = fopen(i2c_file, "w");
			sc_livetime (file, &lt);	// check if slow control is dead or alive

			usleep(10000);
			fclose(f_i2c);
			close(file);
			usleep(200000);
			ret = remove(i2c_file);

//		printf("%d\n",lt);
//		printf("%d\n",last_life_time);
/*
				if (lt != last_life_time){
						counter = 0;
					//	printf("different life time, it's ok, counter: %d\n",counter);
						last_life_time = lt;

						// external watchdog control - pulse on W11
						writeval = 0x0003; //Bit 0 - WATCHDOG output value  Bit 1 - Enable WATCHDOG output
						*((unsigned long *) virt_addr) = writeval;
						usleep (100000);
						writeval = 0x0002;
						*((unsigned long *) virt_addr) = writeval;

				}else{
						counter ++;
						printf("No reply from slowc, counter: %d\n",counter);
					if (counter > 0){	// write event in log file
								system ("mountflash > /dev/null &");
								fp = fopen ("/flash/watchdog.log", "a" );
								current_time();
								fprintf(fp,"Alert! - No reply from Slow control\n");
								fclose (fp);
								system ("umountflash > /dev/null &");

						//		printf("UUB will be killed... \n\r");
						//		exit (1);
						}
						if (counter > 4){	// write event in log file
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
		}

		usleep(frequency);
		//sleep (1);
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


/*
void sc_livetime (int file , int *l)
{char reg [6] = {0x03, 0x00, 0x0, 0x0, 0x0, 0x0};
 char b[4];
	if (write(file, reg, 2) != 2) {
		counter ++;//printf("no device reply!\n");

    }
	usleep (10000);
	if (read(file,b,4)!= 4) {
		counter ++;//printf("no device reply!\n");
	}
printf("0x%x 0x%x\n", b[0], b[1]);
//	printf("b: 0x%x 0x%x 0x%x 0x%x\n", b[0], b[1], b[2], b[3]);
	*l =  b[0]
		+ ( b[1] << 8 )
		+ ( b[2] << 16 )
		+ ( b[3] << 24 );
}

*/

void sc_livetime (int file , int *l)
{
    struct i2c_msg msgs[2];
    struct i2c_rdwr_ioctl_data msgset[1];
	unsigned char reg [6] = {0x03, 0x00, 0x0, 0x0, 0x0, 0x0};
	unsigned char b[4];
 msgs[0].addr = SC_ADDR;
 msgs[0].flags = 0;
 msgs[0].len = 2;
 msgs[0].buf = reg;

 msgs[1].addr = SC_ADDR;
 msgs[1].flags = I2C_M_RD | I2C_M_NOSTART;
 msgs[1].len = 4;
 msgs[1].buf = b;

 msgset[0].msgs = msgs;
 msgset[0].nmsgs = 2;
 if (ioctl(file, I2C_RDWR, &msgset) < 0) {
         perror("ioctl(I2C_RDWR) in i2c_read");
 //       return -1;
         exit (3);
     }

 /* if (write(file, reg, 2) != 2) {
        	 	exit(3);
    }
	usleep (100000);
	if (read(file,b,4)!= 4) {
		  	  	exit(4);
	}
*/
//	printf("b: 0x%x 0x%x 0x%x 0x%x\n", b[0], b[1], b[2], b[3]);
	*l =  b[0]
		+ ( b[1] << 8 )
		+ ( b[2] << 16 )
		+ ( b[3] << 24 );
}

