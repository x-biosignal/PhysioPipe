# Reproducible pipelines from one-line target factories

PhysioPipe is a collection of
[`targets`](https://docs.ropensci.org/targets/) **target factories** for
the Physio ecosystem. Each factory returns a *list of target objects*
for one standard analysis, so a whole reproducible `_targets.R` is a
couple of lines and you still get `targets`’ incremental re-runs and
byte-level provenance.

This vignette builds factories and inspects the target objects they
produce. It does **not** run a pipeline
([`tar_make()`](https://docs.ropensci.org/targets/reference/tar_make.html)),
which would need the ecosystem analysis packages and, for a report, the
Quarto CLI.

``` r

library(PhysioPipe)
library(targets)
```

## A factory returns target objects

[`tar_ecg_hrv()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_ecg_hrv.md)
expands to the standard resting-ECG HRV pipeline
(`read -> lead -> R-peaks -> RR -> {HRV time, HRV freq} -> summary`,
plus a tachogram figure and a Parquet export):

``` r

ecg <- tar_ecg_hrv()
length(ecg)
#> [1] 10
vapply(ecg, function(t) t$settings$name, character(1))
#>  [1] "ecg_files"    "ecg_pe"       "ecg_lead"     "ecg_peaks"    "ecg_rr"      
#>  [6] "ecg_hrv_time" "ecg_hrv_freq" "ecg_hrv"      "ecg_fig"      "ecg_parquet"
```

Each element is a `targets` target object:

``` r

class(ecg[[1]])
#> [1] "tar_stem"    "tar_builder" "tar_target"  "environment"
```

A real `_targets.R` just splices the list in:

``` r

# _targets.R
library(targets)
library(PhysioPipe)
list(
  tar_ecg_hrv()                               # bundled demo record
)
# then, at the console:  targets::tar_make()
```

## The single-modality factories

EEG band power, EMG amplitude/fatigue, and EDA skin-conductance each
have a factory. With `source = NULL` they point at a seeded *synthetic*
signal so the pipeline runs out of the box; pass an expression to read
real data instead.

``` r

lengths(list(
  eeg = tar_eeg_bandpower(),
  emg = tar_emg_features(),
  eda = tar_eda_scr()
))
#> eeg emg eda 
#>   3   4   4

# Point a factory at a real file:
# tar_eeg_bandpower(source = quote(PhysioIO::readEDF("sub01.edf")))
```

## Cohorts fan out automatically

Give
[`tar_ecg_hrv()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_ecg_hrv.md)
several record bases and it switches to dynamic branching (one branch
per record) and adds a combined cohort table:

``` r

length(tar_ecg_hrv(records = c("data/100", "data/101", "data/102")))
#> [1] 8
```

## Synthetic demo data and pure helpers

[`pp_simulate()`](https://x-biosignal.github.io/PhysioPipe/reference/pp_simulate.md)
makes a clearly-synthetic `PhysioExperiment` for exercising a pipeline’s
mechanics (not for making claims):

``` r

pe <- pp_simulate("eeg")
pe
#> class: PhysioExperiment
#> dim: 2001 x 4 
#> assays(1): raw
#> samplingRate: 250 Hz
#> channels(4): EEG1, EEG2, EEG3, EEG4
#> colData names(1): label
```

Small pure helpers assemble pipeline outputs – e.g. stacking per-record
cohort branches into one table:

``` r

pp_bind_cohort(
  list(data.frame(sdnn = 50), data.frame(sdnn = 61)),
  id = c("rec100", "rec101")
)
#>   sdnn record
#> 1   50 rec100
#> 2   61 rec101
```

## Where to go next

- [`?tar_ecg_hrv`](https://x-biosignal.github.io/PhysioPipe/reference/tar_ecg_hrv.md),
  [`?tar_eeg_bandpower`](https://x-biosignal.github.io/PhysioPipe/reference/tar_eeg_bandpower.md),
  [`?tar_emg_features`](https://x-biosignal.github.io/PhysioPipe/reference/tar_emg_features.md),
  [`?tar_eda_scr`](https://x-biosignal.github.io/PhysioPipe/reference/tar_eda_scr.md)
  – the single-modality factories.
- [`?tar_physio_report`](https://x-biosignal.github.io/PhysioPipe/reference/tar_physio_report.md)
  – a Quarto report target (needs `tarchetypes` + Quarto).
- [`?pp_write_parquet`](https://x-biosignal.github.io/PhysioPipe/reference/pp_write_parquet.md)
  – the language-neutral interchange seam that keeps a pipeline
  orchestrator-agnostic.
