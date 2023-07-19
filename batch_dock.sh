#!/bin/bash
source $PROJECT_HOME/source_files/vina.source
source $PROJECT_HOME/source_files/conda.source
conda activate cheminfo2

LIG_I=${1}
LIGDIR=${2}
REC=${3}
VINA_CONF=${4}

cd $LIGDIR
SAVEDIR="$LIGDIR/$(basename $REC .pdbqt)_$(basename $VINA_CONF .txt)"

# create save directory if it does not exist
if [ ! -d $SAVEDIR ]; then
        mkdir $SAVEDIR
fi

# create file list if it does not exist
if [ ! -f $LIGDIR/file_list.txt ]; then
    ls $LIGDIR | grep .tar.bz2 > $LIGDIR/file_list.txt
fi

# set $TARFILE variable as path to tar file which contains many
# compressed ligands (each one a separate mol2 file)
if test -e $LIGDIR/file_list.txt; then
  TARFILE="$(sed "${LIG_I}q;d" $LIGDIR/file_list.txt)"
else
  TARFILE=${LIG_I}.tar.bz2
fi
TARFILE="$(sed "${LIG_I}q;d" $LIGDIR/file_list.txt)"
TARNAME=$(basename $TARFILE .tar.bz2)
mkdir $SAVEDIR/$TARNAME
mkdir $LIGDIR/$TARNAME

# decompress the ligand ar file
tar -xf $LIGDIR/$TARFILE -C $LIGDIR/$TARNAME
cd $LIGDIR/$TARNAME
mkdir -p $SAVEDIR/$TARNAME/docked
mkdir -p $SAVEDIR/$TARNAME/vina_logs
mkdir -p $LIGDIR/$TARNAME/pdbqt
for MOL2FILE in $LIGDIR/$TARNAME/*.mol2; do
	echo "MOL2FILE: $MOL2FILE"
	LIGNAME=$(basename $MOL2FILE .mol2)
	START_T=$(date +%s)
	LIGPATH=$LIGDIR/$TARNAME/pdbqt/${LIGNAME}.pdbqt

  #prepare ligand for vina docking
	prepare_ligand4.py -l $MOL2FILE -o $LIGPATH -U nphs_lps -v\
	&& END_T=$(date +%s)\
	&& echo "Lig prep time: $((END_T-START_T))s"\
	&& echo "LIGNAME: $LIGNAME"\
	&& echo "Ligand path: $LIGPATH"\
	&& echo "RUN VINA COMMAND: --ligand $LIGPATH --receptor $REC --config $VINA_CONF --out $SAVEDIR/$TARNAME/docked/${LIGNAME}.pdbqt --log $SAVEDIR/$TARNAME/vina_logs/${LIGNAME}_log.txt"\

  # run vina
  && vina --ligand $LIGPATH --receptor $REC --config $VINA_CONF --out $SAVEDIR/$TARNAME/docked/${LIGNAME}.pdbqt --log $SAVEDIR/$TARNAME/vina_logs/${LIGNAME}_log.txt
done;

# compress results and clean up
cd $SAVEDIR
tar -cf $TARNAME.tar $TARNAME
rm -rf $SAVEDIR/$TARNAME
cd $LIGDIR
tar -cf $TARNAME.tar $TARNAME
rm -rf $LIGDIR/$TARNAME
rm $TARFILE
