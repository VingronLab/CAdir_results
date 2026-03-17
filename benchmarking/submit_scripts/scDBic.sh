#!/bin/bash

##########
# scDBic #
##########
TMP_DIR=20G

SCD_MINUTES=$(awk "BEGIN {printf \"%d\", $MINUTES * 2}")
SCD_MEMORY=$(awk "BEGIN {printf \"%d\", ${MEMORY%G} * 2}")"G"

# NOTE: if you can find more parameters to adapt.
scdbic_seeds=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
  21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36)
# 2 modes x 5 seeds = 10 combinations

n_loops=3
algorithm="scDBic"
SCRIPT="${scripts_path}/${algorithm}.R"

for mode in "${scdbic_modes[@]}"; do
  for s in "${scdbic_seeds[@]}"; do

    nm="${algorithm}_${filename}_ntop-${nt}_mode-${mode}_seed-${s}"
    tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

    cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$SCD_MEMORY
# t=$SCD_MINUTES
# tmpdir=$TMP_DIR
# END_MXQ

trap 'echo ERROR_TIMEOUT >&2' SIGXCPU
echo \$MXQ_JOB_TMPDIR

Rscript-4.2.2 $SCRIPT   \\
  --outdir $OUTDIR  \\
  --file $f \\
  --dataset $dataset \\
  --name $nm \\
  --ntop $nt \\
  --sim $sim \\
  --cell_clustering $cc \\
  --truth $truth \\
  --scdbic_mode $mode \\
  --seed $s \\
  --tmpdir \$MXQ_JOB_TMPDIR \\
&& mv $tmp_sh $here_dir/.done/
EOF
    chmod +x "$tmp_sh"

    # NOTE: For GPU!
    # mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
    #   --group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
    #   --threads=$THREADS \
    #   --memory=$SCD_MEMORY \
    #   -t $SCD_MINUTES \
    #   --gpu \
    #   --tmpdir=$TMP_DIR \
    #   --blacklist="bandersnatch" \
    #   bash "$tmp_sh"

    # NOTE: For CPU!
    mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
      --group-name="cpu_bench_${mode}_${dataset}_${filename}_${algorithm}" \
      --threads=$THREADS \
      --memory=$SCD_MEMORY \
      -t $SCD_MINUTES \
      --tmpdir=$TMP_DIR \
      --blacklist="bandersnatch" \
      bash "$tmp_sh"

    if [ "$test_run" = true ]; then
      break $n_loops
    fi

  done
done
