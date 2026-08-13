# Join time- and frequency-domain HRV into one row per channel

Join time- and frequency-domain HRV into one row per channel

## Usage

``` r
pp_hrv_combine(hrv_time, hrv_freq)
```

## Arguments

- hrv_time:

  Output of
  [`PhysioECG::ecgHRVtime()`](https://x-biosignal.github.io/PhysioECG//reference/ecgHRVtime.html).

- hrv_freq:

  Output of
  [`PhysioECG::ecgHRVfreq()`](https://x-biosignal.github.io/PhysioECG//reference/ecgHRVfreq.html).

## Value

A data frame merged on `channel`.
