library(Seurat)
library(SingleCellExperiment)

indir <- "./data/real/raw/"
seu <- readRDS(file.path(indir, "tabula_sapiens_raw_seurat.rds"))

sce <- Seurat::as.SingleCellExperiment(seu)
saveRDS(sce, file.path(indir, "tabula_sapiens_raw.rds"))
