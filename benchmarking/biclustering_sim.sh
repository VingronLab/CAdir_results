#!/bin/bash
# TODO: Move to more sensible number than 108 parameter choices. Best divisible number.
# -> 120 is a good choice.

# add date to output folder
# date=$(date '+%Y%m%d')
date="20250403"

THREADS=6
MEMORY=4G
MINUTES=240

LD_LIBRARY_VAR=/home/kohl/.local/lib:/home/kohl/.local/bin:/home/kohl/.local/include
GDAL_DATA_VAR=/home/kohl/.local/share/gdal

dataset="pbmc3k"
# dataset="zeisel"

scripts_path="./algorithms/"

outdir="/project/kohl_data/CAdir/benchmarking/results/biclustering/${date}"

logdir="${outdir}/log/${dataset}"
here_dir="${outdir}/sh/${dataset}"

mkdir -p "$outdir"
mkdir -p "$logdir"
mkdir -p "$here_dir"
mkdir -p "$here_dir/.done/"

OUTDIR="${outdir}/out/${dataset}"
mkdir -p "$OUTDIR"

files="/project/kohl_data/CAdir/data/sim/preprocessed/${dataset}/*.rds"

ntop=(2000 4000 6000)
nclust=6
truth='Group'
cc=0  # set is_cell_clustering to FALSE
sim=1 # set simulation to TRUE

test_run=false

if [[ $sim -eq 0 ]]; then
	mode="real"
elif [[ $sim -eq 1 ]]; then
	mode="sim"
else
	echo "UNCLEAR IF SIM OR NOT"
	exit 0
fi

for f in ${files[@]}; do

	filename=$(basename $f .rds)

	for nt in "${ntop[@]}"; do

		###########
		# CAbiNet #
		###########
		source ./submit_scripts/CAbiNet.sh

		#########
		# QUBIC #
		#########
		source ./submit_scripts/QUBIC.sh

		########
		# s4vd #
		########
		source ./submit_scripts/s4vd.sh

		#########
		# Plaid #
		#########
		source ./submit_scripts/Plaid.sh

		#######
		# CCA #
		#######
		source ./submit_scripts/CCA.sh

		##########
		# Seurat #
		##########
		source ./submit_scripts/Seurat.sh

		############
		# Monocle3 #
		############
		source ./submit_scripts/Monocle3.sh

		############
		# BackSPIN #
		############
		source ./submit_scripts/backSPIN.sh

		###########
		# CAdir   #
		###########
		source ./submit_scripts/CAdir.sh

		############
		# kmeans   #
		############
		source ./submit_scripts/kmeans.sh

	done
done
