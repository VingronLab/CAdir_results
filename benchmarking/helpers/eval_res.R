
ari_cells <- function(reference, biclust_obj, reference_col = "Group") {
  cc <- biclust_obj@NumberxCol

  cc_clust <- vector(mode = "numeric", length = ncol(cc))

  for (j in seq_len(ncol(cc))) {
    idx <- which(cc[, j] == TRUE)

    if (length(idx) == 0) idx <- 0
    if (length(idx) > 1) idx <- sample(x = idx, size = 1)
    cc_clust[j] <- idx
  }

  cc_clust <- as.factor(cc_clust)

  stopifnot(
    length(cc_clust) == length(SummarizedExperiment::colData(reference)[, reference_col])
  )

  ari <- mclust::adjustedRandIndex(
    cc_clust,
    SummarizedExperiment::colData(reference)[, reference_col]
  )
  return(ari)
}


ari_genes <- function(splatter_sim, biclust_obj) {
  rd <- as.data.frame(SummarizedExperiment::rowData(splatter_sim))
  gc <- biclust_obj@RowxNumber

  rd <- rd[rd$Gene %in% rownames(gc), ]

  de_fac <- dplyr::select(rd, tidyselect::starts_with("DEFacGroup"))
  de_fac <- as.matrix(de_fac)

  # doesnt consider that gene can be DE in 2 groups
  de_genes <- de_fac > 1 | de_fac < 1
  de_bool <- matrix(FALSE,
    nrow = nrow(de_fac),
    ncol = ncol(de_fac),
    dimnames = list(
      rownames(de_fac),
      colnames(de_fac)
    )
  )

  for (x in seq_len(nrow(de_fac))) {
    if (any(de_genes[x, ])) {
      vals <- de_fac[x, ][de_genes[x, ]]
      max_val <- which(abs(vals) == max(abs(vals)))

      de_bool[x, which(de_fac[x, ] == vals[max_val])] <- TRUE
    } else {
      next
    }
  }

  grp <- as.numeric(de_bool %*% seq_len(ncol(de_bool)))
  grp_fact <- as.factor(grp)
  names(grp_fact) <- rownames(de_bool)

  gc_clust <- as.numeric(gc %*% seq_len(ncol(gc)))
  gc_clust <- as.factor(gc_clust)
  names(gc_clust) <- rownames(gc)

  gc_clust <- gc_clust[order(base::match(names(gc_clust), names(grp_fact)))]

  ari <- mclust::adjustedRandIndex(gc_clust, grp_fact)

  return(ari)
}

recovery_biclust <- function(res, truth) {
  temp <- c()
  for (i in seq_len(truth@Number)) {
    # Matrix genes x cells
    truthdf <- Matrix::Matrix(0,
      nrow(truth@RowxNumber),
      ncol(truth@NumberxCol),
      sparse = T
    )

    dimnames(truthdf) <- list(rownames(truth@RowxNumber), colnames(truth@NumberxCol))

    # Mark cells and genes in cluster i
    truthdf[truth@RowxNumber[, i], truth@NumberxCol[i, ]] <- 1

    if (res@Number > 1) {
      # for each cluster in results, calculate U/I, take max for each cluster.
      temp <- c(temp, do.call(max, lapply(seq_len(res@Number), function(x) {
        # Matrix marking cells & genes in results that are in cluster i.
        resdf <- Matrix::Matrix(0,
          nrow(res@RowxNumber),
          ncol(res@NumberxCol),
          sparse = T
        )

        dimnames(resdf) <- list(
          rownames(res@RowxNumber),
          colnames(res@NumberxCol)
        )

        # Subset reference to rows & columns in results
        truth_tmp <- truthdf[
          rownames(truthdf) %in% rownames(resdf),
          colnames(truthdf) %in% colnames(resdf)
        ]

        resdf[res@RowxNumber[, x], res@NumberxCol[x, ]] <- 1

        ord_r <- order(match(rownames(resdf), rownames(truth_tmp)))
        ord_c <- order(match(colnames(resdf), colnames(truth_tmp)))

        resdf <- resdf[ord_r, ord_c]

        # Intersection / Union
        return(sum(truth_tmp & resdf) / sum(truth_tmp | resdf))
      })))
    } else {
      temp <- c(temp, unlist(lapply(seq_len(res@Number), function(x) {
        resdf <- Matrix::Matrix(0, nrow(res@RowxNumber), ncol(res@NumberxCol), sparse = T)
        dimnames(resdf) <- list(rownames(res@RowxNumber), colnames(res@NumberxCol))
        resdf[res@RowxNumber[, x], res@NumberxCol[x, ]] <- 1
        truth_tmp <- truthdf[
          rownames(truthdf) %in% rownames(resdf),
          colnames(truthdf) %in% colnames(resdf)
        ]

        ord_r <- order(match(rownames(resdf), rownames(truth_tmp)))
        ord_c <- order(match(colnames(resdf), colnames(truth_tmp)))

        resdf <- resdf[ord_r, ord_c]

        return(sum(truth_tmp & resdf) / sum(truth_tmp | resdf))
      })))
    }
  }
  return(sum(temp) / truth@Number)
}


