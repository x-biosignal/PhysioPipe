#' @keywords internal
"_PACKAGE"

`%||%` <- function(a, b) if (is.null(a)) b else a

# Informative guard for the Suggested ecosystem packages a step needs at run time.
.pp_require <- function(pkgs) {
  miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss)) {
    stop("PhysioPipe needs these packages for this step: ",
         paste(miss, collapse = ", "),
         " (install from the x-biosignal r-universe).", call. = FALSE)
  }
  invisible(TRUE)
}
