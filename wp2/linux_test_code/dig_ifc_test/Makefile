   CCARM=arm-xilinx-linux-gnueabi-gcc

# cflags=-I. -g -O0
cflags=-I.
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h dig_ifc_test.h

all: dig_ifc_test dig_ifc_test2


dig_ifc_test: dig_ifc_test.c  map_dig_ifc.c $(HEADERS)
	$(CCARM) -o dig_ifc_test dig_ifc_test.c map_dig_ifc.c \
	$(cflags) -lrt

dig_ifc_test2: dig_ifc_test2.c  map_dig_ifc.c $(HEADERS)
	$(CCARM) -o dig_ifc_test2 dig_ifc_test2.c map_dig_ifc.c \
	$(cflags) -lrt

clean:;
	rm dig_ifc_test dig_ifc_test2
