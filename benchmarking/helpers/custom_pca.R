
#' Helper function to check if object is empty.
#' @param x object
#' @return TRUE if x has length 0 and is not NULL. FALSE otherwise
is.empty <- function(x) return(isTRUE(length(x) == 0 & !is.null(x)))


#' Check if pcacomp object was correctly created.
#'
#' @description Checks if the slots in a pcacomp object are of the correct size
#' and whether they are coherent.
#' @param object A pcacomp object.
#' @return TRUE if it is a valid pcacomp object. FALSE otherwise.
#' @export
#' @examples
#' # Simulate scRNAseq data.
#' cnts <- data.frame(cell_1 = rpois(10, 5),
#'                    cell_2 = rpois(10, 10),
#'                    cell_3 = rpois(10, 20))
#' rownames(cnts) <- paste0("gene_", 1:10)
#' cnts <- as.matrix(cnts)
#'
#' # Run correspondence analysis.
#' ca <- pcacomp(obj = cnts, princ_coords = 3, top = 5)
#'
#' check_pcacomp(ca)
check_pcacomp <- function(object) {
  errors <- character()

  dim_rows <- object@top_rows
  dims <- object@dims

  # SVD results
  if (isTRUE(!is.empty(object@U) & 
             nrow(object@U) != dim_rows)) {
    msg <- paste0("Nr. of rows in U is ",
                  nrow(object@U),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@U) & 
             ncol(object@U) != dims)) {
    msg <- paste0("Nr. of columns in U is ",
                  ncol(object@U),
                  ".  Should be ",
                  dims,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@V) & 
             ncol(object@V) != dims)) {
    msg <- paste0("Nr. of columns in V is ",
                  ncol(object@V),
                  ".  Should be ",
                  dims,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@D) & 
             length(object@D) != dims)) {
    msg <- paste0("Length of D is ", ncol(object@D), ".  Should be ", dims, ".")
    errors <- c(errors, msg)
  }

  # CA results

  if (isTRUE(!is.empty(object@row_masses) & 
             length(object@row_masses) != dim_rows)) {
    
    msg <- paste0("Length of row_masses is ",
                  length(object@row_masses),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@col_masses) & 
             length(object@col_masses) != nrow(object@V))) {
    
    msg <- paste0("Length of col_masses is ",
                  length(object@col_masses),
                  ".  Should be ",
                  nrow(object@V),
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@row_inertia) & 
             length(object@row_inertia) != dim_rows)){
    
    msg <- paste0("Length of row_inertia is ",
                  length(object@row_inertia),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@col_inertia) & 
             length(object@col_inertia) != nrow(object@V))) {
    
    msg <- paste0("Length of col_inertia is ",
                  length(object@col_inertia),
                  ".  Should be ",
                  nrow(object@V),
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@tot_inertia) & 
             length(object@tot_inertia) != 1)) {
    
    msg <- paste0("Length of tot_inertia is ",
                  length(object@tot_inertia),
                  ".  Should be 1.")
    errors <- c(errors, msg)
  }

  # standardized coordinates

  if (isTRUE(!is.empty(object@std_coords_rows) & 
             nrow(object@std_coords_rows) != dim_rows)) {
    
    msg <- paste0("Nr. of rows in std_coords_rows is ",
                  nrow(object@std_coords_rows),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@std_coords_rows) & 
             ncol(object@std_coords_rows) != dims)) {
    
    msg <- paste0("Nr. of columns in std_coords_rows is ",
                  ncol(object@std_coords_rows),
                  ".  Should be ",
                  dims,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@std_coords_cols) & 
             nrow(object@std_coords_cols) != nrow(object@V))) {
    
    msg <- paste0("Nr. of rows in std_coords_cols is ",
                  nrow(object@std_coords_cols),
                  ".  Should be ",
                  nrow(object@V),
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@std_coords_cols) & 
             ncol(object@std_coords_cols) != dims)) {
    
    msg <- paste0("Nr. of columns in std_coords_cols is ",
                  ncol(object@std_coords_cols),
                  ".  Should be ",
                  dims,
                  ".")
    errors <- c(errors, msg)
  }


  # principal coordinates

  if (isTRUE(!is.empty(object@prin_coords_rows) & 
             nrow(object@prin_coords_rows) != dim_rows)) {
    
    msg <- paste0("Nr. of rows in prin_coords_rows is ",
                  nrow(object@prin_coords_rows),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@prin_coords_rows) & 
             ncol(object@prin_coords_rows) != dims)) {
    
    msg <- paste0("Nr. of columns in prin_coords_rows is ",
                  ncol(object@prin_coords_rows),
                  ".  Should be ",
                  dims,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@prin_coords_cols) & 
             nrow(object@prin_coords_cols) != nrow(object@V))) {
    
    msg <- paste0("Nr. of rows in prin_coords_cols is ",
                  nrow(object@prin_coords_cols),
                  ".  Should be ",
                  nrow(object@V),
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@prin_coords_cols) & 
             ncol(object@prin_coords_cols) != dims)) {
    
    msg <- paste0("Nr. of columns in prin_coords_cols is ",
                  ncol(object@prin_coords_cols),
                  ".  Should be ",
                  dims,
                  ".")
    errors <- c(errors, msg)
  }

  # AP coordinates

  if (isTRUE(!is.empty(object@apl_rows) & 
             nrow(object@apl_rows) != dim_rows)) {
    
    msg <- paste0("Nr. of rows in apl_rows is ",
                  ncol(object@apl_rows),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@apl_rows) & 
             ncol(object@apl_rows) != 2)) {
    
    msg <- paste0("Nr. of columns in apl_rows is ",
                  ncol(object@apl_rows),
                  ".  Should be 2.")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@apl_cols) & 
             nrow(object@apl_cols) != nrow(object@V))) {
    
    msg <- paste0("Nr. of rows in apl_cols is ",
                  ncol(object@apl_cols),
                  ".  Should be ",
                  nrow(object@V),
                  ".")
    errors <- c(errors, msg)
  }

  if (isTRUE(!is.empty(object@apl_cols) & 
             ncol(object@apl_cols) != 2)) {
    
    msg <- paste0("Nr. of columns in apl_cols is ",
                  ncol(object@apl_cols),
                  ".  Should be 2.")
    errors <- c(errors, msg)
  }

  # Salpha score
  if (isTRUE(!is.empty(object@APL_score) & 
             ncol(object@APL_score) != 4)) {
    
    msg <- paste0("Nr. of columns in APL_score is ",
                  ncol(object@APL_score),
                  ".  Should be 4.")
    errors <- c(errors, msg)
  }
  if (isTRUE(!is.empty(object@APL_score) & 
             nrow(object@APL_score) != dim_rows)) {
    
    msg <- paste0("Nr. of rows in APL_score is ",
                  nrow(object@APL_score),
                  ".  Should be ",
                  dim_rows,
                  ".")
    errors <- c(errors, msg)
  }

  if (length(errors) == 0) TRUE else errors
}

