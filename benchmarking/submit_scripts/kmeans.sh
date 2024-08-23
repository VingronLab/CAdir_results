#!/bin/bash

############
# kmeans  ##
############

kmeansk=(3 6 9 12)
dims_km=(10 30 50)
qcut_km=(0.7 0.8 0.9)
coords=("prin")

KMEANS_MINUTES=120

algorithm="kmeans"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=4
for d in "${dims_km[@]}"; do
	for k in "${kmeansk[@]}"; do
		for q in "${qcut_km[@]}"; do
			for c in "${coords[@]}"; do

				nm="${algorithm}_${filename}_ntop-${nt}_k-${k}_ndim-${d}_qcut-${q}_coords-${c}"
				tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

				cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$KMEANS_MINUTES
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
--kmeansk $k \\
--dims $d \\
--qcut $q \\
--coords $c \\
&& mv $tmp_sh $here_dir/.done/
EOF
				chmod +x "$tmp_sh"

				mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
					--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
					--threads=$THREADS \
					--memory=$MEMORY \
					-t $KMEANS_MINUTES \
					bash "$tmp_sh"

        if [ "$test_run" = true ]; then
          break $n_loops
        fi
			done
		done
	done
done
