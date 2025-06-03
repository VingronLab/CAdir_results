library(SingleCellExperiment)
library(scran)
library(scater)
library(zellkonverter)

sce <- readH5AD("./data/real/raw/human_pancreas_norm_complexBatch.h5ad")

idx <- which(names(assays(sce)) == "X")
names(assays(sce))[idx] <- "logcounts"

genevars <- modelGeneVar(sce, assay.type = "logcounts")
chosen <- getTopHVGs(genevars, n = 4000, var.threshold = NULL)

sce <- fixedPCA(sce, rank = 50, subset.row = chosen)
sce <- runUMAP(sce, dimred = "PCA")

saveRDS(sce, "./data/real/raw/human_pancreas_norm_complexBatch.rds")

# reticulate::py_install(c("anndata==0.10.6", "h5py==3.10.0", "hdf5==1.14.3", "natsort==8.4.0", "numpy==1.26.4", "packaging==24.0", "pandas==2.2.1", "python==3.12.2", "scipy==1.12.0"))
