#FIXME: CHANGE TO DIVBICLUST PARAMS
library(Rcpp)

alg_option_list <- list(
  make_option(
    c("--maxdiff"),
    type = "numeric",
    action = "store",
    default = 0.15,
    help = "Argument max_diff",
    metavar = "numeric"
  ),
  make_option(
    c("--dorate"),
    type = "numeric",
    action = "store",
    default = 0.1,
    help = "fraction of missing values in a bicluster",
    metavar = "numeric"
  ),
  make_option(
    c("--seedColSz"),
    type = "numeric",
    action = "store",
    default = 50,
    help = "size of seed gene set",
    metavar = "numeric"
  ),
  make_option(
    c("--maxColSz"),
    type = "numeric",
    action = "store",
    default = 100,
    help = "maximum size of gene set, fixed to 100",
    metavar = "numeric"
  ),
  make_option(
    c("--simThresh"),
    type = "numeric",
    action = "store",
    default = 0.5,
    help = "similarity threshold for pattern merging, fixed to 0.5",
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


max_diff <- opt$maxdiff
do_rate <- opt$dorate
seed_col_sz <- opt$seedColSz
max_col_sz <- opt$maxColSz
simThresh <- opt$simThresh
