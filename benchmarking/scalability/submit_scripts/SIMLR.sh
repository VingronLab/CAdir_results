#!/bin/bash

###########
## SIMLR ##
###########

simlr_k=(6)
ndim=(30)
k_tuning=(30) # FIXME: Should this be left at default value?
# 3*6*3*2

n_loops=3
algorithm="SIMLR"


# SIMLR_MEMORY=$MEMORY*1.5
# Bash doesnt like arithmetic operations with decimals.
# Division by 1 to set decimal points to 0

SIMLR_MEMORY=$(echo "scale=0; (${MEMORY%G} * 1.5)/1" | bc)"G"
if [ "${SIMLR_MEMORY%G}" -gt "${MAXMEM%G}" ]; then
  SIMLR_MEMORY=$MAXMEM
fi

SCRIPT="${scripts_path}/${algorithm}.R"

for s in "${simlr_k[@]}"; do
	for d in "${ndim[@]}"; do
		for k in "${k_tuning[@]}"; do

			nm="${algorithm}_${filename}_ntop-${nt}_simlr_k-${s}_ndim-${d}_k_tuning-${k}"
			tmp_sh="${here_dir}/bench_scalability_${mode}_${dataset}_${nm}.sh"

			cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$SIMLR_MEMORY
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
--simlr_k $s \\
--ndim $d \\
--k_tuning $k \\
&& mv $tmp_sh $here_dir/.done/
EOF
			chmod +x "$tmp_sh"

			mxqsub --stdout="${logdir}/bench_scalability_${mode}_${dataset}_${nm}.stdout.log" \
				--group-name="bench_scalability_${mode}_${dataset}_${filename}_${algorithm}" \
				--threads=$THREADS \
				--memory=$SIMLR_MEMORY \
				-t $MINUTES \
				bash "$tmp_sh"

      if [ "$test_run" = true ]; then
        break $n_loops
      fi
		done
	done
done
