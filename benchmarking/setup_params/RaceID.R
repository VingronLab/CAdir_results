library(RaceID)

alg_option_list <- list(
  make_option(c("--auto_mode"),
    type = "numeric",
    action = "store",
    default = 0,
    help = "Whether or not to run RaceID in auto mode.",
    metavar = "numeric"
  ),
  make_option(c("--raceid_k"),
    type = "numeric",
    action = "store",
    default = 5,
    help = "Number of clusters for RaceID.",
    metavar = "numeric"
  ),
  make_option(c("--raceid_metrics"),
    type = "character",
    action = "store",
    default = "pearson",
    help = "Metric to calculate distance.",
    metavar = "character"
  ),
  make_option(c("--clustering_alg"),
    type = "character",
    action = "store",
    default = "kmedoids",
    help = "Clustering algorithm for RaceID",
    metavar = "character"
  ),
  make_option(c("--samp"),
    type = "numeric",
    action = "store",
    default = NULL,
    help = "n rand cells used for cluster number inference. 1000 is default",
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


auto_mode <- opt$auto_mode
raceid_k <- opt$raceid_k
raceid_metrics <- opt$raceid_metrics
clustering_alg <- opt$clustering_alg
samp <- opt$samp

if (auto_mode == 0) {
  auto_mode <- FALSE
} else if (auto_mode == 1) {
  auto_mode <- TRUE
} else {
  stop("Invalid value for auto_mode!")
}

if (raceid_k == 0) {
  raceid_k <- NULL
}

if (samp == "NULL") {
  samp  <- NULL
}
