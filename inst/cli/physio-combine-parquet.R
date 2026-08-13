#!/usr/bin/env Rscript
# physio-combine-parquet — row-bind per-record Parquet tables into one cohort table.
#   Rscript physio-combine-parquet.R --out cohort.parquet a_hrv.parquet b_hrv.parquet
suppressWarnings(suppressMessages(library(arrow)))
a <- commandArgs(trailingOnly = TRUE)
out <- "cohort.parquet"; files <- character(0)
i <- 1L
while (i <= length(a)) {
  if (a[[i]] == "--out") { out <- a[[i + 1L]]; i <- i + 2L }
  else { files <- c(files, a[[i]]); i <- i + 1L }
}
if (!length(files)) stop("no input parquet files", call. = FALSE)
d <- do.call(rbind, lapply(files, function(f) as.data.frame(read_parquet(f))))
write_parquet(d, out)
cat(sprintf("combined %d files -> %s (%d rows)\n", length(files), out, nrow(d)))