#' An S4 class that contains all elements needed for CA.
#' @name pcacomp-class
#' @rdname pcacomp-class
#' @description
#' This class contains elements necessary to computer CA coordinates or 
#' Association Plot coordinates,
#' as well as other informative data such as row/column inertia, 
#' gene-wise APL-scores, etc. ...
#'
#' @slot U class "matrix". Left singular vectors of the original input matrix.
#' @slot V class "matrix". Right singular vectors of the original input matrix.
#' @slot D class "numeric". Singular values of the original inpt matrix.
#' @slot std_coords_rows class "matrix". Standardized CA coordinates of the 
#' rows.
#' @slot std_coords_cols class "matrix". Standardized CA coordinates of the 
#' columns.
#' @slot prin_coords_rows class "matrix". Principal CA coordinates of the rows.
#' @slot prin_coords_cols class "matrix". Principal CA coordinates of the 
#' columns.
#' @slot apl_rows class "matrix". Association Plot coordinates of the rows 
#' for the direction defined in slot "group"
#' @slot apl_cols class "matrix". Association Plot coordinates of the columns 
#' for the direction defined in slot "group"
#' @slot APL_score class "data.frame". Contains rows sorted by the APL score.
#' Columns: Rowname (gene name in the case of gene expression data),
#' APL score calculated for the direction defined in slot "group",
#' the original row number and the rank of the row as determined by the score.
#' @slot dims class "numeric". Number of dimensions in CA space.
#' @slot group class "numeric". Indices of the chosen columns for APL 
#' calculations.
#' @slot row_masses class "numeric". Row masses of the frequency table.
#' @slot col_masses class "numeric". Column masses of the frequency table.
#' @slot top_rows class "numeric". Number of most variable rows chosen.
#' @slot tot_inertia class "numeric". Total inertia in CA space.
#' @slot row_inertia class "numeric". Row-wise inertia in CA space.
#' @slot col_inertia class "numeric". Column-wise inertia in CA space.
#' @slot permuted_data class "list". Storage slot for permuted data.
#' @slot params class "list". List of parameters.
#' @export
setClass("pcacomp",
         representation(
           U = "matrix",
           V = "matrix",
           D = "numeric",
           std_coords_rows = "matrix",
           std_coords_cols = "matrix",
           prin_coords_rows = "matrix",
           prin_coords_cols = "matrix",
           apl_rows = "matrix",
           apl_cols = "matrix",
           APL_score = "data.frame",
           params = "list",
           dims = "numeric",
           group = "numeric",
           row_masses = "numeric",
           col_masses = "numeric",
           top_rows = "numeric",
           tot_inertia = "numeric",
           row_inertia = "numeric",
           col_inertia = "numeric",
           permuted_data = "list"
         ),
         prototype(
           U = matrix(0, 0, 0),
           V = matrix(0, 0, 0),
           D = numeric(),
           std_coords_rows = matrix(0, 0, 0),
           std_coords_cols = matrix(0, 0, 0),
           prin_coords_rows = matrix(0, 0, 0),
           prin_coords_cols = matrix(0, 0, 0),
           apl_rows = matrix(0, 0, 0),
           apl_cols = matrix(0, 0, 0),
           APL_score = data.frame(),
           params = list(),
           dims = numeric(),
           group = numeric(),
           row_masses = numeric(),
           col_masses = numeric(),
           top_rows = numeric(),
           tot_inertia = numeric(),
           row_inertia = numeric(),
           col_inertia = numeric(),
           permuted_data = list()),
         validity = check_pcacomp
)

