library(biclust)

# Seurat options
alg_option_list <- list(
  make_option(c("--rrelease"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.7
    help = "threshold to prune rows in the layers depending on row homogeneity",
    metavar = "numeric"
  ),
  make_option(c("--crelease"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.7
    help = "threshold to prune rows in the layers depending on column homogeneity",
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

rrelease <- opt$rrelease
crelease <- opt$crelease
