library(CAbiNet)
library(APL)

alg_option_list <- list(
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
  make_option(c("--prune_overlap"),
    type = "logical",
    action = "store",
    default = TRUE,
    help = "prune gene nodes in the SNN graph by overlapping of neighbourhood",
    metavar = "logical"
  ),
  make_option(c("--resolution"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Resolutions leiden algorithm, numbers should be separated by comma",
    metavar = "numeric"
  ),
  make_option(c("--usegap"),
    type = "logical",
    action = "store",
    default = NA,
    help = "Whether to use eigengap or not",
    metavar = "logical"
  ),
  make_option(c("--nclust"),
    type = "numeric",
    action = "store",
    default = NULL,
    help = "Assigning number of clusters for kmeans/skmeans",
    metavar = "numeric"
  ),
  make_option(c("--graph_select"),
    type = "logical",
    action = "store",
    default = NA,
    help = "Whether genes should be selected on the graph",
    metavar = "logical"
  ),
  make_option(c("--graph_select_by_prop"),
    type = "logical",
    action = "store",
    default = FALSE,
    help = "Whether top variable genes should be selected by 80% criterion",
    metavar = "logical"
  ),
  make_option(c("--gcKNN"),
    type = "logical",
    action = "store",
    default = NA,
    help = "Whether gcKNN should be calculated",
    metavar = "logical"
  ),
  make_option(c("--SNN_mode"),
    type = "character",
    action = "store",
    default = NA,
    help = "SNN mode for caclust",
    metavar = "character"
  ),
  make_option(c("--leiden_pack"),
    type = "character",
    action = "store",
    default = "igraph",
    help = "package for running leiden algorithm",
    metavar = "character"
  ),
  make_option(c("--overlap"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "Overlap for graph pruning",
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

# CA
dims <- opt$dims

# CAbiNet
NNs <- opt$NNs
prune <- opt$prune
prune_overlap <- opt$prune_overlap
resol <- as.numeric(opt$resolution)
usegap <- opt$usegap
SNN_mode <- opt$SNN_mode
graph_select <- opt$graph_select
graph_select_by_prop <- opt$graph_select_by_prop
gcKNN <- opt$gcKNN
overlap <- opt$overlap
leiden_pack <- opt$leiden_pack

if (is.character(overlap)) overlap <- NA
