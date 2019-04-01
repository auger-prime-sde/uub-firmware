   CCARM=arm-xilinx-linux-gnueabi-gcc

# cflags=-I. -g -O0
cflags=-I.
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h dig_ifc_test.h

all: linux_dig_ifc_test


linux_dig_ifc_test: dig_ifc_test.c  map_dig_ifc.c $(HEADERS)
	$(CCARM) -o linux_dig_ifc_test dig_ifc_test.c map_dig_ifc.c \
	$(cflags) -lrt

clean:;
	rm linux_dig_ifc_test
