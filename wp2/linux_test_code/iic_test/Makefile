   CCARM=arm-xilinx-linux-gnueabi-gcc

cflags=-I. -g -O0
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h iic_test.h

all: linux_iic_test


linux_iic_test: iic_test.c  map_iic.c $(HEADERS)
	$(CCARM) -o linux_iic_test iic_test.c map_iic.c $(cflags) -lrt

clean:;
	rm linux_iic_test
