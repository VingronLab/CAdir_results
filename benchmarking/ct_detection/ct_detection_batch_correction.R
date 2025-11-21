library(reticulate)
use_condaenv(
  condaenv = "scvi-env-clone",
  conda = "$HOME/miniconda3/bin/conda"
)
sc <- import("scanpy", convert = FALSE)
loompy <- import("loompy")
scvi <- import("scvi", convert = FALSE)
anndata <- import("anndata", convert = FALSE)

renv::load("./")

devtools::load_all("/home/kohl/gits/ClemensKohl/CAdir/")

library(APL)
library(aricode)
library(SingleCellExperiment)
# library(batchelor)
library(scran)
library(dplyr)
library(readr)

library(sceasy)
# library(foreach)
# library(doParallel)

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
    c("--k"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "k for CAdir",
    metavar = "numeric"
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
    c("--q"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "APL quantile",
    metavar = "numeric"
  ),
  make_option(
    c("--pd"),
    type = "logical",
    action = "store_true",
    default = FALSE,
    help = "Whether pick_dims should be used",
    metavar = "logical"
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
  )
)


opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)
if (is.null(opt$outdir)) {
  print_help(opt_parser)
  stop("Argument --outdir is missing.", call. = FALSE)
} else if (is.null(opt$k)) {
  print_help(opt_parser)
  stop("Argument --k is missing.", call. = FALSE)
} else if (is.null(opt$n)) {
  print_help(opt_parser)
  stop("Argument --n is missing.", call. = FALSE)
} else if (is.null(opt$q)) {
  print_help(opt_parser)
  stop("Argument --q is missing.", call. = FALSE)
}

outdir <- opt$outdir
k <- opt$k
n <- opt$n
q <- opt$q
use_pd <- opt$pd
subset_cts <- opt$subset_cts
cellpcl <- opt$cellpcl

# n_cores <- detectCores()
# cluster <- makeCluster(n_cores - 1)
# registerDoParallel(cluster)

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
reps <- 1:5

cat("\nStarting clustering for", n, "clusters.")
set.seed(2358)
# results <- list()
for (i in reps) {
  # results <- foreach(i = reps) %dopar% {

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

  sce_bu <- sce_sub
  sce_dec <- scran::modelGeneVar(sce_sub)
  sce_top <- scran::getTopHVGs(sce_dec, n = 4000, var.threshold = NULL)
  sce_sub <- sce_sub[sce_top, ]
  sce_sub$cell_ontology_class <- sce_bu$cell_ontology_class
  sce_sub$tissue <- sce_bu$tissue
  # sce_sub <- fastMNN(sce_sub, batch = sce_sub$tissue, subset.row = sce_top)

  adata <- sceasy::convertFormat(
    sce_sub,
    from = "sce",
    to = "anndata",
    main_layer = "counts",
    drop_single_values = FALSE
  )

  # run setup_anndata
  scvi$model$SCVI$setup_anndata(adata, batch_key = "tissue")

  # create the model
  model <- scvi$model$SCVI(adata)

  # train the model
  model$train()

  # latent <- model$get_latent_representation()
  cnts_corr <- model$get_normalized_expression()
  cnts_corr <- t(as.matrix(cnts_corr$to_numpy()))
  rownames(cnts_corr) <- rownames(sce_sub)
  colnames(cnts_corr) <- colnames(sce_sub)

  ca <- cacomp(
    obj = cnts_corr,
    princ_coords = 3,
    dims = 200,
    top = nrow(cnts_corr),
    residuals = "pearson",
    python = TRUE,
    clip = TRUE
  )

  if (isTRUE(use_pd)) {
    sub_dims <- pick_dims(
      obj = ca,
      mat = cnts,
      method = "elbow_rule",
      return_plot = FALSE,
      reps = 5
    )
  } else {
    sub_dims <- n + 20
    cat("\nUsing", sub_dims, "dimensions.\n")
  }

  ca <- subset_dims(caobj = ca, dims = sub_dims)

  cak <- dirclust_splitmerge(
    caobj = ca,
    k = k,
    cutoff = NULL,
    method = "random",
    apl_quant = q,
    counts = NULL,
    min_cells = 50,
    reps = 5,
    make_plots = FALSE,
    apl_cutoff_reps = 100,
    qcutoff = 0.2
  )

  cak <- annotate_biclustering(
    obj = cak,
    universe = rownames(sce_sub),
    org = "mm"
  )

  cak <- rank_genes(cadir = cak, caobj = ca)

  sce_sub$cadir <- cak@cell_clusters
  ari <- aricode::clustComp(sce_sub$cadir, sce_sub$cell_ontology_class)

  cts_found <- length(unique(cak@cell_clusters))

  tmp <- data.frame(
    nr_cts = n,
    cts_found = cts_found,
    ari = ari$ARI,
    nmi = ari$NMI,
    k = k,
    apl_q = q,
    dims = sub_dims,
    ncells = ncol(sce_sub),
    ngenes = nrow(sce_sub),
    cellspcl = cellpcl,
    rep = i
  )

  # results[i] <- tmp
  res <- rbind(res, tmp)
}

# stopCluster(cl = cluster)
# res <- do.call("rbind", results)

cat("\nDone.")

id <- paste0("_k-", k, "_n-", n, "_q-", q)
write_csv(x = res, file = file.path(outdir, paste0("ct_detection", id, ".csv")))
