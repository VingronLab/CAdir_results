#!/bin/bash

# s4vd - 108
pcerv=(0.01 0.05 0.15)
pceru=(0.01 0.05 0.15)
ss_thr_min=(0.6 0.7)
ss_thr_add=(0.05 0.15)

algorithm="s4vd"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=4
for pv in "${pcerv[@]}"; do
	for pu in "${pceru[@]}"; do
		for ss in "${ss_thr_min[@]}"; do
			for sa in "${ss_thr_add[@]}"; do

				nm="${algorithm}_${filename}_ntop-${nt}_pcerv-${pv}_pceru-${pu}_ssthrmin-${ss}_ssthradd-${sa}"
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
   --pcerv $pv \\
   --pceru $pu \\
   --ss_thr_min $ss \\
   --ss_thr_add $sa \\
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
done
