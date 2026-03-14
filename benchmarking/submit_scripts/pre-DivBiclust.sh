######################################################################################
######## run pre-divbiclust.r to prepare the input matrix and ground-truth labels#####
######## this will ouput two '.txt' files which will be used as input for divbiclust##
######################################################################################
#FIXME: adapt to new setup

#FIXME: the job needs to finish before we can move on with the other stuff!

pre_outdir="${outdir}/out/divbiclust/${dataset}"
pre_gt="${pre_outdir}/${filename}_Ntop_${nt}_gt.txt"
pre_matfile="${pre_outdir}/${filename}_Ntop_${nt}_matrix.txt"
if [ -f "$pre_gt" ] && [ -f "$pre_matfile" ]; then
  echo "pre-DivBiclust already run."
else

  mkdir -p $pre_outdir

  for f in ${files[@]}; do

    filename=$(basename $f .rds)

    for nt in ${ntop[@]}; do

      algorithm="DivBiclust"
      SCRIPT="${scripts_path}/pre-DivBiclust.R"

      nm="${algorithm}_${filename}_ntop-${nt}"

      mxqsub --stdout="${logdir}/bench_${dataset}_${nm}.stdout.log" \
        --group-name="bench_${filename}_${algorithm}" \
        --threads=$THREADS \
        --memory=$MEMORY \
        -t $MINUTES \
        Rscript-4.2.1 $SCRIPT \
        --outdir $pre_outdir \
        --file $f \
        --dataset $filename \
        --truth $truth \
        --name $nm \
        --sim $sim \
        --ntop $nt
    done
  done
fi
####################################################################################