relevance_biclust <- function(res, truth) {
  # column names of res/truth should be cluster, label
  temp <- c()
  for (i in seq_len(res@Number)) {
    resdf <- Matrix::Matrix(0, nrow(res@RowxNumber), ncol(res@NumberxCol), sparse = T)
    dimnames(resdf) <- list(rownames(res@RowxNumber), colnames(res@NumberxCol))
    resdf[res@RowxNumber[, i], res@NumberxCol[i, ]] <- 1

    if (res@Number > 0) {
      temp <- c(temp, do.call(max, lapply(seq_len(truth@Number), function(x) {
        truthdf <- Matrix::Matrix(0, nrow(truth@RowxNumber), ncol(truth@NumberxCol), sparse = T)
        dimnames(truthdf) <- list(rownames(truth@RowxNumber), colnames(truth@NumberxCol))
        truthdf[truth@RowxNumber[, x], truth@NumberxCol[x, ]] <- 1
        truthdf <- truthdf[
          rownames(truthdf) %in% rownames(resdf),
          colnames(truthdf) %in% colnames(resdf)
        ]

        ord_r <- order(match(rownames(resdf), rownames(truthdf)))
        ord_c <- order(match(colnames(resdf), colnames(truthdf)))

        resdf <- resdf[ord_r, ord_c]

        return(sum(truthdf & resdf) / sum(truthdf | resdf))
      })))
    } else {
      temp <- c(temp, unlist(lapply(seq_len(truth@Number), function(x) {
        truthdf <- Matrix::Matrix(0, nrow(truth@RowxNumber), ncol(truth@NumberxCol), sparse = T)
        dimnames(truthdf) <- list(rownames(truth@RowxNumber), colnames(truth@NumberxCol))
        truthdf[truth@RowxNumber[, x], truth@NumberxCol[x, ]] <- 1
        truthdf <- truthdf[
          rownames(truthdf) %in% rownames(resdf),
          colnames(truthdf) %in% colnames(resdf)
        ]

        ord_r <- order(match(rownames(resdf), rownames(truthdf)))
        ord_c <- order(match(colnames(resdf), colnames(truthdf)))

        resdf <- resdf[ord_r, ord_c]

        return(sum(truthdf & resdf) / sum(truthdf | resdf))
      })))
    }
  }
  return(sum(temp) / res@Number)
}

