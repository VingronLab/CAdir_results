######################################################################################
######## run pre-divbiclust.r to prepare the input matrix and ground-truth labels#####
######## this will ouput two '.txt' files which will be used as input for divbiclust##
######################################################################################

pre_gt="${OUTDIR}/${filename}_Ntop_${nt}_gt.txt"
pre_matfile="${OUTDIR}/${filename}_Ntop_${nt}_matrix.txt"
if [ -f "$pre_gt" ] && [ -f "$pre_matfile" ]; then
  echo "pre-DivBiclust already run."
else
  algorithm="DivBiclust"
  SCRIPT="${scripts_path}/pre-DivBiclust.R"

  nm="${algorithm}_${filename}_ntop-${nt}"

  mxqsub --stdout="${logdir}/bench_${nm}.stdout.log" \
    --group-name="pre-divbiclust_${filename}_${algorithm}" \
    --threads=$THREADS \
    --memory=$MEMORY \
    -t $MINUTES \
    Rscript-4.2.2 $SCRIPT \
    --outdir $OUTDIR \
    --file $f \
    --dataset $filename \
    --truth $truth \
    --name $nm \
    --sim $sim \
    --ntop $nt
fi
####################################################################################
