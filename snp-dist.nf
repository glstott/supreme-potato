#!/usr/bin/env nextflow
nextflow.enable.dsl=2
process.executor = "slurm"
// Authors: Garrick Stott
// Purpose: Nextflow pipe to generate snp-distances from raw fastas

// Print log info to user screen.
log.info """ 
    SNP distance
=============================
Project : $workflow.projectDir
Git info: $workflow.repository - $workflow.revision [$workflow.commitId]
Cmd line: $workflow.commandLine
Manifest's pipeline version: $workflow.manifest.version
=============================
"""

// Set default parameter values
temp_out_dir = "./"
output_dir = "../out/"
mem = "64GB"
threads = 8

// Check for user inputs
if (params.input != null){
   input_dir = params.input 
} 
if (params.temp_out_dir != null){
    temp_out_dir = params.temp_out_dir
}
if (params.output_dir != null){
    output_dir = params.output_dir
}
if (params.run_mode != null){
    run_mode = params.run_mode
}
threads = 1
if (params.threads != null){
    threads = params.threads
}

// Align fasta sequences to a reference strain (Original Wuhan sequence) with MAFFT
process mafft{
    // Initialize environment in conda
    // conda "mafft"

    // Set slurm options.
    cpus threads 
    memory mem
    time "6h"
    queue "batch"
    clusterOptions "--ntasks $threads"
    
    // Establish output directory
//    publishDir = out_dir
    
    input:
    path fasta
    
    output:
    path "${fasta.simpleName}.aligned.fasta"
    
    // Add new fragments to the existing alignment set by the original wuhan sequence.
    script:
    """
    mafft --6merpair --thread ${threads} --addfragments ${fasta} /scratch/gs69042/PMeND/data/EPI_ISL_402124.fasta > ${fasta.simpleName}.aligned.fasta
    """

}

// Split codons 
process codonsplit {
    conda "$workflow.projectDir/envs/codonSplit.yaml"

    // Set slurm options.
    cpus threads 
    memory mem
    time "6h"
    queue "batch"
    clusterOptions "--ntasks $threads"

    input:
    path fasta

    output:
    path "${fasta.simpleName}.split*.fasta" 

    script: 
    """
    python3 /scratch/gs69042/supreme-potato/scripts/codonSplit.py $fasta ${fasta.simpleName}.split12.fasta ${fasta.simpleName}.split3.fasta
    """
}

// Calculate SNP Distance
process snpDist {
    // Initialize environment in conda
    conda "$workflow.projectDir/envs/snp-dist.yaml"

    // Set slurm options.
    cpus threads 
    memory mem
    time "6h"
    queue "batch"
    clusterOptions "--ntasks $threads"
    
    // Establish output directory
    publishDir = output_dir

    input:
    path splitFasta

    output:
    path "${splitFasta.simpleName}.snpdist.csv"

    script:
    """
    snp-dists -m -c $splitFasta > "${splitFasta.simpleName}.snpdist.csv"
    """

}

workflow {
    // Input fasta files for tree building process
    input_files = Channel.fromPath( "$input_dir*.fasta" )
    log.info "List of files to be used: \n$input_files\n"

    // Standard process for generating hamming distances at positions 1+2 and 3
    mafft(input_files)
    codonsplit(mafft.out)
    snpDist(codonsplit.out)
}
