# Structural tests (fast, no pipeline run) --------------------------------------

is_target_list <- function(x) {
  is.list(x) && length(x) > 0 &&
    all(vapply(x, inherits, logical(1), "tar_target"))
}

test_that("single-modality factories return target lists", {
  expect_true(is_target_list(tar_ecg_hrv()))
  expect_true(is_target_list(tar_eeg_bandpower()))
  expect_true(is_target_list(tar_emg_features()))
  expect_true(is_target_list(tar_eda_scr()))
})

test_that("name prefix propagates to target names", {
  nms <- vapply(tar_ecg_hrv(name = "sub01"),
                function(t) t$settings$name, character(1))
  expect_true(all(c("sub01_pe", "sub01_hrv", "sub01_fig") %in% nms))
})

test_that("multiple records switch the ECG factory to cohort branching", {
  single <- vapply(tar_ecg_hrv(), function(t) t$settings$name, character(1))
  cohort <- vapply(tar_ecg_hrv(records = c("a", "b")),
                   function(t) t$settings$name, character(1))
  expect_false("ecg_cohort" %in% single)
  expect_true(any(grepl("_cohort$", cohort)))
})

test_that("report factory guards on missing Quarto tooling", {
  skip_if(requireNamespace("tarchetypes", quietly = TRUE) &&
          requireNamespace("quarto", quietly = TRUE))
  expect_error(tar_physio_report(), "PhysioPipe needs")
})

# Integration test (runs a real pipeline; skipped where deps/tooling absent) -----

test_that("factories build and compute on bundled + synthetic data", {
  skip_on_cran()
  for (p in c("PhysioIO", "PhysioECG", "PhysioAnalysis", "PhysioEMG",
              "PhysioEDA", "PhysioCore", "S4Vectors", "arrow"))
    skip_if_not_installed(p)

  targets::tar_dir({
    writeLines(c(
      "library(targets); library(PhysioPipe)",
      "list(tar_ecg_hrv(), tar_eeg_bandpower(), tar_emg_features(), tar_eda_scr())"
    ), "_targets.R")
    targets::tar_make(reporter = "silent")

    built <- targets::tar_manifest()$name
    expect_true(all(c("ecg_hrv", "eeg_power", "emg_fatigue", "eda_features") %in% built))
    expect_s3_class(targets::tar_read(ecg_hrv), "data.frame")
    expect_equal(nrow(targets::tar_read(eeg_power)), 4L)
    expect_gt(targets::tar_read(eda_features)$scr_count, 0)

    # language-neutral Parquet artifact round-trips
    pq <- targets::tar_read(ecg_parquet)
    expect_true(file.exists(pq))
    expect_equal(as.data.frame(arrow::read_parquet(pq))$mean_hr,
                 targets::tar_read(ecg_hrv)$mean_hr)
  })
})
