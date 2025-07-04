library(QUBIC)
library(biclust)

alg_option_list <- list(
  make_option(
    c("--nclust"),
    type = "numeric",
    action = "store",
    default = NULL,
    help = "Assigning number of clusters for kmeans/skmeans",
    metavar = "numeric"
  ),
  make_option(
    c("--r_param"),
    type = "numeric",
    action = "store",
    default = NA, # default 1
    help = "The range of possible ranks",
    metavar = "numeric"
  ),
  make_option(
    c("--q_param"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.06
    help = "QUBIC q parameter",
    metavar = "numeric"
  ),
  make_option(
    c("--c_param"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.95
    help = "QUBIC c param",
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

# QUBIC
c_param <- opt$c_param
r_param <- opt$r_param
q_param <- opt$q_param

nclust <- opt$nclust

if (nclust == "NULL") {
  nclust <- NULL
}
