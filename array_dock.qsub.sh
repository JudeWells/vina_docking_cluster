#$ -l tmem=7.9G
#$ -l h_vmem=7.9G
#$ -l h_rt=02:56:02
#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -j y
#$ -N adv
#$ -wd /SAN/orengolab/nsp13/shared/logs
#$ -t 1-35489

# This script runs an array job to convert all of the ligands from mol2 into pdbqt and 
# runs autodock vina on all ligands

# information for logging / debugging
START_T=$(date +%s)
hostname
date

# set local directory variables
export PROJECT_USER=shared
export PROJECT_DIR=/SAN/orengolab/nsp13

export PROJECT_HOME=${PROJECT_DIR}/${PROJECT_USER}
#export LIGDIR=$PROJECT_HOME/data/ligand_files/disco_divers2/disco_divers
export LIGDIR=$PROJECT_HOME/data/ligand_files/batchtar_advanced
# activate source files so that conda and vina executables can be found
source $PROJECT_HOME/source_files/vina.source
source $PROJECT_HOME/source_files/conda.source
conda activate cheminfo2

REC=$PROJECT_HOME/data/receptor/wim_charmm_structures/6zsl_prep.pdbqt
VINA_CONF=$LIGDIR/config_jw_6zsl_charmm.txt

# run the main script $SGE_TASK_ID is index of the array job
bash $PROJECT_HOME/batch_dock.sh $SGE_TASK_ID $LIGDIR $REC $VINA_CONF

# output information for logging / debugging
date
END_T=$(date +%s)
echo "Lasted: $((END_T-START_T))s"
