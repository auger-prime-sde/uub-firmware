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
ExecStep $xv_path/bin/xsim iic_filter_tb_behav -key {Behavioral:sim_1:Functional:iic_filter_tb} -tclbatch iic_filter_tb.tcl -view /afs/auger.mtu.edu/common/scratch/dfnitz/git_clones/uub-firmware/ip_repo/iic_filter/iic_filter_v1_0_project/iic_filter_tb_behav.wcfg -log simulate.log
