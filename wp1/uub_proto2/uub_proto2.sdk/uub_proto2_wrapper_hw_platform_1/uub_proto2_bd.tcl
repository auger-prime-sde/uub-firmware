
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

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M04_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M05_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M06_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M08_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M09_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M10_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M11_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M12_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M14_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M20_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0P
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1P
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
  create_bd_pin -dir O -type clk FCLK_CLK0
  create_bd_pin -dir O -type clk FCLK_CLK1
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir I RADIO_CTS
  create_bd_pin -dir O RADIO_RTS
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_reset

  # Create instance: axi_cdma_0, and set properties
  set axi_cdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_cdma:4.1 axi_cdma_0 ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.NUM_MI {21}  ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {8} CONFIG.NUM_SI {2}  ] $axi_interconnect_1

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {333.5} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_RESET_ENABLE {1} CONFIG.PCW_ENET0_RESET_IO {MIO 50} \
CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_I2C0_I2C0_IO {MIO 14 .. 15} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C1_I2C1_IO {MIO 48 .. 49} CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C_RESET_ENABLE {0} CONFIG.PCW_IMPORT_BOARD_PRESET {Z:/cao-projets/SPB16X/lagorio/Auger/Document_travail/xilinx/edk_20140221/ps7_system_prj.xml} \
CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_0_SLEW {fast} CONFIG.PCW_MIO_10_PULLUP {disabled} \
CONFIG.PCW_MIO_10_SLEW {slow} CONFIG.PCW_MIO_11_PULLUP {disabled} \
CONFIG.PCW_MIO_11_SLEW {slow} CONFIG.PCW_MIO_12_PULLUP {disabled} \
CONFIG.PCW_MIO_12_SLEW {slow} CONFIG.PCW_MIO_13_PULLUP {disabled} \
CONFIG.PCW_MIO_13_SLEW {slow} CONFIG.PCW_MIO_14_PULLUP {disabled} \
CONFIG.PCW_MIO_14_SLEW {fast} CONFIG.PCW_MIO_15_PULLUP {disabled} \
CONFIG.PCW_MIO_15_SLEW {fast} CONFIG.PCW_MIO_16_PULLUP {disabled} \
CONFIG.PCW_MIO_16_SLEW {fast} CONFIG.PCW_MIO_17_PULLUP {disabled} \
CONFIG.PCW_MIO_17_SLEW {fast} CONFIG.PCW_MIO_18_PULLUP {disabled} \
CONFIG.PCW_MIO_18_SLEW {fast} CONFIG.PCW_MIO_19_PULLUP {disabled} \
CONFIG.PCW_MIO_19_SLEW {fast} CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {fast} CONFIG.PCW_MIO_20_PULLUP {disabled} \
CONFIG.PCW_MIO_20_SLEW {fast} CONFIG.PCW_MIO_21_PULLUP {disabled} \
CONFIG.PCW_MIO_21_SLEW {fast} CONFIG.PCW_MIO_22_PULLUP {disabled} \
CONFIG.PCW_MIO_22_SLEW {fast} CONFIG.PCW_MIO_23_PULLUP {disabled} \
CONFIG.PCW_MIO_23_SLEW {fast} CONFIG.PCW_MIO_24_PULLUP {disabled} \
CONFIG.PCW_MIO_24_SLEW {fast} CONFIG.PCW_MIO_25_PULLUP {disabled} \
CONFIG.PCW_MIO_25_SLEW {fast} CONFIG.PCW_MIO_26_PULLUP {disabled} \
CONFIG.PCW_MIO_26_SLEW {fast} CONFIG.PCW_MIO_27_PULLUP {disabled} \
CONFIG.PCW_MIO_27_SLEW {fast} CONFIG.PCW_MIO_2_SLEW {fast} \
CONFIG.PCW_MIO_3_SLEW {fast} CONFIG.PCW_MIO_40_PULLUP {disabled} \
CONFIG.PCW_MIO_40_SLEW {slow} CONFIG.PCW_MIO_41_PULLUP {disabled} \
CONFIG.PCW_MIO_41_SLEW {slow} CONFIG.PCW_MIO_42_PULLUP {disabled} \
CONFIG.PCW_MIO_42_SLEW {slow} CONFIG.PCW_MIO_45_PULLUP {disabled} \
CONFIG.PCW_MIO_45_SLEW {fast} CONFIG.PCW_MIO_46_PULLUP {disabled} \
CONFIG.PCW_MIO_47_PULLUP {disabled} CONFIG.PCW_MIO_48_PULLUP {disabled} \
CONFIG.PCW_MIO_49_PULLUP {disabled} CONFIG.PCW_MIO_4_SLEW {fast} \
CONFIG.PCW_MIO_5_SLEW {fast} CONFIG.PCW_MIO_6_SLEW {fast} \
CONFIG.PCW_MIO_8_SLEW {fast} CONFIG.PCW_MIO_9_PULLUP {disabled} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI0_SPI0_IO {MIO 40 .. 45} CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART0_BAUD_RATE {9600} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {1} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_UART0_IO {MIO 46 .. 47} CONFIG.PCW_UART1_BAUD_RATE {115200} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
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
CONFIG.PCW_USB0_RESET_IO {MIO 51} CONFIG.PCW_USE_EXPANDED_IOP {1} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_M_AXI_GP1 {0} \
CONFIG.PCW_USE_S_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_HP0 {1} \
 ] $processing_system7_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M20_AXI] [get_bd_intf_pins axi_interconnect_0/M20_AXI]
  connect_bd_intf_net -intf_net axi_cdma_0_M_AXI [get_bd_intf_pins axi_cdma_0/M_AXI] [get_bd_intf_pins axi_interconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_cdma_0_M_AXI_SG [get_bd_intf_pins axi_cdma_0/M_AXI_SG] [get_bd_intf_pins axi_interconnect_1/S01_AXI]
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
  connect_bd_intf_net -intf_net axi_interconnect_0_M14_AXI [get_bd_intf_pins M08_AXI] [get_bd_intf_pins axi_interconnect_0/M14_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M15_AXI [get_bd_intf_pins M09_AXI] [get_bd_intf_pins axi_interconnect_0/M15_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M16_AXI [get_bd_intf_pins M10_AXI] [get_bd_intf_pins axi_interconnect_0/M16_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M17_AXI [get_bd_intf_pins M11_AXI] [get_bd_intf_pins axi_interconnect_0/M17_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M18_AXI [get_bd_intf_pins M12_AXI] [get_bd_intf_pins axi_interconnect_0/M18_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M19_AXI [get_bd_intf_pins M14_AXI] [get_bd_intf_pins axi_interconnect_0/M19_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins MUON_MEM0] [get_bd_intf_pins axi_interconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins MUON_MEM1] [get_bd_intf_pins axi_interconnect_1/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M02_AXI [get_bd_intf_pins SHWR_MEM0] [get_bd_intf_pins axi_interconnect_1/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M03_AXI [get_bd_intf_pins SHWR_MEM1] [get_bd_intf_pins axi_interconnect_1/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M04_AXI [get_bd_intf_pins SHWR_MEM2] [get_bd_intf_pins axi_interconnect_1/M04_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M05_AXI [get_bd_intf_pins SHWR_MEM3] [get_bd_intf_pins axi_interconnect_1/M05_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M06_AXI [get_bd_intf_pins SHWR_MEM4] [get_bd_intf_pins axi_interconnect_1/M06_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M07_AXI [get_bd_intf_pins axi_interconnect_1/M07_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net RADIO_CTS_1 [get_bd_pins RADIO_CTS] [get_bd_pins processing_system7_0/UART0_CTSN]
  connect_bd_net -net axi_cdma_0_cdma_introut [get_bd_pins axi_cdma_0/cdma_introut] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins axi_cdma_0/s_axi_lite_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/M05_ARESETN] [get_bd_pins axi_interconnect_0/M06_ARESETN] [get_bd_pins axi_interconnect_0/M07_ARESETN] [get_bd_pins axi_interconnect_0/M08_ARESETN] [get_bd_pins axi_interconnect_0/M09_ARESETN] [get_bd_pins axi_interconnect_0/M10_ARESETN] [get_bd_pins axi_interconnect_0/M11_ARESETN] [get_bd_pins axi_interconnect_0/M12_ARESETN] [get_bd_pins axi_interconnect_0/M13_ARESETN] [get_bd_pins axi_interconnect_0/M14_ARESETN] [get_bd_pins axi_interconnect_0/M15_ARESETN] [get_bd_pins axi_interconnect_0/M16_ARESETN] [get_bd_pins axi_interconnect_0/M17_ARESETN] [get_bd_pins axi_interconnect_0/M18_ARESETN] [get_bd_pins axi_interconnect_0/M19_ARESETN] [get_bd_pins axi_interconnect_0/M20_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/M02_ARESETN] [get_bd_pins axi_interconnect_1/M03_ARESETN] [get_bd_pins axi_interconnect_1/M04_ARESETN] [get_bd_pins axi_interconnect_1/M05_ARESETN] [get_bd_pins axi_interconnect_1/M06_ARESETN] [get_bd_pins axi_interconnect_1/M07_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_interconnect_1/S01_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins peripheral_reset] [get_bd_pins proc_sys_reset_0/peripheral_reset]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins axi_cdma_0/m_axi_aclk] [get_bd_pins axi_cdma_0/s_axi_lite_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/M04_ACLK] [get_bd_pins axi_interconnect_0/M05_ACLK] [get_bd_pins axi_interconnect_0/M06_ACLK] [get_bd_pins axi_interconnect_0/M07_ACLK] [get_bd_pins axi_interconnect_0/M08_ACLK] [get_bd_pins axi_interconnect_0/M09_ACLK] [get_bd_pins axi_interconnect_0/M10_ACLK] [get_bd_pins axi_interconnect_0/M11_ACLK] [get_bd_pins axi_interconnect_0/M12_ACLK] [get_bd_pins axi_interconnect_0/M13_ACLK] [get_bd_pins axi_interconnect_0/M14_ACLK] [get_bd_pins axi_interconnect_0/M15_ACLK] [get_bd_pins axi_interconnect_0/M16_ACLK] [get_bd_pins axi_interconnect_0/M17_ACLK] [get_bd_pins axi_interconnect_0/M18_ACLK] [get_bd_pins axi_interconnect_0/M19_ACLK] [get_bd_pins axi_interconnect_0/M20_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/M02_ACLK] [get_bd_pins axi_interconnect_1/M03_ACLK] [get_bd_pins axi_interconnect_1/M04_ACLK] [get_bd_pins axi_interconnect_1/M05_ACLK] [get_bd_pins axi_interconnect_1/M06_ACLK] [get_bd_pins axi_interconnect_1/M07_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_interconnect_1/S01_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins FCLK_CLK1] [get_bd_pins processing_system7_0/FCLK_CLK1]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]
  connect_bd_net -net processing_system7_0_UART0_RTSN [get_bd_pins RADIO_RTS] [get_bd_pins processing_system7_0/UART0_RTSN]
  connect_bd_net -net trigger_memory_0_IRQ [get_bd_pins In1] [get_bd_pins xlconcat_0/In1]
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM0P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MUON_MEM1P
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 TRG_INTR_IFC
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 TRIGGER_IFC

  # Create pins
  create_bd_pin -dir I -from 23 -to 0 ADC0
  create_bd_pin -dir I -from 23 -to 0 ADC1
  create_bd_pin -dir I -from 23 -to 0 ADC2
  create_bd_pin -dir I -from 23 -to 0 ADC3
  create_bd_pin -dir I -from 23 -to 0 ADC4
  create_bd_pin -dir I -from 13 -to 0 FILT_PMT0
  create_bd_pin -dir I -from 13 -to 0 FILT_PMT1
  create_bd_pin -dir I -from 13 -to 0 FILT_PMT2
  create_bd_pin -dir O -type intr IRQ
  create_bd_pin -dir O LEDBAR
  create_bd_pin -dir I LED_FLG
  create_bd_pin -dir I ONE_PPS
  create_bd_pin -dir O -from 5 -to 1 P6X
  create_bd_pin -dir I -from 0 -to 0 -type rst RST
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

  # Create instance: time_tagging_0, and set properties
  set time_tagging_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:time_tagging:1.0 time_tagging_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins time_tagging_0/S00_AXI]
  connect_bd_intf_net -intf_net MUON_MEM0_1 [get_bd_intf_pins MUON_MEM0] [get_bd_intf_pins muon_memory_block/MUON_MEM0]
  connect_bd_intf_net -intf_net MUON_MEM0_PDT_1 [get_bd_intf_pins MUON_MEM0P] [get_bd_intf_pins muon_memory_block/MUON_MEM0P]
  connect_bd_intf_net -intf_net MUON_MEM1P_1 [get_bd_intf_pins MUON_MEM1P] [get_bd_intf_pins muon_memory_block/MUON_MEM1P]
  connect_bd_intf_net -intf_net MUON_MEM1_1 [get_bd_intf_pins MUON_MEM1] [get_bd_intf_pins muon_memory_block/MUON_MEM1]
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
  connect_bd_intf_net -intf_net TRG_INTR_IFC_1 [get_bd_intf_pins TRG_INTR_IFC] [get_bd_intf_pins sde_trigger_0/S_AXI_INTR]
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
  connect_bd_net -net ONE_PPS_1 [get_bd_pins ONE_PPS] [get_bd_pins sde_trigger_0/ONE_PPS] [get_bd_pins time_tagging_0/pps]
  connect_bd_net -net RST_1 [get_bd_pins RST] [get_bd_pins muon_memory_block/rstb] [get_bd_pins shower_memory_block/rstb]
  connect_bd_net -net SHWR_DATA2_1 [get_bd_pins sde_trigger_0/SHWR_DATA2] [get_bd_pins shower_memory_block/SHWR_DATA2]
  connect_bd_net -net SHWR_DATA3_1 [get_bd_pins sde_trigger_0/SHWR_DATA3] [get_bd_pins shower_memory_block/SHWR_DATA3]
  connect_bd_net -net S_AXI_ARESETN_3 [get_bd_pins S_AXI_ARESETN] [get_bd_pins muon_memory_block/s_axi_aresetn] [get_bd_pins sde_trigger_0/s00_axi_aresetn] [get_bd_pins sde_trigger_0/s_axi_intr_aresetn] [get_bd_pins shower_memory_block/s_axi_aresetn] [get_bd_pins time_tagging_0/s00_axi_aresetn]
  connect_bd_net -net S_AXI_CLK_3 [get_bd_pins S_AXI_CLK] [get_bd_pins muon_memory_block/s_axi_aclk] [get_bd_pins sde_trigger_0/s00_axi_aclk] [get_bd_pins sde_trigger_0/s_axi_intr_aclk] [get_bd_pins shower_memory_block/s_axi_aclk] [get_bd_pins time_tagging_0/s00_axi_aclk]
  connect_bd_net -net TRIGGER_CLK_3 [get_bd_pins TRIGGER_CLK] [get_bd_pins muon_memory_block/CLK120] [get_bd_pins sde_trigger_0/CLK120] [get_bd_pins shower_memory_block/CLK120] [get_bd_pins time_tagging_0/clk_120m]
  connect_bd_net -net TRIG_IN_1 [get_bd_pins TRIG_IN] [get_bd_pins sde_trigger_0/TRIG_IN]
  connect_bd_net -net sde_trigger_0_DEAD [get_bd_pins sde_trigger_0/DEAD] [get_bd_pins time_tagging_0/dead]
  connect_bd_net -net sde_trigger_0_LEDBAR [get_bd_pins LEDBAR] [get_bd_pins sde_trigger_0/LEDBAR]
  connect_bd_net -net sde_trigger_0_MUON_ADDR [get_bd_pins muon_memory_block/MUON_ADDR] [get_bd_pins sde_trigger_0/MUON_ADDR]
  connect_bd_net -net sde_trigger_0_MUON_BUF_RNUM [get_bd_pins sde_trigger_0/MUON_BUF_RNUM] [get_bd_pins time_tagging_0/address_rmb]
  connect_bd_net -net sde_trigger_0_MUON_BUF_WNUM [get_bd_pins sde_trigger_0/MUON_BUF_WNUM] [get_bd_pins time_tagging_0/address_wmb]
  connect_bd_net -net sde_trigger_0_MUON_DATA0 [get_bd_pins muon_memory_block/MUON_DATA0] [get_bd_pins sde_trigger_0/MUON_DATA0]
  connect_bd_net -net sde_trigger_0_MUON_DATA1 [get_bd_pins muon_memory_block/MUON_DATA1] [get_bd_pins sde_trigger_0/MUON_DATA1]
  connect_bd_net -net sde_trigger_0_MUON_ENB [get_bd_pins muon_memory_block/MUON_ENB] [get_bd_pins sde_trigger_0/MUON_ENB]
  connect_bd_net -net sde_trigger_0_MUON_EVT_CTR [get_bd_pins sde_trigger_0/MUON_EVT_CTR] [get_bd_pins time_tagging_0/evtcntm]
  connect_bd_net -net sde_trigger_0_MUON_TRIGGER [get_bd_pins sde_trigger_0/MUON_TRIGGER] [get_bd_pins time_tagging_0/evtclks]
  connect_bd_net -net sde_trigger_0_P6X [get_bd_pins P6X] [get_bd_pins sde_trigger_0/P6X]
  connect_bd_net -net sde_trigger_0_SHWR_ADDR [get_bd_pins sde_trigger_0/SHWR_ADDR] [get_bd_pins shower_memory_block/SHWR_ADDR]
  connect_bd_net -net sde_trigger_0_SHWR_BUF_RNUM [get_bd_pins sde_trigger_0/SHWR_BUF_RNUM] [get_bd_pins time_tagging_0/address_rsb]
  connect_bd_net -net sde_trigger_0_SHWR_BUF_WNUM [get_bd_pins sde_trigger_0/SHWR_BUF_WNUM] [get_bd_pins time_tagging_0/address_wsb]
  connect_bd_net -net sde_trigger_0_SHWR_DATA0 [get_bd_pins sde_trigger_0/SHWR_DATA0] [get_bd_pins shower_memory_block/SHWR_DATA0]
  connect_bd_net -net sde_trigger_0_SHWR_DATA1 [get_bd_pins sde_trigger_0/SHWR_DATA1] [get_bd_pins shower_memory_block/SHWR_DATA1]
  connect_bd_net -net sde_trigger_0_SHWR_DATA4 [get_bd_pins sde_trigger_0/SHWR_DATA4] [get_bd_pins shower_memory_block/SHWR_DATA4]
  connect_bd_net -net sde_trigger_0_SHWR_EVT_CTR [get_bd_pins sde_trigger_0/SHWR_EVT_CTR] [get_bd_pins time_tagging_0/evtcnt]
  connect_bd_net -net sde_trigger_0_SHWR_TRIGGER [get_bd_pins sde_trigger_0/SHWR_TRIGGER] [get_bd_pins time_tagging_0/evtclkf]
  connect_bd_net -net sde_trigger_0_TRIG_OUT [get_bd_pins TRIG_OUT] [get_bd_pins sde_trigger_0/TRIG_OUT]
  connect_bd_net -net sde_trigger_0_irq [get_bd_pins IRQ] [get_bd_pins sde_trigger_0/irq]
  
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

# Hierarchical cell: WP1_ADC_CONTROL
proc create_hier_cell_WP1_ADC_CONTROL { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_WP1_ADC_CONTROL() - Empty argument(s)!"
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI4
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI5
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI6

  # Create pins
  create_bd_pin -dir I EXT_TRIG
  create_bd_pin -dir I -from 0 -to 0 FPGA_CK
  create_bd_pin -dir I -from 0 -to 0 RSTn
  create_bd_pin -dir I -from 23 -to 0 adc0
  create_bd_pin -dir I -from 23 -to 0 adc1
  create_bd_pin -dir I -from 23 -to 0 adc2
  create_bd_pin -dir I -from 23 -to 0 adc3
  create_bd_pin -dir I -from 23 -to 0 adc4
  create_bd_pin -dir I -type clk s_axi_aclk

  # Create instance: WP1_ADC_Control_0, and set properties
  set WP1_ADC_Control_0 [ create_bd_cell -type ip -vlnv elettronica.le.infn.it:user:WP1_ADC_Control:1.2 WP1_ADC_Control_0 ]

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

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS_2 {0} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_ALL_OUTPUTS_2 {1} CONFIG.C_IS_DUAL {1}  ] $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {16}  ] $axi_gpio_1

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_0 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_0

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

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_3/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_2_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_2/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_2/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_3_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_3/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_4_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_4/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_4/BRAM_PORTB]
  connect_bd_intf_net -intf_net zync_block_M08_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net zync_block_M09_AXI [get_bd_intf_pins S_AXI3] [get_bd_intf_pins axi_bram_ctrl_3/S_AXI]
  connect_bd_intf_net -intf_net zync_block_M10_AXI [get_bd_intf_pins S_AXI4] [get_bd_intf_pins axi_bram_ctrl_4/S_AXI]
  connect_bd_intf_net -intf_net zync_block_M11_AXI [get_bd_intf_pins S_AXI1] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
  connect_bd_intf_net -intf_net zync_block_M12_AXI [get_bd_intf_pins S_AXI2] [get_bd_intf_pins axi_bram_ctrl_2/S_AXI]
  connect_bd_intf_net -intf_net zync_block_M14_AXI [get_bd_intf_pins S_AXI5] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net zync_block_M20_AXI [get_bd_intf_pins S_AXI6] [get_bd_intf_pins axi_gpio_1/S_AXI]

  # Create port connections
  connect_bd_net -net In_regional_ck_0_IBUF_OUT [get_bd_pins FPGA_CK] [get_bd_pins WP1_ADC_Control_0/FPGA_CK]
  connect_bd_net -net TRIG_IN_1 [get_bd_pins EXT_TRIG] [get_bd_pins WP1_ADC_Control_0/EXT_TRIG]
  connect_bd_net -net WP1_ADC_Control_0_ADC0_mem [get_bd_pins WP1_ADC_Control_0/ADC0_mem] [get_bd_pins blk_mem_gen_0/dina]
  connect_bd_net -net WP1_ADC_Control_0_ADC1_mem [get_bd_pins WP1_ADC_Control_0/ADC1_mem] [get_bd_pins blk_mem_gen_1/dina]
  connect_bd_net -net WP1_ADC_Control_0_ADC2_mem [get_bd_pins WP1_ADC_Control_0/ADC2_mem] [get_bd_pins blk_mem_gen_4/dina]
  connect_bd_net -net WP1_ADC_Control_0_ADC3_mem [get_bd_pins WP1_ADC_Control_0/ADC3_mem] [get_bd_pins blk_mem_gen_3/dina]
  connect_bd_net -net WP1_ADC_Control_0_ADC4_mem [get_bd_pins WP1_ADC_Control_0/ADC4_mem] [get_bd_pins blk_mem_gen_2/dina]
  connect_bd_net -net WP1_ADC_Control_0_ADDR_mem [get_bd_pins WP1_ADC_Control_0/ADDR_mem] [get_bd_pins blk_mem_gen_0/addra] [get_bd_pins blk_mem_gen_1/addra] [get_bd_pins blk_mem_gen_2/addra] [get_bd_pins blk_mem_gen_3/addra] [get_bd_pins blk_mem_gen_4/addra]
  connect_bd_net -net WP1_ADC_Control_0_BRAM_CK [get_bd_pins WP1_ADC_Control_0/BRAM_CK] [get_bd_pins blk_mem_gen_0/clka] [get_bd_pins blk_mem_gen_1/clka] [get_bd_pins blk_mem_gen_2/clka] [get_bd_pins blk_mem_gen_3/clka] [get_bd_pins blk_mem_gen_4/clka]
  connect_bd_net -net WP1_ADC_Control_0_Stop_Addr [get_bd_pins WP1_ADC_Control_0/Stop_Addr] [get_bd_pins axi_gpio_1/gpio_io_i]
  connect_bd_net -net WP1_ADC_Control_0_enable [get_bd_pins WP1_ADC_Control_0/enable] [get_bd_pins blk_mem_gen_0/ena] [get_bd_pins blk_mem_gen_1/ena] [get_bd_pins blk_mem_gen_2/ena] [get_bd_pins blk_mem_gen_3/ena] [get_bd_pins blk_mem_gen_4/ena]
  connect_bd_net -net WP1_ADC_Control_0_wea [get_bd_pins WP1_ADC_Control_0/wea] [get_bd_pins blk_mem_gen_0/wea] [get_bd_pins blk_mem_gen_1/wea] [get_bd_pins blk_mem_gen_2/wea] [get_bd_pins blk_mem_gen_3/wea] [get_bd_pins blk_mem_gen_4/wea]
  connect_bd_net -net WP1_adc_inputs_data_in_to_device [get_bd_pins adc0] [get_bd_pins WP1_ADC_Control_0/adc0]
  connect_bd_net -net WP1_adc_inputs_data_in_to_device1 [get_bd_pins adc1] [get_bd_pins WP1_ADC_Control_0/adc1]
  connect_bd_net -net WP1_adc_inputs_data_in_to_device2 [get_bd_pins adc2] [get_bd_pins WP1_ADC_Control_0/adc2]
  connect_bd_net -net WP1_adc_inputs_data_in_to_device3 [get_bd_pins adc3] [get_bd_pins WP1_ADC_Control_0/adc3]
  connect_bd_net -net WP1_adc_inputs_data_in_to_device4 [get_bd_pins adc4] [get_bd_pins WP1_ADC_Control_0/adc4]
  connect_bd_net -net axi_gpio_0_gpio2_io_o [get_bd_pins WP1_ADC_Control_0/TRIG_TRESH] [get_bd_pins axi_gpio_0/gpio2_io_o]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins WP1_ADC_Control_0/Config_Trig] [get_bd_pins axi_gpio_0/gpio_io_o]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins RSTn] [get_bd_pins WP1_ADC_Control_0/RSTn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_2/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_3/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_4/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins blk_mem_gen_0/rsta] [get_bd_pins blk_mem_gen_1/rsta] [get_bd_pins blk_mem_gen_2/rsta] [get_bd_pins blk_mem_gen_3/rsta] [get_bd_pins blk_mem_gen_4/rsta]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_bram_ctrl_2/s_axi_aclk] [get_bd_pins axi_bram_ctrl_3/s_axi_aclk] [get_bd_pins axi_bram_ctrl_4/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk]
  
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
  set FPGA_CK_N [ create_bd_port -dir I -type clk FPGA_CK_N ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $FPGA_CK_N
  set FPGA_CK_P [ create_bd_port -dir I -type clk FPGA_CK_P ]
  set_property -dict [ list CONFIG.FREQ_HZ {120000000}  ] $FPGA_CK_P
  set GPS_PPS [ create_bd_port -dir I GPS_PPS ]
  set GPS_RX [ create_bd_port -dir I GPS_RX ]
  set GPS_TX [ create_bd_port -dir O GPS_TX ]
  set LED_ASY [ create_bd_port -dir O -from 0 -to 0 LED_ASY ]
  set LED_FLG [ create_bd_port -dir I LED_FLG ]
  set P6X [ create_bd_port -dir O -from 5 -to 1 P6X ]
  set RADIO_CTS [ create_bd_port -dir I RADIO_CTS ]
  set RADIO_RST_IN [ create_bd_port -dir I RADIO_RST_IN ]
  set RADIO_RST_OUT [ create_bd_port -dir O RADIO_RST_OUT ]
  set RADIO_RTS [ create_bd_port -dir O RADIO_RTS ]
  set TRIG_IN [ create_bd_port -dir I TRIG_IN ]
  set TRIG_OUT [ create_bd_port -dir O TRIG_OUT ]
  set USB_IFAULT [ create_bd_port -dir I USB_IFAULT ]
  set WATCHDOG [ create_bd_port -dir I WATCHDOG ]
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
  set ext0_dat [ create_bd_port -dir O -from 7 -to 0 ext0_dat ]
  set ext1_ctl [ create_bd_port -dir O -from 7 -to 0 ext1_ctl ]
  set ext1_dat [ create_bd_port -dir O -from 7 -to 0 ext1_dat ]
  set hconf [ create_bd_port -dir I -from 7 -to 0 hconf ]

  # Create instance: WP1_ADC_CONTROL
  create_hier_cell_WP1_ADC_CONTROL [current_bd_instance .] WP1_ADC_CONTROL

  # Create instance: adc_inputs
  create_hier_cell_adc_inputs [current_bd_instance .] adc_inputs

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]

  # Create instance: clock_1pps_0, and set properties
  set clock_1pps_0 [ create_bd_cell -type ip -vlnv auger.org:dfnitz:clock_1pps:1.0 clock_1pps_0 ]

  # Create instance: filter_block
  create_hier_cell_filter_block [current_bd_instance .] filter_block

  # Create instance: interface_uub_dfn3_0, and set properties
  set interface_uub_dfn3_0 [ create_bd_cell -type ip -vlnv auger.org:auger:interface_uub_dfn3:1.0 interface_uub_dfn3_0 ]

  # Create instance: trigger_memory_block
  create_hier_cell_trigger_memory_block [current_bd_instance .] trigger_memory_block

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list CONFIG.C_BUF_TYPE {IBUFDS}  ] $util_ds_buf_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list CONFIG.CONST_VAL {255} CONFIG.CONST_WIDTH {8}  ] $xlconstant_0

  # Create instance: zync_block
  create_hier_cell_zync_block [current_bd_instance .] zync_block

  # Create interface connections
  connect_bd_intf_net -intf_net SHWR_MEM0P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM0P] [get_bd_intf_pins zync_block/SHWR_MEM0P]
  connect_bd_intf_net -intf_net SHWR_MEM1P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM1P] [get_bd_intf_pins zync_block/SHWR_MEM1P]
  connect_bd_intf_net -intf_net SHWR_MEM2P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM2P] [get_bd_intf_pins zync_block/SHWR_MEM2P]
  connect_bd_intf_net -intf_net SHWR_MEM3P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM3P] [get_bd_intf_pins zync_block/SHWR_MEM3P]
  connect_bd_intf_net -intf_net SHWR_MEM4P_1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM4P] [get_bd_intf_pins zync_block/SHWR_MEM4P]
  connect_bd_intf_net -intf_net axi_interconnect_0_M05_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins zync_block/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins zync_block/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins zync_block/FIXED_IO]
  connect_bd_intf_net -intf_net zync_block_M01_AXI [get_bd_intf_pins trigger_memory_block/TRG_INTR_IFC] [get_bd_intf_pins zync_block/M01_AXI]
  connect_bd_intf_net -intf_net zync_block_M02_AXI [get_bd_intf_pins trigger_memory_block/TRIGGER_IFC] [get_bd_intf_pins zync_block/M02_AXI]
  connect_bd_intf_net -intf_net zync_block_M03_AXI [get_bd_intf_pins trigger_memory_block/S00_AXI] [get_bd_intf_pins zync_block/M03_AXI]
  connect_bd_intf_net -intf_net zync_block_M04_AXI [get_bd_intf_pins interface_uub_dfn3_0/S00_AXI] [get_bd_intf_pins zync_block/M04_AXI]
  connect_bd_intf_net -intf_net zync_block_M08_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI] [get_bd_intf_pins zync_block/M08_AXI]
  connect_bd_intf_net -intf_net zync_block_M09_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI3] [get_bd_intf_pins zync_block/M09_AXI]
  connect_bd_intf_net -intf_net zync_block_M10_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI4] [get_bd_intf_pins zync_block/M10_AXI]
  connect_bd_intf_net -intf_net zync_block_M11_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI1] [get_bd_intf_pins zync_block/M11_AXI]
  connect_bd_intf_net -intf_net zync_block_M12_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI2] [get_bd_intf_pins zync_block/M12_AXI]
  connect_bd_intf_net -intf_net zync_block_M14_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI5] [get_bd_intf_pins zync_block/M14_AXI]
  connect_bd_intf_net -intf_net zync_block_M20_AXI [get_bd_intf_pins WP1_ADC_CONTROL/S_AXI6] [get_bd_intf_pins zync_block/M20_AXI]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM [get_bd_intf_pins trigger_memory_block/MUON_MEM0] [get_bd_intf_pins zync_block/MUON_MEM0]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM0_PDT [get_bd_intf_pins trigger_memory_block/MUON_MEM0P] [get_bd_intf_pins zync_block/MUON_MEM0P]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM1 [get_bd_intf_pins trigger_memory_block/MUON_MEM1] [get_bd_intf_pins zync_block/MUON_MEM1]
  connect_bd_intf_net -intf_net zync_block_MUON_MEM1P [get_bd_intf_pins trigger_memory_block/MUON_MEM1P] [get_bd_intf_pins zync_block/MUON_MEM1P]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM0 [get_bd_intf_pins trigger_memory_block/SHWR_MEM0] [get_bd_intf_pins zync_block/SHWR_MEM0]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM1 [get_bd_intf_pins trigger_memory_block/SHWR_MEM1] [get_bd_intf_pins zync_block/SHWR_MEM1]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM2 [get_bd_intf_pins trigger_memory_block/SHWR_MEM2] [get_bd_intf_pins zync_block/SHWR_MEM2]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM3 [get_bd_intf_pins trigger_memory_block/SHWR_MEM3] [get_bd_intf_pins zync_block/SHWR_MEM3]
  connect_bd_intf_net -intf_net zync_block_SHWR_MEM4 [get_bd_intf_pins trigger_memory_block/SHWR_MEM4] [get_bd_intf_pins zync_block/SHWR_MEM4]

  # Create port connections
  connect_bd_net -net ADC0_CK_N_1 [get_bd_ports ADC0_CK_N] [get_bd_pins adc_inputs/IBUF_CK0_N]
  connect_bd_net -net ADC0_CK_P_1 [get_bd_ports ADC0_CK_P] [get_bd_pins adc_inputs/IBUF_CK0_P]
  connect_bd_net -net ADC1_CK_N_1 [get_bd_ports ADC1_CK_N] [get_bd_pins adc_inputs/IBUF_CK1_N]
  connect_bd_net -net ADC1_CK_P_1 [get_bd_ports ADC1_CK_P] [get_bd_pins adc_inputs/IBUF_CK1_P]
  connect_bd_net -net ADC2_CK_N_1 [get_bd_ports ADC2_CK_N] [get_bd_pins adc_inputs/IBUF_CK2_N]
  connect_bd_net -net ADC2_CK_P_1 [get_bd_ports ADC2_CK_P] [get_bd_pins adc_inputs/IBUF_CK2_P]
  connect_bd_net -net ADC3_CK_N_1 [get_bd_ports ADC3_CK_N] [get_bd_pins adc_inputs/IBUF_CK3_N]
  connect_bd_net -net ADC3_CK_P_1 [get_bd_ports ADC3_CK_P] [get_bd_pins adc_inputs/IBUF_CK3_P]
  connect_bd_net -net ADC4_CK_N_1 [get_bd_ports ADC4_CK_N] [get_bd_pins adc_inputs/IBUF_CK4_N]
  connect_bd_net -net ADC4_CK_P_1 [get_bd_ports ADC4_CK_P] [get_bd_pins adc_inputs/IBUF_CK4_P]
  connect_bd_net -net FPGA_CK_N_1 [get_bd_ports FPGA_CK_N] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
  connect_bd_net -net FPGA_CK_P_1 [get_bd_ports FPGA_CK_P] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
  connect_bd_net -net GPS_PPS_1 [get_bd_ports GPS_PPS] [get_bd_pins interface_uub_dfn3_0/TRUE_PPS]
  connect_bd_net -net In_regional_ck_0_IBUF_OUT [get_bd_pins WP1_ADC_CONTROL/FPGA_CK] [get_bd_pins adc_inputs/CLK120] [get_bd_pins clock_1pps_0/CLK120] [get_bd_pins filter_block/CLK] [get_bd_pins interface_uub_dfn3_0/CLK120] [get_bd_pins trigger_memory_block/TRIGGER_CLK] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  connect_bd_net -net LED_FLG_1 [get_bd_ports LED_FLG] [get_bd_pins trigger_memory_block/LED_FLG]
  connect_bd_net -net RADIO_CTS_1 [get_bd_ports RADIO_CTS] [get_bd_pins zync_block/RADIO_CTS]
  connect_bd_net -net RADIO_RST_IN_1 [get_bd_ports RADIO_RST_IN] [get_bd_pins interface_uub_dfn3_0/RADIO_RST_IN]
  connect_bd_net -net TRIG_IN_1 [get_bd_ports TRIG_IN] [get_bd_pins WP1_ADC_CONTROL/EXT_TRIG] [get_bd_pins trigger_memory_block/TRIG_IN]
  connect_bd_net -net USB_IFAULT_1 [get_bd_ports USB_IFAULT] [get_bd_pins interface_uub_dfn3_0/USB_IFAULT]
  connect_bd_net -net WATCHDOG_1 [get_bd_ports WATCHDOG] [get_bd_pins interface_uub_dfn3_0/WATCHDOG]
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
  connect_bd_net -net adc_inputs_SYNC_OUT0 [get_bd_pins WP1_ADC_CONTROL/adc0] [get_bd_pins adc_inputs/SYNC_OUT0] [get_bd_pins filter_block/IN0] [get_bd_pins trigger_memory_block/ADC0]
  connect_bd_net -net adc_inputs_SYNC_OUT1 [get_bd_pins WP1_ADC_CONTROL/adc1] [get_bd_pins adc_inputs/SYNC_OUT1] [get_bd_pins filter_block/IN1] [get_bd_pins trigger_memory_block/ADC1]
  connect_bd_net -net adc_inputs_SYNC_OUT2 [get_bd_pins WP1_ADC_CONTROL/adc2] [get_bd_pins adc_inputs/SYNC_OUT2] [get_bd_pins filter_block/IN2] [get_bd_pins trigger_memory_block/ADC2]
  connect_bd_net -net adc_inputs_SYNC_OUT3 [get_bd_pins WP1_ADC_CONTROL/adc3] [get_bd_pins adc_inputs/SYNC_OUT3] [get_bd_pins trigger_memory_block/ADC3]
  connect_bd_net -net adc_inputs_SYNC_OUT4 [get_bd_pins WP1_ADC_CONTROL/adc4] [get_bd_pins adc_inputs/SYNC_OUT4] [get_bd_pins trigger_memory_block/ADC4]
  connect_bd_net -net axi_uartlite_0_tx [get_bd_ports GPS_TX] [get_bd_pins axi_uartlite_0/tx]
  connect_bd_net -net clock_1pps_0_CLK1PPS [get_bd_pins clock_1pps_0/CLK1PPS] [get_bd_pins interface_uub_dfn3_0/FAKE_PPS]
  connect_bd_net -net filter_block_OUT0 [get_bd_pins filter_block/OUT0] [get_bd_pins trigger_memory_block/FILT_PMT0]
  connect_bd_net -net filter_block_OUT1 [get_bd_pins filter_block/OUT1] [get_bd_pins trigger_memory_block/FILT_PMT1]
  connect_bd_net -net filter_block_OUT2 [get_bd_pins filter_block/OUT2] [get_bd_pins trigger_memory_block/FILT_PMT2]
  connect_bd_net -net hconf_1 [get_bd_ports hconf] [get_bd_pins interface_uub_dfn3_0/HCONF]
  connect_bd_net -net interface_uub_dfn3_0_PPS [get_bd_pins interface_uub_dfn3_0/PPS] [get_bd_pins trigger_memory_block/ONE_PPS]
  connect_bd_net -net interface_uub_dfn3_0_RADIO_RST_OUT [get_bd_ports RADIO_RST_OUT] [get_bd_pins interface_uub_dfn3_0/RADIO_RST_OUT]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins WP1_ADC_CONTROL/RSTn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins interface_uub_dfn3_0/s00_axi_aresetn] [get_bd_pins trigger_memory_block/S_AXI_ARESETN] [get_bd_pins zync_block/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins trigger_memory_block/RST] [get_bd_pins zync_block/peripheral_reset]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins WP1_ADC_CONTROL/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins interface_uub_dfn3_0/s00_axi_aclk] [get_bd_pins trigger_memory_block/S_AXI_CLK] [get_bd_pins zync_block/FCLK_CLK0]
  connect_bd_net -net rx_1 [get_bd_ports GPS_RX] [get_bd_pins axi_uartlite_0/rx]
  connect_bd_net -net trigger_memory_0_IRQ [get_bd_pins trigger_memory_block/IRQ] [get_bd_pins zync_block/In1]
  connect_bd_net -net trigger_memory_block_LEDBAR [get_bd_ports LED_ASY] [get_bd_pins trigger_memory_block/LEDBAR]
  connect_bd_net -net trigger_memory_block_P6X [get_bd_ports P6X] [get_bd_pins trigger_memory_block/P6X]
  connect_bd_net -net trigger_memory_block_TRIG_OUT [get_bd_ports TRIG_OUT] [get_bd_pins trigger_memory_block/TRIG_OUT]
  connect_bd_net -net xlconstant_0_dout [get_bd_ports ext0_ctl] [get_bd_ports ext0_dat] [get_bd_ports ext1_ctl] [get_bd_ports ext1_dat] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net zync_block_RADIO_RTS [get_bd_ports RADIO_RTS] [get_bd_pins zync_block/RADIO_RTS]

  # Create address segments
  create_bd_addr_seg -range 0x20000 -offset 0x40000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x40000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x44000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem02
  create_bd_addr_seg -range 0x8000 -offset 0x44000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem04
  create_bd_addr_seg -range 0x20000 -offset 0x42000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x42000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x46000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem02
  create_bd_addr_seg -range 0x8000 -offset 0x46000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem04
  create_bd_addr_seg -range 0x8000 -offset 0x48000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x48000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4A000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4A000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4C000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x4C000000 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces zync_block/axi_cdma_0/Data] [get_bd_addr_segs zync_block/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces zync_block/axi_cdma_0/Data_SG] [get_bd_addr_segs zync_block/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x8000 -offset 0x44000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x40000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem01
  create_bd_addr_seg -range 0x4000 -offset 0x50000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem02
  create_bd_addr_seg -range 0x8000 -offset 0x46000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x4000 -offset 0x51000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem01
  create_bd_addr_seg -range 0x20000 -offset 0x42000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/muon_memory_block/axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem05
  create_bd_addr_seg -range 0x8000 -offset 0x48000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem0
  create_bd_addr_seg -range 0x4000 -offset 0x52000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_bram_ctrl_2/S_AXI/Mem0] SEG_axi_bram_ctrl_2_Mem01
  create_bd_addr_seg -range 0x8000 -offset 0x4A000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x4000 -offset 0x53000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_bram_ctrl_3/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem01
  create_bd_addr_seg -range 0x8000 -offset 0x4C000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/shower_memory_block/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem0
  create_bd_addr_seg -range 0x4000 -offset 0x54000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_bram_ctrl_4/S_AXI/Mem0] SEG_axi_bram_ctrl_4_Mem01
  create_bd_addr_seg -range 0x10000 -offset 0x7E200000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs zync_block/axi_cdma_0/S_AXI_LITE/Reg] SEG_axi_cdma_0_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x55000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x56000000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs WP1_ADC_CONTROL/axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x42C00000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs interface_uub_dfn3_0/S00_AXI/S00_AXI_reg] SEG_interface_uub_dfn3_0_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C20000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/sde_trigger_0/S00_AXI/S00_AXI_reg] SEG_sde_trigger_0_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/sde_trigger_0/S_AXI_INTR/S_AXI_INTR_reg] SEG_sde_trigger_0_S_AXI_INTR_reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C30000 [get_bd_addr_spaces zync_block/processing_system7_0/Data] [get_bd_addr_segs trigger_memory_block/time_tagging_0/S00_AXI/S00_AXI_reg] SEG_time_tagging_0_S00_AXI_reg
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


