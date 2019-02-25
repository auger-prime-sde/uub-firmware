# make_it.tcl
#
# Run through all the steps to make uub_v3 project
#-----------------------------------------------------------

open_bd_design {/home/augerdn/dfnitz/scratch/git_clones/uub-firmware/wp2/uub_v3/bd/uub_v3/uub_v3.bd}
reset_target all [get_files  /home/augerdn/dfnitz/scratch/git_clones/uub-firmware/wp2/uub_v3/bd/uub_v3/uub_v3.bd]
reset_run synth_1
launch_runs synth_1 -jobs 2
wait_on_run synth_1
launch_runs impl_1 -jobs 2
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
open_run impl_1
file copy -force /home/augerdn/dfnitz/scratch/git_clones/uub-firmware/wp2/uub_v3/uub_v3.runs/impl_1/uub_v3_wrapper.sysdef /home/augerdn/dfnitz/scratch/git_clones/uub-firmware/wp2/uub_v3/uub_v3.sdk/uub_v3_wrapper.hdf

