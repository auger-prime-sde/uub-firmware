   CCARM=arm-xilinx-linux-gnueabi-gcc

# cflags=-I. -g -O0
cflags=-I.
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h rd_test.h

all: linux_rd_test


linux_rd_test: rd_test.c  map_rd.c config_trigger.c $(HEADERS)
	$(CCARM) -o linux_rd_test rd_test.c map_rd.c config_trigger.c \
	$(cflags) -lrt

clean:;
	rm linux_rd_test
