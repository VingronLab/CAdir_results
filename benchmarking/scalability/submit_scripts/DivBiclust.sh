#!/bin/bash

# divbiclust
maxdiffs=(0.2)
seedColSzs=(60)
maxColSzs=(100)
do_rates=(0.1)
simThreshs=(0.5)

algorithm="DivBiclust"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=5
for maxdiff in "${maxdiffs[@]}"; do
  for seedColSz in "${seedColSzs[@]}"; do
    for maxColSz in "${maxColSzs[@]}"; do
      for simThresh in "${simThreshs[@]}"; do
        for do_rate in "${do_rates[@]}"; do

          nm="${algorithm}_${filename}_ntop-${nt}_maxdiff-${maxdiff}_seedColSz-${seedColSz}_maxColSz-${maxColSz}_simThresh-${simThresh}_doRate-${do_rate}"
					tmp_sh="${here_dir}/bench_scalability_${mode}_${dataset}_${nm}.sh"

          cat <<EOF >$tmp_sh
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
   --truth $truth \\
   --cell_clustering $cc \\
   --maxdiff $maxdiff \\
   --seedColSz $seedColSz \\
   --maxColSz $maxColSz \\
   --simThresh $simThresh \\
   --dorate $do_rate \\
&& mv $tmp_sh $here_dir/.done/
EOF
          chmod +x $tmp_sh

					mxqsub --stdout="${logdir}/bench_scalability_${mode}_${dataset}_${nm}.stdout.log" \
						--group-name="bench_scalability_${mode}_${dataset}_${filename}_${algorithm}" \
						--threads=$THREADS \
						--memory=$MEMORY \
            -t $MINUTES \
            bash $tmp_sh

					if [ "$test_run" = true ]; then
						break $n_loops
					fi
        done
      done
    done
  done
done
