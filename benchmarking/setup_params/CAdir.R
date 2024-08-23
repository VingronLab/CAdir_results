devtools::load_all("/project/kohl_analysis/analysis/CAdir/CAdir/")
library(APL)
library(CAbiNet)

alg_option_list <- list(
  make_option(c("--qcut"),
    type = "numeric",
    action = "store",
    default = 0.8,
    help = "quantile for gene cutoff",
    metavar = "numeric"
  ),
  make_option(c("--angle"),
    type = "numeric",
    action = "store",
    default = 30,
    help = "angle cutoff ",
    metavar = "numeric"
  ),
  make_option(c("--kdir"),
    type = "numeric",
    action = "store",
    default = 30,
    help = "number of directions for CAdir",
    metavar = "numeric"
  ),
  # make_option(c("--coords"),
  #   type = "character",
  #   action = "store",
  #   default = "prin",
  #   help = "Coordinates to use for gene assignment",
  #   metavar = "character"
  # ),
  make_option(c("--apl_quant"),
    type = "numeric",
    action = "store",
    default = 0.99,
    help = "Quantile for APL cutoff",
    metavar = "numeric"
  ),
  make_option(c("--subsp_dim"),
    type = "numeric",
    action = "store",
    default = 30,
    help = "Dimensions for subspaces",
    metavar = "numeric"
  ),
  make_option(c("--dims"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "dimensions",
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

# CAdir
kdir <- opt$kdir
qcut_param <- opt$qcut
angle <- opt$angle
# coords <- opt$coords
apl_quant <- opt$apl_quant

# subspace clustering
subsp_dim <- opt$subsp_dim

# 0 angle to NULL!
angle <- as.numeric(angle)
if (angle == 0) {
  angle <- NULL
}
