library(SingleCellExperiment)
library(zellkonverter)

sce <- readH5AD("./data/real/raw/dmel_E14-16h_raw.h5ad")

names(assays(sce)) <- "counts"
colnames(sce) <- sce$cell_id

# save
saveRDS(sce, file.path("./data/real/raw/dmel_E14-16h_raw.rds"))
