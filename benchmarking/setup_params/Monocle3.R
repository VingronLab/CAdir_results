library(monocle3)

alg_option_list <- list(
  make_option(c("--dims"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "dimensions",
    metavar = "numeric"
  ),
  make_option(c("--resolution"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Resolutions leiden algorithm, numbers should be separated by comma",
    metavar = "numeric"
  ),
  make_option(c("--redm"),
    type = "character",
    action = "store",
    default = "UMAP",
    help = "Dimensin reduction method of Monocle3",
    metavar = "character"
  ),
  make_option(c("--NNs"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "number of nearest neighbour samples for SNN graph",
    metavar = "numeric"
  ),
  make_option(c("--ngene_pg"),
    type = "numeric",
    action = "store",
    default = 100, # default 0.25
    help = "Number of marker genes to calculate by Monocle3",
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

# Monocle3
ntop <- opt$ntop
resolution <- as.numeric(opt$resolution)
reduction_method <- opt$redm
genes_to_test_per_group <- opt$ngene_pg
NNs <- opt$NNs
