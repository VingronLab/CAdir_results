alg_option_list <- list(
  make_option(
    c("--scdbic_mode"),
    type = "character",
    action = "store",
    default = "biclusters",
    help = paste(
      "Which scDBic script to run:",
      "'biclusters' uses scDBic_output_biclusters.R (full gene x cell submatrices);",
      "'cell_assignment' uses scDBic.R (cell cluster IDs, gene assignment is post-hoc)."
    ),
    metavar = "character"
  ),
  make_option(
    c("--seed"),
    type = "numeric",
    action = "store",
    default = 1,
    help = "Random seed for R-level stochastic steps (walktrap etc.)",
    metavar = "numeric"
  ),
  make_option(
    c("--tmpdir"),
    type = "character",
    action = "store",
    default = tempdir(),
    help = "Temporary directory for intermediate files",
    metavar = "character"
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

scdbic_mode <- opt$scdbic_mode
seed        <- as.integer(opt$seed)
tmp_dir     <- opt$tmpdir
conda_env   <- "r-pytorch-txq"

if (!scdbic_mode %in% c("biclusters", "cell_assignment")) {
  stop("--scdbic_mode must be 'biclusters' or 'cell_assignment'.", call. = FALSE)
}
