//Programa que hace uso de las funciones definidas en sem_handler.h y .c para usar semaforos
#include<stdio.h>
#include<stdlib.h>
#include"semhandler.h"	//<<====Debe estar asi encuentra las definiciones de las funciones.
#include <errno.h>
#include <unistd.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <linux/i2c-dev.h>
#include <time.h>
#include <sys/ioctl.h>

//Aqui utilizo andres.h y andres.c, donde declaré y definí funciones, para ejecutar con esas funciones un programa
//tercero

#define SC_ADDR		0x0f
#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)
int file, i, j, ch, val, lt, counter;
char filename[20];
FILE *fp;

void sc_livetime(int, int *);


int main(){

	// definitions to control external watchdog by fpga pin W11
	    void *map_base, *virt_addr;
	    //unsigned long read_result;
		unsigned long writeval;
		off_t target;
		//int i,j,Status;
		int ft, file, last_life_time;
	    target = 0x43c0000c; // register to control pin W11 of the zynq (WATCHDOG)
	    if((ft = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
		map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, ft, target & ~MAP_MASK);
		if(map_base == (void *) -1) FATAL;
		virt_addr = map_base + (target & MAP_MASK);
	    //int opt = 0;

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




	    extern struct slow_control_handler h;
	    //printf("%s--\n",h.sem_handler);

	    printf("semuser_wd\n");
		slow_control_init();	//printf("init\n");
		while(1){




		//for(i=0;i<10;i++){
			//############################################
			slow_control_access(h);//printf("access\n");
			//Start Routine not to be bothered
			//********************************************
			sc_livetime(file, &lt);
			usleep(1000);
			//********************************************
			//End Routine not to be bothered
			slow_control_release(h);//printf("release\n");
			//############################################

			if (lt != last_life_time){
				counter = 0;
				printf("AT. different life time, it's ok, counter: %d\n",counter);
				last_life_time = lt;

				// external watchdog control - pulse on W11
				writeval = 0x0003; //Bit 0 - WATCHDOG output value  Bit 1 - Enable WATCHDOG output
				*((unsigned long *) virt_addr) = writeval;
				usleep (100000);
				writeval = 0x0002;
				*((unsigned long *) virt_addr) = writeval;
				}
			else{
				counter ++;
				printf("No reply from slowc or same lifetime, counter: %d - ",counter);
				if (counter >= 1)	// write event in log file
					printf("an error\n");
				if (counter >= 4){
					printf("UUB will be killed... \n\r");
					exit (1);
					}
				}

			sleep(2);
			}
		slow_control_close(h);
		slow_control_finish(2);//printf("finish\n");
		return(0);
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


void sc_livetime(int file , int *l){
char reg [6] = {0x03, 0x00, 0x0, 0x0, 0x0, 0x0};
char b[4];
	if (write(file, reg, 2) != 2) {
		counter ++;//printf("no device reply!\n");

    }
	usleep (100000);
	if (read(file,b,4)!= 4) {
		counter ++;//printf("no device reply!\n");
	}

	//printf("b: 0x%x 0x%x 0x%x 0x%x\n", b[0], b[1], b[2], b[3]);
	*l =  b[0]
		+ ( b[1] << 8 )
		+ ( b[2] << 16 )
		+ ( b[3] << 24 );
}

