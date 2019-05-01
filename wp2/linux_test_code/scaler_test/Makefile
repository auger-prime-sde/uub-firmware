   CCARM=arm-xilinx-linux-gnueabi-gcc

# cflags=-I. -g -O0
cflags=-I.
HEADERS = xil_assert.h xstatus.h xil_types.h \
	 xparameters.h xparameters_ps.h scaler_test.h

all: scaler_test


scaler_test: scaler_test.c  map_scaler.c config_scaler.c $(HEADERS)
	$(CCARM) -o scaler_test scaler_test.c map_scaler.c config_scaler.c \
	$(cflags) -lrt

clean:;
	rm linux_scaler_test
