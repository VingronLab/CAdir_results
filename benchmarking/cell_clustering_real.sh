#!/bin/bash

# add date to output folder
# date=$(date '+%Y%m%d')
date="20240812"

THREADS=6
MEMORY=50G
MINUTES=240


datasets=("Darmanis"
	"FreytagGold"
	"PBMC_10X"
	"Tirosh_nonmaglignant"
	"BaronPancreas"
	"ZeiselBrain"
	"brain_organoids"
	"dmel_E14-16h"
	"tabula_sapiens_tissue")

small_ds=("Darmanis" "FreytagGold")
medium_ds=("PBMC_10X" "Tirosh_nonmaglignant" "BaronPancreas" "ZeiselBrain")
large_ds=("brain_organoids" "dmel_E14-16h" "tabula_sapiens_tissue")

for dataset in "${datasets[@]}"; do

	if [[ " ${small_ds[*]} " =~ " $dataset " ]]; then
		echo "$dataset is a small dataset."
		THREADS=6
		MEMORY=20G
		MINUTES=120
	elif [[ " ${medium_ds[*]} " =~ " $dataset " ]]; then
		echo "$dataset is a medium dataset."
		THREADS=6
		MEMORY=50G
		MINUTES=240
	elif [[ " ${large_ds[*]} " =~ " $dataset " ]]; then
    # continue
		echo "$dataset is a large dataset."
		THREADS=12
		MEMORY=150G
		MINUTES=480

	else
		echo "Unknown dataset!"
		THREADS=6
		MEMORY=30G
		MINUTES=80
	fi

	scripts_path="./benchmarking/algorithms/"

	outdir="./results/benchmarking/results/real/${date}"

	logdir="${outdir}/log/${dataset}"
	here_dir="${outdir}/sh/${dataset}"

	mkdir -p "$outdir"
	mkdir -p "$logdir"
	mkdir -p "$here_dir"
	mkdir -p "$here_dir/.done/"

	OUTDIR="${outdir}/out/${dataset}"
	mkdir -p "$OUTDIR"

	files="./data/real/preprocessed/benchmarking/${dataset}_filtered.rds"

	ntop=(2000 4000 6000)
	truth='truth'
	cc=1  #set is_cell_clustering to TRUE
	sim=0 # set simulation to FALSE

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

			##########
			# Seurat #
			##########
			source ./submit_scripts/Seurat.sh

			############
			# Monocle3 #
			############
			source ./submit_scripts/Monocle3.sh

			###########
			# CAdir   #
			###########
			source ./submit_scripts/CAdir.sh

			############
			# kmeans   #
			############
			source ./submit_scripts/kmeans.sh

			############
			# RaceID   #
			############
			source ./submit_scripts/RaceID.sh

			########
			# SC3  #
			########
			source ./submit_scripts/SC3.sh

			##########
			# SIMLR  #
			##########
			source ./submit_scripts/SIMLR.sh

			if [ "$test_run" = true ]; then
				break 3
			fi
		done
	done
done
