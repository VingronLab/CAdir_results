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

get_top_cells <- function(cadir, caobj, cluster) {
  alpha <- cadir@parameters$sa_cutoff

  if (is.null(alpha)) {
    alpha <- get_apl_cutoff(
      caobj = caobj,
      method = "random",
      group = which(cadir@cell_clusters == c),
      quant = 0.99,
      apl_cutoff_reps = 100
    )
  }
  group <- which(cadir@cell_clusters == cluster)
  direction <- cadir@directions[cadir@dict[[cluster]], ]

  model <- apl_model(
    caobj = caobj,
    direction = direction,
    group = group
  )

  cell_coords <- model(caobj@std_coords_cols)

  cluster_cells <- names(cadir@cell_clusters)[
    which(cadir@cell_clusters == cluster)
  ]

  # subset genes to cluster genes
  cell_coords <- cell_coords[
    which(rownames(cell_coords) %in% cluster_cells), ,
    drop = FALSE
  ]

  # Step 3: Score by cutoff
  score <- cell_coords[, 1] - (cell_coords[, 2] * alpha)

  ranking <- data.frame(
    "Colname" = rownames(cell_coords),
    "x" = cell_coords[, 1],
    "y" = cell_coords[, 2],
    "Score" = score,
    "Col_num" = seq_len(nrow(cell_coords)),
    "Cluster" = cluster
  )

  ranking <- ranking[order(ranking$Score, decreasing = TRUE), ]
  ranking$Rank <- seq_len(nrow(ranking))

  return(ranking)
}

load_platelet_gs <- function() {
  df <- readr::read_tsv("./platelets_marker_genes.tsv", show_col_types = FALSE, progress = FALSE)
  colnames(df) <- gsub(" ", "_", colnames(df))
  df <- df %>%
    filter(cell_type == "Platelets") %>%
    filter(species %in% c("Hs", "Mm Hs"))

  return(list("Platelets" = df$official_gene_symbol))
}



plot_clusters_custom <- function(cadir,
                                 caobj,
                                 point_size = 1,
                                 size_factor = 1,
                                 show_genes = FALSE,
                                 label_genes = FALSE,
                                 ntop = 5,
                                 text_size = 16,
                                 outlier_cluster) {
  pls <- list()
  cls <- levels(cadir@cell_clusters)

  for (i in seq_along(cls)) {
    p <- cluster_apl(
      caobj = caobj,
      cadir = cadir,
      direction = cadir@directions[cls[i], ],
      cluster = as.character(cls[i]),
      group = which(cadir@cell_clusters == cls[i]),
      show_cells = TRUE,
      show_genes = show_genes,
      show_lines = FALSE,
      highlight_cluster = TRUE,
      # colour_by_group = FALSE,
      label_genes = label_genes,
      point_size = point_size,
      size_factor = size_factor,
      ntop = ntop
    ) +
      ggplot2::ggtitle(paste0("Cluster: ", cls[i])) +
      ggplot2::theme(
        legend.position = "none",
        axis.title.x = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.ticks.x = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(size = text_size)
      )

    if (cls[i] == outlier_cluster) {
      cell_rnk <- get_top_cells(
        cadir = cadir,
        caobj = caobj,
        cluster = outlier_cluster
      )
      p <- p +
        geom_point(
          data = cell_rnk[cell_rnk$Score >= 0, ],
          aes(x = x, y = y),
          color = "#d44a3d",
        )
      # +
      #   ggrepel::geom_label_repel(
      #   data = cell_rnk[cell_rnk$Score >= 0, ],
      #   ggplot2::aes(
      #     x = x,
      #     y = y,
      #     label = Colname
      #   ),
      #   color = "#d44a3d",
      #   box.padding = 1,
      #   max.overlaps = Inf
      # )
    }

    pls[[i]] <- p
  }

  fig <- ggpubr::ggarrange(
    plotlist = pls,
    nrow = ceiling(sqrt(length(cls))),
    ncol = ceiling(sqrt(length(cls)))
  )
  return(suppressWarnings(fig))
}
