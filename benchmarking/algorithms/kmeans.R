algorithm <- "kmeans"

source("./setup_split.R")

cat("\nStarting k-means clustering\n")

t <- Sys.time()

k <- min(dim(cnts)) - 1

use_python <- TRUE
if (dims < k) use_python <- FALSE

pca <- run_pca(
  mat = cnts,
  dims = dims,
  python = use_python
)

pca <- pca_coords(pca)

t_pca <- difftime(Sys.time(), t, units = "secs")

t <- Sys.time()

kres <- kmeans(
  x = pca@prin_coords_cols,
  centers = kmeansk,
  iter.max = 100L,
  nstart = 5,
  algorithm = "Hartigan-Wong"
)

cell_clusters <- kres$cluster
centroids <- kres$centers

t_clust <- difftime(Sys.time(), t, units = "secs")

# Assign genes to clusters
if (coords == "prin") {
  idx <- pca_sphere_idx(pca@prin_coords_rows, qcutoff = qcut_param)
} else if (coords == "std") {
  idx <- pca_sphere_idx(pca@std_coords_rows, qcutoff = qcut_param)
} else {
  stop("Invalid coords argument")
}

gene_coords <- pca@std_coords_rows[idx, ]
gene_dist <- gene_coords %*% t(centroids)
gene_clusters <- apply(gene_dist, 1, which.max)


t_run <- difftime(Sys.time(), t, units = "secs")


res <- bic_to_biclust(
  cell_clusters = cell_clusters,
  gene_clusters = gene_clusters,
  params = list(
    "algorithm" = "kmeans",
    "dims" = dims,
    "nclust" = kmeansk,
    "python" = use_python
  )
)


###########

if (isTRUE(is_cell_clustering)) {
  eval_res <- eval_cell_clustering(
    clustering = cell_clusters,
    reference = colData(data)[, truth]
  )

  eval_res <- c(
    list("algorithm" = algorithm),
    as.list(eval_res),
    list(
      "ngenes" = nrow(cnts),
      "ncells" = ncol(cnts),
      "nclust_found" = length(unique(cell_clusters)),
      "runtime" = t_clust,
      "runtime_dimreduc" = t_pca
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
        "runtime" = t_run,
        "runtime_dimreduc" = t_pca
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
        "runtime" = t_run,
        "runtime_dimreduc" = t_pca
      )
    )
  }
}

eval_res <- bind_cols(eval_res, as_tibble(opt))

write_csv(
  eval_res,
  file.path(
    outdir,
    paste0(algorithm, "_", name, "_EVALUATION.csv")
  )
)
cat("\nFinished benchmarking!\n")
