#' Seurat vignette and conversion to SCE
#' @export
sce_pbmc3k <- function() {
    set.seed(1234)
    
	sce <- TENxPBMCData::TENxPBMCData(dataset = "pbmc3k")
    rownames(sce) <- make.unique(SummarizedExperiment::rowData(sce)$Symbol_TENx)
    colnames(sce) <- SummarizedExperiment::colData(sce)$Barcode

    pbmc <- SeuratObject::CreateSeuratObject(
        counts = as.matrix(SingleCellExperiment::counts(sce)),
        assay = "RNA",
        project = "pbmc3k",
        min.cells = 3,
        min.features = 200,
        meta.data = as.data.frame(SingleCellExperiment::colData(sce))
    )

    pbmc[["percent.mt"]] <- Seurat::PercentageFeatureSet(pbmc, pattern = "^MT-")

    # Filter data
    pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)
    no_zeros_rows <- Matrix::rowSums(pbmc, slot = "counts") > 0
    pbmc <- pbmc[no_zeros_rows, ]

    # Normalization
    pbmc <- Seurat::NormalizeData(pbmc,
        normalization.method = "LogNormalize",
        scale.factor = 10000,
        verbose = FALSE
    )

    pbmc <- Seurat::FindVariableFeatures(pbmc,
        # selection.method = "vst",
        nfeatures = 2000,
        verbose = FALSE
    )

    # Scaling
    all.genes <- rownames(pbmc)
    pbmc <- Seurat::ScaleData(pbmc,
        features = all.genes,
        verbose = FALSE
    )

    # Run PCA
    pbmc <- Seurat::RunPCA(pbmc,
        features = Seurat::VariableFeatures(object = pbmc),
        verbose = FALSE
    )

    # Cell clustering
    pbmc <- Seurat::FindNeighbors(pbmc, dims = 1:10, verbose = FALSE)
    pbmc <- Seurat::FindClusters(pbmc, resolution = 0.5, verbose = FALSE)

    pbmc <- Seurat::RunUMAP(pbmc, dims = 1:10, verbose = FALSE)

    new.cluster.ids <- c(
        "0 - Naive CD4 T",
        "1 - CD14+ Mono",
        "2 - Memory CD4 T",
        "3 - B",
        "4 - CD8 T",
        "5 - FCGR3A+ Mono",
        "6 - NK",
        "7 - DC",
        "8 - Platelet"
    )

    names(new.cluster.ids) <- levels(pbmc)
    pbmc <- SeuratObject::RenameIdents(pbmc, new.cluster.ids)
    pbmc$cell_type <- SeuratObject::Idents(pbmc)

    return(Seurat::as.SingleCellExperiment(pbmc))
}
