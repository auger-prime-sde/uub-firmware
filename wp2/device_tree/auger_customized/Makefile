# Makefile for building the Auger customized device tree for the UUB

all: system.dtb

system.dtb: pcw.dtsi  pl.dtsi  skeleton.dtsi  system-conf.dtsi \
	 system-top.dts zynq-7000.dtsi
	dtc -q -I dts -O dtb -o system.dtb system-top.dts
	dtc -q -I dtb -O dts -o system.dts system.dtb

clean:
	rm -f system.dtb system.dts
