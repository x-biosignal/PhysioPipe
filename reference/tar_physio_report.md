# Quarto report pipeline (target factory)

Wraps
[`tarchetypes::tar_quarto_raw()`](https://docs.ropensci.org/tarchetypes/reference/tar_quarto.html)
so a rendered report becomes a tracked target that re-renders when any
embedded result changes. The `.qmd` reads results with
[`targets::tar_read()`](https://docs.ropensci.org/targets/reference/tar_read.html);
targets discovers those dependencies automatically.

## Usage

``` r
tar_physio_report(name = "report", path = NULL)
```

## Arguments

- name:

  Target name (string).

- path:

  Path to the `.qmd`. Defaults to the bundled template.

## Value

A single target object (requires the `tarchetypes` and `quarto` packages
plus the Quarto CLI at build time).

## Examples

``` r
# list(tar_ecg_hrv(), tar_physio_report())
```
