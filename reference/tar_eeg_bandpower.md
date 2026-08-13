# EEG band-power pipeline (target factory)

`signal -> band power` per channel. Band power is computed from the
Welch PSD integrated over each band, so it is inherently
frequency-selective (no pre-filter needed).

## Usage

``` r
tar_eeg_bandpower(
  name = "eeg",
  source = NULL,
  bands = list(alpha = c(8, 13), beta = c(13, 30)),
  method = "welch",
  relative = FALSE
)
```

## Arguments

- name:

  Target-name prefix.

- source:

  Expression producing a PhysioExperiment, or NULL for a synthetic EEG
  demo (10 Hz alpha + noise).

- bands:

  Named list of `c(low, high)` Hz bands.

- method:

  Welch or wavelet PSD.

- relative:

  Report band power relative to total.

## Value

A list of targets.

## Examples

``` r
# list(tar_eeg_bandpower())
# list(tar_eeg_bandpower(source = quote(PhysioIO::readEDF("sub01.edf"))))
```
