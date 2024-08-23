algorithm <- "SIMLR"
source("./benchmarking/setup_split.R")

cat("\nStarting SIMLR.\n")
t <- Sys.time()

res <- SIMLR(
  X = cnts, #TODO: Logcounts or raw counts?
  c = simlr_k,
  no.dim = ndim,
  k = k_tuning, # 10 #FIXME: Find out what it is and if it should be changed!
  if.impute = FALSE,
  normalize = FALSE,
  cores.ratio = 0
)

t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished SIMLR.\n")

res <- res$y$cluster

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
  stop("biclustering not implemented for SIMLR!")
}

eval_res <- bind_cols(eval_res, as_tibble(opt))

write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)

cat("\nFinished benchmarking!\n")
