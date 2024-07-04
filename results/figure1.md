---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.16.1
  kernelspec:
    display_name: R 4.4
    language: R
    name: ir44
---

# Setup

```R
source("./utils.R")
renv::load("/project/kohl_analysis/analysis/CAdir")
devtools::load_all("/home/kohl/PhD/gits/ClemensKohl/CAdir")

suppressPackageStartupMessages({
  library(APL)
  library(SingleCellExperiment)
  library(dplyr)

  # To load the data set
  library(TENxPBMCData)
  library(Seurat)
  library(SeuratObject)
  library(scater)
  library(scuttle)
  library(scran)
})

options(repr.plot.width = 20, repr.plot.height = 15)
getwd()
```

# Pre-process and annotate data

Loading data set and annotate it according to Seurat vignette.

```R
sce <- sce_pbmc3k()
```

# CAdir on pbmc3k data

After annotating the data according to the Seurat vignette, we cluster the cells and genes using the CAdir package.

```R
set.seed(1234)

sce_bu <- sce
sce.dec <- scran::modelGeneVar(sce)
sce.top <- scran::getTopHVGs(sce.dec, prop = 0.2, var.threshold = NULL)
sce <- sce[sce.top, ]
sce <- runUMAP(sce, ntop = 2000)

ca <- cacomp(
    obj = as.matrix(logcounts(sce)),
    princ_coords = 3,
    dims = 30,
    top = nrow(sce),
    residuals = "pearson",
    python = TRUE,
    clip = TRUE
)
```

With `cutoff = NULL` CAdir tries to estimate the angle cutoff directly from the data.

```R
set.seed(2358)
cak <- dirclust_splitmerge(
    caobj = ca,
    k = 9,
    cutoff = NULL,
    method = "random",
    apl_quant = 0.9999,
    counts = NULL,
    min_cells = 30,
    reps = 5,
    make_plots = TRUE,
    apl_cutoff_reps = 100,
    qcutoff = 0.1
)

cadir <- rank_genes(cadir = cak, caobj = ca)
top <- top_genes(cadir)
```

```R
###########
## CAdir ##
###########

anncak <- annotate_biclustering(
    obj = cak,
    universe = rownames(sce),
    org = "hs"
)

anncak <- rank_genes(cadir = anncak, caobj = ca)
anncak

sce$cadir <- anncak@cell_clusters

um1 <- plotUMAP(sce, colour = "cadir")
um2 <- plotUMAP(sce, colour = "cell_type")

ari <- aricode::clustComp(sce$cadir, sce$cell_type)
p <- um1 + ggtitle(paste0("ARI: ", round(ari$ARI, 2))) + um2
p

ggsave(plot = p, file = "./img/figure1/umap.png")
```

```R
sm <- sm_plot(
  cadir = cak,
  caobj = ca,
  rm_redund = TRUE,
  keep_end = TRUE,
  highlight_cluster = TRUE,
  show_genes = F,
  annotate_clusters = TRUE,
  org = "hs"
)
sm
ggsave(plot = sm, file = "./img/figure1/split_merge_plot.pdf")
```

```R
pc <- plot_clusters(anncak, ca, show_genes=T, label_genes = T, ntop = 5)

ggsave(plot = pc, file = "./img/figure1/plot_clusters.pdf"  )
```

```R
line_plot <- plot_results(anncak, ca)
line_plot
```

```R
sessionInfo()
```
