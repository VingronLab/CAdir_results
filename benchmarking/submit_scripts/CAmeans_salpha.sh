#!/bin/bash

#####################
# old CAdir Salpha ##
#####################

cameans_sa_kdir=(6 10 20 30)
cameans_sa_dims=(10 30 80)
cameans_sa_qcut=(0.6 0.8 0.9)

CADIR_MINUTES=$((MINUTES / 2))

algorithm="old_cadir_sa"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=3
for d in "${cameans_sa_dims[@]}"; do
	for k in "${cameans_sa_kdir[@]}"; do
		for q in "${cameans_sa_qcut[@]}"; do

			nm="${algorithm}_${filename}_ntop-${nt}_kdirs-${k}_ndim-${d}_qcut-${q}"
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
