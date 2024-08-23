source("./helpers/custom_pca.R")

alg_option_list <- list(
  make_option(c("--dims"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "dimensions",
    metavar = "numeric"
  ),
  make_option(c("--qcut"),
    type = "numeric",
    action = "store",
    default = 0.8,
    help = "quantile for gene cutoff",
    metavar = "numeric"
  ),
  make_option(c("--coords"),
    type = "character",
    action = "store",
    default = "prin",
    help = "Coordinates to use for gene assignment",
    metavar = "character"
  ),
  make_option(c("--kmeansk"),
    type = "numeric",
    action = "store",
    default = 30,
    help = "k for kmeans",
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

# SVD
dims <- opt$dims

# kmeans
kmeansk <- opt$kmeansk
qcut_param <- opt$qcut
coords <- opt$coords
