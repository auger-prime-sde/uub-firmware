   CCARM=arm-xilinx-linux-gnueabi-gcc

cflags=-I. -g -O0
HEADERS = sde_trigger.h xil_assert.h xstatus.h \
	fe_lib.h sde_trigger_options.h xil_types.h read_evt.h \
	shwr_evt_defs.h xparameters.h sde_trigger_defs.h time_tagging_defs.h \
	xparameters_ps.h trigger_test.h trigger_test_options.h

all: linux_trigger_test

muon:
	cp trigger_test_options.h.muon trigger_test_options.h
	$(CCARM) -o muon_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

intdebug:
	cp trigger_test_options.h.intdebug trigger_test_options.h
	$(CCARM) -o intdebug_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

smallpmt:
	cp trigger_test_options.h.smallpmt trigger_test_options.h
	$(CCARM) -o smallpmt_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

ssd:
	cp trigger_test_options.h.ssd trigger_test_options.h
	$(CCARM) -o ssd_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

ext:
	cp trigger_test_options.h.ext trigger_test_options.h
	$(CCARM) -o ext_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	$(cflags) -lrt

noise:
	cp trigger_test_options.h.noise trigger_test_options.h
	$(CCARM) -o noise_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	$(cflags) -lrt

wcd:
	cp trigger_test_options.h.wcd trigger_test_options.h
	$(CCARM) -o wcd_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

random:
	cp trigger_test_options.h.random trigger_test_options.h
	$(CCARM) -o random_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

linux_trigger_test: linux_trigger_test.c trigger_test.c shwr_buf_utils.c \
	muon_buf_utils.c map_registers.c config_trigger.c $(HEADERS)
	$(CCARM) -o linux_trigger_test linux_trigger_test.c trigger_test.c \
	shwr_buf_utils.c muon_buf_utils.c map_registers.c config_trigger.c \
	map_ifc.c $(cflags) -lrt

clean:;
	rm linux_trigger_test
