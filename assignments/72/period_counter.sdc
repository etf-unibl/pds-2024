## Generated SDC file "period_counter.sdc"

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

## DATE    "Tue Dec 31 03:46:25 2024"

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

create_clock -period 1000 -waveform {500 1000} [get_ports {clk_i}]
create_clock -name clk_virt -period 1000 -waveform {500 1000}

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

set_input_delay -clock clk_virt -max 55 [get_ports {signal_i}]
set_input_delay -clock clk_virt -min 35 [get_ports {signal_i}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock clk_virt -max 55 [get_ports {period_o[*]}]
set_output_delay -clock clk_virt -min 35 [get_ports {period_o[*]}]

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

set_location_assignment PIN_AF14 -to clk_i
set_location_assignment PIN_AA14 -to rst_i
set_location_assignment PIN_AB12 -to signal_i
set_location_assignment PIN_V16 -to period_o[0]
set_location_assignment PIN_W16 -to period_o[1]
set_location_assignment PIN_V17 -to period_o[2]
set_location_assignment PIN_V18 -to period_o[3]
set_location_assignment PIN_W17 -to period_o[4]
set_location_assignment PIN_W19 -to period_o[5]
set_location_assignment PIN_Y19 -to period_o[6]
set_location_assignment PIN_W20 -to period_o[7]
set_location_assignment PIN_W21 -to period_o[8]
set_location_assignment PIN_Y21 -to period_o[9]
