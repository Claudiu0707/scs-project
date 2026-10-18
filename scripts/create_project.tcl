# ---- Settings you may need to edit (rarely) ----
set proj_name  "scs-project"
set part       "xc7a100tcsg324-1"
set design_top "top_module"      ;# main entity of your design
set sim_top    "top_module_sim"      ;# change to your testbench entity name
# ------------------------------------------------

# Find the repo folder (this file lives in <repo>/scripts)
set repo [file normalize [file join [file dirname [info script]] ..]]

# Create the project in <repo>/vivado (replaces an old one if it exists)
create_project $proj_name "$repo/vivado" -part $part -force

set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]
set_property enable_vhdl_2008 1 [current_project]

# Add every file found in src/ (no list to maintain)
set hdl_files [glob -nocomplain $repo/src/hdl/*.vhd]
if {[llength $hdl_files] > 0} { add_files -fileset sources_1 $hdl_files }

set sim_files [glob -nocomplain $repo/src/sim/*.vhd]
if {[llength $sim_files] > 0} { add_files -fileset sim_1 $sim_files }

set xdc_files [glob -nocomplain $repo/src/constraints/*.xdc]
if {[llength $xdc_files] > 0} { add_files -fileset constrs_1 $xdc_files }

# Set the top modules
set_property top $design_top [get_filesets sources_1]
set_property top $sim_top    [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1