#!/bin/bash

################
# old CAmeans ##
################
cameans_kdir=(6 15 30)
cameans_dims=(10 30)
cameans_angle=(30 40 50)
cameans_qcut=(0.6 0.8)

CADIR_MINUTES=$((MINUTES / 2))

algorithm="old_cadir"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=4
for d in "${cameans_dims[@]}"; do
	for k in "${cameans_kdir[@]}"; do
		for q in "${cameans_qcut[@]}"; do
			for a in "${cameans_angle[@]}"; do

				nm="${algorithm}_${filename}_ntop-${nt}_kdirs-${k}_ndim-${d}_qcut-${q}_angle-${a}"
				tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

				cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$CADIR_MINUTES
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
--kdir $k \\
--dims $d \\
--qcut $q \\
--angle $a \\
&& mv $tmp_sh $here_dir/.done/
EOF
				chmod +x "$tmp_sh"

				mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
					--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
					--threads=$THREADS \
					--memory=$MEMORY \
					-t $CADIR_MINUTES \
					bash "$tmp_sh"

				if [ "$test_run" = true ]; then
					break $n_loops
				fi
			done
		done
	done
done
