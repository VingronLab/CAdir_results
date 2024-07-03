---
jupyter:
  jupytext:
    formats: ipynb,md
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

```r
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

## Load data

```r
sce <- sce_pbmc3k()
```

# CAdir

```r
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

```r
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

```r


```
