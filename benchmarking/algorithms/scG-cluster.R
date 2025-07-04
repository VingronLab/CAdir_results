algorithm <- "scG-cluster"
source("./setup_split.R")

if (!isTRUE(is_cell_clustering)) {
  stop("Not a biclustering algorithm.")
}

cat("\nStarting scG-cluster\n")
t <- Sys.time()

# data <- readRDS("./data/sim/preprocessed/pbmc3k/dePROB-0_1_defacLOC-1_5_defacSCALE-1_5_filtered.rds")
cnts <- as.matrix(counts(data))
# label <- as.numeric(as.factor(colData(data)[, truth]))
label <- as.numeric(as.factor(colnames(data)))

# tmp_dir <- tempdir()
h5file <- tempfile(fileext = ".h5", tmpdir = tmp_dir)
h5preproc <- file.path(tmp_dir, "preproc.h5")

h5createFile(h5file)
h5write(file = h5file, obj = cnts, name = "X")
h5write(file = h5file, obj = label, name = "Y")

if (dataset == "Tirosh_nonmaglignant" || dataset == "dmel_E14-16h") {
  ignore_noint <- "--ignore_noint"
} else {
  ignore_noint <- ""
}

preproc <- "python /home/kohl/gits/ClemensKohl/CAdir_benchmarking/algorithms/scG-cluster/preprocess.py"
preproc <- paste(
  preproc,
  "--file_path", h5file,
  "--save_path", h5preproc,
  "--ngenes", ntop,
  ignore_noint
)
cat(preproc)
system(preproc)

graph <- "python /home/kohl/gits/ClemensKohl/CAdir_benchmarking/algorithms/scG-cluster/graph_function.py"
graph <- paste(
  graph,
  "--outdir", tmp_dir,
  "--file", h5preproc,
  "--method", scg_method
)
cat(graph)
system(graph)

train <- "python /home/kohl/gits/ClemensKohl/CAdir_benchmarking/algorithms/scG-cluster/train.py"
train <- paste(
  train,
  "--dataset_path", h5preproc,
  "--model_pth", tmp_dir,
  "--n_clusters", n_clusters,
  "--method", scg_method,
  "--seed", seed,
  "--pretrain_epochs", pretrain_epochs,
  "--train_epochs", train_epochs
)
cat(train)
system(train)

t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished scG-cluster\n")

res <- scan(file.path(tmp_dir, "cluster_pred.txt"))

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
