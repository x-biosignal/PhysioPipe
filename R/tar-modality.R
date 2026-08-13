# EEG / EMG / EDA single-modality factories ------------------------------------
# Each takes `source` = an unevaluated expression producing a PhysioExperiment
# (e.g. quote(PhysioIO::readEDF("sub01.edf"))), or NULL to use a seeded synthetic
# signal so the pipeline runs out of the box.

.pp_source_cmd <- function(source, modality) {
  if (is.null(source)) bquote(PhysioPipe::pp_simulate(.(modality))) else source
}

#' EEG band-power pipeline (target factory)
#'
#' `signal -> band power` per channel. Band power is computed from the Welch PSD
#' integrated over each band, so it is inherently frequency-selective (no
#' pre-filter needed).
#'
#' @param name Target-name prefix.
#' @param source Expression producing a PhysioExperiment, or NULL for a synthetic
#'   EEG demo (10 Hz alpha + noise).
#' @param bands Named list of `c(low, high)` Hz bands.
#' @param method Welch or wavelet PSD.
#' @param relative Report band power relative to total.
#' @return A list of targets.
#' @export
#' @examples
#' # list(tar_eeg_bandpower())
#' # list(tar_eeg_bandpower(source = quote(PhysioIO::readEDF("sub01.edf"))))
tar_eeg_bandpower <- function(name = "eeg", source = NULL,
                              bands = list(alpha = c(8, 13), beta = c(13, 30)),
                              method = "welch", relative = FALSE) {
  stopifnot(is.character(name), length(name) == 1L)
  n <- function(x) paste0(name, "_", x); s <- function(x) as.symbol(n(x))
  raw <- targets::tar_target_raw
  list(
    raw(n("pe"), .pp_source_cmd(source, "eeg")),
    raw(n("power"), bquote(PhysioAnalysis::bandPower(
      .(s("pe")), bands = .(bands), method = .(method), relative = .(relative)))),
    raw(n("parquet"), bquote(PhysioPipe::pp_write_parquet(.(s("power")),
      file.path("results", paste0(.(name), "_bandpower.parquet")))), format = "file")
  )
}

#' EMG amplitude / fatigue pipeline (target factory)
#'
#' `signal -> linear envelope` and `signal -> spectral fatigue` (median/mean
#' frequency + RMS over windows).
#'
#' @param name Target-name prefix.
#' @param source Expression producing a PhysioExperiment, or NULL for a synthetic
#'   bursty EMG demo.
#' @return A list of targets.
#' @export
#' @examples
#' # list(tar_emg_features())
tar_emg_features <- function(name = "emg", source = NULL) {
  stopifnot(is.character(name), length(name) == 1L)
  n <- function(x) paste0(name, "_", x); s <- function(x) as.symbol(n(x))
  raw <- targets::tar_target_raw
  list(
    raw(n("pe"),       .pp_source_cmd(source, "emg")),
    raw(n("envelope"), bquote(PhysioEMG::emgEnvelope(.(s("pe"))))),
    raw(n("fatigue"),  bquote(PhysioEMG::emgFatigue(.(s("pe"))))),
    raw(n("parquet"),  bquote(PhysioPipe::pp_write_parquet(.(s("fatigue")),
      file.path("results", paste0(.(name), "_fatigue.parquet")))), format = "file")
  )
}

#' EDA skin-conductance pipeline (target factory)
#'
#' `signal -> tonic/phasic decomposition -> SCR features`.
#'
#' @param name Target-name prefix.
#' @param source Expression producing a PhysioExperiment, or NULL for a synthetic
#'   EDA demo (drifting SCL + discrete SCRs).
#' @return A list of targets.
#' @export
#' @examples
#' # list(tar_eda_scr())
tar_eda_scr <- function(name = "eda", source = NULL) {
  stopifnot(is.character(name), length(name) == 1L)
  n <- function(x) paste0(name, "_", x); s <- function(x) as.symbol(n(x))
  raw <- targets::tar_target_raw
  list(
    raw(n("pe"),       .pp_source_cmd(source, "eda")),
    raw(n("decomp"),   bquote(PhysioEDA::edaDecompose(.(s("pe"))))),
    raw(n("features"), bquote(PhysioEDA::edaFeatures(.(s("decomp"))))),
    raw(n("parquet"),  bquote(PhysioPipe::pp_write_parquet(.(s("features")),
      file.path("results", paste0(.(name), "_scr.parquet")))), format = "file")
  )
}
