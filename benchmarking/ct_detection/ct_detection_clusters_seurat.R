renv::load("./")
library(Seurat)
library(APL)
library(aricode)
library(SingleCellExperiment)
library(dplyr)
library(readr)
library(optparse)

option_list <- list(
  make_option(
    c("--outdir"),
    type = "character",
    action = "store",
    default = NULL,
    help = "output directory",
    metavar = "character"
  ),
  make_option(
    c("--n"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Number of cell types",
    metavar = "numeric"
  ),
  make_option(
    c("--subset_cts"),
    type = "logical",
    action = "store_true",
    default = FALSE,
    help = "Whether cell types should be subset",
    metavar = "logical"
  ),
  make_option(
    c("--cellpcl"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Number of cells for subsetting",
    metavar = "numeric"
  ),
  make_option(
    c("--NNs"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "number of nearest neighbour samples for SNN graph",
    metavar = "numeric"
  ),
  make_option(
    c("--resolution"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Resolutions leiden algorithm, numbers should be separated by comma",
    metavar = "numeric"
  )
)


opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)
if (is.null(opt$outdir)) {
  print_help(opt_parser)
  stop("Argument --outdir is missing.", call. = FALSE)
} else if (is.null(opt$NNs)) {
  print_help(opt_parser)
  stop("Argument --NNs is missing.", call. = FALSE)
} else if (is.null(opt$n)) {
  print_help(opt_parser)
  stop("Argument --n is missing.", call. = FALSE)
} else if (is.null(opt$resolution)) {
  print_help(opt_parser)
  stop("Argument --resolution is missing.", call. = FALSE)
}

outdir <- opt$outdir
n <- opt$n
subset_cts <- opt$subset_cts
cellpcl <- opt$cellpcl

# Seurat
NNs <- opt$NNs
resol <- as.numeric(opt$resolution)

# Filtering according to:
# Yu, L., Cao, Y., Yang, J. Y. H. & Yang, P.
# Benchmarking clustering algorithms on estimating the number of
# cell types from single-cell RNA-sequencing data.
# Genome Biology 23, 49 (2022).

datadir <- "./data/real/preprocessed"

sce <- readRDS(file.path(
  datadir,
  "tabula_muris_preproc/tabula_muris_preproc.rds"
))

ct_size <- table(sce$cell_ontology_class)
ct_size <- ct_size[ct_size >= 300]

ct_names <- unique(names(ct_size))
sce <- sce[, sce$cell_ontology_class %in% ct_names]
cell_types <- unique(sce$cell_ontology_class)

res <- data.frame()
reps <- 1:10

cat("\nStarting clustering for", n, "clusters.")
set.seed(2358)
for (i in reps) {
  cat("\nIteration:", i, "\n")

  picked_cts <- sample(x = cell_types, size = n, replace = FALSE)

  if (isTRUE(subset_cts)) {
    chosen_cells <- c()
    for (p in picked_cts) {
      is_ct <- which(sce$cell_ontology_class %in% p)
      is_ct <- sample(x = is_ct, size = cellpcl, replace = FALSE)
      chosen_cells <- c(chosen_cells, is_ct)
    }
    sce_sub <- sce[, chosen_cells]
  } else {
    cellpcl <- 0
    sce_sub <- sce[, sce$cell_ontology_class %in% picked_cts]
  }

  sub_dims <- n + 20
  cat("\nUsing", sub_dims, "dimensions.\n")

  seu <- CreateSeuratObject(
    counts = as(counts(sce_sub), "dgCMatrix"),
    meta.data = as.data.frame(colData(sce_sub))
  )

  seu <- SetAssayData(
    object = seu,
    slot = "data",
    new.data = as(logcounts(sce_sub), "dgCMatrix")
  )

  seu <- FindVariableFeatures(
    object = seu,
    nfeatures = 4000
  )

  seu <- ScaleData(object = seu, features = VariableFeatures(seu))

  seu <- RunPCA(
    object = seu,
    npcs = sub_dims,
    features = VariableFeatures(seu)
  )

  seu <- FindNeighbors(
    object = seu,
    dims = seq_len(sub_dims),
    k.param = NNs
  )

  seu <- FindClusters(
    object = seu,
    resolution = resol
  )

  sce_sub$seurat <- seu$seurat_clusters
  ari <- aricode::clustComp(sce_sub$seurat, sce_sub$cell_ontology_class)

  cts_found <- length(unique(seu$seurat_clusters))

  tmp <- data.frame(
    nr_cts = n,
    cts_found = cts_found,
    ari = ari$ARI,
    nmi = ari$NMI,
    dims = sub_dims,
    NNs = NNs,
    resolution = resol,
    ncells = ncol(seu),
    ngenes = nrow(seu),
    cellspcl = cellpcl,
    rep = i
  )

  res <- rbind(res, tmp)
}

cat("\nDone.")

id <- paste0("_n-", n, "_nns-", NNs, "_res-", resol)
write_csv(
  x = res,
  file = file.path(outdir, paste0("seurat_ct_detection", id, ".csv"))
)
