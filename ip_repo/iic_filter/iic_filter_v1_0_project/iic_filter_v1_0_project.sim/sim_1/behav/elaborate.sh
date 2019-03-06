#!/bin/sh -f
xv_path="/usr/local/Xilinx/Vivado/2015.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto d167d1d6f3ac4e939de3cc90e0bbc3f2 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot iic_filter_tb_behav xil_defaultlib.iic_filter_tb xil_defaultlib.glbl -log elaborate.log
