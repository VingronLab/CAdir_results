#!/bin/bash

#########################
# old CAmeans subspace ##
#########################
subsp_kdir=(6 15)
subsp_dims=(10 20 30)
subsp_angle=(40 50)
subsp_qcut=(0.8)
subsp_cdim=(1 2 3)

CADIR_MINUTES=$((MINUTES / 2))

algorithm="old_cadir_subspace"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=5
for d in "${subsp_dims[@]}"; do
	for k in "${subsp_kdir[@]}"; do
		for q in "${subsp_qcut[@]}"; do
			for a in "${subsp_angle[@]}"; do
				for c in "${subsp_cdim[@]}"; do

					nm="${algorithm}_${filename}_ntop-${nt}_kdirs-${k}_ndim-${d}_qcut-${q}_angle-${a}_cdim-${c}"
					tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

					cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$CADIR_MINUTES
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
--kdir $k \\
--dims $d \\
--qcut $q \\
--angle $a \\
--subsp_dim $c \\
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
done
