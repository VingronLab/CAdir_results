#!/bin/bash

# CCA - 108
delta=(0.5 1.0 1.5 2.0 2.5 3.0)
alpha=(0.5 1.0 1.5 2.0 2.5 3.0)

algorithm="CCA"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=2
for de in "${delta[@]}"; do
	for al in "${alpha[@]}"; do

		nm="${algorithm}_${filename}_ntop-${nt}_delta-${de}_alpha-${al}"
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
   --nclust $nclust \\
   --delta $de \\
   --alpha $al \\
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
