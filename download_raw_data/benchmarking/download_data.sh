#!/bin/bash

OUTDIR="./data/real/raw/"
mkdir -p $OUTDIR

# Tirosh
wget -O $OUTDIR/Tirosh_nonmaglignant_raw.txt.gz "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE72056&format=file&file=GSE72056%5Fmelanoma%5Fsingle%5Fcell%5Frevised%5Fv2%2Etxt%2Egz"
gunzip $OUTDIR/Tirosh_nonmaglignant_raw.txt.gz

# PBMC10x

# NOTE:
# Manually download counts.read.txt, genes.read.txt and meta.counts.new.txt from the link below:
# Requires a registered account!
# https://singlecell.broadinstitute.org/single_cell/study/SCP424/single-cell-comparison-pbmc-data
# Alternatively, data can be downloaded through Gene Expression Omnibus:
# wget -O $OUTDIR/PBCM10x_raw.mtx.gz "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE132044&format=file&file=GSE132044%5Fpbmc%5Fhg38%5Fcount%5Fmatrix%2Emtx%2Egz"
# gunzip $OUTDIR/PBMC10x_raw.txt.gz

# Tabula Sapiens endothelial
wget -O $OUTDIR/tabula_sapiens_tissue_raw.rds "https://datasets.cellxgene.cziscience.com/b9ffa30b-9b8f-48b8-8144-69e9ad16131a.rds"

# DmelSpatial
wget -O $OUTDIR/dmel_E14-16h_raw.h5ad "https://ftp.cngb.org/pub/SciRAID/stomics/STDS0000060/stomics/E14-16h_a_count_normal_stereoseq.h5ad"

# FreytagGold
wget -L -O $OUTDIR/FreytagGold_raw.RData "https://github.com/bahlolab/cluster_benchmark_data/raw/refs/heads/master/goldstandard/Sce_CellRanger.RData"
