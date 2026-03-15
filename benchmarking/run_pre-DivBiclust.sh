#!/bin/bash

scripts_path="./benchmarking/algorithms/"

ntop=(2000 4000 6000)

#############
# SIMULATED #
#############

THREADS=6
MEMORY=4G
MINUTES=240

datasets=("zeisel" "pbmc3k")
for dataset in "${datasets[@]}"; do

  outdir="./data/sim/preprocessed/${dataset}/DivBiclust"
  files="./data/sim/preprocessed/${dataset}/*.rds"

  truth="Group"
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

    logdir="${outdir}/${filename}/log/"
    here_dir="${outdir}/${filename}/sh"
    OUTDIR="${outdir}/${filename}/out"

    mkdir -p "$outdir"
    mkdir -p "$OUTDIR"
    mkdir -p "$logdir"
    mkdir -p "$here_dir"
    mkdir -p "$here_dir/.done/"


    for nt in "${ntop[@]}"; do

      ##################
      # pre-DivBiclust #
      ##################
      source ./benchmarking/submit_scripts/pre-DivBiclust.sh

      if [ "$test_run" = true ]; then
        break 3
      fi
    done
  done
done

########
# REAL #
########

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
    MEMORY=30G
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

  outdir="./data/real/preprocessed/benchmarking/DivBiclust/"

  files="./data/real/preprocessed/benchmarking/${dataset}_filtered.rds"

  truth="truth"
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

  for f in "${files[@]}"; do

    filename=$(basename "$f" .rds)

    logdir="${outdir}/${filename}/log/"
    here_dir="${outdir}/${filename}/sh"
    OUTDIR="${outdir}/${filename}/out"

    mkdir -p "$outdir"
    mkdir -p "$OUTDIR"
    mkdir -p "$logdir"
    mkdir -p "$here_dir"
    mkdir -p "$here_dir/.done/"

    for nt in "${ntop[@]}"; do

      ##################
      # pre-DivBiclust #
      ##################
      source ./benchmarking/submit_scripts/pre-DivBiclust.sh

      if [ "$test_run" = true ]; then
        break 3
      fi
    done
  done
done

##########
# SPARSE #
##########

THREADS=6
MEMORY=4G
MINUTES=240

datasets=("zeisel" "pbmc3k")
for dataset in "${datasets[@]}"; do

  scripts_path="./benchmarking/algorithms/"

  outdir="./data/sim/preprocessed_sparse/${dataset}/DivBiclust"
  files="./data/sim/preprocessed_sparse/${dataset}/*.rds"

  truth="Group"
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

    logdir="${outdir}/${filename}/log/"
    here_dir="${outdir}/${filename}/sh"
    OUTDIR="${outdir}/${filename}/out"

    mkdir -p "$outdir"
    mkdir -p "$OUTDIR"
    mkdir -p "$logdir"
    mkdir -p "$here_dir"
    mkdir -p "$here_dir/.done/"

    for nt in "${ntop[@]}"; do

      ##################
      # pre-DivBiclust #
      ##################
      source ./benchmarking/submit_scripts/pre-DivBiclust.sh

      if [ "$test_run" = true ]; then
        break 3
      fi
    done
  done
done


###############
# SCALABILITY #
###############

indir="./data/sim/preprocessed/scalability/"
datasets=$(ls -d ${indir}/*)

for dataset in ${datasets[@]}; do

	dataset=$(basename $dataset)

	files="${indir}/${dataset}/*.rds"
  
  outdir="./data/sim/preprocessed/scalability/${dataset}/DivBiclust"

	ntop=(2000)
	truth="Group"

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
    
    logdir="${outdir}/${filename}/log/"
    here_dir="${outdir}/${filename}/sh"
    OUTDIR="${outdir}/${filename}/out"
    
    mkdir -p "$outdir"
    mkdir -p "$OUTDIR"
    mkdir -p "$logdir"
    mkdir -p "$here_dir"
    mkdir -p "$here_dir/.done/"

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
      ##################
      # pre-DivBiclust #
      ##################
      source ./benchmarking/submit_scripts/pre-DivBiclust.sh

			if [ "$test_run" = true ]; then
				break 3
			fi

		done
	done
done


