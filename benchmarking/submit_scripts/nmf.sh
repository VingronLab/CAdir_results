#!/bin/bash

k_nmf=(5 6 7)
l_sparse=(0 0.001 0.01 0.1)
nseeds=(10 25 50)

algorithm="nmf"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=3
for k in "${k_nmf[@]}"; do
  for l in "${l_sparse[@]}"; do
    for n in "${nseeds[@]}"; do

      nm="${algorithm}_${filename}_ntop-${nt}_k-${k}_l1-${l}_nseeds-${n}"
      tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

      cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
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
   --k_nmf $k \\
   --L1 $l \\
   --nseeds $n \\
&& mv $tmp_sh $here_dir/.done/
EOF
      chmod +x "$tmp_sh"

      mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
        --group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
        --threads=$THREADS \
        --memory=$MEMORY \
        -t $MINUTES \
        bash "$tmp_sh"

      if [ "$test_run" = true ]; then
        break $n_loops
      fi
    done
  done
done
