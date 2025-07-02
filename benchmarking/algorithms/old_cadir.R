source("./setup.R")
source("/project/kohl_analysis/analysis/CA_means/CAmeans/CA_kmeans.r")
source("./helpers/assign_genes_by_coords.R")

algorithm <- "old_CAdir"


if (is.na(dims)) {
    stop("Need to specify dimensionality.")
}

cat("\nStarting CA.\n")
t <- Sys.time()
caobj <- cacomp(cnts,
    dims = dims,
    top = nrow(cnts),
    python = TRUE
)

t.CA <- difftime(Sys.time(), t, units = "secs")


# Leiden clustering
cat("\nStarting CAdir\n")

t <- Sys.time()

cac <- cameans_splitmerge(
    caobj = caobj,
    k = kdir,
    cutoff = angle,
    min_cells = 20,
    reps = 5,
    make_plots = FALSE
)

genes <- assign_genes_coords(
  caobj = caobj,
  directions = cac$direction,
  qcutoff = qcut_param,
  coords = "prin"
)

cells <- cac$clusters


t.run <- difftime(Sys.time(), t, units = "secs")

cat("\nFinished CAdir\n")

res <- bic_to_biclust(
    cell_clusters = cells,
    gene_clusters = genes,
    params = list(
        "algorithm" = "cadir",
        "dims" = dims,
        "nclust" = kdir,
        "angle" = angle,
        "qcutoff" = qcut_param
    )
)

###########

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
            "runtime" = t.run,
            "runtime_dimreduc" = t.CA
        )
    )

    eval_res <- bind_cols(eval_res, as_tibble(opt))
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
            "runtime" = t.run,
            "runtime_dimreduc" = t.CA
        )
    )

    eval_res <- bind_cols(eval_res, as_tibble(opt))
}

write_csv(eval_res, file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv")))
cat("\nFinished benchmarking!\n")
