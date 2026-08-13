# Synthetic + demo data helpers ------------------------------------------------
# These give every pipeline factory a runnable example without external data.
# Real analyses point the factories at real files instead.

#' Simulate a synthetic PhysioExperiment for demos and tests
#'
#' Deterministic (seeded) synthetic signals per modality. Clearly synthetic —
#' for exercising a pipeline's mechanics, not for making claims.
#'
#' @param modality One of "eeg", "emg", "eda".
#' @param seed Integer RNG seed (fixed so pipelines stay reproducible).
#' @param n_channels,duration,sampling_rate Optional geometry overrides.
#' @return A \code{PhysioExperiment} (time x channels) with a \code{raw} assay.
#' @export
#' @examples
#' if (requireNamespace("PhysioCore", quietly = TRUE)) {
#'   pe <- pp_simulate("eeg")
#' }
pp_simulate <- function(modality = c("eeg", "emg", "eda"),
                        seed = 1L,
                        n_channels = NULL,
                        duration = NULL,
                        sampling_rate = NULL) {
  modality <- match.arg(modality)
  .pp_require(c("PhysioCore", "S4Vectors"))
  set.seed(seed)
  spec <- switch(modality,
    eeg = list(sr = 250,  dur = 8,   ch = 4L),
    emg = list(sr = 1000, dur = 6,   ch = 2L),
    eda = list(sr = 32,   dur = 120, ch = 1L)
  )
  sr  <- sampling_rate %||% spec$sr
  dur <- duration      %||% spec$dur
  ch  <- n_channels    %||% spec$ch
  tt  <- seq(0, dur, by = 1 / sr)
  n   <- length(tt)
  m <- switch(modality,
    eeg = sapply(seq_len(ch), function(i)
            sin(2 * pi * 10 * tt) + stats::rnorm(n, 0, 0.5)),
    emg = {
      burst <- as.numeric((tt %% 1) < 0.4)
      sapply(seq_len(ch), function(i)
        burst * stats::rnorm(n, 0, 1) + stats::rnorm(n, 0, 0.05))
    },
    eda = {
      scl <- 5 + 0.5 * sin(2 * pi * 0.01 * tt)
      scr <- Reduce(`+`, lapply(c(10, 25, 40, 70, 95),
                    function(o) 2 * exp(-(tt - o) / 3) * (tt > o)))
      matrix(scl + scr, ncol = ch)
    }
  )
  labels <- switch(modality,
    eeg = paste0("EEG", seq_len(ch)),
    emg = c("TA", "GAS", paste0("EMG", seq_len(ch)))[seq_len(ch)],
    eda = paste0("EDA", seq_len(ch))
  )
  PhysioCore::PhysioExperiment(
    assays       = S4Vectors::SimpleList(raw = m),
    samplingRate = sr,
    colData      = S4Vectors::DataFrame(label = labels)
  )
}

#' File paths of the bundled demo ECG record (MIT-BIH 100 excerpt)
#'
#' @return Character vector of the record's companion files (.dat, .hea).
#' @export
pp_ecg_demo_files <- function() {
  .pp_require("PhysioIO")
  hea <- system.file("extdata", "100.hea", package = "PhysioIO")
  dat <- system.file("extdata", "100.dat", package = "PhysioIO")
  if (!nzchar(hea) || !nzchar(dat)) {
    stop("Bundled MIT-BIH demo record not found in PhysioIO.", call. = FALSE)
  }
  c(dat, hea)
}

#' Companion files of a WFDB record base
#'
#' @param base Record base path (no extension), e.g. \code{"data/100"}.
#' @return Character vector of existing \code{base.*} signal/header files.
#' @export
pp_wfdb_files <- function(base) {
  f <- Sys.glob(paste0(base, ".*"))
  f <- f[grepl("\\.(dat|hea|atr)$", f)]
  if (!length(f)) stop("No WFDB files found for base: ", base, call. = FALSE)
  f
}
