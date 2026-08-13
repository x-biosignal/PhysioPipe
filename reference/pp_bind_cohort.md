# Stack per-branch data frames from a cohort run into one table

Stack per-branch data frames from a cohort run into one table

## Usage

``` r
pp_bind_cohort(branches, id = NULL)
```

## Arguments

- branches:

  A list of per-record data frames (dynamic-branch output).

- id:

  Optional vector of record ids, added as a `record` column.

## Value

A single row-bound data frame.
