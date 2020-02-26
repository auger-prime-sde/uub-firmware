/*
 * Placeholder PetaLinux user application.
 *
 * Replace this with your application code
 */
#include <stdio.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/wait.h>
#include <stdlib.h>

#define WAIT 5
void usage();


int main(int argc, char *argv[])
{
	  unsigned int sec;
      fd_set rfds;

// SETTING
	int gpsuart;
    struct timeval  timeout;
	  signal(SIGALRM, usage);

	gpsuart=open("/dev/ttyPS0", O_RDWR | O_NOCTTY);


	 timeout.tv_sec = WAIT;    // WAIT seconds
     timeout.tv_usec = 0;    // 0 milliseconds

// WRITING
	char buffsend[7]={64,64,67,106,41,13,10};
    write(gpsuart,buffsend,sizeof(buffsend));


		 char read_buffer[10];   /* Buffer to store the data received              */
		 int  bytes_read = 0;    /* Number of bytes read by the read() system call */
		 int i = 0;
		 alarm(1);

	   	bytes_read = read(gpsuart,&read_buffer,5);



				 printf("{\"message\": \"OK OK\"}");



	close(gpsuart);
}





void usage()
{
	printf("{\"message\": \"failed\"}");
	//system("killall gps_serial");
    exit(0);
}

