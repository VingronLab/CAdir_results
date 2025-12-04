algorithm <- "nmf"
source("./benchmarking/setup_split.R")

# sv4d
cat("\nStarting NMF\n")

t <- Sys.time()

model <- RcppML::nmf(
  data = cnts,
  seed = seq_len(nseeds),
  k = k_nmf,
  L1 = l1
)
# mse_nmf <- evaluate(model, cnts) # calculate mean squared error
w <- model@w
h <- model@h

cell_cls <- apply(h, 2, function(x) which(x == max(x))[1])
genes_cls <- apply(w, 1, function(x) which(x == max(x))[1])

ccs <- sort(unique(cell_cls))
nclusts <- length(ccs)

gcs <- sort(unique(genes_cls))

allcls <- sort(unique(c(ccs, gcs)))

nmf_cells <- matrix(FALSE, nrow = length(allcls), ncol = length(cell_cls))
rownames(nmf_cells) <- paste0("Bic_", allcls)
colnames(nmf_cells) <- colnames(h)

for (i in seq_along(allcls)) {
  if (!allcls[i] %in% ccs) {
    next
  }
  clust_cells <- names(cell_cls)[which(cell_cls == allcls[i])]
  idx <- which(colnames(nmf_cells) %in% clust_cells)
  nmf_cells[i, idx] <- TRUE
}

nmf_genes <- matrix(
  FALSE,
  nrow = length(genes_cls),
  ncol = length(allcls)
)

rownames(nmf_genes) <- names(genes_cls)
colnames(nmf_genes) <- paste0("Bic_", allcls)

for (i in seq_along(allcls)) {
  if (!allcls[i] %in% gcs) {
    next
  }

  clust_genes <- names(genes_cls)[which(genes_cls == allcls[i])]
  idx <- which(rownames(nmf_genes) %in% clust_genes)
  nmf_genes[idx, i] <- TRUE
}

res <- new(
  "Biclust",
  "Parameters" = opt,
  "RowxNumber" = nmf_genes,
  "NumberxCol" = nmf_cells,
  "Number" = nclusts,
  "info" = list("NMF biclustering")
)

t.run <- difftime(Sys.time(), t, units = "secs")
res <- name_biclust(biclust = res, input = cnts)

#########

if (isTRUE(is_cell_clustering)) {
  stop("Not a cell clutering algorithm.")
}

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
      "runtime_dimreduc" = NA
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
      "runtime_dimreduc" = NA
    )
  )

  eval_res <- bind_cols(eval_res, as_tibble(opt))
}


write_csv(
  eval_res,
  file.path(outdir, paste0(algorithm, "_", name, "_EVALUATION.csv"))
)

print("All done!")
cat("\nFinished benchmarking!\n")
