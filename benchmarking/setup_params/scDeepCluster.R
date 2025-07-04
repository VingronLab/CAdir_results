library(reticulate)
library(rhdf5)

alg_option_list <- list(
  make_option(
    c("--n_clusters"),
    type = "numeric",
    action = "store",
    default = 0.8,
    help = "number of clusters",
    metavar = "numeric"
  ),
  make_option(
    c("--knn"),
    type = "numeric",
    action = "store",
    default = 20,
    help = "number of nearest neighbours",
    metavar = "numeric"
  ),
  make_option(
    c("--resolution"),
    type = "numeric",
    action = "store",
    default = 0.8,
    help = "Louvain resolution",
    metavar = "numeric"
  ),
  make_option(
    c("--tmpdir"),
    type = "character",
    action = "store",
    default = tempdir(),
    help = "temporary dir",
    metavar = "character"
  ),
  make_option(
    c("--device"),
    type = "character",
    action = "store",
    default = "cpu",
    help = "Louvain resolution",
    metavar = "character"
  )
)

option_list <- c(option_list, alg_option_list)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

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

n_clusters <- opt$n_clusters
knn <- opt$knn
resolution <- opt$resolution
device <- opt$device
tmp_dir <- opt$tmpdir
