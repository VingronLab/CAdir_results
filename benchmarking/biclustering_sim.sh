#!/bin/bash

# add date to output folder
# date=$(date '+%Y%m%d')
date="20251204"

THREADS=6
MEMORY=4G
MINUTES=240

dataset="pbmc3k"
# dataset="zeisel"

scripts_path="./benchmarking/algorithms/"

outdir="./results/benchmarking/results/biclustering/${date}"

logdir="${outdir}/log/${dataset}"
here_dir="${outdir}/sh/${dataset}"

mkdir -p "$outdir"
mkdir -p "$logdir"
mkdir -p "$here_dir"
mkdir -p "$here_dir/.done/"

OUTDIR="${outdir}/out/${dataset}"
mkdir -p "$OUTDIR"

files="./data/sim/preprocessed/${dataset}/*.rds"

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
		# source ./benchmarking/submit_scripts/CAbiNet.sh

		#########
		# QUBIC #
		#########
		# source ./benchmarking/submit_scripts/QUBIC.sh

		########
		# s4vd #
		########
		# source ./benchmarking/submit_scripts/s4vd.sh

		#########
		# Plaid #
		#########
		# source ./benchmarking/submit_scripts/Plaid.sh

		#######
		# CCA #
		#######
		# source ./benchmarking/submit_scripts/CCA.sh

		##########
		# Seurat #
		##########
		# source ./benchmarking/submit_scripts/Seurat.sh

		############
		# Monocle3 #
		############
		# source ./benchmarking/submit_scripts/Monocle3.sh

		############
		# BackSPIN #
		############
		# source ./benchmarking/submit_scripts/backSPIN.sh

		###########
		# CAdir   #
		###########
		# source ./benchmarking/submit_scripts/CAdir.sh

		############
		# kmeans   #
		############
		# source ./benchmarking/submit_scripts/kmeans.sh
		
    #########
		# NMF   #
		#########
		source ./benchmarking/submit_scripts/nmf.sh

			if [ "$test_run" = true ]; then
				break 2
			fi
	done
done
