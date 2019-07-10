# This makefile 
#   1) Creates rd_interface_options.vh with the compile date loaded into
#      a macro.
#   2) Translates rd_interface_options.vh and rd_interface_defs.vh to 
#      C header files rd_interface_options.h and rd_interface_defs.h
#
# Unfortunately, at this time this makefile has to be run manually before
# repackaging modified rd_interface IP.
#
# 03-Mar-2019 DFN Initial version

all:	rd_interface_id rd_interface_options.vh  \
	../drivers/rd_interface_v2_0/src/rd_interface_defs.h \
	../drivers/rd_interface_v2_0/src/rd_interface_options.h

rd_interface_id: FORCE
	echo "`date +%H%d%m%y`" >rd_interface_id

rd_interface_options.vh: FORCE
	echo "\`ifndef _RD_IFC_OPTIONS" >rd_interface_options.vh
	echo "  \`define _RD_IFC_OPTIONS" >>rd_interface_options.vh
	echo "  \`define RD_IFC_COMPILE_DATE 'h`cat rd_interface_id`" \
	>>rd_interface_options.vh
	echo "\`endif" >>rd_interface_options.vh

../drivers/rd_interface_v2_0/src/rd_interface_defs.h: 	FORCE
	sed -e "s/\`define/\#define/" \
	<../../rd_interface_1.0/hdl/rd_interface_defs.vh | \
	sed -e "s/\`ifndef/\#ifndef/" | \
	sed -e "s/\`endif/\#endif/" | \
	sed -e "s/\`//" | \
	sed -e "s/\`//" | \
	sed -e "s/\`//" | \
	sed -e "s/'h/0x/" \
	> ../drivers/rd_interface_v2_0/src/rd_interface_defs.h

../drivers/rd_interface_v2_0/src/rd_interface_options.h:	rd_interface_options.vh
	sed -e "s/\`define/\#define/" <rd_interface_options.vh | \
	sed -e "s/\`ifndef/\#ifndef/" | \
	sed -e "s/\`endif/\#endif/" | \
	sed -e "s/'h/0x/" \
	> ../drivers/rd_interface_v2_0/src/rd_interface_options.h

clean:
	rm -f ../drivers/rd_interface_v2_0/src/rd_interface_defs.h
	rm -f ../drivers/rd_interface_v2_0/src/rd_interface_options.h
	rm -f rd_interface_options.vh

FORCE:


