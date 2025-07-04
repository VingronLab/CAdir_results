algorithm <- "scDeepCluster"
source("./setup_split.R")

if (!isTRUE(is_cell_clustering)) {
  stop("Not a biclustering algorithm.")
}

cnts <- as.matrix(counts(data))

# tmp_dir <- tempdir()
h5file <- tempfile(fileext = ".h5", tmpdir = tmp_dir)

h5createFile(h5file)
h5write(file = h5file, obj = cnts, name = "X")

if (dataset == "Tirosh_nonmaglignant" || dataset == "dmel_E14-16h") {
  ignore_noint <- "--ignore_noint"
} else {
  ignore_noint <- ""
}

cmd <- "python ./benchmarking/algorithms/scDeepCluster_pytorch/run_scDeepCluster.py"
cmd <- paste(
  cmd,
  "--data_file",
  h5file,
  "--n_clusters",
  n_clusters,
  "--resolution",
  resolution,
  "--knn",
  knn,
  "--device",
  device,
  "--save_dir",
  tmp_dir,
  "--predict_label_file",
  file.path(tmp_dir, "pred_labels.txt"),
  "--ae_weight_file",
  file.path(tmp_dir, "AE_weights.pth.tar"),
  "--final_latent_file",
  file.path(tmp_dir, "final_latent_file.txt"),
  ignore_noint
)

cat("\nStarting scDeepCluster.\n")
t <- Sys.time()
cat(cmd)
system(cmd)

t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished scDeepCluster\n")

res <- scan(file.path(tmp_dir, "pred_labels.txt"))
unlink(tmp_dir, recursive = TRUE)

###############

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
  stop("Not a biclustering algorithm.")
}

eval_res <- bind_cols(eval_res, as_tibble(opt))
write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)
cat("\nFinished benchmarking!\n")
