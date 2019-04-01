# This makefile 
#   1) Creates digital_interface_options.vh with the compile date loaded into
#      a macro.
#   2) Translates digital_interface_options.vh and digital_interface_defs.vh to 
#      C header files digital_interface_options.h and digital_interface_defs.h
#
# Unfortunately, at this time this makefile has to be run manually before
# repackaging modified digital_interface IP.
#
# 03-Mar-2019 DFN Initial version

all:	digital_interface_id digital_interface_options.vh  \
	../drivers/digital_interface_v1_0/src/digital_interface_defs.h \
	../drivers/digital_interface_v1_0/src/digital_interface_options.h

digital_interface_id: FORCE
	echo "`date +%H%d%m%y`" >digital_interface_id

digital_interface_options.vh: FORCE
	echo "\`ifndef _DIG_IFC_OPTIONS" >digital_interface_options.vh
	echo "  \`define _DIG_IFC_OPTIONS" >>digital_interface_options.vh
	echo "  \`define DIG_IFC_COMPILE_DATE 'h`cat digital_interface_id`" \
	>>digital_interface_options.vh
	echo "\`endif" >>digital_interface_options.vh

../drivers/digital_interface_v1_0/src/digital_interface_defs.h: 	FORCE
	sed -e "s/\`define/\#define/" \
	<../../digital_interface_1.0/hdl/digital_interface_defs.vh | \
	sed -e "s/\`ifndef/\#ifndef/" | \
	sed -e "s/\`endif/\#endif/" | \
	sed -e "s/\`//" | \
	sed -e "s/\`//" | \
	sed -e "s/\`//" | \
	sed -e "s/'h/0x/" \
	> ../drivers/digital_interface_v1_0/src/digital_interface_defs.h

../drivers/digital_interface_v1_0/src/digital_interface_options.h:	digital_interface_options.vh
	sed -e "s/\`define/\#define/" <digital_interface_options.vh | \
	sed -e "s/\`ifndef/\#ifndef/" | \
	sed -e "s/\`endif/\#endif/" | \
	sed -e "s/'h/0x/" \
	> ../drivers/digital_interface_v1_0/src/digital_interface_options.h

clean:
	rm -f ../drivers/digital_interface_v1_0/src/digital_interface_defs.h
	rm -f ../drivers/digital_interface_v1_0/src/digital_interface_options.h
	rm -f digital_interface_options.vh

FORCE:


