# Use multiple cores
set_host_options -max_cores 8

####################################
# Setup library                    #
####################################
# Set path
set search_path "../hdl/"

# Set library
set link_library [list "../lib/nangate45-typ-ccs.db" "../lib/memory_45nm.db"]
set target_library [list "../lib/nangate-45typ-ccs.db" "../lib/memory_45nm.db"]
set symbol_library "../lib/nangate-45typ-ccs.db"

#######################################
# Read HDL                            # 
#######################################
set target_verilog_files [list \
main.v \
ApplyStage.v \
ComputeStage.v \
FetchStage.v \
alu.v \
memory.v \
registerfile.v]
set my_toplevel main

analyze -f verilog $target_verilog_files
elaborate $my_toplevel
current_design $my_toplevel

###############################
## Verilog Compiler settings ##
###############################

# to make DC not use the assign statement in its output netlist
set verilogout_no_tri true

# assume this means DC will ignore the case of the letters in net and module names
#set verilogout_ignore_case true

# unconnected nets will be marked by adding a prefix to its name
set verilogout_unconnected_prefix "UNCONNECTED"

# show unconnected pins when creating module ports
set verilogout_show_unconnected_pins true

# make sure that vectored ports don't get split up into single bits
set verilogout_single_bit false

# generate a netlist without creating an EDIF schematic
set edifout_netlist_only true

########################
# Define constraints
########################

# set the clock period in ps
set CLK_PERIOD 2.0
#0.1
#1.73

# setting the approximate skew
set CLK_SKEW [expr 0.025 * $CLK_PERIOD]

# constraint design area units depends on the technology library
set MAX_AREA 0
set_max_area $MAX_AREA

# power constraints
# set MAX_LEAKAGE_POWER 0.0
# set_max_leakage_power $MAX_LEAKAGE_POWER
# set MAX_DYNAMIC_POWER 0.0
# set_max_dynamic_power $MAX_DYNAMIC_POWER

# make sure ports aren't connected together
#set_fix_multiple_port_nets -all

# setting the port of clock
create_clock -period  $CLK_PERIOD CLK

## Design Rule Constraints

#set DRIVINGCELL inv_1
#set DRIVE_PIN {Y}
# set input driving cell strength / Max fanout for all design
#set_driving_cell -lib_cell $DRIVINGCELL -pin $DRIVE_PIN [all_inputs]

# largest fanout allowed 
#set MAX_FANOUT 8
#set_max_fanout $MAX_FANOUT

# models load on output ports
set_load $MAX_OUTPUT_load [all_outputs]
# incase of variable load at each output port
# set_load <loadvalue> [get_ports {<portnames>}] 

# set maximum and minimum capacitance 
# set_max_capacitance
# set_min_capacitance

# setting operating conditions if allowed by technology library 
# set_operating_conditions

# wireload models
# set_wireload_model
# set_wireload_mode 

set MAX_INPUT_DELAY 0.9
set MIN_INPUT_DELAY 0
set OUTPUT_MAX_DELAY 0.4
set OUTPUT_MIN_DELAY -0.4

# models the delay from signal source to design input port
# set_input_delay

# models delay from design to output port
# set_output_delay

# used when you are translating some netlist from one technology to another
link

# for power estimation
saif_map
set_power_prediction

# used to generate separate instances within the netlist
#uniquify

############################
# Design Compiler settings #
############################

# completely flatten the hierarchy to allow optimization to cross hierarchy boundaries
#ungroup -flatten -all

# check internal DC representation for design consistency
check_design

# verifies timing setup is complete
check_timing

# enable DC ultra optimizations 
compile_ultra -no_autoungroup

# verifies timing setup is complete
check_timing

# report design size and object counts
report_area

# reports design database constraints attributes
report_timing

# report design size and object counts
report_power -analysis_effort high
report_power -analysis_effort high > power_fwd.txt

read_saif -input ../saif_rtl/activity.saif -instance_name testbench/tg
report_power -analysis_effort high
report_power -analysis_effort high > power_known.txt
uplevel #0 { report_power -net -cell -analysis_effort high }
uplevel #0 { report_power -net -cell -analysis_effort high } > switching_activity.txt
################
# Output files #
################

# save design
set filename "target"
write -format ddc -hierarchy -output $filename
set filename "target.ddc"
write -format ddc -hierarchy -output $filename

# save delay and parasitic data
set filename "target.sdf"
write_sdf -version 1.0 $filename

# save synthesized verilog netlist
set filename "target.syn.v"
write -format verilog -hierarchy -output $filename

# this file is necessary for P&R with Encounter
set filename "target.sdc"
write_sdc $filename

# write milkyway database
if {[shell_is_in_topographical_mode]} {
    write_milkyway -output $my_toplevel -overwrite
}

redirect [format "%s%s" $my_toplevel  _design.repC] { report_design }
redirect [format "%s%s" $my_toplevel  _area.repC] { report_area }
redirect -append [format "%s%s" $my_toplevel  _area.repC] { report_reference }
redirect [format "%s%s" $my_toplevel  _latches.repC] { report_register -level_sensitive }
redirect [format "%s%s" $my_toplevel  _flops.repC] { report_register -edge }
redirect [format "%s%s" $my_toplevel  _violators.repC] { report_constraint -all_violators }
redirect [format "%s%s" $my_toplevel  _power.repC] { report_power }
redirect [format "%s%s" $my_toplevel  _max_timing.repC] { report_timing -delay max -nworst 3 -max_paths 20 -greater_path 0 -path full -nosplit}
redirect [format "%s%s" $my_toplevel  _min_timing.repC] { report_timing -delay min -nworst 3 -max_paths 20 -greater_path 0 -path full -nosplit}
redirect [format "%s%s" $my_toplevel  _out_min_timing.repC] { report_timing -to [all_outputs] -delay min -nworst 3 -max_paths 1000000 -greater_path 0 -path full -nosplit}

#quit
