# Write a simple RR tachogram PNG (headless) and return its path

Write a simple RR tachogram PNG (headless) and return its path

## Usage

``` r
pp_plot_tachogram(rr, path = "figures/tachogram.png")
```

## Arguments

- rr:

  Output of
  [`PhysioECG::ecgRRintervals()`](https://x-biosignal.github.io/PhysioECG//reference/ecgRRintervals.html).

- path:

  Output PNG path.

## Value

`path` (so the target can be `format = "file"`).
