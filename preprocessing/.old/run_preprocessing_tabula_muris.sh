#!/bin/bash
THREADS=4
MEMORY=100G
MINUTES=120
TMPDIR=80G


datadir="/project/kohl_data/CAdir/data/"
name="tabula_muris"
# name="tabula_muris_limb"

outdir="${datadir}/preprocessed/"
file="${datadir}/${name}_raw.rds"

SCRIPT="./data_preprocessing.R"

mxqsub --stdout="${logdir}/${filename}_filtered${pcts}.stdout.log" \
       --stderr="${logdir}/${filename}_filtered${pcts}.stderr.log" \
       --group-name="${filename}" \
       --threads=$THREADS \
       --memory=$MEMORY \
       --tmpdir=$TMPDIR \
       -t $MINUTES \
Rscript-4.2.1 $SCRIPT   \
       --outdir $outdir \
       --file $file \
       --name "${name}_preproc" \
       --pct 0.01 \
       --truth "cell_ontology_class" \
       --org mm \
       --mt

