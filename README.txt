---SECTION 1: OVERVIEW---
The docking pipeline works as follows:
The main qsub script is designed to run docking as an array job on the cluster.
The script is called: array_dock.qsub.sh
which calls prep_dock_lig.sh on each node.
The pipeline is designed to work with a folder of .mol2 files
where each file contains one ligand.
Folders called 'docking', 'python_scripts'  and 'tests' are just used for testing not used in main pipeline

---SECTION 2: DOCKING STEPS---
1) We assume that the ligands start as an Enamine collection in a single .sdf file

2) Use obabel software to:
	- Convert from single .sdf to multiple .mol2, turn 2d into 3d and add Amber forcefields

3) Receptor needs to be in pdbqt format with protonation

(previous steps are assumed to have already been completed when array_dock.qsub.sh is run)

4) Use mgltools script prepare_ligand4.py to convert ligand mol2 file to .pdbqt

5) Prepare the receptor as a pdbqt file (do protonation and add charges)

6) Run docking using AutoDock Vina and a config file that gives bounding box and exhaustiveness
 	-results will be saved in subdirectory of the specified ligand directory 


---SECTION 3: REQUIREMENTS AND INSTALATION---
The following software is required:
AutoDockVina

The following packages need to be installed using conda:
- mgltools
- obabel (can be installed from source - ie not using conda)

Create a conda environment called cheminfo2 (install above packages in here)



