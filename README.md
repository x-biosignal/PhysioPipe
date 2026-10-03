# PhysioPipe

Reusable [`targets`](https://docs.ropensci.org/targets/) **pipeline factories**
for the Physio ecosystem. Each factory returns a list of targets, so a whole
reproducible `_targets.R` for a standard analysis is a couple of lines — with
incremental re-runs, dependency tracking, and byte-level provenance for free.

```r
library(targets)
library(PhysioPipe)

# A factory returns ready-made `targets` objects -- no _targets.R or pipeline
# run is needed to see what it produces.
hrv <- tar_ecg_hrv()                            # ECG -> R-peaks -> RR -> HRV + tachogram
length(hrv)                                     # the linked targets it generates
vapply(hrv, function(t) t$name, character(1))   # ecg_pe, ecg_peaks, ... ecg_hrv

# A whole standard pipeline is just a list of factories:
pipeline <- list(
  tar_ecg_hrv(),        # resting ECG -> R-peaks -> RR -> HRV (time + freq) + figure
  tar_eeg_bandpower(),  # EEG -> band power per channel
  tar_emg_features(),   # EMG -> linear envelope + spectral fatigue
  tar_eda_scr()         # EDA -> tonic/phasic -> SCR features
)
```

Save that `pipeline` list as `_targets.R`, then build it from the project
directory. Building runs the modality packages
(`PhysioIO`/`PhysioECG`/`PhysioEDA`/...), which are optional dependencies
installed only for the stages you use:

```text
targets::tar_make()             # build (skips unchanged steps)
targets::tar_visnetwork()       # view the DAG (needs visNetwork)
targets::tar_read(ecg_hrv)      # a result
```

Out of the box every factory runs on **bundled/synthetic demo data** (ECG uses
the MIT-BIH `100` excerpt in PhysioIO; EEG/EMG/EDA use a seeded synthetic
signal from `pp_simulate()`). Point them at real data with `records=` /
`source=`.

## The collection

| Factory | Pipeline | Terminal result |
|---|---|---|
| `tar_ecg_hrv()` | read → lead → R-peaks → RR → HRV | `<name>_hrv` (+ tachogram) |
| `tar_eeg_bandpower()` | signal → Welch PSD band power | `<name>_power` |
| `tar_emg_features()` | signal → envelope / spectral fatigue | `<name>_envelope`, `<name>_fatigue` |
| `tar_eda_scr()` | signal → tonic/phasic → SCR features | `<name>_features` |
| `tar_physio_report()` | targets → Quarto report | `report` (needs `tarchetypes`+`quarto`) |

Every factory takes a `name` prefix, so several can coexist in one project
(`tar_ecg_hrv("subjA")`, `tar_ecg_hrv("subjB")`).

## Real data

Reading a recording needs the modality package that owns that format --
`PhysioIO` for EDF and WFDB -- which is a `Suggests`, so install it alongside:

```r
# EEG from an EDF file (needs PhysioIO)
tar_eeg_bandpower(source = quote(PhysioIO::readEDF("sub01.edf")))

# ECG cohort: multiple WFDB records -> dynamic branching + a combined table
tar_ecg_hrv(records = c("data/subjA", "data/subjB", "data/subjC"))
#   -> ecg_pe, ecg_lead, ... branch per record; ecg_cohort row-binds them.
```

## Adding a new pipeline (extending the collection)

A factory is just a function returning `targets::tar_target_raw()` objects with a
prefixed name. Copy `R/tar-modality.R` as a template, wire the ecosystem
functions with `bquote()`, and add a `tar_dir()` test in
`tests/testthat/test-factories.R`.

## How this fits the ecosystem

- **PhysioPipe** = reusable *pipelines* (infrastructure).
- **PhysioRecipes** = *finished* case studies — a recipe is a PhysioPipe factory
  pointed at a frozen public dataset plus a narrative.
- **PhysioLake** = the lineage/artifact sink for pipeline runs.

## Orchestrator-agnostic (CLI · Parquet · Nextflow)

The targets factory is *one* binding. The actual analysis logic is exposed as a
CLI and writes language-neutral Parquet, so the same step runs under targets,
Nextflow, or plain shell — and the output is readable from Python/DuckDB.

```bash
# Layer 2 — orchestrator-agnostic CLI (writes Parquet)
Rscript $(Rscript -e 'cat(system.file("cli/physio-ecg-hrv.R", package="PhysioPipe"))') \
    --record data/100 --channel 1 --out results/100_hrv.parquet

# Layer 3b — Nextflow calls the same CLI (container-ready for HPC/cloud)
nextflow run $(Rscript -e 'cat(system.file("nextflow/ecg_hrv.nf", package="PhysioPipe"))') \
    --record data/100 --outdir results
```

```text
# Layer 3a — targets emits the same Parquet as a tracked target (needs a built
# pipeline and the arrow package)
tar_read(ecg_parquet)   # "results/ecg_hrv.parquet"
```

Verified equivalent: CLI, targets, and Nextflow all produce `mean_hr = 72.03,
sdnn = 1.389` on the bundled MIT-BIH `100` record; the Parquet reads back in
Python with no R runtime.

## Install

```r
# the containers build on Bioconductor, so its repositories are needed too
install.packages("BiocManager", repos = "https://cloud.r-project.org")
install.packages("PhysioPipe",
  repos = c("https://x-biosignal.r-universe.dev", BiocManager::repositories()))
```
