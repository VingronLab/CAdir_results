#!/bin/bash

###############
# scG-cluster #
###############
TMP_DIR=20G
SCG_MINUTES=$(awk "BEGIN {printf \"%d\", $MINUTES * 2}")
SCG_MEMORY=$(awk "BEGIN {printf \"%d\", ${MEMORY%G} * 1.5}")"G"

scg_nclust=(4 6 8 10 12 14)
scg_method=("ncos" "p" "heat")
pretrain=(400 800)
train=(300)
#6*2*3 = 36

n_loops=4
algorithm="scG-cluster"
SCRIPT="${scripts_path}/${algorithm}.R"

for c in "${scg_nclust[@]}"; do
	for m in "${scg_method[@]}"; do
		for p in "${pretrain[@]}"; do
			for t in "${train[@]}"; do

				nm="${algorithm}_${filename}_ntop-${nt}_nclust-${c}_meth-${m}_pretrain-${p}_train-${t}"
				tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

				cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$SCG_MEMORY
# t=$SCG_MINUTES
# tmpdir=$TMP_DIR
# END_MXQ

trap 'echo ERROR_TIMEOUT >&2' SIGXCPU

echo \$MXQ_JOB_TMPDIR

Rscript-4.2.2 $SCRIPT   \\
--outdir $OUTDIR  \\
--file $f \\
--dataset $dataset \\
--name $nm \\
--ntop $nt \\
--sim $sim \\
--cell_clustering $cc \\
--truth $truth \\
--n_clusters $c \\
--scg_method $m \\
--tmpdir \$MXQ_JOB_TMPDIR \\
--seed 0 \\
--train $t \\
--pretrain $p \\
&& mv $tmp_sh $here_dir/.done/
EOF
				chmod +x "$tmp_sh"

				# NOTE: For GPU!
				# mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
				# 	--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
				# 	--threads=$THREADS \
				# 	--memory=$SCG_MEMORY \
				# 	--tmpdir=$TMP_DIR \
				# 	--gpu \
				# 	-t $SCG_MINUTES \
				# 	--blacklist="bandersnatch" \
				# 	bash "$tmp_sh"

				# NOTE: for CPU!
				mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
					--group-name="cpu_bench_${mode}_${dataset}_${filename}_${algorithm}" \
					--threads=$THREADS \
					--memory=$SCG_MEMORY \
					--tmpdir=$TMP_DIR \
					-t $SCG_MINUTES \
					--blacklist="bandersnatch" \
					bash "$tmp_sh"

				if [ "$test_run" = true ]; then
					break $n_loops
				fi
			done
		done
	done
done
