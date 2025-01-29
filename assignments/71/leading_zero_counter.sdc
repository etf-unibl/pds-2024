## Generated SDC file "leading_zero_counter.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"

## DATE    "Wed Dec 25 18:33:02 2024"

##
## DEVICE  "5CSEMA6F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************

create_clock -name clk_i -period 10 [get_ports {clk_i}]
create_clock -name clk_virt -period 10

#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock clk_virt -min 0.400 [get_ports {start_i}]
set_input_delay -clock clk_virt -max 0.600 [get_ports {start_i}]
set_input_delay -clock clk_virt -min 0.400 [get_ports {n_i[*]}]
set_input_delay -clock clk_virt -max 0.600 [get_ports {n_i[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock clk_virt -min 0.400 [get_ports {zeros_o[*]}]
set_output_delay -clock clk_virt -max 0.600 [get_ports {zeros_o[*]}]
set_output_delay -clock clk_virt -min 0.400 [get_ports {ready_o}]
set_output_delay -clock clk_virt -max 0.600 [get_ports {ready_o}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {rst_i}] -to [all_registers]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Pin assignment
#**************************************************************

set_location_assignment PIN_N2 -to clk_i
set_location_assignment PIN_L22 -to rst_i
set_location_assignment PIN_L21 -to start_i
set_location_assignment PIN_AE23 -to n_i[0]
set_location_assignment PIN_AE24 -to n_i[1]
set_location_assignment PIN_AF23 -to n_i[2]
set_location_assignment PIN_AF24 -to n_i[3]
set_location_assignment PIN_AG23 -to n_i[4]
set_location_assignment PIN_AG24 -to n_i[5]
set_location_assignment PIN_AH23 -to n_i[6]
set_location_assignment PIN_AH24 -to n_i[7]
set_location_assignment PIN_AE25 -to n_i[8]
set_location_assignment PIN_AF25 -to n_i[9]
set_location_assignment PIN_AG25 -to n_i[10]
set_location_assignment PIN_AH25 -to n_i[11]
set_location_assignment PIN_AE26 -to n_i[12]
set_location_assignment PIN_AF26 -to n_i[13]
set_location_assignment PIN_AG26 -to n_i[14]
set_location_assignment PIN_AH26 -to n_i[15]

# Output pins

set_location_assignment PIN_AF8 -to ready_o
set_location_assignment PIN_AE8 -to zeros_o[0]
set_location_assignment PIN_AF7 -to zeros_o[1]
set_location_assignment PIN_AG7 -to zeros_o[2]
set_location_assignment PIN_AH7 -to zeros_o[3]
set_location_assignment PIN_AH6 -to zeros_o[4]

#**************************************************************
