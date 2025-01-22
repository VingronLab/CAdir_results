library(s4vd)

alg_option_list <- list(
  make_option(c("--nclust"),
    type = "numeric",
    action = "store",
    default = NULL,
    help = "Assigning number of clusters for kmeans/skmeans",
    metavar = "numeric"
  ),
  make_option(c("--pcerv"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.05
    help = "Per comparsion wise error rate for v.",
    metavar = "numeric"
  ),
  make_option(c("--pceru"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.05
    help = "Per comparsion wise error rate for u.",
    metavar = "numeric"
  ),
  make_option(c("--ss_thr_min"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.6
    help = "Range of the cutoff threshold minimum.",
    metavar = "numeric"
  ),
  make_option(c("--ss_thr_add"),
    type = "numeric",
    action = "store",
    default = NA, # default 0.05
    help = "Range of the cutoff threshold: to add on minimum",
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

pcerv <- opt$pcerv
pceru <- opt$pceru
ss_thr <- c(opt$ss_thr_min, (opt$ss_thr_min + opt$ss_thr_add))

nclust <- opt$nclust

if (nclust == "NULL") {
  nclust <- NULL
}
