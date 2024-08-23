#!/bin/bash

LD_LIBRARY_VAR=/home/kohl/.local/lib:/home/kohl/.local/bin:/home/kohl/.local/include
GDAL_DATA_VAR=/home/kohl/.local/share/gdal

# Monocle 108
res_monocle=(1)
dims_monocle=(30)
NNs_monocle=(30)
reduce_method=("PCA")
ngene_perg=(50)

algorithm="Monocle3"
SCRIPT="${scripts_path}/${algorithm}.R"

# Bash doesnt like arithmetic operations with decimals.
# division by 1 to set 0 decimal points.

MONOCLE_MEM=$(echo "scale=0; (${MEMORY%G} * 1.5)/1" | bc)"G"
if [ "${MONOCLE_MEM%G}" -gt "${MAXMEM%G}" ]; then
  MONOCLE_MEM=$MAXMEM
fi

if [[ $sim -eq 0 ]]; then
  mode="real"
elif [[ $sim -eq 1 ]]; then
  mode="sim"
else
  echo "UNCLEAR IF SIM OR NOT"
  exit 0
fi

n_loops=5
for d in "${dims_monocle[@]}"; do
	for r in "${res_monocle[@]}"; do
		for m in "${reduce_method[@]}"; do
			for k in "${NNs_monocle[@]}"; do
				for n in "${ngene_perg[@]}"; do

					nm="${algorithm}_${filename}_ntop-${nt}_dims-${d}_redm-${m}_resolution-${r}_ngene_pg-${n}_NNs-${k}"
					tmp_sh="${here_dir}/bench_scalability_${mode}_${dataset}_${nm}.sh"

					cat <<EOF >"$tmp_sh"
#!/bin/bash

# BEGIN_MXQ
# threads=$THREADS
# memory=$MONOCLE_MEM
# t=$MINUTES
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
   --dims $d \\
   --resolution $r \\
   --ngene_pg $n \\
   --NNs $k \\
   --redm $m \\
&& mv $tmp_sh $here_dir/.done/
EOF
					chmod +x "$tmp_sh"

					mxqsub --stdout="${logdir}/bench_scalability_${mode}_${dataset}_${nm}.stdout.log" \
						--group-name="bench_scalability_${mode}_${dataset}_${filename}_${algorithm}" \
						--threads=$THREADS \
						--memory=$MONOCLE_MEM \
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
