#!/bin/bash

# backSPIN

# Levels:
# Level_0_group (always 0)
# Level_1_group (0 - 1)
# Level_2_group (0 - 3)
# Level_3_group (0 - 7)
# Level_4_group (0 - 15)

numLevels=(3 4 5 6)
stop_const=(0.5 0.825 1.15)
low_thrs=(0.1 0.2 0.3)

BS_MINUTES=600

algorithm="BackSPIN"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=3
for l in "${numLevels[@]}"; do
	for s in "${stop_const[@]}"; do
		for t in "${low_thrs[@]}"; do

			nm="${algorithm}_${filename}_ntop-${nt}_numLevels-${l}_stopconst-${s}_lowthrs-${t}"
			tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

			cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$BS_MINUTES
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
  --numLevels $l \\
  --stop_const $s \\
  --low_thrs $t \\
&& mv $tmp_sh $here_dir/.done/
EOF
			chmod +x "$tmp_sh"

			mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
				--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
				--threads=$THREADS \
				--memory=$MEMORY \
				-t $BS_MINUTES \
				bash "$tmp_sh"

			if [ "$test_run" = true ]; then
				break $n_loops
			fi
		done
	done
done
