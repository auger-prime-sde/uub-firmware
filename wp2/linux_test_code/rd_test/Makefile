   CCARM=arm-xilinx-linux-gnueabi-gcc

# cflags=-I. -g -O0
cflags=-I.
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h rd_test.h

all: rd_test


rd_test: rd_test.c  map_rd.c config_trigger.c print_events.c $(HEADERS)
	$(CCARM) -o rd_test rd_test.c map_rd.c config_trigger.c \
	print_events.c $(cflags) -lrt

clean:;
	rm rd_test
