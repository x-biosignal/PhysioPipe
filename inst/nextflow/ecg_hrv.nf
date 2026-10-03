#!/usr/bin/env nextflow
// Nextflow binding for the ECG/HRV pipeline. Fans out over a cohort of WFDB
// records (one process per record) and combines them, calling the SAME
// orchestrator-agnostic CLIs (inst/cli/) as the PhysioPipe targets factory.
//
//   # single record
//   nextflow run ecg_hrv.nf --record /path/to/100 --outdir results
//   # cohort (glob of .hea headers) — nf-core-style fan-out
//   nextflow run ecg_hrv.nf --records 'data/*.hea' --outdir results
//   # on HPC/cloud, add a container engine:
//   nextflow run ecg_hrv.nf --records 'data/*.hea' -profile singularity
nextflow.enable.dsl = 2

params.record   = null            // single WFDB base (path, no extension)
params.records  = null            // glob of .hea files for a cohort
params.channel  = 1
params.detector = 'pan_tompkins'
params.outdir   = 'results'

process ECG_HRV {
    tag "$id"
    container 'ghcr.io/x-biosignal/physiopipe:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(id), path(dat), path(hea)

    output:
    path "${id}_hrv.parquet"

    script:
    """
    CLI=\$(Rscript -e 'cat(system.file("cli/physio-ecg-hrv.R", package="PhysioPipe"))')
    Rscript "\$CLI" --record ${id} --channel ${params.channel} \
        --detector ${params.detector} --out ${id}_hrv.parquet
    """
}

process COMBINE {
    container 'ghcr.io/x-biosignal/physiopipe:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path parquets

    output:
    path 'cohort_hrv.parquet'

    script:
    """
    CLI=\$(Rscript -e 'cat(system.file("cli/physio-combine-parquet.R", package="PhysioPipe"))')
    Rscript "\$CLI" --out cohort_hrv.parquet ${parquets}
    """
}

// map a .hea header to a (id, dat, hea) tuple
def to_record = { hea ->
    def dat = file(hea.toString().replaceAll(/\.hea$/, '.dat'))
    tuple(hea.baseName, dat, hea)
}

workflow {
    if( params.records ) {
        recs = Channel.fromPath(params.records).map(to_record)
    } else if( params.record ) {
        recs = Channel.fromPath("${params.record}.hea").map(to_record)
    } else {
        error "Pass --record <base> or --records '<glob of .hea>'"
    }
    ECG_HRV(recs)
    COMBINE(ECG_HRV.out.collect())
}