#' Create new "pcacomp" object.
#' @description Creates new pcacomp object.
#'
#' @param ... slot names and objects for new pcacomp object.
#' @return pcacomp object
#' @rdname pcacomp-class
#' @export
#' @examples
#' set.seed(1234)
#'
#' # Simulate counts
#' cnts <- mapply(function(x){rpois(n = 500, lambda = x)}, 
#'                x = sample(1:20, 50, replace = TRUE))
#' rownames(cnts) <- paste0("gene_", 1:nrow(cnts))
#' colnames(cnts) <- paste0("cell_", 1:ncol(cnts))
#'
#' res <-  APL:::comp_std_residuals(mat=cnts)
#' SVD <- svd(res$S)
#' names(SVD) <- c("D", "U", "V")
#' SVD <- SVD[c(2, 1, 3)]
#'
#' ca <- new_pcacomp(U = SVD$U,
#'                  V = SVD$V,
#'                  D = SVD$D,
#'                  row_masses = res$rowm,
#'                  col_masses = res$colm)
new_pcacomp <- function(...) new("pcacomp",...)


#' Access slots in a pcacomp object
#' 
#' @param caobj a pcacomp object
#' @param slot slot to return
#' @returns Chosen slot of the pcacomp object
#' @examples 
#' # Simulate scRNAseq data.
#' cnts <- data.frame(cell_1 = rpois(10, 5),
#'                    cell_2 = rpois(10, 10),
#'                    cell_3 = rpois(10, 20))
#' rownames(cnts) <- paste0("gene_", 1:10)
#' cnts <- as.matrix(cnts)
#'
#' # Run correspondence analysis.
#' ca <- pcacomp(obj = cnts, princ_coords = 3, top = 5)
#' 
#' # access left singular vectors
#' pcacomp_slot(ca, "U")
#' 
#' @export
pcacomp_slot <- function(pcaobj, slot){
  stopifnot(slot %in% slotNames(pcaobj))
  
  return(slot(pcaobj, slot))
}

