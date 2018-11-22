/*
 * Placeholder PetaLinux user application.
 *
 * Replace this with your application code
 */
#include <stdio.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
// SETTING
	int gpsuart;
	gpsuart=open("/dev/ttyUL1", O_RDWR | O_NOCTTY);
/*
	if(gpsuart == -1)
	  printf("Error! in Opening ttyUL1\n");
	else
	  printf("ttyUL1 Opened Successfully\n");


	struct termios SerialPortSettings;
	tcgetattr(gpsuart, &SerialPortSettings);
	SerialPortSettings.c_cc[VMIN] = 1;
	SerialPortSettings.c_cc[VTIME] = 1;
	if((tcsetattr(gpsuart,TCSANOW,&SerialPortSettings)) != 0)
	    printf("\n  ERROR ! in Setting attributes");
*/


// WRITING
	char buffsend[7]={64,64,67,106,41,13,10};
	write(gpsuart,buffsend,sizeof(buffsend));


// READING

		 char read_buffer[10];   /* Buffer to store the data received              */
		 int  bytes_read = 0;    /* Number of bytes read by the read() system call */
		 int i = 0;
		 bytes_read = read(gpsuart,&read_buffer,5);
	//	 printf("\nBytes Ricevuti %d", bytes_read);
	//	 printf("\n\n");

	//	 for(i=0;i<bytes_read;i++){   /*printing only the received characters*/
	//		 printf("%c",read_buffer[i]);
	//	 }

	//	 printf("%c",read_buffer[0]);

	//	 if (read_buffer[0] = "1")
			 printf("OK OK");



	close(gpsuart);
}


