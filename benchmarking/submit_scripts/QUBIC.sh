#!/bin/bash

# QUBIC - 108
r_param=(1 3 6)
c_param=(0.90 0.95 0.99)
q_param=(0.01 0.06 0.1 0.2)

algorithm="QUBIC"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=3
for r in "${r_param[@]}"; do
	for q in "${q_param[@]}"; do
		for c in "${c_param[@]}"; do

			if (($r >= 6)); then
				MEM_QUBIC=20G
			else
				MEM_QUBIC=$MEMORY
			fi

			nm="${algorithm}_${filename}_ntop-${nt}_rparam-${r}_qparam-${q}_cparam-${c}"
			tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

			cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEM_QUBIC
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
   --nclust $nclust \\
   --r_param $r \\
   --q_param $q \\
   --c_param $c \\
&& mv $tmp_sh $here_dir/.done/
EOF
			chmod +x "$tmp_sh"

			mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
				--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
				--threads=$THREADS \
				--memory=$MEM_QUBIC \
				-t $MINUTES \
				bash "$tmp_sh"

			if [ "$test_run" = true ]; then
				break $n_loops
			fi
		done
	done
done
