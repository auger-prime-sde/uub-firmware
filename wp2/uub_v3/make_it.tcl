# make_it_afs.tcl
#-----------------------------------------------------------
#open_bd_design {/home/augerdn/dfnitz/git_clones/uub-firmware/wp2/uub_v3/uub_v3.srcs/sources_1/bd/uub_v3/uub_v3.bd}
cd {/home/augerdn/dfnitz/git_clones/uub-firmware/ip_repo/sde_trigger/hdl}
exec make
cd {/home/augerdn/dfnitz/git_clones/uub-firmware/wp2/uub_v3}
update_ip_catalog -rebuild -scan_changes
report_ip_status -name ip_status
upgrade_ip -vlnv auger.org:user:sde_trigger:3.0 [get_ips  uub_v3_sde_trigger_0_0]
report_ip_status -name ip_status
reset_target all [get_files  /home/augerdn/dfnitz/git_clones/uub-firmware/wp2/uub_v3/uub_v3.srcs/sources_1/bd/uub_v3/uub_v3.bd]
archive_project -force -exclude_run_results /home/augerdn/dfnitz/git_clones/uub-firmware/wp2/uub_v3/uub_v3.zip
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
open_run impl_1

file copy -force /home/augerdn/dfnitz/git_clones/uub-firmware/wp2/uub_v3/uub_v3.runs/impl_1/uub_v3_wrapper.sysdef /home/augerdn/dfnitz/git_clones/uub-firmware/wp2/uub_v3/uub_v3.sdk/uub_v3_wrapper.hdf


