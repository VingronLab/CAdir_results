library(igraph)
library(SIMLR)

# SC3 Options
alg_option_list <- list(
  make_option(c("--simlr_k"),
    type = "numeric",
    action = "store",
    default = 5,
    help = "Number of clusters for SIMLR",
    metavar = "numeric"
  ),
  make_option(c("--ndim"),
    type = "numeric",
    action = "store",
    default = 30,
    help = "Number of dimensions for SIMLR",
    metavar = "numeric"
  ),
  make_option(c("--k_tuning"),
    type = "numeric",
    action = "store",
    default = 10,
    help = "Mysterious tuning parameter",
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

simlr_k <- opt$simlr_k
ndim <- opt$ndim
k_tuning <- opt$k_tuning
