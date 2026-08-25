# Pure pipeline-step helpers referenced by the target factories -----------------

#' Read a WFDB record (by companion files or base) into a PhysioExperiment
#'
#' @param record Either the companion files (\code{c(".dat", ".hea")}) or a
#'   single record base path (no extension).
#' @return A \code{PhysioExperiment}.
#' @export
pp_ecg_read <- function(record) {
  .pp_require("PhysioIO")
  base <- unique(sub("\\.(dat|hea|atr)$", "", record))
  if (length(base) != 1L) {
    stop("Expected a single record base, got: ",
         paste(base, collapse = ", "), call. = FALSE)
  }
  PhysioIO::readWFDB(base)
}

#' Join time- and frequency-domain HRV into one row per channel
#'
#' @param hrv_time Output of \code{PhysioECG::ecgHRVtime()}.
#' @param hrv_freq Output of \code{PhysioECG::ecgHRVfreq()}.
#' @return A data frame merged on \code{channel}.
#' @export
pp_hrv_combine <- function(hrv_time, hrv_freq) {
  merge(hrv_time, hrv_freq, by = "channel", suffixes = c("_time", "_freq"))
}

#' Stack per-branch data frames from a cohort run into one table
#'
#' @param branches A list of per-record data frames (dynamic-branch output).
#' @param id Optional vector of record ids, added as a \code{record} column.
#' @return A single row-bound data frame.
#' @export
pp_bind_cohort <- function(branches, id = NULL) {
  if (!is.null(id) && length(id) == length(branches)) {
    branches <- Map(function(df, i) { df$record <- i; df }, branches, id)
  }
  do.call(rbind, branches)
}

#' Write a data frame to Parquet (language-neutral interchange)
#'
#' Intermediate/terminal tables written as Parquet can be read by Python
#' (pandas/pyarrow), DuckDB, and Nextflow processes — unlike the default `.rds`
#' target store. This is the seam that keeps pipelines orchestrator-agnostic.
#'
#' @param df A data frame.
#' @param path Output `.parquet` path.
#' @return `path` (so the target can be `format = "file"`).
#' @export
pp_write_parquet <- function(df, path) {
  .pp_require("arrow")
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  arrow::write_parquet(df, path)
  path
}

#' Write a simple RR tachogram PNG (headless) and return its path
#'
#' @param rr Output of \code{PhysioECG::ecgRRintervals()}.
#' @param path Output PNG path.
#' @return \code{path} (so the target can be \code{format = "file"}).
#' @export
pp_plot_tachogram <- function(rr, path = "figures/tachogram.png") {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  # Headless PNG that works on Linux/macOS/Windows: prefer ragg (no system
  # display needed), then a cairo device, then the platform default.
  opened <- FALSE
  if (requireNamespace("ragg", quietly = TRUE)) {
    opened <- tryCatch({ ragg::agg_png(path, width = 900, height = 400, res = 110); TRUE },
                       error = function(e) FALSE)
  }
  if (!opened && isTRUE(capabilities("cairo"))) {
    opened <- tryCatch({
      grDevices::png(path, width = 900, height = 400, res = 110, type = "cairo"); TRUE
    }, error = function(e) FALSE)
  }
  if (!opened) grDevices::png(path, width = 900, height = 400, res = 110)
  on.exit(grDevices::dev.off())
  graphics::plot(rr$time_sec, rr$rr_ms, type = "b", pch = 19, col = "#2b6cb0",
                 xlab = "Time (s)", ylab = "RR interval (ms)",
                 main = "RR tachogram")
  path
}
