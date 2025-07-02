algorithm <- "SC3"
source("./setup_split.R")

if (is.null(sc3_k)) {
  k_est <- TRUE
} else {
  k_est <- FALSE
}

counts(data) <- as.matrix(counts(data))
logcounts(data) <- as.matrix(logcounts(data))

rowData(data)$feature_symbol <- rownames(data)

cat("\nStarting SC3.\n")
t <- Sys.time()

sce <- SC3::sc3(
  object = data,
  ks = sc3_k, # number of clusters.
  gene_filter = gene_filtering, # Turn gene_filtering on/off
  pct_dropout_min = 10,
  pct_dropout_max = 90,
  d_region_min = d_min, # 0.04,
  d_region_max = d_max, # 0.07,
  svm_num_cells = NULL,
  svm_train_inds = NULL,
  svm_max = 5000, # Below this n cells SVM is not used. as in their paper.
  n_cores = 5, # DEBUGGING otherwise set NULL
  kmeans_nstart = NULL,
  kmeans_iter_max = 1e+09,
  k_estimator = k_est, # TRUE -> estimates k iff ks = NULL
  biology = FALSE, # TRUE
  rand_seed = 2358
)

# TODO: Add gene expression (biology=TRUE) for biclustering.
t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished SC3\n")

if (is.null(sc3_k)) {
  sc3_col <- grep("sc3_[0-9]+_clusters", colnames(colData(sce)))
} else {
  sc3_col <- paste0("sc3_", sc3_k, "_clusters")
}

res <- colData(sce)[, sc3_col]
res <- as.character(res)

if (anyNA(res)) {
  res[is.na(res)] <- "N/A"
}

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
  stop("biclustering not implemented for SC3!")
}

eval_res <- bind_cols(eval_res, as_tibble(opt))

write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)

cat("\nFinished benchmarking!\n")
