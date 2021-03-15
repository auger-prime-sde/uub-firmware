/*
 * XADC READ under petalinux
 * written by R.Assiro may 2017		*/

#include <stdio.h>
float temp;
int main()
{
	FILE *in;
	in = fopen ("/sys/bus/iio/devices/iio:device0/in_temp0_raw", "r");
	fscanf (in, "%f", &temp);
	fclose (in);
	float zynq_temp = ((temp-2230)*123)/1000;

	printf("{");	//json format
    printf("\"Zynq\": %.1f", zynq_temp);
    printf("}");
}