#' Prints slot names of pcacomp object
#' 
#' @param caobj a pcacomp object
#' @returns Prints slot names of pcacomp object
#' @examples 
#' # Simulate scRNAseq data.
#' cnts <- data.frame(cell_1 = rpois(10, 5),
#'                    cell_2 = rpois(10, 10),
#'                    cell_3 = rpois(10, 20))
#' rownames(cnts) <- paste0("gene_", 1:10)
#' cnts <- as.matrix(cnts)
#'
#' # Run correspondence analysis.
#' ca <- pcacomp(obj = cnts, princ_coords = 3, top = 5)
#' 
#' # show slot names:
#' pcacomp_names(ca)
#' 
#' @export
pcacomp_names <- function(pcaobj){
  slotNames(pcaobj)
}


run_pca <- function(mat,
                    dims,
                    rm_zeros = TRUE,
                    python = TRUE) {
    parameters <- list()

    if (rm_zeros == TRUE) {

        mat <- APL:::rm_zeros(mat)
    }

    mat <- Matrix::t(mat)
    mat <- scale(mat)

    k <- min(dim(mat)) - 1
    if (is.null(dims)) dims <- k
    if (dims > k) dims <- k

    if (python == TRUE) {

        svd_torch <- NULL
        reticulate::source_python(
            system.file("python/python_svd.py", package = "APL")
        )
        SVD <- svd_torch(mat)

        names(SVD) <- c("U", "D", "V")
        SVD$D <- as.vector(SVD$D)

    } else if (dims < k) {

        SVD <- irlba::irlba(
            mat,
            nv = dims,
            smallest = FALSE
        ) # eigenvalues in a decreasing order

        SVD <- SVD[1:3]
        names(SVD)[1:3] <- c("D", "U", "V")
        SVD$D <- as.vector(SVD$D)

    } else {

        SVD <- svd(mat, nu = dims, nv = dims)
        names(SVD) <- c("D", "U", "V")
        SVD <- SVD[c(2, 1, 3)]
        if (length(SVD$D) > dims) SVD$D <- SVD$D[seq_len(dims)]
    }

    # Make sure that the singular values/vectors
    # are in a decreasing order.
    ord <- order(SVD$D, decreasing = TRUE)
    SVD$D <- SVD$D[ord]
    SVD$V <- SVD$V[,ord]
    SVD$U <- SVD$U[,ord]

    # Rename the singular values/vectors
    ndim <- length(SVD$D)
    pcs <- paste0("PC", seq_len(ndim))

    names(SVD$D) <- pcs

    dimnames(SVD$V) <- list(
        colnames(mat),
        pcs
    )

    dimnames(SVD$U) <- list(
        rownames(mat),
        pcs
    )

    SVD$D <- as.vector(SVD$D)
    if (ndim > dims) SVD$D <- SVD$D[seq_len(dims)]


    parameters$rm_zeros <- rm_zeros
    parameters$python <- python
    SVD$params <- parameters

    SVD <- do.call(new_pcacomp, SVD)

    if (!is.null(dims)) {
        if (dims > length(SVD@D)) {
            warning(
                "Chosen number of dimensions is larger than the ",
                "number of dimensions obtained from the singular ",
                "value decomposition. Argument ignored."
            )

            SVD@dims <- length(SVD@D)

        } else if (dims == length(SVD@D)) {

            SVD@dims <- dims
 
        } else {
            dims <- min(dims, length(SVD@D))
            SVD@dims <- dims

            dims <- seq(dims)

            # subset to number of dimensions
            SVD@U <- SVD@U[, dims]
            SVD@V <- SVD@V[, dims]
            SVD@D <- SVD@D[dims]
        }

        SVD <- subset_pca_dims(SVD, SVD@dims)

    } else {

        SVD@dims <- length(SVD@D)

    }

    return(SVD)
}



