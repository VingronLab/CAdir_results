# to install run "pip install backspinpy"
source("./algorithms/backspin/backspin_fun.R")

# Backspin Options
alg_option_list <- list(
  make_option(c("--numLevels"),
    type = "numeric",
    action = "store",
    default = 2,
    help = "the number of splits that will be tried",
    metavar = "numeric"
  ),
  make_option(c("--stop_const"),
    type = "numeric",
    action = "store",
    default = 1.15,
    help = "minimum score that a breaking point has to reach to be suitable for splitting",
    metavar = "numeric"
  ),
  make_option(c("--low_thrs"),
    type = "numeric",
    action = "store",
    default = 0.2,
    help = "genes with average lower than this threshold are assigned to either of the splitting group reling on genes that are higly correlated with them",
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

# BackSpin
numL <- opt$numLevels
stopc <- opt$stop_const
lowT <- opt$low_thrs
