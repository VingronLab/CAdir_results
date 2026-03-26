#NOTE: Script to evaluate cell clustering results.

eval_cell_clustering <- function(clustering, reference) {
  require(mclust)
  require(aricode)

  mclust_ari <- mclust::adjustedRandIndex(reference, clustering)
  eval_metrics <- aricode::clustComp(reference, clustering)

  res <- c(list("ARI_cells_mclust" = mclust_ari), eval_metrics)

  return(res)
}

# Parse cluster assignments from a DivBiclust output file.
# The output file contains lines of the form:
#   Pattern N: (#cells = M) i1 i2 ... iM
# where cell indices are 0-based.
# Returns an integer vector of length `ncell` (or max observed index + 1 if
# ncell is NULL).  Each element is the 1-based pattern number for that cell,
# or NA if the cell was not assigned to any pattern.
parse_divbiclust_output <- function(filepath, ncell = NULL) {
  lines <- readLines(filepath)

  pattern_lines <- grep("^Pattern [0-9]+:", lines, value = TRUE)

  if (length(pattern_lines) == 0) {
    message("No Pattern lines found in: ", filepath)
    if (is.null(ncell)) {
      return(integer(0))
    }
    return(rep(NA_integer_, ncell))
  }

  parsed <- lapply(pattern_lines, function(ln) {
    pat_id <- as.integer(sub("^Pattern ([0-9]+):.*", "\\1", ln))
    cell_part <- sub("^Pattern [0-9]+: \\(#cells = [0-9]+\\) ", "", ln)
    cells_0based <- as.integer(strsplit(trimws(cell_part), "\\s+")[[1]])
    list(pat_id = pat_id, cells = cells_0based)
  })

  cells <- unlist(lapply(parsed, function(p) p$cells + 1L))
  clusters <- unlist(lapply(parsed, function(p) {
    rep(p$pat_id + 1L, length(p$cells))
  }))

  n <- if (!is.null(ncell)) ncell else max(cells)
  assignment <- rep(NA_integer_, n)
  assignment[cells] <- clusters
  assignment
}
