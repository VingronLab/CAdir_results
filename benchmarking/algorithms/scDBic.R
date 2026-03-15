algorithm <- "scDBic"
source("./benchmarking/setup_split.R")

# NOTE: conda env setup
# conda create -n r-pytorch python=3.10
# conda activate r-pytorch
# pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
# conda install -c conda-forge numpy==2.1.2 pandas==2.3.3 scipy==1.15 scikit-learn==1.7.2 scanpy==1.11.5 igraph==1.0.0

# Initialize Python with the configured conda env before sourcing the scDBic
# scripts so their internal use_condaenv() calls become no-ops.
library(reticulate)
use_condaenv(conda_env, required = TRUE)
py_run_string("pass")

# Set the R seed before sourcing.  Both scDBic scripts have their set.seed(1L)
# commented out so this value is preserved through walktrap and other R-level
# stochastic steps.  The Python / ML seed is fixed at 1 inside the scripts
# (set_seed(1) in py_run_string) and is intentionally not varied here.
set.seed(seed)

# scDBic scripts apply log1p internally, so pass raw counts.
raw_cnts <- as.matrix(counts(data))
input_csv <- file.path(tmp_dir, "scDBic_input.csv")
write.csv(raw_cnts, file = input_csv)

cat("\nStarting scDBic.\n")
t <- Sys.time()

if (scdbic_mode == "cell_assignment") {
  # ---- algorithms/scDBic/scDBic.R ----------------------------------------
  # Returns data.frame(v1 = cell_name, v2 = bicluster_id) saved to OUTPUT_DIR.

  INPUT_FILE <- input_csv
  LABEL_FILE <- NULL
  OUTPUT_DIR <- file.path(tmp_dir, "scDBic_out")
  LOG_DIR <- file.path(tmp_dir, "scDBic_logs")
  CONDA_ENV_NAME <- conda_env
  CONDA_PATH <- NULL

  source("./benchmarking/algorithms/scDBic/scDBic.R")

  t.run <- difftime(Sys.time(), t, units = "secs")
  cat("\nFinished scDBic.\n")

  result <- read.csv(
    file.path(OUTPUT_DIR, "scDBic_results_raw.csv"),
    stringsAsFactors = FALSE
  )

  # Cell clusters come directly from the scDBic output.
  cell_clust <- setNames(result$v2, result$v1)

  # Gene assignment (post-hoc): assign each gene to the bicluster in which
  # it has the highest mean logcounts expression.
  bic_ids <- sort(unique(cell_clust))
  gene_means <- sapply(bic_ids, function(b) {
    rowMeans(cnts[, names(cell_clust)[cell_clust == b], drop = FALSE])
  })
  gene_clust <- setNames(
    bic_ids[apply(gene_means, 1, which.max)],
    rownames(cnts)
  )

  res <- bic_to_biclust(cell_clust, gene_clust)
  res <- name_biclust(res, cnts)
} else {
  # ---- algorithms/scDBic/scDBic_output_biclusters.R -----------------------
  # Saves each terminal bicluster as a CSV (rows = genes, cols = cells) to
  # file.path(output_base, "biclusters").
  # Note: rm1() only subsets columns (cells), never rows, so every bicluster
  # will contain the full gene set of the input matrix.

  input_file <- input_csv
  output_base <- file.path(tmp_dir, "scDBic_out")

  source("./benchmarking/algorithms/scDBic/scDBic_output_biclusters.R")

  t.run <- difftime(Sys.time(), t, units = "secs")
  cat("\nFinished scDBic.\n")

  bic_dir <- file.path(output_base, "biclusters")
  bic_files <- list.files(bic_dir, pattern = "\\.csv$", full.names = TRUE)

  if (length(bic_files) == 0) {
    stop("scDBic_output_biclusters.R produced no bicluster files.")
  }

  all_genes <- rownames(cnts)
  all_cells <- colnames(cnts)
  n_bic <- length(bic_files)

  RowxNumber <- matrix(
    FALSE,
    nrow = length(all_genes),
    ncol = n_bic,
    dimnames = list(all_genes, paste0("BC", seq_len(n_bic)))
  )
  NumberxCol <- matrix(
    FALSE,
    nrow = n_bic,
    ncol = length(all_cells),
    dimnames = list(paste0("BC", seq_len(n_bic)), all_cells)
  )

  for (i in seq_along(bic_files)) {
    bic_mat <- read.csv(bic_files[i], row.names = 1, check.names = FALSE)
    bic_genes <- intersect(rownames(bic_mat), all_genes)
    bic_cells <- intersect(colnames(bic_mat), all_cells)
    RowxNumber[bic_genes, i] <- TRUE
    NumberxCol[i, bic_cells] <- TRUE
  }

  res <- new(
    "Biclust",
    Parameters = list(algorithm = algorithm, mode = scdbic_mode),
    RowxNumber = RowxNumber,
    NumberxCol = NumberxCol,
    Number = n_bic,
    info = list()
  )
}

###############

if (isTRUE(is_cell_clustering)) {
  cell_clust_vec <- if (scdbic_mode == "cell_assignment") {
    cell_clust
  } else {
    apply(res@NumberxCol, 2, function(col) which(col)[1])
  }

  eval_res <- eval_cell_clustering(
    clustering = cell_clust_vec,
    reference = colData(data)[, truth]
  )

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = nrow(cnts),
      "ncells" = ncol(cnts),
      "nclust_found" = res@Number,
      "runtime" = t.run,
      "runtime_dimreduc" = NA
    )
  )
} else {
  if (isTRUE(sim)) {
    eval_res <- evaluate_sim(sce = data, biclust = res, truth_col = truth)
  } else {
    eval_res <- evaluate_real(sce = data, biclust = res, truth_col = truth)
  }

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = nrow(cnts),
      "ncells" = ncol(cnts),
      "nclust_found" = res@Number,
      "runtime" = t.run,
      "runtime_dimreduc" = NA
    )
  )
}

eval_res <- bind_cols(eval_res, as_tibble(opt))
write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)
cat("\nFinished benchmarking!\n")
