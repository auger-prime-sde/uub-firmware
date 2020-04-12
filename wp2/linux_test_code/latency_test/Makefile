   CCARM=arm-xilinx-linux-gnueabi-gcc

# cflags=-I. -g -O0
cflags=-I. -O3 -Wall
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h latency_test.h map_registers.h

all: latency_test


latency_test: latency_test.c  map_registers.c config_trigger.c print_events.c  \
	$(HEADERS)
	$(CCARM) -o latency_test latency_test.c map_registers.c \
	config_trigger.c print_events.c $(cflags) -lrt

clean:;
	rm latency_test
