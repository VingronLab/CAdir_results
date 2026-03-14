# FIXME: adapt
library(Matrix)
library(Rcpp)
library(tidyverse)
library(SingleCellExperiment)
library(reticulate)
library(scran)
library(scater)
library(optparse)

set.seed(2358)

# source("./helper_funs.R")
# source("./clustering_error.R")

option_list = list(
  make_option(
    c("--name"),
    type = "character",
    action = "store",
    default = "sample",
    help = "Name of sample",
    metavar = "character"
  ),

  make_option(
    c("--file"),
    type = "character",
    action = "store",
    default = NULL,
    help = "Name of file to load",
    metavar = "character"
  ),

  make_option(
    c("--dataset"),
    type = "character",
    action = "store",
    default = NULL,
    help = "Name of the dataset",
    metavar = "character"
  ),

  make_option(
    c("--outdir"),
    type = "character",
    action = "store",
    default = NULL,
    help = "output directory",
    metavar = "character"
  ),

  make_option(
    c("--ntop"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "top X most variable genes",
    metavar = "numeric"
  ),

  make_option(
    c("--sim"),
    type = "logical",
    action = "store",
    default = FALSE,
    help = "Is the dataset a simulated one or not",
    metavar = "logical"
  ),

  make_option(
    c("--truth"),
    type = "character",
    action = "store",
    default = "truth",
    help = "Name of Column which defines ground truth of sample clusters in colData(sce)",
    metavar = "character"
  )
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

if (is.null(opt$file)) {
  print_help(opt_parser)
  stop("Argument --file is missing.", call. = FALSE)
} else if (is.null(opt$outdir)) {
  print_help(opt_parser)
  stop("Argument --outdir is missing.", call. = FALSE)
} else if (is.null(opt$name)) {
  print_help(opt_parser)
  stop("Argument --name is missing.", call. = FALSE)
}


# Misc
filepath <- opt$file
ntop <- opt$ntop
outdir <- opt$outdir
name <- opt$name
truth <- opt$truth

dataset <- opt$dataset

if (isTRUE(sim)) {
  sim_params <- stringr::str_match(
    string = opt$file,
    # pattern = ".*dePROB-(?<dePROB>[0-9]_[0-9]*)_defacLOC-(?<defacLOC>[0-9]_?[0-9]*)_defacSCALE-(?<defacSCALE>[0-9]_?[0-9]*).rds")
    pattern = ".*dePROB-(?<dePROB>[0-9]_[0-9]*)_defacLOC-(?<defacLOC>[0-9]_?[0-9]*)_defacSCALE-(?<defacSCALE>[0-9]_?[0-9]*)[:graph:]{0,9}.rds"
  )

  opt$dePROB <- as.numeric(gsub("_", ".", sim_params[, "dePROB"]))
  opt$defacLOC <- as.numeric(gsub("_", ".", sim_params[, "defacLOC"]))
  opt$defacSCALE <- as.numeric(gsub("_", ".", sim_params[, "defacSCALE"]))
}

fileformat <- tools::file_ext(filepath)


if (fileformat == "txt") {
  stop("Provided txt file as input. RDS required.")

  # cnts = read.table(opt$file, row.names = 1, header=T, sep = "\t")
  # cnts = as.matrix(cnts)
  # data = cnts
} else if (fileformat %in% c("rds", "RDS")) {
  data <- readRDS(filepath)

  if (is(data, "Seurat")) {
    stop("Please provide SingleCellExperiment data, not Seurat.")
  }

  if (!is.na(ntop)) {
    genevars <- modelGeneVar(data, assay.type = "logcounts")

    if (isTRUE(graph_select_by_prop) & isTRUE(graph_select)) {
      chosen <- getTopHVGs(genevars, prop = 0.8, var.threshold = NULL)
    } else {
      chosen <- getTopHVGs(genevars, n = ntop, var.threshold = NULL)
    }

    data_old <- data
    data <- data[chosen, ]
  }

  cnts <- as.matrix(logcounts(data))

  trueclusters <- colData(data)[, colnames(colData(data)) == truth]
}


ngene <- nrow(cnts)
ncell <- ncol(cnts)

## write the cell indexes of each cluster to a _gt.txt file
clustnms <- unique(trueclusters)
gt_file <- file(
  file.path(outdir, paste0(dataset, "_Ntop_", ntop, "_gt.txt")),
  open = "w"
)

for (i in clustnms) {
  idx <- which(data[[truth]] == i) - 1 ## substracte by 1 for cpp counting
  writeLines(paste(idx, collapse = " "), gt_file)
}

close(gt_file)

matfile <- file(
  file.path(outdir, paste0(dataset, "_Ntop_", ntop, "_matrix.txt")),
  open <- "w"
)
writeLines(paste(dim(cnts), collapse = " "), matfile)

for (i in seq_len(nrow(cnts))) {
  writeLines(
    paste(rownames(cnts)[i], paste(cnts[i, ], collapse = ","), sep = ","),
    matfile
  )
}
close(matfile)

cat("\nFinished pre-DivBiclust!\n")
