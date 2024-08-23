#!/bin/bash

#######
# SC3 #
#######

#FIXME: Choose better parameter than messing with the num eigenv.
sc3_k=(0 4 6 8 10 15)
gene_filtering=(0 1)
d_min=(0.04 0.05 0.06)
d_max=(0.07 0.08 0.09)
# 3*6*2*3

n_loops=3
algorithm="SC3"
SCRIPT="${scripts_path}/${algorithm}.R"

for s in "${sc3_k[@]}"; do
	for g in "${gene_filtering[@]}"; do
		for index in "${!d_min[@]}"; do

			nm="${algorithm}_${filename}_ntop-${nt}_sc3_k-${s}_gene_filtering-${g}_dmin-${d_min[$index]}_dmax-${d_max[$index]}"
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
--sc3_k $s \\
--gene_filtering $g \\
--d_min ${d_min[$index]} \\
--d_max ${d_max[$index]} \\
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
