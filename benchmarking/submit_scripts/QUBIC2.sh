#!/bin/bash

MXQ_TMPDIR=100G

qQubic2=(0.02 0.06 0.1)   # quantile threshold for discretiziation
q_nclust=(4 6 8 10 14 18) # number of clusters
# -d: KL, -d -C: KL dual, -d -C -N: qubic1.0 objective function + dual
# -d tells qubic2 its discretized data
objF=("C" "N") # objective function, do not test regular expansion.

n_loops=3
for q in "${qQubic2[@]}"; do
  for o in "${q_nclust[@]}"; do
    for c in "${objF[@]}"; do
			
      nm="${algorithm}_${filename}_ntop-${nt}_quant-${q}_qnclust-${o}_objf-${c}"
			tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

			cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEM_QUBIC
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
   --objF $c \\
&& mv $tmp_sh $here_dir/.done/
EOF
			chmod +x "$tmp_sh"

			mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
				--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
				--threads=$THREADS \
				--memory=$MEM_QUBIC \
        --tmpdir=$MXQ_TMPDIR \
				-t $MINUTES \
				bash "$tmp_sh"


      if [ "$test_run" = true ]; then
        break $n_loops
      fi
    done
  done
done
