
name_biclust <- function(biclust, input) {

  if (biclust@Number > 0) {
    if (is.null(dimnames(biclust@RowxNumber))) {
      dimnames(biclust@RowxNumber) <- list(
        rownames(input),
        paste0("BC", seq_len(ncol(biclust@RowxNumber)))
      )
    }

    if (is.null(dimnames(biclust@NumberxCol))) {
      if (biclust@Number == 1 &&
        nrow(biclust@NumberxCol) != 1 &&
        ncol(biclust@NumberxCol) == 1) {
        biclust@NumberxCol <- t(biclust@NumberxCol)
      }

      dimnames(biclust@NumberxCol) <- list(
        paste0("BC", seq_len(nrow(biclust@NumberxCol))),
        colnames(input)
      )
    }
  }

  return(biclust)
}

#' Converts two vectors of gene and cell clusters to biclustlib results.
#'
#' @param cell_clusters Named vector of cell clusters. 
#' @param gene_clusters Named vector of gene clusters.
#'
#' @return
#' An object of type "Biclust".
#'
#' @export
bic_to_biclust <- function(cell_clusters, gene_clusters, params = NULL) {

    require("biclust")

    ctypes <- sort(unique(cell_clusters))
    gtypes <- sort(unique(gene_clusters))
    bitypes <- union(ctypes, gtypes)

    Number <- length(bitypes)

    if (Number == 0) {
        NumberxCol <- matrix(0)
        RowxNumber <- matrix(0)
    } else {
        NumberxCol <- do.call(rbind, lapply(bitypes, function(x) {
            cell_clusters == x
        }))
        RowxNumber <- do.call(cbind, lapply(bitypes, function(x) {
            gene_clusters == x
        }))
    }

    rownames(RowxNumber) <- names(gene_clusters)
    colnames(RowxNumber) <- paste0("BC", bitypes)

    rownames(NumberxCol) <- paste0("BC", bitypes)
    colnames(NumberxCol) <- names(cell_clusters)

    bic <- new("Biclust",
        "Parameters" = params,
        "RowxNumber" = RowxNumber,
        "NumberxCol" = NumberxCol,
        "Number" = Number,
        "info" = list("Generated from cell and gene clusters.")
    )

    return(bic)
}

dist_to_line <- function(X, lines, Xnorm) {

    if (is.matrix(lines)) {
        lines <- t(lines)
    }
    proj = (X %*% lines)
    dist = Xnorm^2 - proj^2
    dist[dist<0] = 0
    dist = sqrt(dist)

    return(dist)
}



#' Calculate the norm of a row-vector.
row_norm <- function(x) {
    if (is.matrix(x)) {
        norm <- sqrt(rowSums(x^2))
    } else if (is.null(dim(x))) {
        norm <- sqrt(sum(x^2))
    } else {
        stop("Uknown object.")
    }

    return(norm)
}

