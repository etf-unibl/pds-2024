## Generated SDC file "sequential_divider.sdc"

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
## VERSION "Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"

## DATE    "Mon Dec 30 00:00:08 2024"

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

create_clock -name clk_i -period 16 [get_ports {clk_i}]
create_clock -name clk_i_virt -period 16

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

set_input_delay -clock clk_i_virt -max 0.900 [get_ports {start_i}]
set_input_delay -clock clk_i_virt -min 0.820 [get_ports {start_i}]
set_input_delay -clock clk_i_virt -max 0.900 [get_ports {a_i[*]}]
set_input_delay -clock clk_i_virt -min 0.820 [get_ports {a_i[*]}]
set_input_delay -clock clk_i_virt -max 0.900 [get_ports {b_i[*]}]
set_input_delay -clock clk_i_virt -min 0.820 [get_ports {b_i[*]}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock clk_i_virt -max 0.900 [get_ports {q_o[*]}]
set_output_delay -clock clk_i_virt -min 0.820 [get_ports {q_o[*]}]
set_output_delay -clock clk_i_virt -max 0.900 [get_ports {r_o[*]}]
set_output_delay -clock clk_i_virt -min 0.820 [get_ports {r_o[*]}]
set_output_delay -clock clk_i_virt -max 0.900 [get_ports {done_o}]
set_output_delay -clock clk_i_virt -min 0.820 [get_ports {done_o}]

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

