// Data Acquisition from ADC data to file
// implemented USB write file if memory key is connected
// written by R.Assiro and G.Marsella 02 2016

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <time.h>

int main(int argc, char *argv[])
{
	int fd, file,i,j, Status, data_trig, ord;
	int nbin = 4096;
//	int int_trig =  0x55000000;
//	int stop_trig = 0x56000000;
	int value = 0;
	unsigned page_addr, page_offset;
	void *ptr,*pt[5],*ptrt,*ptrt1;
	unsigned page_size=sysconf(_SC_PAGESIZE);
	page_offset = 16;
	FILE *fp, *fp1, *fp2;
	int nevt=0, Nev=0;
	time_t rawtime;
	struct tm *timeinfo;
	char buffer[80];
	time ( &rawtime );
	timeinfo = localtime ( &rawtime );
//	if (argc>1) ord = argv[1];
	if (argc>1) Nev =atoi(argv[1]);
	char filename1[100];
//	char filename2[100];

	if (argc < 2 || argc > 2){
			usage();
			exit(1);
	}
	printf("Acquire is running...Nev=%d\n",Nev);
	i=system ("umount /usb 2>/dev/null");
	i=system ("mountusb 2>/dev/null"); //mountusb is a bash script
//	printf ("The value returned was: %d.\n",i);
	if (i == 0){
//		  sprintf(filename1,"/usb/adc_data%s%s.dat", argv[1], asctime(timeinfo));
		  sprintf(filename1,"/usb/adc_data.dat");
		  printf("Writing file on USB...\n");
	}
	else {
		  sprintf(filename1,"/home/root/adc_data.dat");
		  printf("Writing file on system...\n");
	}
	fp1 = fopen (filename1, "w" );
	char c;

	while(nevt<10)
	{
		fp = fopen ("/srv/www/adc_data.json", "w" );
		/* Open /dev/mem file */
		fd = open ("/dev/mem", O_RDWR);


		unsigned int bram[5];
		int w, ADC0A[5], ADC0B[5];
		bram[0] = 0x44000000;// ADC 1
		bram[1] = 0x46000000;// ADC 2
		bram[2] = 0x48000000;// ADC 3
		bram[3] = 0x4A000000;// ADC 4
		bram[4] = 0x4C000000;// ADC 5
		fprintf(fp1,"\nEvent %d\n",nevt);

		for(i=0;i<5;i++){
			pt[i] = mmap(NULL, page_size*4, PROT_READ|PROT_WRITE, MAP_SHARED, fd, bram[i]);
		}
			nevt++;
			fprintf(fp,"[");
			for (i =0; i<nbin; i++) //
			{
				fprintf(fp,"{");
				for (j=0; j<5; j++) {
					ADC0A[j] = *((unsigned *)(pt[j] + page_offset));
					ADC0B[j] =ADC0A[j]&0x1fff;

					fprintf(fp1,"%4d\t",(ADC0A[j]>>16)&0x1fff);
					fprintf(fp1,"%4d\t", ADC0B[j]);
					fprintf  (fp,"\"adc%d\": \"%d\"",j*2, (ADC0A[j]>>16)&0x1fff);
					fprintf(fp,", \"adc%d\": \"%d\"",j*2+1, ADC0B[j]);
					if (j != 4) {fprintf(fp,", ");}
				}
				page_offset=(page_offset+4)&0x3ffc;
				fprintf(fp,"}");
				if (i!=nbin-1)  fprintf(fp,", ");
			}
			fprintf(fp,"]");
			fclose(fp);
			usleep(10000);
		} //close event loop!!
		printf("Done!\n\r");
		fclose(fp1);
		i=system ("umount /usb 2>/dev/null");
	//	return 0;


}
void usage(void)
{
/*	printf("____________________________\n");
	printf("|         ACQUIRE          |\n");
	printf("|   -e External SMA input  |\n");
	printf("|   -i internal trigger    |\n");
	printf("|   -f FPGA Lecce trigger  |\n");
	printf("|   -n FPGA Nitz trigger   |\n");
	printf("|                          |\n");
	printf("|    written by R.Assiro   |\n");
	printf("|__________________________|\n");
	exit(1);*/
}

