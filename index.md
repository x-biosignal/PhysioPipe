# PhysioPipe

Reusable [`targets`](https://docs.ropensci.org/targets/) **pipeline
factories** for the Physio ecosystem. Each factory returns a list of
targets, so a whole reproducible `_targets.R` for a standard analysis is
a couple of lines — with incremental re-runs, dependency tracking, and
byte-level provenance for free.

``` r

# _targets.R
library(targets)
library(PhysioPipe)

list(
  tar_ecg_hrv(),        # resting ECG -> R-peaks -> RR -> HRV (time + freq) + figure
  tar_eeg_bandpower(),  # EEG -> band power per channel
  tar_emg_features(),   # EMG -> linear envelope + spectral fatigue
  tar_eda_scr()         # EDA -> tonic/phasic -> SCR features
)
```

``` r

targets::tar_make()             # build (skips unchanged steps)
targets::tar_visnetwork()       # view the DAG
targets::tar_read(ecg_hrv)      # a result
```

Out of the box every factory runs on **bundled/synthetic demo data**
(ECG uses the MIT-BIH `100` excerpt in PhysioIO; EEG/EMG/EDA use a
seeded synthetic signal from
[`pp_simulate()`](https://x-biosignal.github.io/PhysioPipe/reference/pp_simulate.md)).
Point them at real data with `records=` / `source=`.

## The collection

| Factory | Pipeline | Terminal result |
|----|----|----|
| [`tar_ecg_hrv()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_ecg_hrv.md) | read → lead → R-peaks → RR → HRV | `<name>_hrv` (+ tachogram) |
| [`tar_eeg_bandpower()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_eeg_bandpower.md) | signal → Welch PSD band power | `<name>_power` |
| [`tar_emg_features()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_emg_features.md) | signal → envelope / spectral fatigue | `<name>_envelope`, `<name>_fatigue` |
| [`tar_eda_scr()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_eda_scr.md) | signal → tonic/phasic → SCR features | `<name>_features` |
| [`tar_physio_report()`](https://x-biosignal.github.io/PhysioPipe/reference/tar_physio_report.md) | targets → Quarto report | `report` (needs `tarchetypes`+`quarto`) |

Every factory takes a `name` prefix, so several can coexist in one
project (`tar_ecg_hrv("subjA")`, `tar_ecg_hrv("subjB")`).

## Real data

``` r

# EEG from an EDF file
tar_eeg_bandpower(source = quote(PhysioIO::readEDF("sub01.edf")))

# ECG cohort: multiple WFDB records -> dynamic branching + a combined table
tar_ecg_hrv(records = c("data/subjA", "data/subjB", "data/subjC"))
#   -> ecg_pe, ecg_lead, ... branch per record; ecg_cohort row-binds them.
```

## Adding a new pipeline (extending the collection)

A factory is just a function returning
[`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html)
objects with a prefixed name. Copy `R/tar-modality.R` as a template,
wire the ecosystem functions with
[`bquote()`](https://rdrr.io/r/base/bquote.html), and add a
[`tar_dir()`](https://docs.ropensci.org/targets/reference/tar_dir.html)
test in `tests/testthat/test-factories.R`.

## How this fits the ecosystem

- **PhysioPipe** = reusable *pipelines* (infrastructure).
- **PhysioRecipes** = *finished* case studies — a recipe is a PhysioPipe
  factory pointed at a frozen public dataset plus a narrative.
- **PhysioLake** = the lineage/artifact sink for pipeline runs.

## Orchestrator-agnostic (CLI · Parquet · Nextflow)

The targets factory is *one* binding. The actual analysis logic is
exposed as a CLI and writes language-neutral Parquet, so the same step
runs under targets, Nextflow, or plain shell — and the output is
readable from Python/DuckDB.

``` bash
# Layer 2 — orchestrator-agnostic CLI (writes Parquet)
Rscript $(Rscript -e 'cat(system.file("cli/physio-ecg-hrv.R", package="PhysioPipe"))') \
    --record data/100 --channel 1 --out results/100_hrv.parquet

# Layer 3b — Nextflow calls the same CLI (container-ready for HPC/cloud)
nextflow run $(Rscript -e 'cat(system.file("nextflow/ecg_hrv.nf", package="PhysioPipe"))') \
    --record data/100 --outdir results
```

``` r

# Layer 3a — targets emits the same Parquet as a tracked target
tar_read(ecg_parquet)   # "results/ecg_hrv.parquet"
```

Verified equivalent: CLI, targets, and Nextflow all produce
`mean_hr = 72.03, sdnn = 1.389` on the bundled MIT-BIH `100` record; the
Parquet reads back in Python with no R runtime.

## Install

``` r

install.packages("PhysioPipe",
  repos = c("https://x-biosignal.r-universe.dev", getOption("repos")))
```
