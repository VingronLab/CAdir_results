#!/bin/bash

#########################################################################################################
########### Attention:
########### The simulated data sets can be downloaded from online data repository.
########### Or you can also run the sim_generation.R script to generate simulated data sets by yourself.
#########################################################################################################


cd ./benchmarking/ || exit

# date=$(date '+%Y%m%d')
date="20240822"

scripts_path="./benchmarking/algorithms"

outdir="./results/benchmarking/results/scalability/${date}"

logdir="${outdir}/log/${dataset}"
here_dir="${outdir}/sh/${dataset}"

mkdir -p $outdir
mkdir -p $logdir
mkdir -p $here_dir
mkdir -p $here_dir/.done/

OUTDIR="${outdir}/out/${dataset}"
mkdir -p $OUTDIR

###########3

indir="./data/sim/preprocessed/scalability/"
datasets=$(ls -d ${indir}/*)

for dataset in ${datasets[@]}; do

	dataset=$(basename $dataset)

	files="${indir}/${dataset}/*.rds"

	ntop=(2000)
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

		# Extract the substring after "ncell-"
		substring=$(echo $filename | grep -o "ncell[^_]*")
		# Extract the number using regular expression
		number=$(echo "$substring" | grep -o '[0-9]*')

		if [[ "${substring}" == "ncell-1e+05" ]]; then
			number=100000
    elif [[ "${substring}" == "ncell-2e+05" ]]; then
			number=200000
    elif [[ "${substring}" == "ncell-4e+05" ]]; then
			number=400000
    elif [[ "${substring}" == "ncell-6e+05" ]]; then
			number=600000
		fi

    THREADS=1
    MEMORY=500G
    MINUTES=300

    MAXMEM=950G

		# Set runtime, memory depending on the number.
		if [[ $number -le 10000 ]]; then
			MEMORY=200G
			MINUTES=720
		elif [[ $number -gt 10000 && $number -le 60000 ]]; then
			MEMORY=450G
			MINUTES=1440
		elif [[ $number -gt 60000 && $number -le 400000 ]]; then
			MEMORY=950G
			MINUTES=1440
		else
			MEMORY=950G
			MINUTES=1440
		fi

		for nt in ${ntop[@]}; do

			###########
			# CAbiNet #
			###########
			source ./scalability/submit_scripts/CAbiNet.sh

			##########
			# Seurat #
			##########
			source ./scalability/submit_scripts/Seurat.sh

			############
			# Monocle3 #
			############
			source ./scalability/submit_scripts/Monocle3.sh

			###########
			# CAdir   #
			###########
			source ./scalability/submit_scripts/CAdir.sh

			############
			# kmeans   #
			############
			source ./scalability/submit_scripts/kmeans.sh

			############
			# RaceID   #
			############
			source ./scalability/submit_scripts/RaceID.sh

			########
			# SC3  #
			########
			source ./scalability/submit_scripts/SC3.sh

			##########
			# SIMLR  #
			##########
			source ./scalability/submit_scripts/SIMLR.sh

			if [ "$test_run" = true ]; then
				break 3
			fi

		done
	done
done
