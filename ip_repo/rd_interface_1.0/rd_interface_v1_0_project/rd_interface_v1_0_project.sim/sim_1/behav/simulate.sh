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
ExecStep $xv_path/bin/xsim rd_interface_tb_behav -key {Behavioral:sim_1:Functional:rd_interface_tb} -tclbatch rd_interface_tb.tcl -view /afs/auger.mtu.edu/common/scratch/dfnitz/git_clones/uub-firmware/ip_repo/rd_interface_1.0/rd_interface_v1_0_project/rd_interface_v1_0_behav.wcfg -log simulate.log
