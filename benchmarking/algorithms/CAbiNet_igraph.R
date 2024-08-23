algorithm <- "CAbiNet"
source("./benchmarking/setup_split.R")

algorithm <- "CAbiNet_igraph"


if (is.na(dims)) {
  stop("Need to specify dimensionality.")
}

cat("\nStarting CA.\n")
t <- Sys.time()
caobj <- cacomp(cnts,
  dims = dims,
  top = nrow(cnts),
  python = TRUE
)

t.CA <- difftime(Sys.time(), t, units = "secs")


# Leiden clustering
cat("\nStarting CAclust leiden\n")

t <- Sys.time()

res <- caclust(
  obj = caobj,
  k = NNs,
  loops = FALSE,
  SNN_prune = prune,
  mode = SNN_mode,
  select_genes = graph_select,
  prune_overlap = prune_overlap,
  overlap = overlap,
  calc_gene_cell_kNN = gcKNN,
  algorithm = "leiden",
  leiden_pack = "igraph"
)

t.run <- difftime(Sys.time(), t, units = "secs")



###########

if (isTRUE(is_cell_clustering)) {
  eval_res <- eval_cell_clustering(
    clustering = cell_clusters(res),
    reference = colData(data)[, truth]
  )

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = nrow(cnts),
      "ncells" = ncol(cnts),
      "nclust_found" = length(unique(cell_clusters(res))),
      "runtime" = t.run,
      "runtime_dimreduc" = t.CA
    )
  )
} else {
  res <- convert_to_biclust(res)

  if (isTRUE(sim)) {
    eval_res <- evaluate_sim(
      sce = data,
      biclust = res,
      truth_col = truth
    )

    eval_res <- c(
      list("algorithm" = algorithm),
      as.list(eval_res),
      list(
        "ngenes" = nrow(cnts),
        "ncells" = ncol(cnts),
        "nclust_found" = res@Number,
        "runtime" = t.run,
        "runtime_dimreduc" = t.CA
      )
    )
  } else {
    eval_res <- evaluate_real(
      sce = data,
      biclust = res,
      truth_col = truth
    )

    eval_res <- c(
      list("algorithm" = algorithm),
      as.list(eval_res),
      list(
        "ngenes" = nrow(cnts),
        "ncells" = ncol(cnts),
        "nclust_found" = res@Number,
        "runtime" = t.run,
        "runtime_dimreduc" = t.CA
      )
    )
  }
}

eval_res <- bind_cols(eval_res, tibble::as_tibble(opt))
write_csv(eval_res, file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv")))
cat("\nFinished benchmarking!\n")