pca_coords <- function(pcaobj) {
    pcaobj@std_coords_rows <- pcaobj@V
    pcaobj@std_coords_cols <- pcaobj@U


    E <- pcaobj@D**2 / (nrow(pcaobj@U) - 1)

    pcaobj@prin_coords_rows <- sweep(pcaobj@V, 2, sqrt(E), FUN = "*")
    pcaobj@prin_coords_cols <- pcaobj@U %*% diag(pcaobj@D)

    return(pcaobj)
}


#' Subset dimensions of a caobj
#'
#' @description Subsets the dimensions according to user input.
#'
#' @return Returns caobj.
#'
#' @param caobj A caobj.
#' @param dims Integer. Number of dimensions.
#' @examples
#' # Simulate scRNAseq data.
#' cnts <- data.frame(
#'     cell_1 = rpois(10, 5),
#'     cell_2 = rpois(10, 10),
#'     cell_3 = rpois(10, 20)
#' )
#' rownames(cnts) <- paste0("gene_", 1:10)
#' cnts <- as.matrix(cnts)
#'
#' # Run correspondence analysis.
#' ca <- pcacomp(cnts)
#' ca <- subset_dims(ca, 2)
#' @export
subset_pca_dims <- function(pcaobj, dims) {
    if (dims == 1) {
        stop("Please choose more than 1 dimension.")
    }

    stopifnot(is(pcaobj, "pcacomp"))

    if (is.null(dims)) {
        return(pcaobj)
    }

    if (dims > length(pcaobj@D)) {
        warning(
            "dims is larger than the number of available dimensions.",
            " Argument ignored"
        )
    } else if (dims == length(pcaobj@D)) {
        pcaobj@dims <- dims
        return(pcaobj)
    }

    dims <- min(dims, length(pcaobj@D))
    pcaobj@dims <- dims
    dims <- seq(dims)
    pcaobj@U <- pcaobj@U[, dims]
    pcaobj@V <- pcaobj@V[, dims]
    pcaobj@D <- pcaobj@D[dims]

    if (!is.empty(pcaobj@std_coords_cols)) {
        pcaobj@std_coords_cols <- pcaobj@std_coords_cols[, dims]
    }
    if (!is.empty(pcaobj@prin_coords_cols)) {
        pcaobj@prin_coords_cols <- pcaobj@prin_coords_cols[, dims]
    }

    if (!is.empty(pcaobj@std_coords_rows)) {
        pcaobj@std_coords_rows <- pcaobj@std_coords_rows[, dims]
    }
    if (!is.empty(pcaobj@prin_coords_rows)) {
        pcaobj@prin_coords_rows <- pcaobj@prin_coords_rows[, dims]
    }

    stopifnot(validObject(pcaobj))
    return(pcaobj)
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

#' Removes everything within a sphere
#'  of the defined quantile of the vector norm.
#'
#' @param x matrix of row vectors
#' @param qcutoff quantile.
#'
#' @returns
#' Matrix of the vectors longer than the defined cutoff.
sphere_cutoff <- function(x, qcutoff = 0.8) {
    xn <- row_norm(x)
    q <- quantile(xn, qcutoff)
    x <- x[xn > q, ]
    return(x)
}

pca_sphere_idx <- function(x, qcutoff = 0.8) {
    xn <- row_norm(x)
    q <- quantile(xn, qcutoff)

    idx <- which(xn > q)

    return(idx)
}
