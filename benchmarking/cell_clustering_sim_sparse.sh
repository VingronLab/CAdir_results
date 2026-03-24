#!/bin/bash

# add date to output folder
# date=$(date '+%Y%m%d')
# date="20260320_revision2"
date="20260325_revision2"

THREADS=6
MEMORY=30G
MINUTES=60

datasets=("zeisel" "pbmc3k")
for dataset in "${datasets[@]}"; do

	scripts_path="./benchmarking/algorithms/"

	outdir="./results/benchmarking/results/simulated_sparse/${date}"

	logdir="${outdir}/log/${dataset}"
	here_dir="${outdir}/sh/${dataset}"

	mkdir -p "$outdir"
	mkdir -p "$logdir"
	mkdir -p "$here_dir"
	mkdir -p "$here_dir/.done/"

	OUTDIR="${outdir}/out/${dataset}"
	mkdir -p "$OUTDIR"

	files="./data/sim/preprocessed_sparse/${dataset}/*.rds"

	ntop=(2000 4000 6000)
	# nclust=6
	truth="Group"
	cc=1  # set is_cell_clustering to TRUE
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

			##########
			# Seurat #
			##########
			source ./benchmarking/submit_scripts/Seurat.sh

			############
			# Monocle3 #
			############
			# source ./benchmarking/submit_scripts/Monocle3.sh

			###########
			# CAdir   #
			###########
			# source ./benchmarking/submit_scripts/CAdir.sh

			############
			# kmeans   #
			############
			# source ./benchmarking/submit_scripts/kmeans.sh

			############
			# RaceID   #
			############
			# source ./benchmarking/submit_scripts/RaceID.sh

			########
			# SC3  #
			########
			# source ./benchmarking/submit_scripts/SC3.sh

			##########
			# SIMLR  #
			##########
			# source ./benchmarking/submit_scripts/SIMLR.sh

      ##################
			# scDeepCluster  #
      ##################
			# source ./benchmarking/submit_scripts/scDeepCluster.sh

      ###############
      # scG-cluster #
      ###############
      # source ./benchmarking/submit_scripts/scG-cluster.sh
      
      ##########
      # QUBIC2 #
      ##########
      source ./benchmarking/submit_scripts/QUBIC2.sh

			if [ "$test_run" = true ]; then
				break 3
			fi
		done
	done
done
