#!/bin/bash

THREADS=12
MEMORY=50G
MINUTES=1200

# date=$(date '+%Y%m%d')
# date="260418_TEST"
date="20260325_revision2"

outdir="./results/benchmarking/results/ct_detection/${date}"
# outdir="./results/benchmarking/results/ct_detection_batch_corr/${date}"
logdir="${outdir}/log/"
resdir="${outdir}/out/"

mkdir -p "$outdir"
mkdir -p "$logdir"
mkdir -p "$resdir"

# SCRIPT="./benchmarking/ct_detection/ct_detection_batch_correction.R"

test_run=false
nr_cts=(4 6 8 10 12 14 16 18 20 22 24 26 28 30)

#########
# CAdir #
#########
ks=(5 10 15 20 25 30)
apl_qs=(0.9900 0.9990 0.9999)
SCRIPT="./benchmarking/ct_detection/ct_detection_clusters.R"

for k in "${ks[@]}"; do
  for n in "${nr_cts[@]}"; do
    for q in "${apl_qs[@]}"; do

      if [[ $n -le 10 ]]; then
        THREADS=6
        MEMORY=50G
        MINUTES=720
      elif [[ $n -gt 10 && $n -le 20 ]]; then
        THREADS=6
        MEMORY=100G
        MINUTES=960
      elif [[ $n -gt 20 && $n -le 30 ]]; then
        THREADS=12
        MEMORY=200G
        MINUTES=1200
      else
        THREADS=32
        MEMORY=500G
        MINUTES=1200
      fi

      mxqsub \
        --stdout="${logdir}/ct_detection_k-${k}_n-${n}_q-${q}.stdout.log" \
        --group-name="ct_detection_subs_${date}" \
        --threads=$THREADS \
        --memory=$MEMORY \
        -t $MINUTES \
        Rscript-4.4.0 $SCRIPT \
        --outdir $resdir \
        --k "$k" \
        --n "$n" \
        --q "$q" \
        --subset_cts \
        --cellpcl 200
        # --pd

      if [ "$test_run" = true ]; then
        break 3
      fi
    done
  done
done


##########
# Seurat #
##########

# ks=(5 10 15 20 25 30)
ks=(25 30 35 40 45 50)
resolution=(0.5 1.0 1.5)
SCRIPT="./benchmarking/ct_detection/ct_detection_clusters_seurat.R"

for k in "${ks[@]}"; do
  for n in "${nr_cts[@]}"; do
    for r in "${resolution[@]}"; do

      if [[ $n -le 10 ]]; then
        THREADS=6
        MEMORY=50G
        MINUTES=720
      elif [[ $n -gt 10 && $n -le 20 ]]; then
        THREADS=6
        MEMORY=100G
        MINUTES=960
      elif [[ $n -gt 20 && $n -le 30 ]]; then
        THREADS=12
        MEMORY=200G
        MINUTES=1200
      else
        THREADS=32
        MEMORY=500G
        MINUTES=1200
      fi

      mxqsub \
        --stdout="${logdir}/ct_detection_k-${k}_n-${n}_r-${r}.stdout.log" \
        --group-name="ct_detection_subs_${date}" \
        --threads=$THREADS \
        --memory=$MEMORY \
        -t $MINUTES \
        Rscript-4.4.0 $SCRIPT \
        --outdir $resdir \
        --n "$n" \
        --NNs "$k" \
        --resolution "$r" \
        --subset_cts \
        --cellpcl 200
        # --pd

      if [ "$test_run" = true ]; then
        break 3
      fi
    done
  done
done
