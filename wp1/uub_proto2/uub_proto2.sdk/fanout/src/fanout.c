// UUB FANOUT initialization on I2C-1
#include <fcntl.h>
#include <stdio.h>
#include <linux/i2c-dev.h>

int addr = 0x28; /* The I2C address FANOUT CDCUN1208*/
char filename[20];
int file, i;

int main ()
{
	char buf[]={0x0,0x0,0x0};
	char reset_start[]={0x15, 0x0, 0x0};
	char reset_stop[]={0x15, 0x0, 0x0};
	char conf_put[]={0x11, 0x0, 0x8};

	i2c();


printf(" impostazione i2c... ");



    if (write(file, reset_start, sizeof(reset_start)) != sizeof(reset_start)) {
    	 	exit(3);
     }

printf(" reset... ");

 //   usleep(100);
    if (write(file, reset_stop, sizeof(reset_stop)) != sizeof(reset_stop)) {
    	 	exit(3);
     }


    for (i = 0; i < 7; i = i ++) {
    			buf[0] = i;	//Imposto indirizzo
    			buf[1] = 0x2; // imposto valore  valore 0x218
    			buf[2] = 0x18;

    			if (write(file, buf, sizeof(buf)) != sizeof(buf)) {
    					exit(3);
    			}
    }


    if (write(file, conf_put, sizeof(conf_put)) != sizeof(conf_put)) {
    	 	exit(3);
     }


	printf("OK\n\r");
}





void i2c(){
	printf("Initialization of I2C Fanout..... ");
	snprintf(filename, 19, "/dev/i2c-1");
	file = open(filename, O_RDWR);
	if (file < 0) {
			exit("no open file");
	}
	if (ioctl(file, I2C_SLAVE, addr) < 0) {
			exit("Fail to setup slave addr!");
	}
}
