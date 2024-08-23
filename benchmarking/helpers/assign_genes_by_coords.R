
ca_sphere_idx <- function(x, qcutoff = 0.8) {
    xn <- row_norm(x)
    q <- quantile(xn, qcutoff)

    idx <- which(xn > q)

    return(idx)
}

assign_genes_coords <- function(caobj,
                                directions,
                                qcutoff = NULL,
                                coords = "prin") {

    if (coords == "prin") {
        idx <- ca_sphere_idx(caobj@prin_coords_rows, qcutoff = qcutoff)
    } else if (coords == "std") {
        idx <- ca_sphere_idx(caobj@std_coords_rows, qcutoff = qcutoff)
    } else {
        stop("Invalid coords argument")
    }

    X <- caobj@std_coords_rows[idx, ]

    ldist <- dist_to_line(X, directions, norm_vec(X))
    # find closest line
    clusters <- apply(ldist, 1, which.min)

    return(clusters)
}


dist_to_subspace <- function(X, subspaces, Xnorm) {
  nspaces <- length(subspaces)
  subsp_dist <- matrix(0, nrow = nrow(X), ncol = nspaces)

  for (s in seq_len(nspaces)) {
    proj <- (X %*% subspaces[[s]])
    dist <- rowSums(Xnorm^2 - proj^2)
    dist[dist < 0] <- 0
    subsp_dist[, s] <- sqrt(dist)
  }
  rownames(subsp_dist) <- rownames(X)
  colnames(subsp_dist) <- names(subspaces)

  return(subsp_dist)
}

assign_genes_coords_subspace <- function(caobj,
                                         subspaces,
                                         qcutoff = NULL,
                                         coords = "prin") {
  if (coords == "prin") {
    idx <- ca_sphere_idx(caobj@prin_coords_rows, qcutoff = qcutoff)
  } else if (coords == "std") {
    idx <- ca_sphere_idx(caobj@std_coords_rows, qcutoff = qcutoff)
  } else {
    stop("Invalid coords argument")
  }

  X <- caobj@std_coords_rows[idx, ]
  sdist <- dist_to_subspace(X, subspaces, norm_vec(X))

  # find closest line
  clusters <- apply(sdist, 1, which.min)

  return(clusters)
}
