#!/usr/bin/env Rscript
# physio-eda-scr — orchestrator-agnostic CLI for EDA skin-conductance features.
#   Rscript physio-eda-scr.R --in eda.edf --out scr.parquet
#   Rscript physio-eda-scr.R --demo --out scr.parquet
suppressWarnings(suppressMessages({ library(PhysioPipe); library(PhysioEDA) }))

parse_args <- function(args) {
  out <- list(out = "scr.parquet")
  i <- 1L
  while (i <= length(args)) {
    key <- sub("^--", "", args[[i]])
    if (key %in% c("demo")) { out[[key]] <- TRUE; i <- i + 1L }
    else { out[[key]] <- args[[i + 1L]]; i <- i + 2L }
  }
  out
}
a <- parse_args(commandArgs(trailingOnly = TRUE))

pe <- if (isTRUE(a$demo)) {
  pp_simulate("eda")
} else if (!is.null(a$`in`)) {
  PhysioIO::readEDF(a$`in`)
} else {
  stop("give --in <edf> or --demo", call. = FALSE)
}

features <- edaFeatures(edaDecompose(pe))
pp_write_parquet(features, a$out)
cat(sprintf("wrote %s (scr_count=%s)\n", a$out, features$scr_count[1]))
