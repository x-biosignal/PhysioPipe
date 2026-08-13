#!/usr/bin/env Rscript
# physio-eeg-bandpower — orchestrator-agnostic CLI for EEG band power.
#   Rscript physio-eeg-bandpower.R --in sub01.edf --out power.parquet
#   Rscript physio-eeg-bandpower.R --demo --out power.parquet
suppressWarnings(suppressMessages({ library(PhysioPipe); library(PhysioAnalysis) }))

parse_args <- function(args) {
  out <- list(out = "power.parquet")
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
  pp_simulate("eeg")
} else if (!is.null(a$`in`)) {
  PhysioIO::readEDF(a$`in`)
} else {
  stop("give --in <edf> or --demo", call. = FALSE)
}

power <- bandPower(pe, bands = list(alpha = c(8, 13), beta = c(13, 30)), method = "welch")
pp_write_parquet(power, a$out)
cat(sprintf("wrote %s (%d channels)\n", a$out, nrow(power)))
