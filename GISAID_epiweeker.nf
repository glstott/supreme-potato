#!/usr/bin/env nextflow
nextflow.enable.dsl=2
// Authors: Garrick Stott
// Purpose: Quick pipeline to generate epiweek files from gisaid tarballs.

// Input tarballs to begin the process.
temp_out_dir = "."
output_dir = "../out"
if (params.input != null){
   input_dir = params.input 
} 
if (params.temp_out_dir != null){
    temp_out_dir = params.temp_out_dir
}
if (params.output_dir != null){
    output_dir = params.output_dir
}

// Process GISAID tarballs
process untar_GISAID {
    publishDir = temp_out_dir
    // This process will untar GISAID download and merge files.
    input:
    path tar

    output:
    path "${tar.simpleName}.fasta", emit: raw_fasta
    path "${tar.simpleName}.metadata.tsv", emit: raw_tsv

    script:
    """
    tar --transform "s/.*\\.metadata\\.tsv/${tar.simpleName}.metadata.tsv/" --transform "s/.*\\.fasta/${tar.simpleName}.fasta/" -xvf $tar 
    """
}
process collect_GISAID {
    publishDir = temp_out_dir
    
    // This process will untar GISAID download and merge files.
    input:
    path fasta
    path tsv

    output:
    path "combined.fasta", emit: collected_fasta
    path "combined.metadata.tsv", emit: collected_tsv

    script:
    """
    cat *.fasta > combined.fasta
    awk 'FNR==1 && NR!=1{next;}{print}' *.metadata.tsv > combined.metadata.tsv
    """
}

// Split data by epiweek and generate files for IQT
process epiweek_split {
    publishDir = output_dir
    conda "-c bioconda epiweeks pandas biopython python=3.8"

    input:
    path fasta
    path "${fasta.simpleName}.metadata.tsv"

    output:
    path "*.fasta" 
    path "*.dt.tsv"
    path "*.metadata.tsv" 

    script:
    """
    python $workflow.projectDir/scripts/epiweeker.py ${fasta.simpleName}.metadata.tsv $fasta 
    """
}

workflow {
    input_files = Channel.fromPath( "$input_dir/*.tar" )
    log.info "List of files to be used: \n$input_files\n"
    
    untar_GISAID(input_files)
    collect_GISAID(untar_GISAID.out.raw_fasta.collect(), untar_GISAID.out.raw_tsv.collect())
    epiweek_split(collect_GISAID.out.collected_fasta, collect_GISAID.out.collected_tsv)
    
    
}
