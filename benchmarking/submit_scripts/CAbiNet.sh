#!/bin/bash

# CAclust - 108

res=1
dims=(40 80 150)
NNs=(30 60 100)
overlap=(0.1)
graph_select=(FALSE TRUE)
SNN_mode=("all")
calc_gckNN=(TRUE FALSE)
prune=$(echo 'print(1/15)' | python3)


n_loops=5
for d in "${dims[@]}"; do
	for n in "${NNs[@]}"; do
		for gs in "${graph_select[@]}"; do
			for snn in "${SNN_mode[@]}"; do
				for gc in "${calc_gckNN[@]}"; do

					counter=0

					for ov in "${overlap[@]}"; do
						if [ "$gs" = "FALSE" ]; then

							if (($counter >= 1)); then
								break
							else
								ov=NA
								MEM_caclust=$((${MEMORY%G} + 20))"G"
							fi

						else
							MEM_caclust=$MEMORY
						fi

						algorithm="CAbiNet_igraph"
						SCRIPT="${scripts_path}/${algorithm}.R"

						nm="${algorithm}_${filename}_ntop-${nt}_dims-${d}_NNs-${n}_gs-${gs}_SNN-${snn}_gcKNN-${gc}_overlap-${ov}"

						tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

						cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEM_caclust
# t=$MINUTES
# END_MXQ

export LD_LIBRARY_PATH=$LD_LIBRARY_VAR:\$LD_LIBRARY_PATH
export GDAL_DATA=$GDAL_DATA_VAR:\$GDAL_DATA

trap 'echo ERROR_TIMEOUT >&2' SIGXCPU

Rscript-4.2.2 $SCRIPT   \\
   --outdir $OUTDIR  \\
   --file $f \\
   --dataset $dataset \\
   --cell_clustering $cc \\
   --name $nm \\
   --ntop $nt \\
   --dims $d    \\
   --prune $prune \\
   --NNs $n     \\
   --resolution $res     \\
   --sim $sim \\
   --truth $truth \\
   --graph_select $gs \\
   --nclust NULL \\
   --SNN_mode $snn \\
   --gcKNN $gc \\
   --overlap $ov \\
&& mv $tmp_sh $here_dir/.done/
EOF
						chmod +x "$tmp_sh"

						mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
							--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}" \
							--threads=$THREADS \
							--memory="$MEM_caclust" \
							-t $MINUTES \
							bash "$tmp_sh"

						counter=$((counter + 1))

            if [ "$test_run" = true ]; then
              break $n_loops
            fi
					done
				done
			done
		done
	done
done
