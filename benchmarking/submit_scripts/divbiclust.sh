
# divbiclust
maxdiffs=(0.15 0.2 0.25)
seedColSzs=(30 60 90)
maxColSzs=(100 200)
do_rates=(0 0.1)
simThreshs=(0.5)


if [ $is_preprocessing = true ] ; then

######################################################################################
######## run pre-divbiclust.r to prepare the input matrix and ground-truth labels#####
######## this will ouput two '.txt' files which wiil be used as input for divbiclust##
######################################################################################

OUTDIR="${outdir}/out/${dataset}"
mkdir -p $OUTDIR

for f in ${files[@]}; do

  filename=`basename $f .rds`

  for nt in ${ntop[@]}; do


    algorithm="divbiclust"
    SCRIPT="${scripts_path}/pre-divbiclust.R"

    nm="${algorithm}_${filename}_ntop-${nt}"

    mxqsub --stdout="${logdir}/bench_${dataset}_${nm}.stdout.log" \
      --group-name="bench_${filename}_${algorithm}" \
      --threads=$THREADS \
      --memory=$MEMORY \
      -t $MINUTES \
      Rscript-4.2.1 $SCRIPT   \
      --outdir $OUTDIR  \
      --file $f \
      --dataset $dataset \
      --name $nm \
      --ntop $nt

    done
  done
  is_preprocessing=false
fi
