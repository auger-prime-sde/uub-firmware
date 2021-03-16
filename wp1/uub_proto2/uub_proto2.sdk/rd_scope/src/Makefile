CC=arm-xilinx-linux-gnueabi-gcc

reg: reg.c;\
	$(CC) -lrt reg.c -I. -o reg



rd: read_evt.c FeShwrRead_test.c;\
	$(CC) -lrt -I. read_evt.c FeShwrRead_test.c -o rd


clean:;
	rm reg rd
