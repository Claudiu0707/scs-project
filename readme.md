
Before every commit, run this command in the TCL Console:
`write_project_tcl -force -no_copy_sources -target_proj_dir ./vivado <absolute_path_to_project_root>/scripts/create_project.tcl`

Windows example:
`write_project_tcl -force -no_copy_sources -target_proj_dir ./vivado C:/Users/<USER_NAME>/Desktop/<PROJECT_NAME>/scripts/create_project.tcl`

After pulling:
- check the project directory: if folder vivado/ exists, delete it
- open vivado home screen and run the following command in the TCL Console: `source C:/Users/<USER_NAME>/Desktop/<PROJECT_NAME>/scripts/setup.tcl`
  for Linux: `source /home/<USER_NAME>/<SPECIFIC_PATH_TO_PROJECT_DIRECTORY>/<PROJECT_NAME>/scripts/setup.tcl`