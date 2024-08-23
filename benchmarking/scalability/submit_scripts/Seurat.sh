#!/bin/bash

# Seurat
res_seurat=(1)
dims_seurat=(30)
NNs_seurat=(20)
min_perc=(0.15)
logfc_thr=(0.25)
return_thr=(0.05)

algorithm="Seurat"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=6
for d in "${dims_seurat[@]}"; do
	for n in "${NNs_seurat[@]}"; do
		for r in "${res_seurat[@]}"; do
			for mp in "${min_perc[@]}"; do
				for lt in "${logfc_thr[@]}"; do
					for rt in "${return_thr[@]}"; do

						nm="${algorithm}_${filename}_ntop-${nt}_dims-${d}_NNs-${n}_resolution-${r}_minperc-${mp}_logfcthr-${lt}_return_thr-${rt}"
						tmp_sh="${here_dir}/bench_scalability_${mode}_${dataset}_${nm}.sh"

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
   --truth $truth \\
   --cell_clustering $cc \\
   --dims $d \\
   --NNs $n \\
   --resolution $r \\
   --logfc_thr $lt \\
   --min_perc $mp \\
   --rthr $rt \\
&& mv $tmp_sh $here_dir/.done/
EOF
						chmod +x "$tmp_sh"

						mxqsub --stdout="${logdir}/bench_scalability_${mode}_${dataset}_${nm}.stdout.log" \
							--group-name="bench_scalability_${mode}_${dataset}_${filename}_${algorithm}" \
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
	done
done
