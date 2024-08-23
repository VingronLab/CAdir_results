library(optparse)

library(biclust)
library(SingleCellExperiment)
library(scran)
library(dplyr)
library(readr)
library(tibble)

set.seed(2358)

source("./benchmarking/helpers/sim_eval.R")
source("./benchmarking/helpers/cell_clustering_eval.R")
source("./benchmarking/helpers/utils.R")
source("./benchmarking/algorithms/biclustlib/clustering_error.R")

# Set to false unless set to TRUE by CAbiNet
graph_select_by_prop <- FALSE
graph_select <- FALSE

option_list <- list(
  make_option(c("--name"),
    type = "character",
    action = "store",
    default = "sample",
    help = "Name of sample",
    metavar = "character"
  ),
  make_option(c("--file"),
    type = "character",
    action = "store",
    default = NULL,
    help = "Name of file to load",
    metavar = "character"
  ),
  make_option(c("--dataset"),
    type = "character",
    action = "store",
    default = NULL,
    help = "Name of the dataset",
    metavar = "character"
  ),
  make_option(c("--outdir"),
    type = "character",
    action = "store",
    default = NULL,
    help = "output directory",
    metavar = "character"
  ),
  make_option(c("--ntop"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "top X most variable genes",
    metavar = "numeric"
  ),
  make_option(c("--sim"),
    type = "numeric",
    action = "store",
    default = 0,
    help = "Is the dataset a simulated one or not",
    metavar = "numeric"
  ),
  make_option(c("--truth"),
    type = "character",
    action = "store",
    default = "truth",
    help = "Name of ground truth column in colData(sce)",
    metavar = "character"
  ),
  # Toggle if it is only a cell clustering.
  make_option(c("--cell_clustering"),
    type = "numeric",
    action = "store",
    default = 0,
    help = "Whether or not only cell clustering algorithm is evaluated.",
    metavar = "numeric"
  )
)

alg_params <- file.path("./setup_params", paste0(algorithm, ".R"))
source(alg_params)

# Misc
name <- opt$name
filepath <- opt$file
dataset <- opt$dataset
outdir <- opt$outdir
ntop <- opt$ntop
truth <- opt$truth

if (opt$sim == 0) {
  sim <- FALSE
} else if (opt$sim == 1) {
  sim <- TRUE
} else {
  stop("Invalid value for sim")
}

if (opt$cell_clustering == 0) {
  is_cell_clustering <- FALSE
} else if (opt$cell_clustering == 1) {
  is_cell_clustering <- TRUE
} else {
  stop("Invalid value for cell_clustering")
}

if (isTRUE(sim)) {
  sim_params <- stringr::str_match(
    string = opt$file,
    # pattern = ".*dePROB-(?<dePROB>[0-9]_[0-9]*)_defacLOC-(?<defacLOC>[0-9]_?[0-9]*)_defacSCALE-(?<defacSCALE>[0-9]_?[0-9]*).rds")
    pattern <- ".*dePROB-(?<dePROB>[0-9]_[0-9]*)_defacLOC-(?<defacLOC>[0-9]_?[0-9]*)_defacSCALE-(?<defacSCALE>[0-9]_?[0-9]*)[:graph:]{0,9}.rds"
  )

  opt$dePROB <- as.numeric(gsub("_", ".", sim_params[, "dePROB"]))
  opt$defacLOC <- as.numeric(gsub("_", ".", sim_params[, "defacLOC"]))
  opt$defacSCALE <- as.numeric(gsub("_", ".", sim_params[, "defacSCALE"]))
}


fileformat <- tools::file_ext(filepath)

if (fileformat == "txt") {
  cat("running divbiclust.....")
} else if (fileformat %in% c("rds", "RDS")) {
  data <- readRDS(filepath)

  if (is(data, "Seurat")) {
    stop("Please provide SingleCellExperiment data, not Seurat.")
  }

  if (!is.na(ntop)) {
    genevars <- scran::modelGeneVar(data, assay.type = "logcounts")

    if (isTRUE(graph_select_by_prop) && isTRUE(graph_select)) {
      chosen <- scran::getTopHVGs(genevars, prop = 0.8, var.threshold = NULL)
    } else {
      chosen <- scran::getTopHVGs(genevars, n = ntop, var.threshold = NULL)
    }

    data_old <- data
    data <- data[chosen, ]
  }


  cnts <- as.matrix(logcounts(data))


  trueclusters <- colData(data)[, colnames(colData(data)) == truth]

  # TODO: Commenting this out will lead to errors!
  # Add to the setup script iff necessary!
  # if (is.null(nclust)) {
  #   nclust <- length(unique(colData(data)[, colnames(colData(data)) == truth]))
  # }
}
