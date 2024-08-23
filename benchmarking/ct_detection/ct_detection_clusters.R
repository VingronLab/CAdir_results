library(CAdir)
library(APL)
library(aricode)
library(SingleCellExperiment)
library(dplyr)
library(readr)
library(optparse)

option_list <- list(
  make_option(c("--outdir"),
    type = "character",
    action = "store",
    default = NULL,
    help = "output directory",
    metavar = "character"
  ),
  make_option(c("--k"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "k for CAdir",
    metavar = "numeric"
  ),
  make_option(c("--n"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Number of cell types",
    metavar = "numeric"
  ),
  make_option(c("--q"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "APL quantile",
    metavar = "numeric"
  ),
  make_option(c("--pd"),
    type = "logical",
    action = "store_true",
    default = FALSE,
    help = "Whether pick_dims should be used",
    metavar = "logical"
  ),
  make_option(c("--subset_cts"),
    type = "logical",
    action = "store_true",
    default = FALSE,
    help = "Whether cell types should be subset",
    metavar = "logical"
  ),
  make_option(c("--cellpcl"),
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

  sce_dec <- scran::modelGeneVar(sce_sub)
  sce_top <- scran::getTopHVGs(sce_dec, n = 4000, var.threshold = NULL)
  sce_sub <- sce_sub[sce_top, ]

  ca <- cacomp(
    obj = logcounts(sce_sub),
    princ_coords = 3,
    dims = 200,
    top = nrow(sce_sub),
    residuals = "pearson",
    python = TRUE,
    clip = TRUE
  )

  if (isTRUE(use_pd)) {
    sub_dims <- pick_dims(
      obj = ca,
      mat = logcounts(sce_sub),
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
    make_plots = TRUE,
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

  res <- rbind(res, tmp)
}


cat("\nDone.")

id <- paste0("_k-", k, "_n-", n, "_q-", q)
write_csv(x = res, file = file.path(outdir, paste0("ct_detection.csv", id, ".csv")))
