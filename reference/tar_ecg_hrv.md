# ECG heart-rate-variability pipeline (target factory)

Builds a standard resting-ECG pipeline as a list of `targets`:
`read -> lead -> R-peaks -> RR -> {HRV time, HRV freq} -> summary`, plus
an RR-tachogram figure. With more than one record it fans out via
dynamic branching (one branch per record) and adds a combined cohort
table.

## Usage

``` r
tar_ecg_hrv(
  name = "ecg",
  records = NULL,
  channel = 1L,
  detector = "pan_tompkins"
)
```

## Arguments

- name:

  Target-name prefix (a string; targets are `"<name>_pe"` etc.).

- records:

  `NULL` to use the bundled demo record (MIT-BIH 100 excerpt), or a
  character vector of WFDB record bases (paths without extension).

- channel:

  Lead index to analyse (MIT-BIH 100: 1 = MLII, 2 = V5).

- detector:

  `ecgDetectRpeaks()` method (e.g. "pan_tompkins", "hamilton").

## Value

A list of target objects to splice into a `_targets.R` pipeline.

## See also

[`tar_eeg_bandpower()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_eeg_bandpower.md),
[`tar_emg_features()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_emg_features.md),
[`tar_eda_scr()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_eda_scr.md)

## Examples

``` r
# In _targets.R:
#   library(targets); library(PhysioPipe)
#   list(tar_ecg_hrv())                       # bundled demo, single record
#   list(tar_ecg_hrv(records = my_bases))     # cohort (dynamic branching)
```
