library(SC3)

# SC3 Options
alg_option_list <- list(
  make_option(c("--sc3_k"),
    type = "numeric",
    action = "store",
    default = 5,
    help = "Number of clusters for SC3",
    metavar = "numeric"
  ),
  make_option(c("--gene_filtering"),
    type = "numeric",
    action = "store",
    default = 0,
    help = "Turn SC3 gene filtering on/off.",
    metavar = "numeric"
  ),
  make_option(c("--d_min"),
    type = "numeric",
    action = "store",
    default = 0.04,
    help = "Min n eigenvector as % of cells.",
    metavar = "numeric"
  ),
  make_option(c("--d_max"),
    type = "numeric",
    action = "store",
    default = 0.07,
    help = "Max n eigenvector as % of cells.",
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

sc3_k <- opt$sc3_k
if (sc3_k == 0) sc3_k <- NULL
d_min <- opt$d_min
d_max <- opt$d_max

if (opt$gene_filtering == 0) {
  gene_filtering <- FALSE
} else if (opt$gene_filtering == 1) {
  gene_filtering <- TRUE
} else {
  stop("no valid gene_filtering")
}
