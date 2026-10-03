# Write a data frame to Parquet (language-neutral interchange)

Intermediate/terminal tables written as Parquet can be read by Python
(pandas/pyarrow), DuckDB, and Nextflow processes — unlike the default
`.rds` target store. This is the seam that keeps pipelines
orchestrator-agnostic.

## Usage

``` r
pp_write_parquet(df, path)
```

## Arguments

- df:

  A data frame.

- path:

  Output `.parquet` path.

## Value

`path` (so the target can be `format = "file"`).

## Examples

``` r
if (requireNamespace("arrow", quietly = TRUE)) {
  path <- pp_write_parquet(data.frame(a = 1:3, b = 4:6),
                           file.path(tempdir(), "demo.parquet"))
  file.exists(path)
}
#> [1] TRUE
```
