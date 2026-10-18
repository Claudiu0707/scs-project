# Find the folder this file is in (the scripts folder)
set ::origin_dir_loc [file normalize [file dirname [info script]]]

# Move to the main repo folder, so the project is created in test-project/vivado
cd [file normalize "$::origin_dir_loc/.."]

# Run the generated recipe
source "$::origin_dir_loc/create_project.tcl"