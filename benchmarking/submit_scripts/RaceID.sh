#!/bin/bash

############
## RACEID ##
############

raceid_k=(5 8 10 15) # Number of clusters.
raceid_metric=("euclidean" "pearson" "logpearson")
clustering_alg=("kmedoids" "kmeans" "hclust")
# 4*3*3

n_loops=3
algorithm="RaceID"
SCRIPT="${scripts_path}/${algorithm}.R"
auto_mode=0 # set sat=FALSE, cln=NULL

for k in "${raceid_k[@]}"; do
  for m in "${raceid_metric[@]}"; do
    for c in "${clustering_alg[@]}"; do

      nm="${algorithm}_${filename}_ntop-${nt}_auto_mode-${auto_mode}_k-${k}_metric-${m}_alg-${c}"
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
--auto_mode $auto_mode \\
--raceid_k $k \\
--raceid_metric $m \\
--clustering_alg $c \\
--samp 1000 \\
&& mv $tmp_sh $here_dir/.done/
EOF
      chmod +x "$tmp_sh"

      mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
        --group-name="bench_${mode}_${dataset}_${filename}_${algorithm}_auto" \
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

samps=(1000 2000 3000 4000)

n_loops=3
auto_mode=1 # set sat=FALSE, cln=NULL
k=0
for m in "${raceid_metric[@]}"; do
  for c in "${clustering_alg[@]}"; do
    for s in "${samps[@]}"; do

      nm="${algorithm}_${filename}_ntop-${nt}_auto_mode-${auto_mode}_k-${k}_metric-${m}_alg-${c}_samp-${s}"
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
--auto_mode $auto_mode \\
--raceid_k $k \\
--raceid_metric $m \\
--clustering_alg $c \\
--samp $s \\
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
