#NOTE: Script to evaluate cell clustering results.

eval_cell_clustering <- function(clustering, reference) {
  require(mclust)
  require(aricode)

  mclust_ari <- mclust::adjustedRandIndex(reference, clustering)
  eval_metrics <- aricode::clustComp(reference, clustering)

  res <- c(list("ARI_cells_mclust" = mclust_ari), eval_metrics)

  return(res)
}
