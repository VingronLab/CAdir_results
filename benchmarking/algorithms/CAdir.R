algorithm <- "CAdir"
source("./setup_split.R")

if (is.null(angle)) {
  algorithm <- "CAdir_auto"
}

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


t <- Sys.time()

cadir <- dirclust_splitmerge(
  caobj = caobj,
  k = kdir,
  cutoff = angle,
  method = "random",
  apl_quant = apl_quant,
  counts = NULL,
  min_cells = 20,
  reps = 5,
  make_plots = FALSE
)

t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished CAdir\n")

res <- cadir_to_biclust(cadir)

###########

if (isTRUE(is_cell_clustering)) {
  eval_res <- eval_cell_clustering(
    clustering = cell_clusters(cadir),
    reference = colData(data)[, truth]
  )

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = nrow(cnts),
      "ncells" = ncol(cnts),
      "nclust_found" = length(unique(cell_clusters(cadir))),
      "runtime" = t.run,
      "runtime_dimreduc" = t.CA
    )
  )
} else {
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

eval_res <- bind_cols(eval_res, as_tibble(opt))
write_csv(eval_res,
          file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv")))
cat("\nFinished benchmarking!\n")
