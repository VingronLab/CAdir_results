alg_option_list <- list(
  make_option(
    c("--qqubic2"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "quantile threshold for discretiziation",
    metavar = "numeric"
  ),
  make_option(
    c("--qnclust"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "number of clusters",
    metavar = "numeric"
  ),
  make_option(
    c("--objF"),
    type = "character",
    action = "store",
    default = "",
    help = "objective function: C for KLDual, N for Dual",
    metavar = "character"
  ),
  make_option(
    c("--qcons"),
    type = "numeric",
    action = "store",
    default = NA,
    help = "consistency level of the block",
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

qQubic2 <- opt$qqubic2
q_nclust <- opt$qnclust
q_cons <- opt$qcons

if (opt$objF == "C") {
  objF <- "-C"
} else if (opt$objF == "N") {
  objF <- "-C -N"
} else {
  stop("invalid objF")
}
