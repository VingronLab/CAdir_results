#!/bin/bash

CADIR_MINUTES=$((MINUTES / 2))

###########
## CAdir ##
###########

# 108
kdir_cd=(10 15)
dims_cd=(10 30 60)
angle_cd=(40 50 60)
qcut_cd=(0.7 0.8)
apl_quant_cd=(0.99)

algorithm="CAdir"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=5
for d in "${dims_cd[@]}"; do
	for k in "${kdir_cd[@]}"; do
		for a in "${angle_cd[@]}"; do
			for q in "${qcut_cd[@]}"; do
				for p in "${apl_quant_cd[@]}"; do

					nm="${algorithm}_${filename}_ntop-${nt}_kdirs-${k}_ndim-${d}_qcut-${q}_angle-${a}_aquant-${p}"
					tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

					cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$CADIR_MINUTES
# END_MXQ

export LD_LIBRARY_PATH=$LD_LIBRARY_VAR:\$LD_LIBRARY_PATH
export GDAL_DATA=$GDAL_DATA_VAR:\$GDAL_DATA

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

# end CAdir

##############
# CAdir auto #
##############

# 108
kdir_cd=(10 15 20)
dims_cd=(10 30 60)
angle_cd=(0)
qcut_cd=(0.7 0.8)
apl_quant_cd=(0.99 0.999)

algorithm="CAdir"
SCRIPT="${scripts_path}/${algorithm}.R"

n_loops=5
for d in "${dims_cd[@]}"; do
	for k in "${kdir_cd[@]}"; do
		for a in "${angle_cd[@]}"; do
			for q in "${qcut_cd[@]}"; do
				for p in "${apl_quant_cd[@]}"; do

					nm="${algorithm}_auto_${filename}_ntop-${nt}_kdirs-${k}_ndim-${d}_qcut-${q}_angle-${a}_aquant-${p}"
					tmp_sh="${here_dir}/bench_${mode}_${dataset}_${nm}.sh"

					cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MEMORY
# t=$CADIR_MINUTES
# END_MXQ

export LD_LIBRARY_PATH=$LD_LIBRARY_VAR:\$LD_LIBRARY_PATH
export GDAL_DATA=$GDAL_DATA_VAR:\$GDAL_DATA

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

					mxqsub --stdout="${logdir}/bench_${mode}_${dataset}_${nm}.stdout.log" \
						--group-name="bench_${mode}_${dataset}_${filename}_${algorithm}_auto" \
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
