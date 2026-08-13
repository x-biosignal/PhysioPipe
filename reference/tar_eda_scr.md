# EDA skin-conductance pipeline (target factory)

`signal -> tonic/phasic decomposition -> SCR features`.

## Usage

``` r
tar_eda_scr(name = "eda", source = NULL)
```

## Arguments

- name:

  Target-name prefix.

- source:

  Expression producing a PhysioExperiment, or NULL for a synthetic EDA
  demo (drifting SCL + discrete SCRs).

## Value

A list of targets.

## Examples

``` r
# list(tar_eda_scr())
```
