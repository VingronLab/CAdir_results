#!/bin/bash

THREADS=6
MEMORY=3G
MINUTES=500

date="20240812"
outdir="./results/benchmarking/results/real/${date}/eval"
indir="./results/benchmarking/results/real/${date}/out/"

files=$(ls ./results/benchmarking/results/real/${date}/out/)

mkdir -p $outdir

for file in $files
do
echo $file
  mxqsub --stdout=$outdir/"$file.stdout.log" \
         --group-name="gather_results_real" \
         --threads=$THREADS \
         --memory=$MEMORY \
         -t $MINUTES \
	Rscript-4.4.0 ./benchmarking/collate_results.R \
    --name "${date}_${file}_collated" \
    --indir  $indir/$file \
    --outdir $outdir
done
