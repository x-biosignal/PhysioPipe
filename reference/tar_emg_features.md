# EMG amplitude / fatigue pipeline (target factory)

`signal -> linear envelope` and `signal -> spectral fatigue`
(median/mean frequency + RMS over windows).

## Usage

``` r
tar_emg_features(name = "emg", source = NULL)
```

## Arguments

- name:

  Target-name prefix.

- source:

  Expression producing a PhysioExperiment, or NULL for a synthetic
  bursty EMG demo.

## Value

A list of targets.

## Examples

``` r
# Returns target objects (synthetic bursty-EMG demo).
targs <- tar_emg_features()
length(targs)
#> [1] 4
```
