library(Seurat)

# Seurat options
alg_option_list <- list(
  make_option(c("--logfc_thr"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.25
    help = "minimum log2fc threshold to test genes.",
    metavar = "numeric"
  ),
  make_option(c("--min_perc"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.25
    help = "minimum fraction of min.pct cells to test genes in.",
    metavar = "numeric"
  ),
  make_option(c("--rthr"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.01
    help = "return threshold above which genes are returned.",
    metavar = "numeric"
  ),
  make_option(c("--dims"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "dimensions",
    metavar = "numeric"
  ),
  make_option(c("--NNs"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "number of nearest neighbour samples for SNN graph",
    metavar = "numeric"
  ),
  make_option(c("--prune"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "prune cutoff for sample SNN graph",
    metavar = "numeric"
  ),
  make_option(c("--resolution"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Resolutions leiden algorithm, numbers should be separated by comma",
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
NNs <- opt$NNs
prune <- opt$prune
resol <- as.numeric(opt$resolution)

# Seurat
logfc_thr <- opt$logfc_thr
min_perc <- opt$min_perc
rthr <- opt$rthr
