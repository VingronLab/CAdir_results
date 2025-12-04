library(RcppML)
library(Matrix)

alg_option_list <- list(
  make_option(
    c("--k_nmf"),
    type = "numeric",
    action = "store",
    default = NULL,
    help = "number of factors",
    metavar = "numeric"
  ),
  make_option(
    c("--L1"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.05
    help = "Sparsity",
    metavar = "numeric"
  ),
  make_option(
    c("--nseeds"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.05
    help = "number of random restarts",
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

k_nmf <- opt$k_nmf
l1 <- opt$L1
nseeds <- opt$nseeds
