#!/bin/bash

# add date to output folder
# date=$(date '+%Y%m%d')
date="20240812"

THREADS=6
MEMORY=15G
MINUTES=60

LD_LIBRARY_VAR=/home/kohl/.local/lib:/home/kohl/.local/bin:/home/kohl/.local/include
GDAL_DATA_VAR=/home/kohl/.local/share/gdal

datasets=("zeisel" "pbmc3k")
for dataset in "${datasets[@]}"; do

	scripts_path="./algorithms/"

	outdir="/project/kohl_data/CAdir/benchmarking/results/simulated/${date}"

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
	# nclust=6
	truth='Group'
	cc=1  #set is_cell_clustering to TRUE
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
			# source ./submit_scripts/CAbiNet.sh

			##########
			# Seurat #
			##########
			# source ./submit_scripts/Seurat.sh

			############
			# Monocle3 #
			############
			# source ./submit_scripts/Monocle3.sh

			###########
			# CAdir   #
			###########
			source ./submit_scripts/CAdir.sh

			############
			# kmeans   #
			############
			# source ./submit_scripts/kmeans.sh

			############
			# RaceID   #
			############
			# source ./submit_scripts/RaceID.sh

			########
			# SC3  #
			########
			# source ./submit_scripts/SC3.sh

			##########
			# SIMLR  #
			##########
			# source ./submit_scripts/SIMLR.sh

			if [ "$test_run" = true ]; then
				break 3
			fi
		done
	done
done
