# Companion files of a WFDB record base

Companion files of a WFDB record base

## Usage

``` r
pp_wfdb_files(base)
```

## Arguments

- base:

  Record base path (no extension), e.g. `"data/100"`.

## Value

Character vector of existing `base.*` signal/header files.

## Examples

``` r
# Create a stand-in record base and list its WFDB companion files.
base <- file.path(tempdir(), "100")
file.create(paste0(base, c(".dat", ".hea", ".atr")))
#> [1] TRUE TRUE TRUE
basename(pp_wfdb_files(base))
#> [1] "100.atr" "100.dat" "100.hea"
```
