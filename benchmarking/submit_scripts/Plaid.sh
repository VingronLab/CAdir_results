#!/bin/bash

# Plaid - 108
rrelease=(0.50 0.54 0.58 0.62 0.66 0.70)
crelease=(0.50 0.54 0.58 0.62 0.66 0.70)

algorithm="Plaid"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=2
for rr in "${rrelease[@]}"; do
	for cr in "${crelease[@]}"; do

		nm="${algorithm}_${filename}_ntop-${nt}_rrelease-${rr}_crelease-${cr}"
		tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

		cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$MINUTES
# END_MXQ

export LD_LIBRARY_PATH=$LD_LIBRARY_VAR:\$LD_LIBRARY_PATH
export GDAL_DATA=$GDAL_DATA_VAR:\$GDAL_DATA

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
   --rrelease $rr \\
   --crelease $cr \\
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
