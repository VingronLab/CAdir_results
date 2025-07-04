library(rhdf5)


alg_option_list <- list(
  make_option(
    c("--seed"),
    type = "numeric",
    action = "store",
    default = 0,
    help = "Seed",
    metavar = "numeric"
  ),
  make_option(
    c("--tmpdir"),
    type = "character",
    action = "store",
    default = tempdir(),
    help = "temporary directory",
    metavar = "character"
  ),
  make_option(
    c("--scg_method"),
    type = "character",
    action = "store",
    default = "ncos",
    help = "Graph building method",
    metavar = "character"
  ),
  make_option(
    c("--n_clusters"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Number of clusters",
    metavar = "numeric"
  ),
  make_option(
    c("--pretrain"),
    type = "numeric",
    action = "store",
    default = 800,
    help = "Pretraining epochs",
    metavar = "numeric"
  ),
  make_option(
    c("--train"),
    type = "numeric",
    action = "store",
    default = 300,
    help = "Training epochs",
    metavar = "numeric"
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

seed <- opt$seed
n_clusters <- opt$n_clusters
tmp_dir <- opt$tmpdir
scg_method <- opt$scg_method
pretrain_epochs <- opt$pretrain
train_epochs <- opt$train
