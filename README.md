# supreme-potato
Various NextFlow pipelines for BAU work. 

## snp-dist.nf

Note: Alignment is still a sticking point. Runs well when MAFFT is loaded as a module in sapelo, but compatibility problems when loaded with Conda. I'll need to work on this.

* Process: 
  * Generates alignment based on reference sequence, 
  * then splits the alignment into 1+2 and 3rd codon positions, 
  * finally it calculates the hamming distance for each file. 
* Not the fastest way to do this, but useful script.
* Written in DSL2 to enable loading as a module in other pipelines, e.g. PMeND.
