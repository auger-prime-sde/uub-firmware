
################################################################
# This is a generated script based on design: uub_proto2
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source uub_proto2_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name uub_proto2

# This script was generated for a remote BD.
set str_bd_folder /afs/auger.mtu.edu/common/scratch/dfnitz/git_clones/uub-firmware/wp2/uub_proto2/bd
set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

# Check if remote design exists on disk
if { [file exists $str_bd_filepath ] == 1 } {
   puts "ERROR: The remote BD file path <$str_bd_filepath> already exists!"
   return 1
}

# Check if design exists in memory
set list_existing_designs [get_bd_designs -quiet $design_name]
if { $list_existing_designs ne "" } {
   puts "ERROR: The design <$design_name> already exists in this project!"
   puts "ERROR: Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."

   return 1
}

# Check if design exists on disk within project
set list_existing_designs [get_files */${design_name}.bd]
if { $list_existing_designs ne "" } {
   puts "ERROR: The design <$design_name> already exists in this project at location:"
   puts "   $list_existing_designs"
   puts "ERROR: Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."

   return 1
}

# Now can create the remote BD
create_bd_design -dir $str_bd_folder $design_name
current_bd_design $design_name

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: shower_memory_block
proc create_hier_cell_shower_memory_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_shower_memory_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM0P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM1P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM2P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM3P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM4
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM4P

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 CLK120
  create_bd_pin -dir I -from 31 -to 0 SHWR_ADDR
  create_bd_pin -dir I -from 31 -to 0 SHWR_DATA0
  create_bd_pin -dir I -from 31 -to 0 SHWR_DATA1
  create_bd_pin -dir I -from 31 -to 0 SHWR_DATA2
  create_bd_pin -dir I -from 31 -to 0 SHWR_DATA3
  create_bd_pin -dir I -from 31 -to 0 SHWR_DATA4
  create_bd_pin -dir I -from 0 -to 0 rstb
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst s_axi_aresetn

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_1

  # Create instance: axi_bram_ctrl_2, and set properties
  set axi_bram_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_2 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_2

  # Create instance: axi_bram_ctrl_3, and set properties
  set axi_bram_ctrl_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_3 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_3

  # Create instance: axi_bram_ctrl_4, and set properties
  set axi_bram_ctrl_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_4 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_4

  # Create instance: axi_crossbar_0, and set properties
  set axi_crossbar_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_0 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_0

  # Create instance: axi_crossbar_1, and set properties
  set axi_crossbar_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_1 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_1

  # Create instance: axi_crossbar_2, and set properties
  set axi_crossbar_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_2 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_2

  # Create instance: axi_crossbar_3, and set properties
  set axi_crossbar_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_3 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_3

  # Create instance: axi_crossbar_4, and set properties
  set axi_crossbar_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_4 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_4

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_1 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_1

  # Create instance: blk_mem_gen_2, and set properties
  set blk_mem_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_2 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_2

  # Create instance: blk_mem_gen_3, and set properties
  set blk_mem_gen_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_3 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_3

  # Create instance: blk_mem_gen_4, and set properties
  set blk_mem_gen_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_4 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_4

  # Create instance: blk_mem_gen_5, and set properties
  set blk_mem_gen_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_5 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_5

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list CONFIG.CONST_VAL {15} CONFIG.CONST_WIDTH {4}  ] $xlconstant_1

  # Create interface connections
  connect_bd_intf_net -intf_net SHWR_MEM0P_1 [get_bd_intf_pins SHWR_MEM0P] [get_bd_intf_pins axi_crossbar_0/S01_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM0_1 [get_bd_intf_pins SHWR_MEM0] [get_bd_intf_pins axi_crossbar_0/S00_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM1P_1 [get_bd_intf_pins SHWR_MEM1P] [get_bd_intf_pins axi_crossbar_1/S01_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM1_1 [get_bd_intf_pins SHWR_MEM1] [get_bd_intf_pins axi_crossbar_1/S00_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM2P_1 [get_bd_intf_pins SHWR_MEM2P] [get_bd_intf_pins axi_crossbar_2/S01_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM2_1 [get_bd_intf_pins SHWR_MEM2] [get_bd_intf_pins axi_crossbar_2/S00_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM3P_1 [get_bd_intf_pins SHWR_MEM3P] [get_bd_intf_pins axi_crossbar_3/S01_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM3_1 [get_bd_intf_pins SHWR_MEM3] [get_bd_intf_pins axi_crossbar_3/S00_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM4P_1 [get_bd_intf_pins SHWR_MEM4P] [get_bd_intf_pins axi_crossbar_4/S01_AXI]
  connect_bd_intf_net -intf_net SHWR_MEM4_1 [get_bd_intf_pins SHWR_MEM4] [get_bd_intf_pins axi_crossbar_4/S00_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_2/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_2_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_2/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_4/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_3_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_3/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_3/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_4_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_4/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_5/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_crossbar_0_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_crossbar_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_1_M00_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_crossbar_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_2_M00_AXI [get_bd_intf_pins axi_bram_ctrl_2/S_AXI] [get_bd_intf_pins axi_crossbar_2/M00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_3_M00_AXI [get_bd_intf_pins axi_bram_ctrl_3/S_AXI] [get_bd_intf_pins axi_crossbar_3/M00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_4_M00_AXI [get_bd_intf_pins axi_bram_ctrl_4/S_AXI] [get_bd_intf_pins axi_crossbar_4/M00_AXI]

  # Create port connections
  connect_bd_net -net RST_1 [get_bd_pins rstb] [get_bd_pins blk_mem_gen_1/rstb] [get_bd_pins blk_mem_gen_2/rstb] [get_bd_pins blk_mem_gen_3/rstb] [get_bd_pins blk_mem_gen_4/rstb] [get_bd_pins blk_mem_gen_5/rstb]
  connect_bd_net -net S_AXI_ARESETN_3 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_2/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_3/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_4/s_axi_aresetn] [get_bd_pins axi_crossbar_0/aresetn] [get_bd_pins axi_crossbar_1/aresetn] [get_bd_pins axi_crossbar_2/aresetn] [get_bd_pins axi_crossbar_3/aresetn] [get_bd_pins axi_crossbar_4/aresetn]
  connect_bd_net -net S_AXI_CLK_3 [get_bd_pins s_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_bram_ctrl_2/s_axi_aclk] [get_bd_pins axi_bram_ctrl_3/s_axi_aclk] [get_bd_pins axi_bram_ctrl_4/s_axi_aclk] [get_bd_pins axi_crossbar_0/aclk] [get_bd_pins axi_crossbar_1/aclk] [get_bd_pins axi_crossbar_2/aclk] [get_bd_pins axi_crossbar_3/aclk] [get_bd_pins axi_crossbar_4/aclk]
  connect_bd_net -net TRIGGER_CLK_3 [get_bd_pins CLK120] [get_bd_pins blk_mem_gen_1/clkb] [get_bd_pins blk_mem_gen_2/clkb] [get_bd_pins blk_mem_gen_3/clkb] [get_bd_pins blk_mem_gen_4/clkb] [get_bd_pins blk_mem_gen_5/clkb]
  connect_bd_net -net sde_trigger_0_SHWR_ADDR [get_bd_pins SHWR_ADDR] [get_bd_pins blk_mem_gen_1/addrb] [get_bd_pins blk_mem_gen_2/addrb] [get_bd_pins blk_mem_gen_3/addrb] [get_bd_pins blk_mem_gen_4/addrb] [get_bd_pins blk_mem_gen_5/addrb]
  connect_bd_net -net sde_trigger_0_SHWR_DATA0 [get_bd_pins SHWR_DATA0] [get_bd_pins blk_mem_gen_1/dinb]
  connect_bd_net -net sde_trigger_0_SHWR_DATA1 [get_bd_pins SHWR_DATA1] [get_bd_pins blk_mem_gen_2/dinb]
  connect_bd_net -net sde_trigger_0_SHWR_DATA2 [get_bd_pins SHWR_DATA3] [get_bd_pins blk_mem_gen_3/dinb]
  connect_bd_net -net sde_trigger_0_SHWR_DATA3 [get_bd_pins SHWR_DATA2] [get_bd_pins blk_mem_gen_4/dinb]
  connect_bd_net -net sde_trigger_0_SHWR_DATA4 [get_bd_pins SHWR_DATA4] [get_bd_pins blk_mem_gen_5/dinb]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins blk_mem_gen_1/enb] [get_bd_pins blk_mem_gen_2/enb] [get_bd_pins blk_mem_gen_3/enb] [get_bd_pins blk_mem_gen_4/enb] [get_bd_pins blk_mem_gen_5/enb] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins blk_mem_gen_1/web] [get_bd_pins blk_mem_gen_2/web] [get_bd_pins blk_mem_gen_3/web] [get_bd_pins blk_mem_gen_4/web] [get_bd_pins blk_mem_gen_5/web] [get_bd_pins xlconstant_1/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: muon_memory_block
proc create_hier_cell_muon_memory_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_muon_memory_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1P

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 CLK120
  create_bd_pin -dir I -from 31 -to 0 MUON_ADDR
  create_bd_pin -dir I -from 31 -to 0 MUON_DATA0
  create_bd_pin -dir I -from 31 -to 0 MUON_DATA1
  create_bd_pin -dir I MUON_ENB
  create_bd_pin -dir I -from 0 -to 0 rstb
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst s_axi_aresetn

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_1

  # Create instance: axi_crossbar_0, and set properties
  set axi_crossbar_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_0 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_0

  # Create instance: axi_crossbar_1, and set properties
  set axi_crossbar_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_1 ]
  set_property -dict [ list CONFIG.DATA_WIDTH {32} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_crossbar_1

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_0 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_0

  # Create instance: blk_mem_gen_6, and set properties
  set blk_mem_gen_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_6 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_6

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list CONFIG.CONST_VAL {15} CONFIG.CONST_WIDTH {4}  ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net MUON_MEM0P_1 [get_bd_intf_pins MUON_MEM0P] [get_bd_intf_pins axi_crossbar_1/S01_AXI]
  connect_bd_intf_net -intf_net MUON_MEM0_1 [get_bd_intf_pins MUON_MEM0] [get_bd_intf_pins axi_crossbar_1/S00_AXI]
  connect_bd_intf_net -intf_net MUON_MEM1P_1 [get_bd_intf_pins MUON_MEM1P] [get_bd_intf_pins axi_crossbar_0/S01_AXI]
  connect_bd_intf_net -intf_net MUON_MEM1_1 [get_bd_intf_pins MUON_MEM1] [get_bd_intf_pins axi_crossbar_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_6/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_crossbar_0_M00_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_crossbar_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_1_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_crossbar_1/M00_AXI]

  # Create port connections
  connect_bd_net -net S_AXI_CLK_3 [get_bd_pins s_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_crossbar_0/aclk] [get_bd_pins axi_crossbar_1/aclk]
  connect_bd_net -net TRIGGER_CLK_3 [get_bd_pins CLK120] [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins blk_mem_gen_6/clkb]
  connect_bd_net -net rstb_1 [get_bd_pins rstb] [get_bd_pins blk_mem_gen_0/rstb] [get_bd_pins blk_mem_gen_6/rstb]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_crossbar_0/aresetn] [get_bd_pins axi_crossbar_1/aresetn]
  connect_bd_net -net sde_trigger_0_MUON_ADDR [get_bd_pins MUON_ADDR] [get_bd_pins blk_mem_gen_0/addrb] [get_bd_pins blk_mem_gen_6/addrb]
  connect_bd_net -net sde_trigger_0_MUON_DATA0 [get_bd_pins MUON_DATA0] [get_bd_pins blk_mem_gen_0/dinb]
  connect_bd_net -net sde_trigger_0_MUON_DATA1 [get_bd_pins MUON_DATA1] [get_bd_pins blk_mem_gen_6/dinb]
  connect_bd_net -net sde_trigger_0_MUON_ENB [get_bd_pins MUON_ENB] [get_bd_pins blk_mem_gen_0/enb] [get_bd_pins blk_mem_gen_6/enb]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins blk_mem_gen_0/web] [get_bd_pins blk_mem_gen_6/web] [get_bd_pins xlconstant_0/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: zync_block
proc create_hier_cell_zync_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_zync_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 AMIGA_UART_IFC
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 FAKE_MEM0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 FAKE_MEM1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M04_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M05_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M06_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_INTR_IFC
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 RD_IFC
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 RD_MEM0P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 RD_MEM1P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM0P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM1P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM2
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM2P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM3
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM3P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM4
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM4P

  # Create pins
  create_bd_pin -dir I AMIGA_UART_INT
  create_bd_pin -dir O DBG1
  create_bd_pin -dir O DBG2
  create_bd_pin -dir O DBG3
  create_bd_pin -dir O -type clk FCLK_CLK0
  create_bd_pin -dir I GPS_UART_INT
  create_bd_pin -dir I MUON_INT
  create_bd_pin -dir I RADIO_CTS
  create_bd_pin -dir O RADIO_RTS
  create_bd_pin -dir O -from 0 -to 0 RD_RST
  create_bd_pin -dir O RD_XFR_CLK
  create_bd_pin -dir I -from 0 -to 0 SHWR_INT
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_reset

  # Create instance: axi_cdma_0, and set properties
  set axi_cdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_cdma:4.1 axi_cdma_0 ]

  # Create instance: axi_cdma_1, and set properties
  set axi_cdma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_cdma:4.1 axi_cdma_1 ]

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0 ]
  set_property -dict [ list CONFIG.IIC_FREQ_KHZ {400}  ] $axi_iic_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.NUM_MI {23}  ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {6} CONFIG.NUM_SI {2}  ] $axi_interconnect_1

  # Create instance: axi_interconnect_2, and set properties
  set axi_interconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_2 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {3} CONFIG.NUM_SI {2}  ] $axi_interconnect_2

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {333.5} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_RESET_ENABLE {1} CONFIG.PCW_ENET0_RESET_IO {MIO 50} \
CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {30} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} CONFIG.PCW_I2C0_I2C0_IO {MIO 14 .. 15} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C1_I2C1_IO {MIO 48 .. 49} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} CONFIG.PCW_IMPORT_BOARD_PRESET {None} \
CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {0} CONFIG.PCW_QSPI_GRP_SS1_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SPI0_SPI0_IO {MIO 40 .. 45} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART0_BAUD_RATE {115200} CONFIG.PCW_UART0_GRP_FULL_ENABLE {1} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART0_UART0_IO {MIO 46 .. 47} \
CONFIG.PCW_UART1_BAUD_RATE {115200} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.24} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.24} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.24} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.243} CONFIG.PCW_UIPARAM_DDR_CL {6} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {400} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {LPDDR 2} CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {14} CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {LPDDR2_800} \
CONFIG.PCW_UIPARAM_DDR_T_FAW {50} CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {42} \
CONFIG.PCW_UIPARAM_DDR_T_RC {63} CONFIG.PCW_UIPARAM_DDR_T_RCD {8} \
CONFIG.PCW_UIPARAM_DDR_T_RP {9} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 51} CONFIG.PCW_USE_EXPANDED_IOP {0} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_M_AXI_GP1 {0} \
CONFIG.PCW_USE_S_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.PCW_USE_S_AXI_HP1 {1}  ] $processing_system7_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list CONFIG.NUM_PORTS {7}  ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_cdma_0_M_AXI [get_bd_intf_pins axi_cdma_0/M_AXI] [get_bd_intf_pins axi_interconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_cdma_0_M_AXI_SG [get_bd_intf_pins axi_cdma_0/M_AXI_SG] [get_bd_intf_pins axi_interconnect_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_cdma_1_M_AXI [get_bd_intf_pins axi_cdma_1/M_AXI] [get_bd_intf_pins axi_interconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net axi_cdma_1_M_AXI_SG [get_bd_intf_pins axi_cdma_1/M_AXI_SG] [get_bd_intf_pins axi_interconnect_2/S01_AXI]
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_pins IIC] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_cdma_0/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins axi_interconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins M04_AXI] [get_bd_intf_pins axi_interconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M05_AXI [get_bd_intf_pins M05_AXI] [get_bd_intf_pins axi_interconnect_0/M05_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M06_AXI [get_bd_intf_pins M06_AXI] [get_bd_intf_pins axi_interconnect_0/M06_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M07_AXI [get_bd_intf_pins MUON_MEM0P] [get_bd_intf_pins axi_interconnect_0/M07_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M08_AXI [get_bd_intf_pins MUON_MEM1P] [get_bd_intf_pins axi_interconnect_0/M08_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M09_AXI [get_bd_intf_pins SHWR_MEM0P] [get_bd_intf_pins axi_interconnect_0/M09_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M10_AXI [get_bd_intf_pins SHWR_MEM1P] [get_bd_intf_pins axi_interconnect_0/M10_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M11_AXI [get_bd_intf_pins SHWR_MEM2P] [get_bd_intf_pins axi_interconnect_0/M11_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M12_AXI [get_bd_intf_pins SHWR_MEM3P] [get_bd_intf_pins axi_interconnect_0/M12_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M13_AXI [get_bd_intf_pins SHWR_MEM4P] [get_bd_intf_pins axi_interconnect_0/M13_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M14_AXI [get_bd_intf_pins axi_cdma_1/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_0/M14_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M15_AXI [get_bd_intf_pins MUON_INTR_IFC] [get_bd_intf_pins axi_interconnect_0/M15_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M16_AXI [get_bd_intf_pins AMIGA_UART_IFC] [get_bd_intf_pins axi_interconnect_0/M16_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M17_AXI [get_bd_intf_pins FAKE_MEM0] [get_bd_intf_pins axi_interconnect_0/M17_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M18_AXI [get_bd_intf_pins FAKE_MEM1] [get_bd_intf_pins axi_interconnect_0/M18_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M19_AXI [get_bd_intf_pins RD_MEM0P] [get_bd_intf_pins axi_interconnect_0/M19_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M20_AXI [get_bd_intf_pins RD_MEM1P] [get_bd_intf_pins axi_interconnect_0/M20_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M21_AXI [get_bd_intf_pins RD_IFC] [get_bd_intf_pins axi_interconnect_0/M21_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M22_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M22_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins SHWR_MEM0] [get_bd_intf_pins axi_interconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins SHWR_MEM1] [get_bd_intf_pins axi_interconnect_1/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M02_AXI [get_bd_intf_pins SHWR_MEM2] [get_bd_intf_pins axi_interconnect_1/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M03_AXI [get_bd_intf_pins SHWR_MEM3] [get_bd_intf_pins axi_interconnect_1/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M04_AXI [get_bd_intf_pins SHWR_MEM4] [get_bd_intf_pins axi_interconnect_1/M04_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M05_AXI [get_bd_intf_pins axi_interconnect_1/M05_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_interconnect_2_M00_AXI [get_bd_intf_pins MUON_MEM0] [get_bd_intf_pins axi_interconnect_2/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_2_M01_AXI [get_bd_intf_pins MUON_MEM1] [get_bd_intf_pins axi_interconnect_2/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_2_M02_AXI [get_bd_intf_pins axi_interconnect_2/M02_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net AMIGA_UART_INT_1 [get_bd_pins AMIGA_UART_INT] [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net GPS_UART_INT_1 [get_bd_pins GPS_UART_INT] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net MUON_INT_1 [get_bd_pins MUON_INT] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net axi_cdma_0_cdma_introut [get_bd_pins axi_cdma_0/cdma_introut] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_cdma_1_cdma_introut [get_bd_pins axi_cdma_1/cdma_introut] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins xlconcat_0/In6]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/M05_ARESETN] [get_bd_pins axi_interconnect_0/M06_ARESETN] [get_bd_pins axi_interconnect_0/M07_ARESETN] [get_bd_pins axi_interconnect_0/M08_ARESETN] [get_bd_pins axi_interconnect_0/M09_ARESETN] [get_bd_pins axi_interconnect_0/M10_ARESETN] [get_bd_pins axi_interconnect_0/M11_ARESETN] [get_bd_pins axi_interconnect_0/M12_ARESETN] [get_bd_pins axi_interconnect_0/M13_ARESETN] [get_bd_pins axi_interconnect_0/M14_ARESETN] [get_bd_pins axi_interconnect_0/M15_ARESETN] [get_bd_pins axi_interconnect_0/M16_ARESETN] [get_bd_pins axi_interconnect_0/M17_ARESETN] [get_bd_pins axi_interconnect_0/M18_ARESETN] [get_bd_pins axi_interconnect_0/M19_ARESETN] [get_bd_pins axi_interconnect_0/M20_ARESETN] [get_bd_pins axi_interconnect_0/M21_ARESETN] [get_bd_pins axi_interconnect_0/M22_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/M02_ARESETN] [get_bd_pins axi_interconnect_1/M03_ARESETN] [get_bd_pins axi_interconnect_1/M04_ARESETN] [get_bd_pins axi_interconnect_1/M05_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_interconnect_1/S01_ARESETN] [get_bd_pins axi_interconnect_2/ARESETN] [get_bd_pins axi_interconnect_2/M00_ARESETN] [get_bd_pins axi_interconnect_2/M01_ARESETN] [get_bd_pins axi_interconnect_2/M02_ARESETN] [get_bd_pins axi_interconnect_2/S00_ARESETN] [get_bd_pins axi_interconnect_2/S01_ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins axi_cdma_0/s_axi_lite_aresetn] [get_bd_pins axi_cdma_1/s_axi_lite_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins peripheral_reset] [get_bd_pins proc_sys_reset_0/peripheral_reset]
  connect_bd_net -net proc_sys_reset_1_peripheral_reset [get_bd_pins RD_RST] [get_bd_pins proc_sys_reset_1/peripheral_reset]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins axi_cdma_0/m_axi_aclk] [get_bd_pins axi_cdma_0/s_axi_lite_aclk] [get_bd_pins axi_cdma_1/m_axi_aclk] [get_bd_pins axi_cdma_1/s_axi_lite_aclk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/M04_ACLK] [get_bd_pins axi_interconnect_0/M05_ACLK] [get_bd_pins axi_interconnect_0/M06_ACLK] [get_bd_pins axi_interconnect_0/M07_ACLK] [get_bd_pins axi_interconnect_0/M08_ACLK] [get_bd_pins axi_interconnect_0/M09_ACLK] [get_bd_pins axi_interconnect_0/M10_ACLK] [get_bd_pins axi_interconnect_0/M11_ACLK] [get_bd_pins axi_interconnect_0/M12_ACLK] [get_bd_pins axi_interconnect_0/M13_ACLK] [get_bd_pins axi_interconnect_0/M14_ACLK] [get_bd_pins axi_interconnect_0/M15_ACLK] [get_bd_pins axi_interconnect_0/M16_ACLK] [get_bd_pins axi_interconnect_0/M17_ACLK] [get_bd_pins axi_interconnect_0/M18_ACLK] [get_bd_pins axi_interconnect_0/M19_ACLK] [get_bd_pins axi_interconnect_0/M20_ACLK] [get_bd_pins axi_interconnect_0/M21_ACLK] [get_bd_pins axi_interconnect_0/M22_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/M02_ACLK] [get_bd_pins axi_interconnect_1/M03_ACLK] [get_bd_pins axi_interconnect_1/M04_ACLK] [get_bd_pins axi_interconnect_1/M05_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_interconnect_1/S01_ACLK] [get_bd_pins axi_interconnect_2/ACLK] [get_bd_pins axi_interconnect_2/M00_ACLK] [get_bd_pins axi_interconnect_2/M01_ACLK] [get_bd_pins axi_interconnect_2/M02_ACLK] [get_bd_pins axi_interconnect_2/S00_ACLK] [get_bd_pins axi_interconnect_2/S01_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP1_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins RD_XFR_CLK] [get_bd_pins proc_sys_reset_1/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK1]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_1/aux_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]
  connect_bd_net -net processing_system7_0_UART0_RTSN [get_bd_pins RADIO_CTS] [get_bd_pins RADIO_RTS]
  connect_bd_net -net trigger_memory_0_IRQ [get_bd_pins SHWR_INT] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: trigger_memory_block
proc create_hier_cell_trigger_memory_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_trigger_memory_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_INTR_IFC
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_INTR_IFC
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM0P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM1P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM2P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM3P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM4
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SHWR_MEM4P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 TRIGGER_IFC

  # Create pins
  create_bd_pin -dir I -from 23 -to 0 ADC0
  create_bd_pin -dir I -from 23 -to 0 ADC1
  create_bd_pin -dir I -from 23 -to 0 ADC2
  create_bd_pin -dir I -from 23 -to 0 ADC3
  create_bd_pin -dir I -from 23 -to 0 ADC4
  create_bd_pin -dir O -type data DEAD
  create_bd_pin -dir I -from 13 -to 0 FILT_PMT0
  create_bd_pin -dir I -from 13 -to 0 FILT_PMT1
  create_bd_pin -dir I -from 13 -to 0 FILT_PMT2
  create_bd_pin -dir O LED
  create_bd_pin -dir I LED_FLG
  create_bd_pin -dir O -from 1 -to 0 -type data MUON_BUF_RNUM
  create_bd_pin -dir O -from 1 -to 0 -type data MUON_BUF_WNUM
  create_bd_pin -dir O -from 3 -to 0 MUON_EVT_CTR
  create_bd_pin -dir O MUON_IRQ
  create_bd_pin -dir O -type data MUON_TRIGGER
  create_bd_pin -dir I ONE_PPS
  create_bd_pin -dir O P61
  create_bd_pin -dir O P62
  create_bd_pin -dir O P63
  create_bd_pin -dir I -from 0 -to 0 -type rst RST
  create_bd_pin -dir O -from 1 -to 0 -type data SHWR_BUF_RNUM
  create_bd_pin -dir O -from 1 -to 0 -type data SHWR_BUF_WNUM
  create_bd_pin -dir O -from 3 -to 0 -type data SHWR_EVT_CTR
  create_bd_pin -dir O -from 15 -to 0 SHWR_EVT_ID
  create_bd_pin -dir O SHWR_IRQ
  create_bd_pin -dir O -type data SHWR_TRIGGER
  create_bd_pin -dir O SHWR_TRIG_FAST
  create_bd_pin -dir I -from 0 -to 0 -type rst S_AXI_ARESETN
  create_bd_pin -dir I -type clk S_AXI_CLK
  create_bd_pin -dir I -from 0 -to 0 TRIGGER_CLK
  create_bd_pin -dir I TRIG_IN
  create_bd_pin -dir O TRIG_OUT

  # Create instance: muon_memory_block
  create_hier_cell_muon_memory_block $hier_obj muon_memory_block

  # Create instance: sde_trigger_0, and set properties
  set sde_trigger_0 [ create_bd_cell -type ip -vlnv auger.mtu.edu:user:sde_trigger:1.2 sde_trigger_0 ]

  # Create instance: shower_memory_block
  create_hier_cell_shower_memory_block $hier_obj shower_memory_block

  # Create interface connections
  connect_bd_intf_net -intf_net MUON_INTR_IFC_1 [get_bd_intf_pins MUON_INTR_IFC] [get_bd_intf_pins sde_trigger_0/S1_AXI_INTR]
  connect_bd_intf_net -intf_net MUON_MEM0_1 [get_bd_intf_pins MUON_MEM0] [get_bd_intf_pins muon_memory_block/MUON_MEM0]
  connect_bd_intf_net -intf_net MUON_MEM0_PDT_1 [get_bd_intf_pins MUON_MEM0P] [get_bd_intf_pins muon_memory_block/MUON_MEM0P]
  connect_bd_intf_net -intf_net MUON_MEM1P_1 [get_bd_intf_pins MUON_MEM1P] [get_bd_intf_pins muon_memory_block/MUON_MEM1P]
  connect_bd_intf_net -intf_net MUON_MEM1_1 [get_bd_intf_pins MUON_MEM1] [get_bd_intf_pins muon_memory_block/MUON_MEM1]
  connect_bd_intf_net -intf_net SHWR_INTR_IFC_1 [get_bd_intf_pins SHWR_INTR_IFC] [get_bd_intf_pins sde_trigger_0/S_AXI_INTR]
  connect_bd_intf_net -intf_net SHWR_MEM0P_1 [get_bd_intf_pins SHWR_MEM0P] [get_bd_intf_pins shower_memory_block/SHWR_MEM0P]
  connect_bd_intf_net -intf_net SHWR_MEM0_1 [get_bd_intf_pins SHWR_MEM0] [get_bd_intf_pins shower_memory_block/SHWR_MEM0]
  connect_bd_intf_net -intf_net SHWR_MEM1P_1 [get_bd_intf_pins SHWR_MEM1P] [get_bd_intf_pins shower_memory_block/SHWR_MEM1P]
  connect_bd_intf_net -intf_net SHWR_MEM1_1 [get_bd_intf_pins SHWR_MEM1] [get_bd_intf_pins shower_memory_block/SHWR_MEM1]
  connect_bd_intf_net -intf_net SHWR_MEM2P_1 [get_bd_intf_pins SHWR_MEM2P] [get_bd_intf_pins shower_memory_block/SHWR_MEM2P]
  connect_bd_intf_net -intf_net SHWR_MEM2_1 [get_bd_intf_pins SHWR_MEM2] [get_bd_intf_pins shower_memory_block/SHWR_MEM2]
  connect_bd_intf_net -intf_net SHWR_MEM3P_1 [get_bd_intf_pins SHWR_MEM3P] [get_bd_intf_pins shower_memory_block/SHWR_MEM3P]
  connect_bd_intf_net -intf_net SHWR_MEM3_1 [get_bd_intf_pins SHWR_MEM3] [get_bd_intf_pins shower_memory_block/SHWR_MEM3]
  connect_bd_intf_net -intf_net SHWR_MEM4P_1 [get_bd_intf_pins SHWR_MEM4P] [get_bd_intf_pins shower_memory_block/SHWR_MEM4P]
  connect_bd_intf_net -intf_net SHWR_MEM4_1 [get_bd_intf_pins SHWR_MEM4] [get_bd_intf_pins shower_memory_block/SHWR_MEM4]
  connect_bd_intf_net -intf_net TRIGGER_IFC_1 [get_bd_intf_pins TRIGGER_IFC] [get_bd_intf_pins sde_trigger_0/S00_AXI]

  # Create port connections
  connect_bd_net -net ADC0_1 [get_bd_pins ADC0] [get_bd_pins sde_trigger_0/ADC0]
  connect_bd_net -net ADC1_1 [get_bd_pins ADC1] [get_bd_pins sde_trigger_0/ADC1]
  connect_bd_net -net ADC2_1 [get_bd_pins ADC2] [get_bd_pins sde_trigger_0/ADC2]
  connect_bd_net -net ADC3_1 [get_bd_pins ADC3] [get_bd_pins sde_trigger_0/ADC3]
  connect_bd_net -net ADC4_1 [get_bd_pins ADC4] [get_bd_pins sde_trigger_0/ADC4]
  connect_bd_net -net ENAB_PPS_1 [get_bd_pins LED_FLG] [get_bd_pins sde_trigger_0/LED_FLG]
  connect_bd_net -net FILT_PMT0_1 [get_bd_pins FILT_PMT0] [get_bd_pins sde_trigger_0/FILT_PMT0]
  connect_bd_net -net FILT_PMT1_1 [get_bd_pins FILT_PMT1] [get_bd_pins sde_trigger_0/FILT_PMT1]
  connect_bd_net -net FILT_PMT2_1 [get_bd_pins FILT_PMT2] [get_bd_pins sde_trigger_0/FILT_PMT2]
  connect_bd_net -net ONE_PPS_1 [get_bd_pins ONE_PPS] [get_bd_pins sde_trigger_0/ONE_PPS]
  connect_bd_net -net RST_1 [get_bd_pins RST] [get_bd_pins muon_memory_block/rstb] [get_bd_pins shower_memory_block/rstb]
  connect_bd_net -net SHWR_DATA2_1 [get_bd_pins sde_trigger_0/SHWR_DATA2] [get_bd_pins shower_memory_block/SHWR_DATA2]
  connect_bd_net -net SHWR_DATA3_1 [get_bd_pins sde_trigger_0/SHWR_DATA3] [get_bd_pins shower_memory_block/SHWR_DATA3]
  connect_bd_net -net S_AXI_ARESETN_3 [get_bd_pins S_AXI_ARESETN] [get_bd_pins muon_memory_block/s_axi_aresetn] [get_bd_pins sde_trigger_0/s00_axi_aresetn] [get_bd_pins sde_trigger_0/s1_axi_intr_aresetn] [get_bd_pins sde_trigger_0/s_axi_intr_aresetn] [get_bd_pins shower_memory_block/s_axi_aresetn]
  connect_bd_net -net S_AXI_CLK_3 [get_bd_pins S_AXI_CLK] [get_bd_pins muon_memory_block/s_axi_aclk] [get_bd_pins sde_trigger_0/s00_axi_aclk] [get_bd_pins sde_trigger_0/s1_axi_intr_aclk] [get_bd_pins sde_trigger_0/s_axi_intr_aclk] [get_bd_pins shower_memory_block/s_axi_aclk]
  connect_bd_net -net TRIGGER_CLK_3 [get_bd_pins TRIGGER_CLK] [get_bd_pins muon_memory_block/CLK120] [get_bd_pins sde_trigger_0/CLK120] [get_bd_pins shower_memory_block/CLK120]
  connect_bd_net -net TRIG_IN_1 [get_bd_pins TRIG_IN] [get_bd_pins sde_trigger_0/TRIG_IN]
  connect_bd_net -net sde_trigger_0_DEAD [get_bd_pins DEAD] [get_bd_pins sde_trigger_0/DEAD]
  connect_bd_net -net sde_trigger_0_LEDBAR [get_bd_pins LED] [get_bd_pins sde_trigger_0/LED]
  connect_bd_net -net sde_trigger_0_MUON_ADDR [get_bd_pins muon_memory_block/MUON_ADDR] [get_bd_pins sde_trigger_0/MUON_ADDR]
  connect_bd_net -net sde_trigger_0_MUON_BUF_RNUM [get_bd_pins MUON_BUF_RNUM] [get_bd_pins sde_trigger_0/MUON_BUF_RNUM]
  connect_bd_net -net sde_trigger_0_MUON_BUF_WNUM [get_bd_pins MUON_BUF_WNUM] [get_bd_pins sde_trigger_0/MUON_BUF_WNUM]
  connect_bd_net -net sde_trigger_0_MUON_DATA0 [get_bd_pins muon_memory_block/MUON_DATA0] [get_bd_pins sde_trigger_0/MUON_DATA0]
  connect_bd_net -net sde_trigger_0_MUON_DATA1 [get_bd_pins muon_memory_block/MUON_DATA1] [get_bd_pins sde_trigger_0/MUON_DATA1]
  connect_bd_net -net sde_trigger_0_MUON_ENB [get_bd_pins muon_memory_block/MUON_ENB] [get_bd_pins sde_trigger_0/MUON_ENB]
  connect_bd_net -net sde_trigger_0_MUON_EVT_CTR [get_bd_pins MUON_EVT_CTR] [get_bd_pins sde_trigger_0/MUON_EVT_CTR]
  connect_bd_net -net sde_trigger_0_MUON_IRQ [get_bd_pins MUON_IRQ] [get_bd_pins sde_trigger_0/MUON_IRQ]
  connect_bd_net -net sde_trigger_0_MUON_TRIGGER [get_bd_pins MUON_TRIGGER] [get_bd_pins sde_trigger_0/MUON_TRIGGER]
  connect_bd_net -net sde_trigger_0_P61 [get_bd_pins P61] [get_bd_pins sde_trigger_0/P61]
  connect_bd_net -net sde_trigger_0_P62 [get_bd_pins P62] [get_bd_pins sde_trigger_0/P62]
  connect_bd_net -net sde_trigger_0_P63 [get_bd_pins P63] [get_bd_pins sde_trigger_0/P63]
  connect_bd_net -net sde_trigger_0_SHWR_ADDR [get_bd_pins sde_trigger_0/SHWR_ADDR] [get_bd_pins shower_memory_block/SHWR_ADDR]
  connect_bd_net -net sde_trigger_0_SHWR_BUF_RNUM [get_bd_pins SHWR_BUF_RNUM] [get_bd_pins sde_trigger_0/SHWR_BUF_RNUM]
  connect_bd_net -net sde_trigger_0_SHWR_BUF_WNUM [get_bd_pins SHWR_BUF_WNUM] [get_bd_pins sde_trigger_0/SHWR_BUF_WNUM]
  connect_bd_net -net sde_trigger_0_SHWR_DATA0 [get_bd_pins sde_trigger_0/SHWR_DATA0] [get_bd_pins shower_memory_block/SHWR_DATA0]
  connect_bd_net -net sde_trigger_0_SHWR_DATA1 [get_bd_pins sde_trigger_0/SHWR_DATA1] [get_bd_pins shower_memory_block/SHWR_DATA1]
  connect_bd_net -net sde_trigger_0_SHWR_DATA4 [get_bd_pins sde_trigger_0/SHWR_DATA4] [get_bd_pins shower_memory_block/SHWR_DATA4]
  connect_bd_net -net sde_trigger_0_SHWR_EVT_CTR [get_bd_pins SHWR_EVT_CTR] [get_bd_pins sde_trigger_0/SHWR_EVT_CTR]
  connect_bd_net -net sde_trigger_0_SHWR_EVT_ID [get_bd_pins SHWR_EVT_ID] [get_bd_pins sde_trigger_0/SHWR_EVT_ID]
  connect_bd_net -net sde_trigger_0_SHWR_IRQ [get_bd_pins SHWR_IRQ] [get_bd_pins sde_trigger_0/SHWR_IRQ]
  connect_bd_net -net sde_trigger_0_SHWR_TRIGGER [get_bd_pins SHWR_TRIGGER] [get_bd_pins sde_trigger_0/SHWR_TRIGGER]
  connect_bd_net -net sde_trigger_0_SHWR_TRIG_FAST [get_bd_pins SHWR_TRIG_FAST] [get_bd_pins sde_trigger_0/SHWR_TRIG_FAST]
  connect_bd_net -net sde_trigger_0_TRIG_OUT [get_bd_pins TRIG_OUT] [get_bd_pins sde_trigger_0/TRIG_OUT]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: test_control_block
proc create_hier_cell_test_control_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_test_control_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 FAKE_MEM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 FAKE_MEM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  # Create pins
  create_bd_pin -dir I -from 23 -to 0 ADC0_IN
  create_bd_pin -dir O -from 23 -to 0 ADC0_OUT
  create_bd_pin -dir I -from 23 -to 0 ADC1_IN
  create_bd_pin -dir O -from 23 -to 0 ADC1_OUT
  create_bd_pin -dir I -from 23 -to 0 ADC2_IN
  create_bd_pin -dir O -from 23 -to 0 ADC2_OUT
  create_bd_pin -dir I -from 23 -to 0 ADC3_IN
  create_bd_pin -dir O -from 23 -to 0 ADC3_OUT
  create_bd_pin -dir I -from 23 -to 0 ADC4_IN
  create_bd_pin -dir O -from 23 -to 0 ADC4_OUT
  create_bd_pin -dir I -from 0 -to 0 -type clk CLK
  create_bd_pin -dir I FAKE_PPS
  create_bd_pin -dir O PPS
  create_bd_pin -dir I -from 0 -to 0 RST
  create_bd_pin -dir I TRUE_PPS
  create_bd_pin -dir I -type clk s00_axi_aclk
  create_bd_pin -dir I -from 0 -to 0 -type rst s00_axi_aresetn

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]
  set_property -dict [ list CONFIG.ECC_TYPE {0} CONFIG.PROTOCOL {AXI4} CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list CONFIG.ECC_TYPE {Hamming} CONFIG.PROTOCOL {AXI4} CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_1

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_0 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_0

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_1 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_1

  # Create instance: fake_signal_0, and set properties
  set fake_signal_0 [ create_bd_cell -type ip -vlnv user.org:user:fake_signal:1.0 fake_signal_0 ]

  # Create instance: test_control_0, and set properties
  set test_control_0 [ create_bd_cell -type ip -vlnv user.org:user:test_control:1.0 test_control_0 ]

  # Create instance: xlconstant_4, and set properties
  set xlconstant_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_4 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {32}  ] $xlconstant_4

  # Create instance: xlconstant_5, and set properties
  set xlconstant_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_5 ]
  set_property -dict [ list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}  ] $xlconstant_5

  # Create instance: xlconstant_6, and set properties
  set xlconstant_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_6 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {4}  ] $xlconstant_6

  # Create interface connections
  connect_bd_intf_net -intf_net FAKE_MEM0_1 [get_bd_intf_pins FAKE_MEM0] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net FAKE_MEM1_1 [get_bd_intf_pins FAKE_MEM1] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net zync_block_M06_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins test_control_0/S00_AXI]

  # Create port connections
  connect_bd_net -net ADC1_1 [get_bd_pins ADC1_OUT] [get_bd_pins fake_signal_0/ADC1_OUT]
  connect_bd_net -net ADC2_1 [get_bd_pins ADC2_OUT] [get_bd_pins fake_signal_0/ADC2_OUT]
  connect_bd_net -net ADC3_1 [get_bd_pins ADC3_OUT] [get_bd_pins fake_signal_0/ADC3_OUT]
  connect_bd_net -net ADC4_1 [get_bd_pins ADC4_OUT] [get_bd_pins fake_signal_0/ADC4_OUT]
  connect_bd_net -net GPS_PPS_1 [get_bd_pins TRUE_PPS] [get_bd_pins test_control_0/TRUE_PPS]
  connect_bd_net -net In_regional_ck_0_IBUF_OUT [get_bd_pins CLK] [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins blk_mem_gen_1/clkb] [get_bd_pins fake_signal_0/CLK] [get_bd_pins test_control_0/CLK120]
  connect_bd_net -net RST_1 [get_bd_pins RST] [get_bd_pins blk_mem_gen_0/rstb] [get_bd_pins blk_mem_gen_1/rstb]
  connect_bd_net -net adc_inputs_SYNC_OUT0 [get_bd_pins ADC0_IN] [get_bd_pins fake_signal_0/ADC0_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT1 [get_bd_pins ADC1_IN] [get_bd_pins fake_signal_0/ADC1_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT2 [get_bd_pins ADC2_IN] [get_bd_pins fake_signal_0/ADC2_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT3 [get_bd_pins ADC3_IN] [get_bd_pins fake_signal_0/ADC3_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT4 [get_bd_pins ADC4_IN] [get_bd_pins fake_signal_0/ADC4_IN]
  connect_bd_net -net blk_mem_gen_0_doutb [get_bd_pins blk_mem_gen_0/doutb] [get_bd_pins fake_signal_0/EVENT_IN0]
  connect_bd_net -net blk_mem_gen_1_doutb [get_bd_pins blk_mem_gen_1/doutb] [get_bd_pins fake_signal_0/EVENT_IN1]
  connect_bd_net -net clock_1pps_0_CLK1PPS [get_bd_pins FAKE_PPS] [get_bd_pins test_control_0/FAKE_PPS]
  connect_bd_net -net fake_signal_0_ADC0_OUT [get_bd_pins ADC0_OUT] [get_bd_pins fake_signal_0/ADC0_OUT]
  connect_bd_net -net fake_signal_0_EVENT_ADR [get_bd_pins blk_mem_gen_0/addrb] [get_bd_pins blk_mem_gen_1/addrb] [get_bd_pins fake_signal_0/EVENT_ADR]
  connect_bd_net -net interface_uub_dfn3_1_USE_FAKE_MUON [get_bd_pins fake_signal_0/USE_FAKE_MUON] [get_bd_pins test_control_0/USE_FAKE_MUON]
  connect_bd_net -net interface_uub_dfn3_1_USE_FAKE_SHWR [get_bd_pins fake_signal_0/USE_FAKE_SHWR] [get_bd_pins test_control_0/USE_FAKE_SHWR]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins s00_axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins test_control_0/s00_axi_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s00_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins test_control_0/s00_axi_aclk]
  connect_bd_net -net test_control_0_FAKE_MODE [get_bd_pins fake_signal_0/MODE] [get_bd_pins test_control_0/FAKE_MODE]
  connect_bd_net -net test_control_0_PPS [get_bd_pins PPS] [get_bd_pins test_control_0/PPS]
  connect_bd_net -net xlconstant_4_dout [get_bd_pins blk_mem_gen_0/dinb] [get_bd_pins blk_mem_gen_1/dinb] [get_bd_pins xlconstant_4/dout]
  connect_bd_net -net xlconstant_5_dout [get_bd_pins blk_mem_gen_0/enb] [get_bd_pins blk_mem_gen_1/enb] [get_bd_pins xlconstant_5/dout]
  connect_bd_net -net xlconstant_6_dout [get_bd_pins blk_mem_gen_0/web] [get_bd_pins blk_mem_gen_1/web] [get_bd_pins xlconstant_6/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: filter_block
proc create_hier_cell_filter_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_filter_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 CLK
  create_bd_pin -dir I -from 23 -to 0 IN0
  create_bd_pin -dir I -from 23 -to 0 IN1
  create_bd_pin -dir I -from 23 -to 0 IN2
  create_bd_pin -dir O -from 13 -to 0 OUT0
  create_bd_pin -dir O -from 13 -to 0 OUT1
  create_bd_pin -dir O -from 13 -to 0 OUT2

  # Create instance: fir_compiler_0, and set properties
  set fir_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_0 ]
  set_property -dict [ list CONFIG.Channel_Sequence {Basic} \
CONFIG.CoefficientVector {5,0,12,22,0,-61,-96,0,256,551,681,551,256,0,-96,-61,0,22,12,0,5} CONFIG.Coefficient_Fractional_Bits {0} \
CONFIG.Coefficient_Sets {1} CONFIG.Coefficient_Sign {Signed} \
CONFIG.Coefficient_Structure {Inferred} CONFIG.Coefficient_Width {11} \
CONFIG.ColumnConfig {11} CONFIG.DATA_Has_TLAST {Not_Required} \
CONFIG.Data_Fractional_Bits {0} CONFIG.Data_Sign {Unsigned} \
CONFIG.Data_Width {12} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
CONFIG.M_DATA_Has_TUSER {Not_Required} CONFIG.Number_Channels {1} \
CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} CONFIG.Output_Width {24} \
CONFIG.Quantization {Integer_Coefficients} CONFIG.RateSpecification {Input_Sample_Period} \
CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.SamplePeriod {1} \
CONFIG.Select_Pattern {All}  ] $fir_compiler_0

  # Create instance: fir_compiler_1, and set properties
  set fir_compiler_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_1 ]
  set_property -dict [ list CONFIG.Channel_Sequence {Basic} \
CONFIG.CoefficientVector {5,0,12,22,0,-61,-96,0,256,551,681,551,256,0,-96,-61,0,22,12,0,5} CONFIG.Coefficient_Fractional_Bits {0} \
CONFIG.Coefficient_Sets {1} CONFIG.Coefficient_Sign {Signed} \
CONFIG.Coefficient_Structure {Inferred} CONFIG.Coefficient_Width {11} \
CONFIG.ColumnConfig {11} CONFIG.DATA_Has_TLAST {Not_Required} \
CONFIG.Data_Fractional_Bits {0} CONFIG.Data_Sign {Unsigned} \
CONFIG.Data_Width {12} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
CONFIG.M_DATA_Has_TUSER {Not_Required} CONFIG.Number_Channels {1} \
CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} CONFIG.Output_Width {24} \
CONFIG.Quantization {Integer_Coefficients} CONFIG.RateSpecification {Input_Sample_Period} \
CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.SamplePeriod {1} \
CONFIG.Select_Pattern {All}  ] $fir_compiler_1

  # Create instance: fir_compiler_2, and set properties
  set fir_compiler_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_2 ]
  set_property -dict [ list CONFIG.Channel_Sequence {Basic} \
CONFIG.CoefficientVector {5,0,12,22,0,-61,-96,0,256,551,681,551,256,0,-96,-61,0,22,12,0,5} CONFIG.Coefficient_Fractional_Bits {0} \
CONFIG.Coefficient_Sets {1} CONFIG.Coefficient_Sign {Signed} \
CONFIG.Coefficient_Structure {Inferred} CONFIG.Coefficient_Width {11} \
CONFIG.ColumnConfig {11} CONFIG.DATA_Has_TLAST {Not_Required} \
CONFIG.Data_Fractional_Bits {0} CONFIG.Data_Sign {Unsigned} \
CONFIG.Data_Width {12} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
CONFIG.M_DATA_Has_TUSER {Not_Required} CONFIG.Number_Channels {1} \
CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} CONFIG.Output_Width {24} \
CONFIG.Quantization {Integer_Coefficients} CONFIG.RateSpecification {Input_Sample_Period} \
CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.SamplePeriod {1} \
CONFIG.Select_Pattern {All}  ] $fir_compiler_2

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list CONFIG.IN0_WIDTH {12} CONFIG.IN1_WIDTH {4}  ] $xlconcat_0

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [ list CONFIG.IN0_WIDTH {12} CONFIG.IN1_WIDTH {4}  ] $xlconcat_1

  # Create instance: xlconcat_2, and set properties
  set xlconcat_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_2 ]
  set_property -dict [ list CONFIG.IN0_WIDTH {12} CONFIG.IN1_WIDTH {4}  ] $xlconcat_2

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {4}  ] $xlconstant_1

  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]

  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {4}  ] $xlconstant_3

  # Create instance: xlconstant_5, and set properties
  set xlconstant_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_5 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {4}  ] $xlconstant_5

  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2 ]
  set_property -dict [ list CONFIG.DIN_FROM {23} CONFIG.DIN_TO {12} CONFIG.DIN_WIDTH {24} CONFIG.DOUT_WIDTH {12}  ] $xlslice_2

  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_3 ]
  set_property -dict [ list CONFIG.DIN_FROM {23} CONFIG.DIN_TO {10} CONFIG.DIN_WIDTH {24} CONFIG.DOUT_WIDTH {14}  ] $xlslice_3

  # Create instance: xlslice_4, and set properties
  set xlslice_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_4 ]
  set_property -dict [ list CONFIG.DIN_FROM {23} CONFIG.DIN_TO {12} CONFIG.DIN_WIDTH {24} CONFIG.DOUT_WIDTH {12}  ] $xlslice_4

  # Create instance: xlslice_5, and set properties
  set xlslice_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_5 ]
  set_property -dict [ list CONFIG.DIN_FROM {23} CONFIG.DIN_TO {10} CONFIG.DIN_WIDTH {24} CONFIG.DOUT_WIDTH {14}  ] $xlslice_5

  # Create instance: xlslice_6, and set properties
  set xlslice_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_6 ]
  set_property -dict [ list CONFIG.DIN_FROM {23} CONFIG.DIN_TO {12} CONFIG.DIN_WIDTH {24} CONFIG.DOUT_WIDTH {12}  ] $xlslice_6

  # Create instance: xlslice_7, and set properties
  set xlslice_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_7 ]
  set_property -dict [ list CONFIG.DIN_FROM {23} CONFIG.DIN_TO {10} CONFIG.DIN_WIDTH {24} CONFIG.DOUT_WIDTH {14}  ] $xlslice_7

  # Create port connections
  connect_bd_net -net CLK_1 [get_bd_pins CLK] [get_bd_pins fir_compiler_0/aclk] [get_bd_pins fir_compiler_1/aclk] [get_bd_pins fir_compiler_2/aclk]
  connect_bd_net -net IN0_1 [get_bd_pins IN0] [get_bd_pins xlslice_2/Din]
  connect_bd_net -net IN0_2 [get_bd_pins IN1] [get_bd_pins xlslice_4/Din]
  connect_bd_net -net IN0_3 [get_bd_pins IN2] [get_bd_pins xlslice_6/Din]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata [get_bd_pins fir_compiler_0/m_axis_data_tdata] [get_bd_pins xlslice_3/Din]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata1 [get_bd_pins fir_compiler_1/m_axis_data_tdata] [get_bd_pins xlslice_5/Din]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata2 [get_bd_pins fir_compiler_2/m_axis_data_tdata] [get_bd_pins xlslice_7/Din]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins fir_compiler_0/s_axis_data_tdata] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_0_dout1 [get_bd_pins fir_compiler_1/s_axis_data_tdata] [get_bd_pins xlconcat_1/dout]
  connect_bd_net -net xlconcat_0_dout2 [get_bd_pins fir_compiler_2/s_axis_data_tdata] [get_bd_pins xlconcat_2/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconcat_0/In1] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_1_dout1 [get_bd_pins xlconcat_1/In1] [get_bd_pins xlconstant_3/dout]
  connect_bd_net -net xlconstant_1_dout2 [get_bd_pins xlconcat_2/In1] [get_bd_pins xlconstant_5/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins fir_compiler_0/s_axis_data_tvalid] [get_bd_pins fir_compiler_1/s_axis_data_tvalid] [get_bd_pins fir_compiler_2/s_axis_data_tvalid] [get_bd_pins xlconstant_2/dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins xlconcat_0/In0] [get_bd_pins xlslice_2/Dout]
  connect_bd_net -net xlslice_2_Dout1 [get_bd_pins xlconcat_1/In0] [get_bd_pins xlslice_4/Dout]
  connect_bd_net -net xlslice_2_Dout2 [get_bd_pins xlconcat_2/In0] [get_bd_pins xlslice_6/Dout]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins OUT0] [get_bd_pins xlslice_3/Dout]
  connect_bd_net -net xlslice_3_Dout1 [get_bd_pins OUT1] [get_bd_pins xlslice_5/Dout]
  connect_bd_net -net xlslice_3_Dout2 [get_bd_pins OUT2] [get_bd_pins xlslice_7/Dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: fake_rd_block
proc create_hier_cell_fake_rd_block { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_fake_rd_block() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 FAKE_RD_DATA
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 RD_DATA0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 SOO_AXI

  # Create pins
  create_bd_pin -dir O DEBUG1
  create_bd_pin -dir O DEBUG2
  create_bd_pin -dir O ENABLE_FAKE_XFR
  create_bd_pin -dir I ENABLE_XFR_IN
  create_bd_pin -dir I -from 0 -to 0 FAKE_RD_CLK
  create_bd_pin -dir O FAKE_RD_XFR_CLK
  create_bd_pin -dir I -from 0 -to 0 RST
  create_bd_pin -dir I S00_AXI_ACLK
  create_bd_pin -dir I -from 0 -to 0 S00_AXI_ARESETN
  create_bd_pin -dir I SERIAL_CLK_IN
  create_bd_pin -dir I SERIAL_DATA0_IN
  create_bd_pin -dir O SERIAL_FAKE_OUT

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]
  set_property -dict [ list CONFIG.ECC_TYPE {0} CONFIG.PROTOCOL {AXI4} CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_1

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_0 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_0

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_1 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_1

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.1 clk_wiz_0 ]
  set_property -dict [ list CONFIG.CLKOUT1_DRIVES {BUFG} \
CONFIG.CLKOUT1_JITTER {235.587} CONFIG.CLKOUT1_PHASE_ERROR {208.802} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} CONFIG.CLKOUT1_REQUESTED_PHASE {0.00} \
CONFIG.CLKOUT2_DRIVES {BUFG} CONFIG.CLKOUT3_DRIVES {BUFG} \
CONFIG.CLKOUT4_DRIVES {BUFG} CONFIG.CLKOUT5_DRIVES {BUFG} \
CONFIG.CLKOUT6_DRIVES {BUFG} CONFIG.CLKOUT7_DRIVES {BUFG} \
CONFIG.MMCM_CLKFBOUT_MULT_F {20} CONFIG.MMCM_CLKOUT0_DIVIDE_F {16} \
CONFIG.MMCM_COMPENSATION {ZHOLD} CONFIG.MMCM_DIVCLK_DIVIDE {3} \
CONFIG.PRIMITIVE {PLL} CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} CONFIG.USE_LOCKED {false} \
CONFIG.USE_PHASE_ALIGNMENT {false} CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: fake_rd_interface_0, and set properties
  set fake_rd_interface_0 [ create_bd_cell -type ip -vlnv auger.org:auger:fake_rd_interface:1.0 fake_rd_interface_0 ]

  # Create instance: xlconstant_5, and set properties
  set xlconstant_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_5 ]
  set_property -dict [ list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}  ] $xlconstant_5

  # Create instance: xlconstant_6, and set properties
  set xlconstant_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_6 ]
  set_property -dict [ list CONFIG.CONST_VAL {15} CONFIG.CONST_WIDTH {4}  ] $xlconstant_6

  # Create instance: xlconstant_7, and set properties
  set xlconstant_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_7 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {4}  ] $xlconstant_7

  # Create interface connections
  connect_bd_intf_net -intf_net FAKE_RD_DATA_1 [get_bd_intf_pins FAKE_RD_DATA] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net RD_DATA0_1 [get_bd_intf_pins RD_DATA0] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
  connect_bd_intf_net -intf_net SOO_AXI_1 [get_bd_intf_pins SOO_AXI] [get_bd_intf_pins fake_rd_interface_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net ENABLE_XFR_IN_1 [get_bd_pins ENABLE_XFR_IN] [get_bd_pins fake_rd_interface_0/ENABLE_XFR_IN]
  connect_bd_net -net FAKE_RD_CLK_1 [get_bd_pins FAKE_RD_CLK] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net RST_1 [get_bd_pins RST] [get_bd_pins blk_mem_gen_0/rstb] [get_bd_pins blk_mem_gen_1/rstb]
  connect_bd_net -net S00_AXI_ACLK_1 [get_bd_pins S00_AXI_ACLK] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins fake_rd_interface_0/s00_axi_aclk]
  connect_bd_net -net S00_AXI_ARESETN_1 [get_bd_pins S00_AXI_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins fake_rd_interface_0/s00_axi_aresetn]
  connect_bd_net -net SERIAL_CLK_IN_1 [get_bd_pins SERIAL_CLK_IN] [get_bd_pins blk_mem_gen_1/clkb] [get_bd_pins fake_rd_interface_0/SERIAL_CLK_IN]
  connect_bd_net -net SERIAL_DATA0_IN_1 [get_bd_pins SERIAL_DATA0_IN] [get_bd_pins fake_rd_interface_0/SERIAL_DATA0_IN]
  connect_bd_net -net XFR_CLK_1 [get_bd_pins FAKE_RD_XFR_CLK] [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins fake_rd_interface_0/LOCAL_CLK]
  connect_bd_net -net blk_mem_gen_0_doutb [get_bd_pins blk_mem_gen_0/doutb] [get_bd_pins fake_rd_interface_0/FAKE_DATA]
  connect_bd_net -net fake_rd_interface_0_DATA_ADDR [get_bd_pins blk_mem_gen_1/addrb] [get_bd_pins fake_rd_interface_0/DATA_ADDR]
  connect_bd_net -net fake_rd_interface_0_DATA_TO_MEM [get_bd_pins blk_mem_gen_1/dinb] [get_bd_pins fake_rd_interface_0/DATA_TO_MEM]
  connect_bd_net -net fake_rd_interface_0_DEBUG1 [get_bd_pins DEBUG1] [get_bd_pins fake_rd_interface_0/DEBUG1]
  connect_bd_net -net fake_rd_interface_0_ENABLE_FAKE_XFR [get_bd_pins ENABLE_FAKE_XFR] [get_bd_pins fake_rd_interface_0/ENABLE_FAKE_XFR]
  connect_bd_net -net fake_rd_interface_0_ENABLE_MEM_WRT [get_bd_pins DEBUG2] [get_bd_pins blk_mem_gen_1/enb] [get_bd_pins fake_rd_interface_0/ENABLE_MEM_WRT]
  connect_bd_net -net fake_rd_interface_0_FAKE_DATA_ADDR [get_bd_pins blk_mem_gen_0/addrb] [get_bd_pins fake_rd_interface_0/FAKE_DATA_ADDR]
  connect_bd_net -net fake_rd_interface_0_SERIAL_FAKE_OUT [get_bd_pins SERIAL_FAKE_OUT] [get_bd_pins fake_rd_interface_0/SERIAL_FAKE_OUT]
  connect_bd_net -net xlconstant_5_dout [get_bd_pins blk_mem_gen_0/enb] [get_bd_pins xlconstant_5/dout]
  connect_bd_net -net xlconstant_6_dout [get_bd_pins blk_mem_gen_1/web] [get_bd_pins xlconstant_6/dout]
  connect_bd_net -net xlconstant_7_dout [get_bd_pins blk_mem_gen_0/web] [get_bd_pins xlconstant_7/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: adc_inputs
proc create_hier_cell_adc_inputs { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_adc_inputs() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 -type clk CLK120
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK0_N
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK0_P
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK1_N
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK1_P
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK2_N
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK2_P
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK3_N
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK3_P
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK4_N
  create_bd_pin -dir I -from 0 -to 0 IBUF_CK4_P
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS0_N
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS0_P
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS1_N
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS1_P
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS2_N
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS2_P
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS3_N
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS3_P
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS4_N
  create_bd_pin -dir I -from 11 -to 0 IBUF_DS4_P
  create_bd_pin -dir O -from 23 -to 0 SYNC_OUT0
  create_bd_pin -dir O -from 23 -to 0 SYNC_OUT1
  create_bd_pin -dir O -from 23 -to 0 SYNC_OUT2
  create_bd_pin -dir O -from 23 -to 0 SYNC_OUT3
  create_bd_pin -dir O -from 23 -to 0 SYNC_OUT4

  # Create instance: ddr_synchronizer_24bit_0, and set properties
  set ddr_synchronizer_24bit_0 [ create_bd_cell -type ip -vlnv auger.org:auger:ddr_synchronizer_24bit:1.0 ddr_synchronizer_24bit_0 ]

  # Create instance: ddr_synchronizer_24bit_1, and set properties
  set ddr_synchronizer_24bit_1 [ create_bd_cell -type ip -vlnv auger.org:auger:ddr_synchronizer_24bit:1.0 ddr_synchronizer_24bit_1 ]

  # Create instance: ddr_synchronizer_24bit_2, and set properties
  set ddr_synchronizer_24bit_2 [ create_bd_cell -type ip -vlnv auger.org:auger:ddr_synchronizer_24bit:1.0 ddr_synchronizer_24bit_2 ]

  # Create instance: ddr_synchronizer_24bit_3, and set properties
  set ddr_synchronizer_24bit_3 [ create_bd_cell -type ip -vlnv auger.org:auger:ddr_synchronizer_24bit:1.0 ddr_synchronizer_24bit_3 ]

  # Create instance: ddr_synchronizer_24bit_4, and set properties
  set ddr_synchronizer_24bit_4 [ create_bd_cell -type ip -vlnv auger.org:auger:ddr_synchronizer_24bit:1.0 ddr_synchronizer_24bit_4 ]

  # Create instance: util_ds_buf_1, and set properties
  set util_ds_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_1 ]
  set_property -dict [ list CONFIG.C_SIZE {12}  ] $util_ds_buf_1

  # Create instance: util_ds_buf_2, and set properties
  set util_ds_buf_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_2 ]

  # Create instance: util_ds_buf_3, and set properties
  set util_ds_buf_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_3 ]
  set_property -dict [ list CONFIG.C_SIZE {12}  ] $util_ds_buf_3

  # Create instance: util_ds_buf_4, and set properties
  set util_ds_buf_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_4 ]

  # Create instance: util_ds_buf_5, and set properties
  set util_ds_buf_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_5 ]

  # Create instance: util_ds_buf_6, and set properties
  set util_ds_buf_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_6 ]
  set_property -dict [ list CONFIG.C_SIZE {12}  ] $util_ds_buf_6

  # Create instance: util_ds_buf_7, and set properties
  set util_ds_buf_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_7 ]

  # Create instance: util_ds_buf_8, and set properties
  set util_ds_buf_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_8 ]
  set_property -dict [ list CONFIG.C_SIZE {12}  ] $util_ds_buf_8

  # Create instance: util_ds_buf_10, and set properties
  set util_ds_buf_10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_10 ]
  set_property -dict [ list CONFIG.C_SIZE {12}  ] $util_ds_buf_10

  # Create instance: util_ds_buf_11, and set properties
  set util_ds_buf_11 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_11 ]

  # Create port connections
  connect_bd_net -net ADC0_CK_N_1 [get_bd_pins IBUF_CK1_N] [get_bd_pins util_ds_buf_2/IBUF_DS_N]
  connect_bd_net -net ADC0_CK_P_2 [get_bd_pins IBUF_CK1_P] [get_bd_pins util_ds_buf_2/IBUF_DS_P]
  connect_bd_net -net ADC1_CK_N_1 [get_bd_pins IBUF_CK0_N] [get_bd_pins util_ds_buf_4/IBUF_DS_N]
  connect_bd_net -net ADC1_CK_P_1 [get_bd_pins IBUF_CK0_P] [get_bd_pins util_ds_buf_4/IBUF_DS_P]
  connect_bd_net -net ADC2_CK_N_1 [get_bd_pins IBUF_CK2_N] [get_bd_pins util_ds_buf_5/IBUF_DS_N]
  connect_bd_net -net ADC2_CK_P_1 [get_bd_pins IBUF_CK2_P] [get_bd_pins util_ds_buf_5/IBUF_DS_P]
  connect_bd_net -net ADC3_CK_N_1 [get_bd_pins IBUF_CK3_N] [get_bd_pins util_ds_buf_7/IBUF_DS_N]
  connect_bd_net -net ADC3_CK_P_1 [get_bd_pins IBUF_CK3_P] [get_bd_pins util_ds_buf_7/IBUF_DS_P]
  connect_bd_net -net ADC4_CK_N_1 [get_bd_pins IBUF_CK4_N] [get_bd_pins util_ds_buf_11/IBUF_DS_N]
  connect_bd_net -net ADC4_CK_P_1 [get_bd_pins IBUF_CK4_P] [get_bd_pins util_ds_buf_11/IBUF_DS_P]
  connect_bd_net -net In_regional_ck_0_IBUF_OUT [get_bd_pins CLK120] [get_bd_pins ddr_synchronizer_24bit_0/CLK] [get_bd_pins ddr_synchronizer_24bit_1/CLK] [get_bd_pins ddr_synchronizer_24bit_2/CLK] [get_bd_pins ddr_synchronizer_24bit_3/CLK] [get_bd_pins ddr_synchronizer_24bit_4/CLK]
  connect_bd_net -net adc0_n_2 [get_bd_pins IBUF_DS1_N] [get_bd_pins util_ds_buf_1/IBUF_DS_N]
  connect_bd_net -net adc0_p_1 [get_bd_pins IBUF_DS1_P] [get_bd_pins util_ds_buf_1/IBUF_DS_P]
  connect_bd_net -net adc1_n_1 [get_bd_pins IBUF_DS0_N] [get_bd_pins util_ds_buf_3/IBUF_DS_N]
  connect_bd_net -net adc1_p_1 [get_bd_pins IBUF_DS0_P] [get_bd_pins util_ds_buf_3/IBUF_DS_P]
  connect_bd_net -net adc2_n_1 [get_bd_pins IBUF_DS2_N] [get_bd_pins util_ds_buf_8/IBUF_DS_N]
  connect_bd_net -net adc2_p_1 [get_bd_pins IBUF_DS2_P] [get_bd_pins util_ds_buf_8/IBUF_DS_P]
  connect_bd_net -net adc3_n_1 [get_bd_pins IBUF_DS3_N] [get_bd_pins util_ds_buf_6/IBUF_DS_N]
  connect_bd_net -net adc3_p_1 [get_bd_pins IBUF_DS3_P] [get_bd_pins util_ds_buf_6/IBUF_DS_P]
  connect_bd_net -net adc4_n_1 [get_bd_pins IBUF_DS4_N] [get_bd_pins util_ds_buf_10/IBUF_DS_N]
  connect_bd_net -net adc4_p_1 [get_bd_pins IBUF_DS4_P] [get_bd_pins util_ds_buf_10/IBUF_DS_P]
  connect_bd_net -net ddr_synchronizer_24bit_1_SYNC_OUT [get_bd_pins SYNC_OUT1] [get_bd_pins ddr_synchronizer_24bit_1/SYNC_OUT]
  connect_bd_net -net ddr_synchronizer_26bit_1_SYNC_OUT [get_bd_pins SYNC_OUT0] [get_bd_pins ddr_synchronizer_24bit_0/SYNC_OUT]
  connect_bd_net -net ddr_synchronizer_26bit_2_SYNC_OUT [get_bd_pins SYNC_OUT2] [get_bd_pins ddr_synchronizer_24bit_2/SYNC_OUT]
  connect_bd_net -net ddr_synchronizer_26bit_3_SYNC_OUT [get_bd_pins SYNC_OUT3] [get_bd_pins ddr_synchronizer_24bit_3/SYNC_OUT]
  connect_bd_net -net ddr_synchronizer_26bit_4_SYNC_OUT [get_bd_pins SYNC_OUT4] [get_bd_pins ddr_synchronizer_24bit_4/SYNC_OUT]
  connect_bd_net -net util_ds_buf_10_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_4/ASYNC_IN] [get_bd_pins util_ds_buf_10/IBUF_OUT]
  connect_bd_net -net util_ds_buf_11_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_4/DDR_CLK] [get_bd_pins util_ds_buf_11/IBUF_OUT]
  connect_bd_net -net util_ds_buf_1_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_1/ASYNC_IN] [get_bd_pins util_ds_buf_1/IBUF_OUT]
  connect_bd_net -net util_ds_buf_2_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_1/DDR_CLK] [get_bd_pins util_ds_buf_2/IBUF_OUT]
  connect_bd_net -net util_ds_buf_3_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_0/ASYNC_IN] [get_bd_pins util_ds_buf_3/IBUF_OUT]
  connect_bd_net -net util_ds_buf_4_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_0/DDR_CLK] [get_bd_pins util_ds_buf_4/IBUF_OUT]
  connect_bd_net -net util_ds_buf_5_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_2/DDR_CLK] [get_bd_pins util_ds_buf_5/IBUF_OUT]
  connect_bd_net -net util_ds_buf_6_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_3/ASYNC_IN] [get_bd_pins util_ds_buf_6/IBUF_OUT]
  connect_bd_net -net util_ds_buf_7_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_3/DDR_CLK] [get_bd_pins util_ds_buf_7/IBUF_OUT]
  connect_bd_net -net util_ds_buf_8_IBUF_OUT [get_bd_pins ddr_synchronizer_24bit_2/ASYNC_IN] [get_bd_pins util_ds_buf_8/IBUF_OUT]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set iic_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_rtl ]

  # Create ports
  set ADC0_CK_N [ create_bd_port -dir I -type clk ADC0_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC0_CK_N
  set ADC0_CK_P [ create_bd_port -dir I -type clk ADC0_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC0_CK_P
  set ADC1_CK_N [ create_bd_port -dir I -type clk ADC1_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC1_CK_N
  set ADC1_CK_P [ create_bd_port -dir I -type clk ADC1_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC1_CK_P
  set ADC2_CK_N [ create_bd_port -dir I -type clk ADC2_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC2_CK_N
  set ADC2_CK_P [ create_bd_port -dir I -type clk ADC2_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC2_CK_P
  set ADC3_CK_N [ create_bd_port -dir I -type clk ADC3_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC3_CK_N
  set ADC3_CK_P [ create_bd_port -dir I -type clk ADC3_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC3_CK_P
  set ADC4_CK_N [ create_bd_port -dir I -type clk ADC4_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC4_CK_N
  set ADC4_CK_P [ create_bd_port -dir I -type clk ADC4_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $ADC4_CK_P
  set ADC_PWD [ create_bd_port -dir O ADC_PWD ]
  set AMIGA_CLOCK_OUT [ create_bd_port -dir O AMIGA_CLOCK_OUT ]
  set AMIGA_LTS_OUT [ create_bd_port -dir O AMIGA_LTS_OUT ]
  set AMIGA_RX [ create_bd_port -dir I AMIGA_RX ]
  set AMIGA_TX [ create_bd_port -dir O AMIGA_TX ]
  set ENABLE_RD_XFR [ create_bd_port -dir I ENABLE_RD_XFR ]
  set ENABLE_RD_XFR_CTL [ create_bd_port -dir O -from 0 -to 0 ENABLE_RD_XFR_CTL ]
  set EXT0_DAT4 [ create_bd_port -dir O -from 0 -to 0 EXT0_DAT4 ]
  set EXT0_DAT5 [ create_bd_port -dir O -from 0 -to 0 EXT0_DAT5 ]
  set EXT0_DAT6 [ create_bd_port -dir O -from 0 -to 0 EXT0_DAT6 ]
  set EXT0_DAT7 [ create_bd_port -dir O -from 0 -to 0 EXT0_DAT7 ]
  set FAKE_ENABLE_RD_XFR [ create_bd_port -dir O FAKE_ENABLE_RD_XFR ]
  set FAKE_ENABLE_RD_XFR_CTL [ create_bd_port -dir O -from 0 -to 0 FAKE_ENABLE_RD_XFR_CTL ]
  set FAKE_RD_SER_DATA0 [ create_bd_port -dir O FAKE_RD_SER_DATA0 ]
  set FAKE_RD_SER_DATA0_CTL [ create_bd_port -dir O -from 0 -to 0 FAKE_RD_SER_DATA0_CTL ]
  set FAKE_RD_SER_DATA1 [ create_bd_port -dir O FAKE_RD_SER_DATA1 ]
  set FAKE_RD_SER_DATA1_CTL [ create_bd_port -dir O -from 0 -to 0 FAKE_RD_SER_DATA1_CTL ]
  set FAKE_RD_XFR_CLK [ create_bd_port -dir O FAKE_RD_XFR_CLK ]
  set FAKE_RD_XFR_CLK_CTL [ create_bd_port -dir O -from 0 -to 0 FAKE_RD_XFR_CLK_CTL ]
  set FPGA_CK_N [ create_bd_port -dir I -type clk FPGA_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $FPGA_CK_N
  set FPGA_CK_P [ create_bd_port -dir I -type clk FPGA_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $FPGA_CK_P
  set GPS_PPS [ create_bd_port -dir I GPS_PPS ]
  set GPS_RX [ create_bd_port -dir I GPS_RX ]
  set GPS_TX [ create_bd_port -dir O GPS_TX ]
  set HCONF0 [ create_bd_port -dir I HCONF0 ]
  set HCONF1 [ create_bd_port -dir I HCONF1 ]
  set HCONF2 [ create_bd_port -dir I HCONF2 ]
  set HCONF3 [ create_bd_port -dir I HCONF3 ]
  set HCONF4 [ create_bd_port -dir I HCONF4 ]
  set HCONF5 [ create_bd_port -dir I HCONF5 ]
  set LED_ASY [ create_bd_port -dir O -from 0 -to 0 LED_ASY ]
  set LED_FLG [ create_bd_port -dir I LED_FLG ]
  set P61 [ create_bd_port -dir O P61 ]
  set P62 [ create_bd_port -dir O P62 ]
  set P63 [ create_bd_port -dir O P63 ]
  set P65 [ create_bd_port -dir O P65 ]
  set RADIO_CTS [ create_bd_port -dir I RADIO_CTS ]
  set RADIO_RST_IN [ create_bd_port -dir I RADIO_RST_IN ]
  set RADIO_RST_OUT [ create_bd_port -dir O RADIO_RST_OUT ]
  set RADIO_RTS [ create_bd_port -dir O RADIO_RTS ]
  set RD_SER_DATA0 [ create_bd_port -dir I RD_SER_DATA0 ]
  set RD_SER_DATA0_CTL [ create_bd_port -dir O -from 0 -to 0 RD_SER_DATA0_CTL ]
  set RD_SER_DATA1 [ create_bd_port -dir I RD_SER_DATA1 ]
  set RD_SER_DATA1_CTL [ create_bd_port -dir O -from 0 -to 0 RD_SER_DATA1_CTL ]
  set RD_XFR_CLK [ create_bd_port -dir I -type clk RD_XFR_CLK ]
  set RD_XFR_CLK_CTL [ create_bd_port -dir O -from 0 -to 0 RD_XFR_CLK_CTL ]
  set TRIG_IN [ create_bd_port -dir I TRIG_IN ]
  set TRIG_OUT [ create_bd_port -dir O TRIG_OUT ]
  set USB_IFAULT [ create_bd_port -dir I USB_IFAULT ]
  set WATCHDOG [ create_bd_port -dir IO WATCHDOG ]
  set adc0_n [ create_bd_port -dir I -from 11 -to 0 adc0_n ]
  set adc0_p [ create_bd_port -dir I -from 11 -to 0 adc0_p ]
  set adc1_n [ create_bd_port -dir I -from 11 -to 0 -type data adc1_n ]
  set adc1_p [ create_bd_port -dir I -from 11 -to 0 -type data adc1_p ]
  set adc2_n [ create_bd_port -dir I -from 11 -to 0 -type data adc2_n ]
  set adc2_p [ create_bd_port -dir I -from 11 -to 0 -type data adc2_p ]
  set adc3_n [ create_bd_port -dir I -from 11 -to 0 -type data adc3_n ]
  set adc3_p [ create_bd_port -dir I -from 11 -to 0 -type data adc3_p ]
  set adc4_n [ create_bd_port -dir I -from 11 -to 0 -type data adc4_n ]
  set adc4_p [ create_bd_port -dir I -from 11 -to 0 -type data adc4_p ]
  set ext0_ctl [ create_bd_port -dir O -from 7 -to 0 ext0_ctl ]

  # Create instance: adc_inputs
  create_hier_cell_adc_inputs [current_bd_instance .] adc_inputs

  # Create instance: amiga_trigger_0, and set properties
  set amiga_trigger_0 [ create_bd_cell -type ip -vlnv user.org:user:amiga_trigger:1.0 amiga_trigger_0 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]

  # Create instance: axi_uartlite_1, and set properties
  set axi_uartlite_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_1 ]

  # Create instance: clock_1pps_0, and set properties
  set clock_1pps_0 [ create_bd_cell -type ip -vlnv auger.org:dfnitz:clock_1pps:1.0 clock_1pps_0 ]

  # Create instance: fake_rd_block
  create_hier_cell_fake_rd_block [current_bd_instance .] fake_rd_block

  # Create instance: filter_block
  create_hier_cell_filter_block [current_bd_instance .] filter_block

  # Create instance: iic_filter_0, and set properties
  set iic_filter_0 [ create_bd_cell -type ip -vlnv auger.org:auger:iic_filter:1.0 iic_filter_0 ]

  # Create instance: interface_uub_dfn3_0, and set properties
  set interface_uub_dfn3_0 [ create_bd_cell -type ip -vlnv auger.org:auger:interface_uub_dfn3:1.0 interface_uub_dfn3_0 ]

  # Create instance: test_control_block
  create_hier_cell_test_control_block [current_bd_instance .] test_control_block

  # Create instance: time_tagging_0, and set properties
  set time_tagging_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:time_tagging:1.0 time_tagging_0 ]

  # Create instance: trigger_memory_block
  create_hier_cell_trigger_memory_block [current_bd_instance .] trigger_memory_block

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list CONFIG.C_BUF_TYPE {IBUFDS}  ] $util_ds_buf_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {1}  ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list CONFIG.CONST_VAL {251} CONFIG.CONST_WIDTH {8}  ] $xlconstant_1

  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {1}  ] $xlconstant_2

  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
  set_property -dict [ list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}  ] $xlconstant_3

  # Create instance: xlconstant_4, and set properties
  set xlconstant_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_4 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {8}  ] $xlconstant_4

  # Create instance: zync_block
  create_hier_cell_zync_block [current_bd_instance .] zync_block

  # Create interface connections
  connect_bd_intf_net -intf_net SHWR_MEM0P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM0P] [get_bd_intf_pins zync_block/SHWR_MEM0P]
  connect_bd_intf_net -intf_net SHWR_MEM1P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM1P] [get_bd_intf_pins zync_block/SHWR_MEM1P]
  connect_bd_intf_net -intf_net SHWR_MEM2P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM2P] [get_bd_intf_pins zync_block/SHWR_MEM2P]
  connect_bd_intf_net -intf_net SHWR_MEM3P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM3P] [get_bd_intf_pins zync_block/SHWR_MEM3P]
  connect_bd_intf_net -intf_net SHWR_MEM4P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM4P] [get_bd_intf_pins zync_block/SHWR_MEM4P]
  connect_bd_intf_net -intf_net axi_interconnect_0_M05_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins zync_block/M05_AXI]
  connect_bd_intf_net -intf_net iic_filter_0_iic_m [get_bd_intf_ports iic_rtl] [get_bd_intf_pins iic_filter_0/iic_m]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins zync_block/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins zync_block/FIXED_IO]
  connect_bd_intf_net -intf_net zync_block_AMIGA_UART_IFC [get_bd_intf_pins axi_uartlite_1/S_AXI] [get_bd_intf_pins zync_block/AMIGA_UART_IFC]
  connect_bd_intf_net -intf_net zync_block_FAKE_MEM0 [get_bd_intf_pins test_control_block/FAKE_MEM0] [get_bd_intf_pins zync_block/FAKE_MEM0]
  connect_bd_intf_net -intf_net zync_block_FAKE_MEM1 [get_bd_intf_pins test_control_block/FAKE_MEM1] [get_bd_intf_pins zync_block/FAKE_MEM1]
  connect_bd_intf_net -intf_net zync_block_IIC [get_bd_intf_pins iic_filter_0/iic_s] [get_bd_intf_pins zync_block/IIC]
  connect_bd_intf_net -intf_net zync_block_M01_AXI [get_bd_intf_pins trigger_memory_block/SHWR_INTR_IFC] [get_bd_intf_pins zync_block/M01_AXI]
  connect_bd_intf_net -intf_net zync_block_M02_AXI [get_bd_intf_pins trigger_memory_block/TRIGGER_IFC] [get_bd_intf_pins zync_block/M02_AXI]
  connect_bd_intf_net -intf_net zync_block_M03_AXI [get_bd_intf_pins time_tagging_0/S00_AXI] [get_bd_intf_pins zync_block/M03_AXI]
  connect_bd_intf_net -intf_net zync_block_M04_AXI [get_bd_intf_pins interface_uub_dfn3_0/S00_AXI] [get_bd_intf_pins zync_block/M04_AXI]
  connect_bd_intf_net -intf_net zync_block_M06_AXI [get_bd_intf_pins test_control_block/S00_AXI] [get_bd_intf_pins zync_block/M06_AXI]
  connect_bd_intf_net -intf_net zync_block_MUON_INTR_IFC [get_bd_intf_pins trigger_memory_block/MUON_INTR_IFC] [get_bd_intf_pins zync_block/MUON_INTR_IFC]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM [get_bd_intf_pins trigger_memory_block/MUON_MEM0] [get_bd_intf_pins zync_block/MUON_MEM0]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM0_PDT [get_bd_intf_pins trigger_memory_block/MUON_MEM0P] [get_bd_intf_pins zync_block/MUON_MEM0P]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM1 [get_bd_intf_pins trigger_memory_block/MUON_MEM1] [get_bd_intf_pins zync_block/MUON_MEM1]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM1P [get_bd_intf_pins trigger_memory_block/MUON_MEM1P] [get_bd_intf_pins zync_block/MUON_MEM1P]
  connect_bd_intf_net -intf_net zync_block_RD_IFC [get_bd_intf_pins fake_rd_block/SOO_AXI] [get_bd_intf_pins zync_block/RD_IFC]
  connect_bd_intf_net -intf_net zync_block_RD_MEM0P [get_bd_intf_pins fake_rd_block/RD_DATA0] [get_bd_intf_pins zync_block/RD_MEM0P]
  connect_bd_intf_net -intf_net zync_block_RD_MEM1P [get_bd_intf_pins fake_rd_block/FAKE_RD_DATA] [get_bd_intf_pins zync_block/RD_MEM1P]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM0 [get_bd_intf_pins trigger_memory_block/SHWR_MEM0] [get_bd_intf_pins zync_block/SHWR_MEM0]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM1] [get_bd_intf_pins zync_block/SHWR_MEM1]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM2 [get_bd_intf_pins trigger_memory_block/SHWR_MEM2] [get_bd_intf_pins zync_block/SHWR_MEM2]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM3 [get_bd_intf_pins trigger_memory_block/SHWR_MEM3] [get_bd_intf_pins zync_block/SHWR_MEM3]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM4 [get_bd_intf_pins trigger_memory_block/SHWR_MEM4] [get_bd_intf_pins zync_block/SHWR_MEM4]

  # Create port connections
  connect_bd_net -net ADC0_CK_N_1 [get_bd_ports ADC0_CK_N] [get_bd_pins adc_inputs/IBUF_CK0_N]
  connect_bd_net -net ADC0_CK_P_1 [get_bd_ports ADC0_CK_P] [get_bd_pins adc_inputs/IBUF_CK0_P]
  connect_bd_net -net ADC1_1 [get_bd_pins filter_block/IN1] [get_bd_pins test_control_block/ADC1_OUT] [get_bd_pins trigger_memory_block/ADC1]
  connect_bd_net -net ADC1_CK_N_1 [get_bd_ports ADC1_CK_N] [get_bd_pins adc_inputs/IBUF_CK1_N]
  connect_bd_net -net ADC1_CK_P_1 [get_bd_ports ADC1_CK_P] [get_bd_pins adc_inputs/IBUF_CK1_P]
  connect_bd_net -net ADC2_1 [get_bd_pins filter_block/IN2] [get_bd_pins test_control_block/ADC2_OUT] [get_bd_pins trigger_memory_block/ADC2]
  connect_bd_net -net ADC2_CK_N_1 [get_bd_ports ADC2_CK_N] [get_bd_pins adc_inputs/IBUF_CK2_N]
  connect_bd_net -net ADC2_CK_P_1 [get_bd_ports ADC2_CK_P] [get_bd_pins adc_inputs/IBUF_CK2_P]
  connect_bd_net -net ADC3_1 [get_bd_pins test_control_block/ADC3_OUT] [get_bd_pins trigger_memory_block/ADC3]
  connect_bd_net -net ADC3_CK_N_1 [get_bd_ports ADC3_CK_N] [get_bd_pins adc_inputs/IBUF_CK3_N]
  connect_bd_net -net ADC3_CK_P_1 [get_bd_ports ADC3_CK_P] [get_bd_pins adc_inputs/IBUF_CK3_P]
  connect_bd_net -net ADC4_1 [get_bd_pins test_control_block/ADC4_OUT] [get_bd_pins trigger_memory_block/ADC4]
  connect_bd_net -net ADC4_CK_N_1 [get_bd_ports ADC4_CK_N] [get_bd_pins adc_inputs/IBUF_CK4_N]
  connect_bd_net -net ADC4_CK_P_1 [get_bd_ports ADC4_CK_P] [get_bd_pins adc_inputs/IBUF_CK4_P]
  connect_bd_net -net AMIGA_RX_1 [get_bd_ports AMIGA_RX] [get_bd_pins axi_uartlite_1/rx]
  connect_bd_net -net ENABLE_RD_XFR_1 [get_bd_ports ENABLE_RD_XFR] [get_bd_pins fake_rd_block/ENABLE_XFR_IN]
  connect_bd_net -net FPGA_CK_N_1 [get_bd_ports FPGA_CK_N] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
  connect_bd_net -net FPGA_CK_P_1 [get_bd_ports FPGA_CK_P] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
  connect_bd_net -net GPS_PPS_1 [get_bd_ports GPS_PPS] [get_bd_pins test_control_block/TRUE_PPS]
  connect_bd_net -net GPS_UART_INT_1 [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins zync_block/GPS_UART_INT]
  connect_bd_net -net In_regional_ck_0_IBUF_OUT [get_bd_pins adc_inputs/CLK120] [get_bd_pins amiga_trigger_0/clock_120M] [get_bd_pins clock_1pps_0/CLK120] [get_bd_pins fake_rd_block/FAKE_RD_CLK] [get_bd_pins filter_block/CLK] [get_bd_pins iic_filter_0/Sysclk] [get_bd_pins interface_uub_dfn3_0/CLK120] [get_bd_pins test_control_block/CLK] [get_bd_pins time_tagging_0/clk_120m] [get_bd_pins trigger_memory_block/TRIGGER_CLK] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  connect_bd_net -net LED_FLG_1 [get_bd_ports LED_FLG] [get_bd_pins trigger_memory_block/LED_FLG]
  connect_bd_net -net Net [get_bd_ports WATCHDOG] [get_bd_pins interface_uub_dfn3_0/WATCHDOG]
  connect_bd_net -net RADIO_CTS_1 [get_bd_ports RADIO_CTS] [get_bd_pins zync_block/RADIO_CTS]
  connect_bd_net -net RADIO_RST_IN_1 [get_bd_ports RADIO_RST_IN] [get_bd_pins interface_uub_dfn3_0/RADIO_RST_IN]
  connect_bd_net -net RD_SER_DATA0_1 [get_bd_ports RD_SER_DATA0] [get_bd_pins fake_rd_block/SERIAL_DATA0_IN]
  connect_bd_net -net RD_XFR_CLK_1 [get_bd_ports RD_XFR_CLK] [get_bd_pins fake_rd_block/SERIAL_CLK_IN]
  connect_bd_net -net RST_1 [get_bd_pins fake_rd_block/RST] [get_bd_pins zync_block/RD_RST]
  connect_bd_net -net TRIG_IN_1 [get_bd_ports TRIG_IN] [get_bd_pins trigger_memory_block/TRIG_IN]
  connect_bd_net -net USB_IFAULT_1 [get_bd_ports USB_IFAULT] [get_bd_pins interface_uub_dfn3_0/USB_IFAULT]
  connect_bd_net -net adc0_n_1 [get_bd_ports adc0_n] [get_bd_pins adc_inputs/IBUF_DS0_N]
  connect_bd_net -net adc0_p_1 [get_bd_ports adc0_p] [get_bd_pins adc_inputs/IBUF_DS0_P]
  connect_bd_net -net adc1_n_1 [get_bd_ports adc1_n] [get_bd_pins adc_inputs/IBUF_DS1_N]
  connect_bd_net -net adc1_p_1 [get_bd_ports adc1_p] [get_bd_pins adc_inputs/IBUF_DS1_P]
  connect_bd_net -net adc2_n_1 [get_bd_ports adc2_n] [get_bd_pins adc_inputs/IBUF_DS2_N]
  connect_bd_net -net adc2_p_1 [get_bd_ports adc2_p] [get_bd_pins adc_inputs/IBUF_DS2_P]
  connect_bd_net -net adc3_n_1 [get_bd_ports adc3_n] [get_bd_pins adc_inputs/IBUF_DS3_N]
  connect_bd_net -net adc3_p_1 [get_bd_ports adc3_p] [get_bd_pins adc_inputs/IBUF_DS3_P]
  connect_bd_net -net adc4_n_1 [get_bd_ports adc4_n] [get_bd_pins adc_inputs/IBUF_DS4_N]
  connect_bd_net -net adc4_p_1 [get_bd_ports adc4_p] [get_bd_pins adc_inputs/IBUF_DS4_P]
  connect_bd_net -net adc_inputs_SYNC_OUT0 [get_bd_pins adc_inputs/SYNC_OUT0] [get_bd_pins test_control_block/ADC0_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT1 [get_bd_pins adc_inputs/SYNC_OUT1] [get_bd_pins test_control_block/ADC1_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT2 [get_bd_pins adc_inputs/SYNC_OUT2] [get_bd_pins test_control_block/ADC2_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT3 [get_bd_pins adc_inputs/SYNC_OUT3] [get_bd_pins test_control_block/ADC3_IN]
  connect_bd_net -net adc_inputs_SYNC_OUT4 [get_bd_pins adc_inputs/SYNC_OUT4] [get_bd_pins test_control_block/ADC4_IN]
  connect_bd_net -net amiga_trigger_0_clock_out [get_bd_ports AMIGA_CLOCK_OUT] [get_bd_pins amiga_trigger_0/clock_out]
  connect_bd_net -net amiga_trigger_0_lts_out [get_bd_ports AMIGA_LTS_OUT] [get_bd_pins amiga_trigger_0/lts_out]
  connect_bd_net -net axi_uartlite_0_tx [get_bd_ports GPS_TX] [get_bd_pins axi_uartlite_0/tx]
  connect_bd_net -net axi_uartlite_1_interrupt [get_bd_pins axi_uartlite_1/interrupt] [get_bd_pins zync_block/AMIGA_UART_INT]
  connect_bd_net -net axi_uartlite_1_tx [get_bd_ports AMIGA_TX] [get_bd_pins axi_uartlite_1/tx]
  connect_bd_net -net clock_1pps_0_CLK1PPS [get_bd_pins clock_1pps_0/CLK1PPS] [get_bd_pins test_control_block/FAKE_PPS]
  connect_bd_net -net fake_rd_block_ENABLE_FAKE_XFR [get_bd_ports FAKE_ENABLE_RD_XFR] [get_bd_pins fake_rd_block/ENABLE_FAKE_XFR]
  connect_bd_net -net fake_rd_block_FAKE_RD_XFR_CLK [get_bd_ports FAKE_RD_XFR_CLK] [get_bd_pins fake_rd_block/FAKE_RD_XFR_CLK]
  connect_bd_net -net fake_rd_block_SERIAL_FAKE_OUT [get_bd_ports FAKE_RD_SER_DATA0] [get_bd_pins fake_rd_block/SERIAL_FAKE_OUT]
  connect_bd_net -net fake_signal_0_ADC0_OUT [get_bd_pins filter_block/IN0] [get_bd_pins test_control_block/ADC0_OUT] [get_bd_pins trigger_memory_block/ADC0]
  connect_bd_net -net filter_block_OUT0 [get_bd_pins filter_block/OUT0] [get_bd_pins trigger_memory_block/FILT_PMT0]
  connect_bd_net -net filter_block_OUT1 [get_bd_pins filter_block/OUT1] [get_bd_pins trigger_memory_block/FILT_PMT1]
  connect_bd_net -net filter_block_OUT2 [get_bd_pins filter_block/OUT2] [get_bd_pins trigger_memory_block/FILT_PMT2]
  connect_bd_net -net interface_uub_dfn3_0_ADC_PWD [get_bd_ports ADC_PWD] [get_bd_pins interface_uub_dfn3_0/ADC_PWD]
  connect_bd_net -net interface_uub_dfn3_0_P65 [get_bd_ports P65] [get_bd_pins interface_uub_dfn3_0/P65]
  connect_bd_net -net interface_uub_dfn3_0_RADIO_RST_OUT [get_bd_ports RADIO_RST_OUT] [get_bd_pins interface_uub_dfn3_0/RADIO_RST_OUT]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins amiga_trigger_0/resetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins axi_uartlite_1/s_axi_aresetn] [get_bd_pins fake_rd_block/S00_AXI_ARESETN] [get_bd_pins iic_filter_0/Rst] [get_bd_pins interface_uub_dfn3_0/s00_axi_aresetn] [get_bd_pins test_control_block/s00_axi_aresetn] [get_bd_pins time_tagging_0/s00_axi_aresetn] [get_bd_pins trigger_memory_block/S_AXI_ARESETN] [get_bd_pins zync_block/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins test_control_block/RST] [get_bd_pins trigger_memory_block/RST] [get_bd_pins zync_block/peripheral_reset]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins axi_uartlite_1/s_axi_aclk] [get_bd_pins fake_rd_block/S00_AXI_ACLK] [get_bd_pins interface_uub_dfn3_0/s00_axi_aclk] [get_bd_pins test_control_block/s00_axi_aclk] [get_bd_pins time_tagging_0/s00_axi_aclk] [get_bd_pins trigger_memory_block/S_AXI_CLK] [get_bd_pins zync_block/FCLK_CLK0]
  connect_bd_net -net rx_1 [get_bd_ports GPS_RX] [get_bd_pins axi_uartlite_0/rx]
  connect_bd_net -net test_control_0_PPS [get_bd_pins test_control_block/PPS] [get_bd_pins time_tagging_0/pps] [get_bd_pins trigger_memory_block/ONE_PPS]
  connect_bd_net -net trigger_memory_0_DEAD [get_bd_pins time_tagging_0/dead] [get_bd_pins trigger_memory_block/DEAD]
  connect_bd_net -net trigger_memory_0_IRQ [get_bd_pins trigger_memory_block/SHWR_IRQ] [get_bd_pins zync_block/SHWR_INT]
  connect_bd_net -net trigger_memory_0_MUON_BUF_RNUM [get_bd_pins time_tagging_0/address_rmb] [get_bd_pins trigger_memory_block/MUON_BUF_RNUM]
  connect_bd_net -net trigger_memory_0_MUON_BUF_WNUM [get_bd_pins time_tagging_0/address_wmb] [get_bd_pins trigger_memory_block/MUON_BUF_WNUM]
  connect_bd_net -net trigger_memory_0_MUON_TRIGGER [get_bd_pins time_tagging_0/evtclks] [get_bd_pins trigger_memory_block/MUON_TRIGGER]
  connect_bd_net -net trigger_memory_0_SHWR_BUF_RNUM [get_bd_pins time_tagging_0/address_rsb] [get_bd_pins trigger_memory_block/SHWR_BUF_RNUM]
  connect_bd_net -net trigger_memory_0_SHWR_BUF_WNUM [get_bd_pins time_tagging_0/address_wsb] [get_bd_pins trigger_memory_block/SHWR_BUF_WNUM]
  connect_bd_net -net trigger_memory_0_SHWR_EVT_CTR [get_bd_pins time_tagging_0/evtcnt] [get_bd_pins trigger_memory_block/SHWR_EVT_CTR]
  connect_bd_net -net trigger_memory_0_SHWR_TRIGGER [get_bd_pins time_tagging_0/evtclkf] [get_bd_pins trigger_memory_block/SHWR_TRIGGER]
  connect_bd_net -net trigger_memory_block_LEDBAR [get_bd_ports LED_ASY] [get_bd_pins trigger_memory_block/LED]
  connect_bd_net -net trigger_memory_block_MUON_EVT_CTR [get_bd_pins time_tagging_0/evtcntm] [get_bd_pins trigger_memory_block/MUON_EVT_CTR]
  connect_bd_net -net trigger_memory_block_MUON_IRQ [get_bd_pins trigger_memory_block/MUON_IRQ] [get_bd_pins zync_block/MUON_INT]
  connect_bd_net -net trigger_memory_block_SHWR_EVT_ID [get_bd_pins amiga_trigger_0/lts_in] [get_bd_pins trigger_memory_block/SHWR_EVT_ID]
  connect_bd_net -net trigger_memory_block_TRIG_OUT [get_bd_ports TRIG_OUT] [get_bd_pins amiga_trigger_0/trigger] [get_bd_pins trigger_memory_block/TRIG_OUT]
  connect_bd_net -net xlconstant_0_dout [get_bd_ports ENABLE_RD_XFR_CTL] [get_bd_ports RD_SER_DATA0_CTL] [get_bd_ports RD_SER_DATA1_CTL] [get_bd_ports RD_XFR_CLK_CTL] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_ports ext0_ctl] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_ports EXT0_DAT4] [get_bd_ports EXT0_DAT5] [get_bd_ports EXT0_DAT6] [get_bd_ports EXT0_DAT7] [get_bd_pins xlconstant_2/dout]
  connect_bd_net -net xlconstant_3_dout [get_bd_ports FAKE_ENABLE_RD_XFR_CTL] [get_bd_ports FAKE_RD_SER_DATA0_CTL] [get_bd_ports FAKE_RD_SER_DATA1_CTL] [get_bd_ports FAKE_RD_XFR_CLK_CTL] [get_bd_pins xlconstant_3/dout]
  connect_bd_net -net xlconstant_4_dout [get_bd_pins interface_uub_dfn3_0/HCONF] [get_bd_pins xlconstant_4/dout]
  connect_bd_net -net zync_block_DBG1 [get_bd_ports P61] [get_bd_pins zync_block/DBG1]
  connect_bd_net -net zync_block_DBG2 [get_bd_ports P62] [get_bd_pins zync_block/DBG2]
  connect_bd_net -net zync_block_DBG3 [get_bd_ports P63] [get_bd_pins zync_block/DBG3]
  connect_bd_net -net zync_block_RADIO_RTS [get_bd_ports RADIO_RTS] [get_bd_pins zync_block/RADIO_RTS]

  # Create address segments
  create_bd_addr_seg -range 0x8000 -offset 0x44000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x44000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x46000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x46000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x48000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x48000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4A000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4A000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4C000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4C000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs zync_block/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs zync_block/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000 -offset 0x40000000 [get_bd_addr_spaces zync_block/axi_cdma_1/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x40000000 [get_bd_addr_spaces zync_block/axi_cdma_1/Data_SG] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x42000000 [get_bd_addr_spaces zync_block/axi_cdma_1/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x42000000 [get_bd_addr_spaces zync_block/axi_cdma_1/Data_SG] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces zync_block/axi_cdma_1/Data] [get_bd_addr_segs zync_block/processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces zync_block/axi_cdma_1/Data_SG] [get_bd_addr_segs zync_block/processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x2000 -offset 0x4E000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs test_control_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x52000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs fake_rd_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem01
  create_bd_addr_seg -range 0x20000 -offset 0x40000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem03
  create_bd_addr_seg -range 0x8000 -offset 0x44000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem07
  create_bd_addr_seg -range 0x2000 -offset 0x50000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs test_control_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x54000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs fake_rd_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem03
  create_bd_addr_seg -range 0x20000 -offset 0x42000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem05
  create_bd_addr_seg -range 0x8000 -offset 0x46000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem09
  create_bd_addr_seg -range 0x8000 -offset 0x48000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4A000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4C000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x7E200000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs zync_block/axi_cdma_0/S_AXI_LITE/Reg] SEG_axi_cdma_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x7E210000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs zync_block/axi_cdma_1/S_AXI_LITE/Reg] SEG_axi_cdma_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41600000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs zync_block/axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x42C00000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x42C10000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs axi_uartlite_1/S_AXI/Reg] SEG_axi_uartlite_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C60000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs fake_rd_block/fake_rd_interface_0/S00_AXI/S00_AXI_reg] SEG_fake_rd_interface_0_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs interface_uub_dfn3_0/S00_AXI/S00_AXI_reg] SEG_interface_uub_dfn3_0_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C20000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/sde_trigger_0/S00_AXI/S00_AXI_reg] SEG_sde_trigger_0_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/sde_trigger_0/S_AXI_INTR/S_AXI_INTR_reg] SEG_sde_trigger_0_S_AXI_INTR_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C50000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/sde_trigger_0/S1_AXI_INTR/reg0] SEG_sde_trigger_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C40000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs test_control_block/test_control_0/S00_AXI/S00_AXI_reg] SEG_test_control_0_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C30000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs time_tagging_0/S00_AXI/S00_AXI_reg] SEG_time_tagging_0_S00_AXI_reg
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


