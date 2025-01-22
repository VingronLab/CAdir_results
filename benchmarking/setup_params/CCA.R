library(biclust)

alg_option_list <- list(
  make_option(c("--nclust"),
    type = "numeric",
    action = "store",
    default = NULL,
    help = "Assigning number of clusters for kmeans/skmeans",
    metavar = "numeric"
  ),
  make_option(c("--alpha"),
    type = "numeric",
    action = "store",
    default = NA, # default 1.5
    help = "Scaling factor",
    metavar = "numeric"
  ),
  make_option(c("--delta"),
    type = "numeric",
    action = "store",
    default = NA, # default 1
    help = "Maximum of accepted score",
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

alpha <- opt$alpha
delta <- opt$delta

nclust <- opt$nclust

if (nclust == "NULL") {
  nclust <- NULL
}
