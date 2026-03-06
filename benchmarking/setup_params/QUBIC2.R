source("./benchmarking/helpers/sim_eval.R")
source("./benchmarking/helpers/utils.R")
source("./benchmarking/algorithms/biclustlib/clustering_error.R")

alg_option_list <- list(
  make_option(
    c("--qqubic2"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "?",
    metavar = "numeric"
  ),
  make_option(
    c("--nclust"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "number of clusters",
    metavar = "numeric"
  ),
  make_option(
    c("--objF"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "?",
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

qQubic2 <- opt$qqubic2
nclust <- opt$nclust
objF <- opt$objF
