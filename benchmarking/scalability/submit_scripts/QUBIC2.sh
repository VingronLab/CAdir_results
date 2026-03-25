#!/bin/bash

MXQ_TMPDIR=100G
############
## QUBIC2 ##
############

qQubic2=(0.06) 
q_nclust=(6)
objF=("C") 
q_cons=(1.0)

algorithm="QUBIC2"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=4
for q in "${qQubic2[@]}"; do
  for o in "${q_nclust[@]}"; do
    for l in "${objF[@]}"; do
      for c in "${q_cons[@]}"; do

        nm="${algorithm}_${filename}_ntop-${nt}_quant-${q}_qnclust-${o}_objf-${l}_qcons-${c}"
        tmp_sh="${here_dir}/bench_scalability_${mode}_${dataset}_${nm}.sh"

        cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# tmpdir=$MXQ_TMPDIR 
# t=$MINUTES
# END_MXQ

trap 'echo ERROR_TIMEOUT >&2' SIGXCPU

Rscript-4.2.2 $SCRIPT   \\
   --outdir $OUTDIR  \\
   --file $f \\
   --dataset $dataset \\
   --name $nm \\
   --ntop $nt \\
   --sim $sim \\
   --cell_clustering $cc \\
   --truth $truth \\
   --nclust $nclust \\
   --qqubic2 $q \\
   --qnclust $o \\
   --objF $l \\
   --qcons $c \\
&& mv $tmp_sh $here_dir/.done/
EOF
        chmod +x "$tmp_sh"

        mxqsub --stdout="${logdir}/bench_scalability_${mode}_${dataset}_${nm}.stdout.log" \
          --group-name="bench_scalability_${mode}_${dataset}_${filename}_${algorithm}" \
          --threads=$THREADS \
          --memory=$MEMORY \
          --tmpdir=$MXQ_TMPDIR \
          -t $MINUTES \
          bash "$tmp_sh"

        if [ "$test_run" = true ]; then
          break $n_loops
        fi
      done
    done
  done
done
