#!/bin/bash

###########
## CAdir ##
###########

kdir_cd=(10)
dims_cd=(30)
angle_cd=(40)
qcut_cd=(0.8)
apl_quant_cd=(0.99)

CADIR_MINUTES=$((MINUTES / 1))

algorithm="CAdir"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=5
for d in "${dims_cd[@]}"; do
	for k in "${kdir_cd[@]}"; do
		for a in "${angle_cd[@]}"; do
			for q in "${qcut_cd[@]}"; do
				for p in "${apl_quant_cd[@]}"; do

					nm="${algorithm}_${filename}_ntop-${nt}_kdirs-${k}_ndim-${d}_qcut-${q}_angle-${a}_aquant-${p}"
					tmp_sh="${here_dir}/bench_scalability_${mode}_${dataset}_${nm}.sh"

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
--truth $truth \\
--cell_clustering $cc \\
--kdir $k \\
--dims $d \\
--qcut $q \\
--angle $a \\
--apl_quant $p \\
&& mv $tmp_sh $here_dir/.done/
EOF
					chmod +x "$tmp_sh"

					mxqsub --stdout="${logdir}/bench_scalability_${mode}_${dataset}_${nm}.stdout.log" \
						--group-name="bench_scalability_${mode}_${dataset}_${filename}_${algorithm}" \
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

# end CAdir
