algorithm <- "RaceID"
source("./setup_split.R")

if (isTRUE(auto_mode)) {
  algorithm <- "RaceID_auto"
  raceid_k <- NULL
}


# Create SCseq object from raw counts

sc <- SCseq(as.matrix(counts(data)))
# sc <- SCseq(intestinalData)

cat("\nStarting RaceID workflow.\n")
t <- Sys.time()

# Feature selection - already done, we dont need to redo it.
sc <- filterdata(sc, mintotal = 1, minnumber = 1, minexpr = 1)
# fdata <- getfdata(sc)

# Compute distances
# NOTE: FSelect toggles feature selection.
# Optimally, we would like to keep this on, but in 2/3 cases it actually leads to
# NA values in the distance matrix and was therefore turned off.
# Short expl.: Genes above background is very small, for a single cell they have identical counts
# --> std = 0 -> NA
sc <- compdist(sc, metric = raceid_metrics, FSelect = FALSE)

# Cluster
sc <- clustexp(
  object = sc, # sc class object.
  sat = auto_mode, # If True figures cluster numbers out.
  samp = samp, # n rand cells used for cluster number inference. 1000 is default
  cln = raceid_k, # If NULL determine cluster numbers by itself, otherwise k=cln
  clustnr = 30, # Maximum number of clusters.
  bootnr = 50, # Number of booststrapping runs
  rseed = 17000,
  FUNcluster = clustering_alg
)

t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished RaceID\n")

res <- sc@cluster$kpart

if (isTRUE(is_cell_clustering)) {
  eval_res <- eval_cell_clustering(
    clustering = res,
    reference = colData(data)[, truth]
  )

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = nrow(cnts),
      "ncells" = ncol(cnts),
      "nclust_found" = length(unique(res)),
      "runtime" = t.run,
      "runtime_dimreduc" = NA
    )
  )
} else {
  stop("Biclustering not implemented for RaceID!")
}

###########

eval_res <- bind_cols(eval_res, as_tibble(opt))

write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)

cat("\nFinished benchmarking!\n")
