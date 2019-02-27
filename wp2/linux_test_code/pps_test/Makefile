   CCARM=arm-xilinx-linux-gnueabi-gcc

cflags=-I. -g -O0
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h pps_test.h

all: linux_pps_test


linux_pps_test: pps_test.c  map_ttag.c $(HEADERS)
	$(CCARM) -o linux_pps_test pps_test.c map_ttag.c \
	$(cflags) -lrt

clean:;
	rm linux_pps_test
