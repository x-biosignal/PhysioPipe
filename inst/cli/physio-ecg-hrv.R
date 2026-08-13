#!/usr/bin/env Rscript
# physio-ecg-hrv — orchestrator-agnostic CLI for the ECG/HRV pipeline.
#
# Reads a WFDB record, computes heart-rate variability (time + frequency), and
# writes a language-neutral Parquet table. The SAME domain functions back the
# PhysioPipe targets factory, so targets and Nextflow (and anything else) share
# one implementation.
#
#   Rscript physio-ecg-hrv.R --record data/100 --channel 1 \
#       --detector pan_tompkins --out results/100_hrv.parquet
#
suppressWarnings(suppressMessages({
  library(PhysioPipe)
  library(PhysioECG)
}))

# --- tiny --key value argument parser (no extra deps) -------------------------
parse_args <- function(args) {
  out <- list(channel = "1", detector = "pan_tompkins", out = "hrv.parquet")
  i <- 1L
  while (i <= length(args)) {
    key <- sub("^--", "", args[[i]])
    out[[key]] <- args[[i + 1L]]
    i <- i + 2L
  }
  out
}
a <- parse_args(commandArgs(trailingOnly = TRUE))
if (is.null(a$record)) stop("--record <WFDB base path> is required", call. = FALSE)

# --- pipeline (identical to the targets factory) ------------------------------
pe   <- pp_ecg_read(pp_wfdb_files(a$record))
lead <- pe[, as.integer(a$channel)]
peaks <- ecgDetectRpeaks(lead, method = a$detector)
rr    <- ecgRRintervals(lead, peaks)
hrv   <- pp_hrv_combine(ecgHRVtime(rr), ecgHRVfreq(rr))
hrv$record <- basename(a$record)

pp_write_parquet(hrv, a$out)
cat(sprintf("wrote %s (mean_hr=%.1f, sdnn=%.2f)\n", a$out, hrv$mean_hr[1], hrv$sdnn[1]))
