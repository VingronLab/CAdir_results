## R wrapper for divbiclust cpp functions
algorithm <- "DivBiclust"
source("./benchmarking/setup_split.R")
sourceCpp("./benchmarking/algorithms/src/divbiclust.cpp")

cat("\nStarting DivBiclust...\n")
t <- Sys.time()

res <- DivBiclust(
  ds_type = ds_type,
  in_file = in_file,
  max_diff = max_diff,
  do_rate = do_rate,
  seed_col_sz = seed_col_sz,
  max_col_sz = max_col_sz,
  simthresh = simThresh
)
t.run <- Sys.time() - t

ari <- stringr::word(res, 1, 1, "_")
ari <- as.numeric(ari)
ncluster <- stringr::word(res, 2, 2, "_")
ncluster <- as.numeric(ncluster)

output_file <- paste0(ds_type, "_output.txt")
cell_assignments <- parse_divbiclust_output(output_file, ncell = ncell)

if (isTRUE(is_cell_clustering)) {
  if (all(is.na(cell_assignments))) {
    message("DivBiclust found no biclusters — skipping evaluation.")
    ncluster <- 0L
    eval_res <- list(
      "ARI_cells_mclust" = NA,
      "RI" = NA,
      "ARI" = NA,
      "MI" = NA,
      "AMI" = NA,
      "VI" = NA,
      "NVI" = NA,
      "ID" = NA,
      "NID" = NA,
      "NMI" = NA,
      "Chi2" = NA,
      "MARI" = NA,
      "MARIraw" = NA
    )
  } else {
    if (anyNA(cell_assignments)) {
      cat("\nWARNING: CELL ASSIGNMENTS CONTAIN NAs.\n")
    }
    eval_res <- eval_cell_clustering(
      clustering = cell_assignments,
      reference = colData(data)[, truth]
    )
  }

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = ntop,
      "ncells" = ncell,
      "nclust_found" = ncluster,
      "runtime" = t.run,
      "runtime_dimreduc" = NA
    )
  )
} else {
  stop("Biclustering evaluation not implemented for DivBiclust.")
}

eval_res <- bind_cols(eval_res, as_tibble(opt))


write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)
cat("\nFinished benchmarking!\n")
