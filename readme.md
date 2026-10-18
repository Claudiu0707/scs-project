### Project Setup
Requires **Vivado 2024.2**

1. Choose a folder and clone the repo
`git clone https://github.com/Claudiu0707/scs-project.git`
2. Open Vivado, close any open project and run the following command in the **TCL Console**:
   
	**Windows:** `source C:/Users/<USER_NAME>/<PATH_TO_PROJECT>/<PROJECT_NAME>/scripts/create_project.tcl `
   
	**Linux:** `source /home/<USER_NAME>/<PATH_TO_PROJECT>/<PROJECT_NAME>/scripts/create_project.tcl`

**Rebuild the project after every `git pull`, `git checkout`, or`git merge`using the same procedure.** 

------------

### Project Structure

    scs-project/
    ├── .gitignore
    ├── .gitattributes
    ├── scripts/
    │   └── create_project.tcl
    └── src/
        ├── hdl/                 
        ├── sim/                 
        └── constraints/  

#### Creating files
When creating a new file in Vivado, change **File location** from ***Local to project*** to ***Choose location*** and pick the right folder in `src/` (for example, a VHD design file goes in `src/hdl/`) to ensure that the file is tracked by git.
