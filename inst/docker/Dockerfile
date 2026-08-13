# Container image for the PhysioPipe Nextflow bindings — the same environment
# every process runs in on HPC/cloud.
#
# Build (after PhysioPipe is published to the x-biosignal r-universe):
#   docker build -t ghcr.io/x-biosignal/physiopipe:latest -f inst/docker/Dockerfile .
#   docker push  ghcr.io/x-biosignal/physiopipe:latest
FROM rocker/r-ver:4.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      libcurl4-openssl-dev libssl-dev libxml2-dev cmake \
    && rm -rf /var/lib/apt/lists/*

# Install PhysioPipe + orchestration deps and the sibling Physio* packages it
# calls, all from the ecosystem r-universe (+ CRAN for the rest).
RUN R -q -e 'options(repos = c(xbiosignal = "https://x-biosignal.r-universe.dev", \
                               CRAN = "https://cloud.r-project.org")); \
      install.packages(c("PhysioPipe", "targets", "arrow"), dependencies = TRUE); \
      if (!requireNamespace("PhysioPipe", quietly = TRUE)) quit(status = 1L)'

CMD ["R", "--no-save"]