# FIXME: Rework
# TODO: implement fuzzy clusters.
sim_truth <- function(splatter_sim,
                      factor_cutoff = 1,
                      no_overlap = TRUE) {

  rd <- as.data.frame(SummarizedExperiment::rowData(splatter_sim))
  cd <- as.data.frame(SummarizedExperiment::colData(splatter_sim))

  de_fac <- dplyr::select(rd, tidyselect::starts_with("DEFacGroup"))
  colnames(de_fac) <- gsub("DEFacGroup", "Group", colnames(de_fac))

  de_fac <- as.matrix(de_fac)

  if (any(de_fac < 1)) {
    stop("Only simulated datesets with no downregulated genes allowed.")
  }
  
  # All genes with a pos. factor are DE
  de_genes <- de_fac > factor_cutoff

  if (isTRUE(no_overlap)) {
    de_bool <- matrix(FALSE,
      nrow = nrow(de_fac),
      ncol = ncol(de_fac),
      dimnames = list(
        rownames(de_fac),
        colnames(de_fac)
      )
    )

    for (x in seq_len(nrow(de_fac))) {
      if (any(de_genes[x, ])) {
        vals <- de_fac[x, ][de_genes[x, ]]
        max_val <- which(abs(vals) == max(abs(vals)))

        de_bool[x, which(de_fac[x, ] == vals[max_val])] <- TRUE
      } else {
        next
      }
    }

    de_genes <- de_bool
  }

  cell_clusts <- model.matrix(~ Group - 1, data = cd) == 1
  colnames(cell_clusts) <- gsub("GroupGroup", "Group", colnames(cell_clusts))

  row_x_number <- de_genes
  number_x_col <- t(cell_clusts)

  if (isTRUE(no_overlap)) {
    number <- length(intersect(rownames(number_x_col), colnames(row_x_number)))
  } else {
    number <- length(union(rownames(number_x_col), colnames(row_x_number)))
  }


  bic <- new("Biclust",
    "Parameters" = list("Splatter_Params" = splatter_sim@metadata$Params),
    "RowxNumber" = row_x_number,
    "NumberxCol" = number_x_col,
    "Number" = number,
    "info" = list("splatter simulated data")
  )

  return(bic)
}


evaluate_sim <- function(sce,
                         biclust,
                         truth_col = NULL,
                         no_overlap = TRUE) {

  true_biclust <- sim_truth(
    splatter_sim = sce,
    factor_cutoff = 1,
    no_overlap = no_overlap
  )

  if (biclust@Number > 0) {
    nomono_biclust <- rm_monoclusters(biclust)
    nomono_truth <- rm_monoclusters(true_biclust)

    ac <- ari_cells(
      reference = sce,
      biclust_obj = biclust,
      reference_col = "Group"
    )

    ag <- ari_genes(
      splatter_sim = sce,
      biclust_obj = biclust
    )

    relevance <- relevance_biclust(nomono_biclust, nomono_truth)
    recovery <- recovery_biclust(nomono_biclust, nomono_truth)

    fARI <- fclust::ARI.F(VC = sce$Group, U = t(biclust@NumberxCol))

    genes_kept <- rownames(nomono_biclust@RowxNumber)
    nomono_truth@RowxNumber <- nomono_truth@RowxNumber[rownames(nomono_truth@RowxNumber) %in% genes_kept, ]

    clustering_error <- biclustlib_CE(nomono_biclust, nomono_truth)

  } else {
    ac <- NA
    ag <- NA
    relevance <- NA
    recovery <- NA
    clustering_error <- NA
    RNIA <- NA
    fARI <- NA
  }

  evldf <- c(
    "ARI_cells" = ac,
    "ARI_genes" = ag,
    "relevance" = relevance,
    "recovery" = recovery,
    "clustering_error" = clustering_error,
    "fuzzyARI_cells" = fARI,
  )

  return(evldf)
}

evaluate_real <- function(sce, biclust, truth_col = NULL) {

  if (biclust@Number > 0) {
    nomono_biclust <- rm_monoclusters(biclust)

    ac <- ari_cells(
      reference = sce,
      biclust_obj = biclust,
      reference_col = truth_col
    )

    ag <- NA
    relevance <- NA
    recovery <- NA
    clustering_error <- NA

  } else {
    ac <- NA
    ag <- NA
    relevance <- NA
    recovery <- NA
    clustering_error <- NA
  }

  evldf <- c(
    "ARI_cells" = ac,
    "ARI_genes" = ag,
    "relevance" = relevance,
    "recovery" = recovery,
    "clustering_error" = clustering_error,
  )

  return(evldf)
}

