#!/bin/bash

outdir="/project/kohl_analysis/analysis/CAdir/results/data/real/raw/"
mkdir -p $outdir

# https://figshare.com/articles/dataset/Tabula_Sapiens_release_1_0/14267219
wget -O tabula_sapiens_raw_seurat.rds https://datasets.cellxgene.cziscience.com/981bcf57-30cb-4a85-b905-e04373432fef.rds -P $outdir

Rscript-4.4 "./convert_seu_to_sce.R"

