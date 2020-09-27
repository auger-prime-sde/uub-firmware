   CCARM=arm-xilinx-linux-gnueabi-gcc

cflags=-I. -g -O0 -Wall
HEADERS = sde_trigger.h xil_assert.h xstatus.h \
	fe_lib.h sde_trigger_options.h xil_types.h read_evt.h \
	shwr_evt_defs.h xparameters.h sde_trigger_defs.h time_tagging_defs.h \
	xparameters_ps.h randoms.h

all: randoms convert_file

randoms:	randoms.c shwr_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(HEADERS)
	$(CCARM) -o randoms randoms.c \
	shwr_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

convert_file:	convert_file.c
	cc -o convert_file convert_file.c $(cflags) -lrt

clean:
	rm randoms
