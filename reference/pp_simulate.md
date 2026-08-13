# Simulate a synthetic PhysioExperiment for demos and tests

Deterministic (seeded) synthetic signals per modality. Clearly synthetic
— for exercising a pipeline's mechanics, not for making claims.

## Usage

``` r
pp_simulate(
  modality = c("eeg", "emg", "eda"),
  seed = 1L,
  n_channels = NULL,
  duration = NULL,
  sampling_rate = NULL
)
```

## Arguments

- modality:

  One of "eeg", "emg", "eda".

- seed:

  Integer RNG seed (fixed so pipelines stay reproducible).

- n_channels, duration, sampling_rate:

  Optional geometry overrides.

## Value

A `PhysioExperiment` (time x channels) with a `raw` assay.

## Examples

``` r
if (requireNamespace("PhysioCore", quietly = TRUE)) {
  pe <- pp_simulate("eeg")
}
```
