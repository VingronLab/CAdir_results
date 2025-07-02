#!/bin/bash

#################
# scDeepCluster #
#################
TMP_DIR=20G

SCD_MINUTES=$(awk "BEGIN {printf \"%d\", $MINUTES * 2}")
SCD_MEMORY=$(awk "BEGIN {printf \"%d\", ${MEMORY%G} * 1.5}")"G"

scdeep_nclust=(4 6 8 10 12 14)
scdeep_knn=(20 50)
scdeep_res=(0.8 1 1.2)
#6*2*3 = 36

# dl_device="cuda"
dl_device="cpu"

n_loops=3
algorithm="scDeepCluster"
SCRIPT="${scripts_path}/${algorithm}.R"

for n in "${scdeep_nclust[@]}"; do
	for k in "${scdeep_knn[@]}"; do
		for r in "${scdeep_res[@]}"; do

			nm="${algorithm}_${filename}_ntop-${nt}_nclust-${n}_knn-${k}_res-${r}"
			tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

			cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$SCD_MEMORY
# t=$SCD_MINUTES
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
--n_clusters $n \\
--knn $k \\
--device $dl_device \\
--resolution $r \\
--tmpdir \$MXQ_JOB_TMPDIR \\
&& mv $tmp_sh $here_dir/.done/
EOF
			chmod +x "$tmp_sh"

      # NOTE: For GPU!
			# mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
			# 	--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
			# 	--threads=$THREADS \
			# 	--memory=$SCD_MEMORY \
			# 	-t $SCD_MINUTES \
			# 	--gpu \
			# 	--tmpdir=$TMP_DIR \
			# 	--blacklist="bandersnatch" \
			# 	bash "$tmp_sh"

      # NOTE: For CPU!
				mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
				 --group-name="cpu_bench_${mode}_${dataset}_${filename}_${algorithm}" \
				 --threads=$THREADS \
				 --memory=$SCD_MEMORY \
				 -t $SCD_MINUTES \
				 --tmpdir=$TMP_DIR \
				  --blacklist="bandersnatch" \
				 bash "$tmp_sh"

			if [ "$test_run" = true ]; then
				break $n_loops
			fi
		done
	done
done
