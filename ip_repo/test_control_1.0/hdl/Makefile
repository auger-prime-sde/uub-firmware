# This makefile 
#   1) Creates test_control_options.vh with the compile date loaded into
#      a macro.
#   2) Translates test_control_options.vh and test_control_defs.vh to 
#      C header files test_control_options.h and test_control_defs.h
#
# Unfortunately, at this time this makefile has to be run manually before
# repackaging modified test_control IP.
#
# 13-Mar-2020 DFN Initial version

all:	test_control_id test_control_options.vh  \
	../drivers/test_control_v1_0/src/test_control_defs.h \
	../drivers/test_control_v1_0/src/test_control_options.h

test_control_id: FORCE
	echo "`date +%H%d%m%y`" >test_control_id

test_control_options.vh: FORCE
	echo "\`ifndef _TEST_CTL_OPTIONS" >test_control_options.vh
	echo "  \`define _TEST_CTL_OPTIONS" >>test_control_options.vh
	echo "  \`define TEST_CTL_COMPILE_DATE 'h`cat test_control_id`" \
	>>test_control_options.vh
	echo "\`endif" >>test_control_options.vh

../drivers/test_control_v1_0/src/test_control_defs.h: 	FORCE
	sed -e "s/\`define/\#define/" \
	<../../test_control_1.0/hdl/test_control_defs.vh | \
	sed -e "s/\`ifndef/\#ifndef/" | \
	sed -e "s/\`endif/\#endif/" | \
	sed -e "s/\`//" | \
	sed -e "s/\`//" | \
	sed -e "s/\`//" | \
	sed -e "s/'h/0x/" \
	> ../drivers/test_control_v1_0/src/test_control_defs.h

../drivers/test_control_v1_0/src/test_control_options.h:	test_control_options.vh
	sed -e "s/\`define/\#define/" <test_control_options.vh | \
	sed -e "s/\`ifndef/\#ifndef/" | \
	sed -e "s/\`endif/\#endif/" | \
	sed -e "s/'h/0x/" \
	> ../drivers/test_control_v1_0/src/test_control_options.h

clean:
	rm -f ../drivers/test_control_v1_0/src/test_control_defs.h
	rm -f ../drivers/test_control_v1_0/src/test_control_options.h
	rm -f test_control_options.vh

FORCE:


