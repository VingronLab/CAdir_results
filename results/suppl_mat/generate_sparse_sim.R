library(splatter)
library(SingleCellExperiment)
library(scater)
library(scuttle)
library(scran)
library(scRNAseq)
library(TENxPBMCData)
library(Seurat)

set.seed(12345)

# Uncomment for splatter data based on Zeisel Brain data.
datasets <- c("zeisel", "pbmc3k")

# Uncomment for splatter data based on Pbcm3k data.
# dataset <- "pbmc3k"

for (dataset in datasets) {
  maindir <- paste0("./data/sim/raw_sparse/", dataset, "/")
  dir.create(maindir, recursive = TRUE)

  if (dataset == "zeisel") {
    sce <- ZeiselBrainData()
    clust.sce <- quickCluster(sce)
    sce <- computeSumFactors(sce, cluster = clust.sce, min.mean = 0.1)
    sce <- logNormCounts(sce)
    sce <- runUMAP(sce)
    counts(sce) <- as.matrix(counts(sce))
    logcounts(sce) <- as.matrix(logcounts(sce))
  } else if (dataset == "pbmc3k") {
    sce <- TENxPBMCData(dataset = "pbmc3k")
    rownames(sce) <- make.names(rowData(sce)$Symbol_TENx, unique = TRUE)
    colnames(sce) <- colData(sce)$Barcode

    # For pre-processing we used Seurat.
    pbmc <- CreateSeuratObject(
      counts = as.matrix(counts(sce)),
      assay = "RNA",
      project = "pbmc3k",
      min.cells = 3,
      min.features = 200,
      meta.data = as.data.frame(colData(sce))
    )

    pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

    # Filter data
    pbmc <- subset(
      pbmc,
      subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5
    )
    no_zeros_rows <- rowSums(pbmc, slot = "counts") > 0
    pbmc <- pbmc[no_zeros_rows, ]

    # Normalization
    pbmc <- NormalizeData(
      pbmc,
      normalization.method = "LogNormalize",
      scale.factor = 10000,
      verbose = FALSE
    )

    pbmc <- FindVariableFeatures(pbmc, nfeatures = 2000, verbose = FALSE)

    # Scaling
    all.genes <- rownames(pbmc)
    pbmc <- ScaleData(pbmc, features = all.genes, verbose = FALSE)

    # Run PCA
    pbmc <- RunPCA(
      pbmc,
      features = VariableFeatures(object = pbmc),
      verbose = FALSE
    )

    # Cell clustering
    pbmc <- FindNeighbors(pbmc, dims = 1:10, verbose = FALSE)
    pbmc <- FindClusters(pbmc, resolution = 0.5, verbose = FALSE)

    pbmc <- RunUMAP(pbmc, dims = 1:10, verbose = FALSE)
    # DimPlot(pbmc, reduction = "umap", label = FALSE, pt.size = 0.5)

    new.cluster.ids <- c(
      "naive_CD4_Tcell",
      "CD14_monocyte",
      "memory_CD4_Tcell",
      "Bcell",
      "CD8_Tcell",
      "FCGR3A_monocyte",
      "NKcell",
      "DC",
      "platelet"
    )

    names(new.cluster.ids) <- levels(pbmc)
    pbmc <- RenameIdents(pbmc, new.cluster.ids)
    pbmc$cell_type <- Idents(pbmc)

    sce <- as.SingleCellExperiment(pbmc)
    logcounts(sce) <- as.matrix(logcounts(sce))
    counts(sce) <- as.matrix(counts(sce))
  } else {
    stop(
      "Please pick either 'zeisel' or 'pbmc3k' for the dataset to base the simulation on."
    )
  }

  params <- splatEstimate(sce)

  deprob <- c(0.02, 0.06, 0.1)
  defacloc_defacscale <- c(0.75, 1.5)

  for (p in deprob) {
    for (l in defacloc_defacscale) {
      sim_full <- splatSimulate(
        params,
        nGenes = 10000,
        batchCells = 1000,
        group.prob = c(0.25, 0.1, 0.1, 0.2, 0.3, 0.05),
        method = "groups",
        de.prob = p,
        de.facLoc = l,
        de.facScale = l,
        out.prob = 0.001,
        de.downProb = c(0),
        dropout.type = "experiment",
        verbose = FALSE,
        seed = 1234
      )

      full_sparsity <- sum(counts(sim_full) == 0) /
        (nrow(counts(sim_full)) *
          ncol(counts(sim_full)))

      sim <- splatSimulate(
        params,
        nGenes = 10000,
        batchCells = 1000,
        group.prob = c(0.25, 0.1, 0.1, 0.2, 0.3, 0.05),
        method = "groups",
        de.prob = p,
        de.facLoc = l,
        de.facScale = l,
        out.prob = 0.001,
        de.downProb = c(0),
        dropout.type = "experiment",
        dropout.mid = 20,
        dropout.shape = -0.05,
        verbose = FALSE,
        seed = 1234
      )
      sparse_sparsity <- sum(counts(sim) == 0) /
        (nrow(counts(sim)) *
          ncol(counts(sim)))
      sparse_sparsity

      pnts <- seq(0, max(counts(sim)), by = 0.01)
      splat_log <- function(x, xz, k) 1 / (1 + exp(-k * (x - xz)))
      log_pnts <- splat_log(
        x = pnts,
        xz = 20,
        k = -0.05
      )
      # plot(log_pnts[1:1000])
      df <- data.frame(exprs = pnts, prob = log_pnts)
      log_prob <- ggplot(df, aes(x = exprs, y = prob)) +
        geom_line() +
        xlim(x = c(0, 200)) +
        ggtitle(paste0("Sparsity: ", sparse_sparsity)) +
        theme_bw()

      clust.sim <- quickCluster(sim)
      sim <- computeSumFactors(sim, cluster = clust.sim, min.mean = 0.1)
      sim <- logNormCounts(sim)
      sim <- runUMAP(sim)

      pumap <- plotUMAP(sim, colour_by = "Group")

      name <- paste0(
        "dePROB-",
        gsub("\\.", "_", p),
        "_defacLOC-",
        gsub("\\.", "_", l),
        "_defacSCALE-",
        gsub("\\.", "_", l)
      )

      outdir <- paste0(maindir, name)
      dir.create(outdir)

      ggsave(
        plot = pumap,
        filename = paste0(outdir, "/", name, "_UMAP.png")
      )
      ggsave(
        plot = log_prob,
        filename = paste0(outdir, "/", name, "_logistic_dropouts.png")
      )

      outcsv <- data.frame(
        "original" = full_sparsity,
        "sparse" = sparse_sparsity
      )
      write.csv(outcsv, file = paste0(outdir, "/", name, "sparsity.csv"))

      saveRDS(
        sim,
        paste0(
          outdir,
          "/",
          name,
          ".rds"
        )
      )

      png(paste0(outdir, "/", name, "_distribution.png"))
      grid <- seq(0, 30, .1)
      log_mean <- l
      log_sd <- sqrt(l)

      plot(
        grid,
        dlnorm(grid, log_mean, log_sd),
        type = "l",
        xlab = "DE-factor",
        ylab = "density"
      )
      legend(
        "topright",
        paste0("log-norm: ", log_mean, " mean, ", log_sd, " sd"),
        lty = 1,
        col = 1
      )
      dev.off()
    }
  }
  system(paste0("ln -rs ", maindir, "/*/*.rds ", maindir))
}
