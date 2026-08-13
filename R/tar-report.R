#' Quarto report pipeline (target factory)
#'
#' Wraps `tarchetypes::tar_quarto_raw()` so a rendered report becomes a tracked
#' target that re-renders when any embedded result changes. The `.qmd` reads
#' results with `targets::tar_read()`; targets discovers those dependencies
#' automatically.
#'
#' @param name Target name (string).
#' @param path Path to the `.qmd`. Defaults to the bundled template.
#' @return A single target object (requires the `tarchetypes` and `quarto`
#'   packages plus the Quarto CLI at build time).
#' @export
#' @examples
#' # list(tar_ecg_hrv(), tar_physio_report())
tar_physio_report <- function(name = "report", path = NULL) {
  .pp_require(c("tarchetypes", "quarto"))
  if (is.null(path)) {
    path <- system.file("report", "physio_report.qmd", package = "PhysioPipe")
  }
  if (!nzchar(path) || !file.exists(path)) {
    stop("Report template not found: ", path, call. = FALSE)
  }
  tarchetypes::tar_quarto_raw(name, path = path)
}
