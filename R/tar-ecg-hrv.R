#' ECG heart-rate-variability pipeline (target factory)
#'
#' Builds a standard resting-ECG pipeline as a list of `targets`:
#' `read -> lead -> R-peaks -> RR -> {HRV time, HRV freq} -> summary`, plus an
#' RR-tachogram figure. With more than one record it fans out via dynamic
#' branching (one branch per record) and adds a combined cohort table.
#'
#' @param name Target-name prefix (a string; targets are `"<name>_pe"` etc.).
#' @param records `NULL` to use the bundled demo record (MIT-BIH 100 excerpt),
#'   or a character vector of WFDB record bases (paths without extension).
#' @param channel Lead index to analyse (MIT-BIH 100: 1 = MLII, 2 = V5).
#' @param detector `ecgDetectRpeaks()` method (e.g. "pan_tompkins", "hamilton").
#' @return A list of target objects to splice into a `_targets.R` pipeline.
#' @seealso [tar_eeg_bandpower()], [tar_emg_features()], [tar_eda_scr()]
#' @export
#' @examples
#' # In _targets.R:
#' #   library(targets); library(PhysioPipe)
#' #   list(tar_ecg_hrv())                       # bundled demo, single record
#' #   list(tar_ecg_hrv(records = my_bases))     # cohort (dynamic branching)
tar_ecg_hrv <- function(name = "ecg", records = NULL, channel = 1L,
                        detector = "pan_tompkins") {
  stopifnot(is.character(name), length(name) == 1L)
  n <- function(x) paste0(name, "_", x)
  s <- function(x) as.symbol(n(x))
  raw <- targets::tar_target_raw

  cohort <- !is.null(records) && length(records) > 1L

  if (!cohort) {
    files_cmd <- if (is.null(records)) {
      quote(PhysioPipe::pp_ecg_demo_files())
    } else {
      bquote(PhysioPipe::pp_wfdb_files(.(records)))
    }
    return(list(
      raw(n("files"), files_cmd, format = "file"),
      raw(n("pe"),       bquote(PhysioPipe::pp_ecg_read(.(s("files"))))),
      raw(n("lead"),     bquote(.(s("pe"))[, .(channel)])),
      raw(n("peaks"),    bquote(PhysioECG::ecgDetectRpeaks(.(s("lead")), method = .(detector)))),
      raw(n("rr"),       bquote(PhysioECG::ecgRRintervals(.(s("lead")), .(s("peaks"))))),
      raw(n("hrv_time"), bquote(PhysioECG::ecgHRVtime(.(s("rr"))))),
      raw(n("hrv_freq"), bquote(PhysioECG::ecgHRVfreq(.(s("rr"))))),
      raw(n("hrv"),      bquote(PhysioPipe::pp_hrv_combine(.(s("hrv_time")), .(s("hrv_freq"))))),
      raw(n("fig"),      bquote(PhysioPipe::pp_plot_tachogram(.(s("rr")),
                                  file.path("figures", paste0(.(name), "_tachogram.png")))),
          format = "file"),
      # Language-neutral interchange: the terminal table as Parquet, readable by
      # Python / DuckDB / a Nextflow process (not locked in the .rds store).
      raw(n("parquet"),  bquote(PhysioPipe::pp_write_parquet(.(s("hrv")),
                                  file.path("results", paste0(.(name), "_hrv.parquet")))),
          format = "file")
    ))
  }

  # Cohort: dynamic branching, one branch per record base.
  map_ <- function(x) bquote(map(.(as.symbol(n(x)))))
  list(
    # a single c(...) call so the command is one language object, not a vector
    raw(n("bases"),  as.call(c(quote(c), as.list(records)))),
    raw(n("files"),  bquote(PhysioPipe::pp_wfdb_files(.(s("bases")))),
        pattern = map_("bases"), format = "file"),
    raw(n("pe"),     bquote(PhysioPipe::pp_ecg_read(.(s("files")))),
        pattern = map_("files")),
    raw(n("lead"),   bquote(.(s("pe"))[, .(channel)]),
        pattern = map_("pe")),
    raw(n("peaks"),  bquote(PhysioECG::ecgDetectRpeaks(.(s("lead")), method = .(detector))),
        pattern = map_("lead")),
    raw(n("rr"),     bquote(PhysioECG::ecgRRintervals(.(s("lead")), .(s("peaks")))),
        pattern = bquote(map(.(s("lead")), .(s("peaks"))))),
    raw(n("hrv"),    bquote(PhysioECG::ecgHRVtime(.(s("rr")))),
        pattern = map_("rr"), iteration = "list"),
    raw(n("cohort"), bquote(PhysioPipe::pp_bind_cohort(.(s("hrv")), id = .(s("bases")))))
  )
}
