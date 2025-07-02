algorithm <- "scASDC"
source("./setup_split.R")

if (!isTRUE(is_cell_clustering)) {
  stop("Not a biclustering algorithm.")
}

cnts <- as.matrix(counts(data))

pred_dir <- tempdir()
h5file <- tempfile(fileext = ".h5", tmpdir = pred_dir)

h5createFile(h5file)
h5write(file = h5file, obj = cnts, name = "X")

cmd <- "python /home/kohl/gits/scDeepCluster_pytorch/run_scDeepCluster.py"
cmd <- paste(
  cmd,
  "--dataset", h5file,
  "--name", name,
  "--k", scasdc_k,
  "--n_clusters", scasdc_nclusters,
  "--nz", scasdc_nz,
  "--outdir", pred_dir,
  "--n_input", ntop
)

cat("\nStarting scDeepCluster.\n")
t <- Sys.time()

system(cmd)

t.run <- difftime(Sys.time(), t, units = "secs")
cat("\nFinished scDeepCluster\n")
