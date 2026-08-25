#!/usr/bin/env Rscript
# physio-emg-features — orchestrator-agnostic CLI for EMG spectral fatigue.
#   Rscript physio-emg-features.R --in emg.edf --out fatigue.parquet
#   Rscript physio-emg-features.R --demo --out fatigue.parquet
suppressWarnings(suppressMessages({ library(PhysioPipe); library(PhysioEMG) }))

parse_args <- function(args) {
  out <- list(out = "fatigue.parquet")
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
  pp_simulate("emg")
} else if (!is.null(a$`in`)) {
  PhysioIO::readEDF(a$`in`)
} else {
  stop("give --in <edf> or --demo", call. = FALSE)
}

fatigue <- emgFatigue(pe)
pp_write_parquet(fatigue, a$out)
cat(sprintf("wrote %s (%d windows)\n", a$out, nrow(fatigue)))
