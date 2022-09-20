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

## GISAID_epiweeker.nf

* Simple NF script using DSL2. This workflow will take a directory of tarballs, merge them into a massive FASTA and TSV file, then split them by epiweek (cumulative). 
* Note: For now, important to omit the forward slash at the end of each directory statement. I may have included manual pathing which will break otherwise. 

### Example use on Sapelo2:
```
ml Nextflow
ml Miniconda3
nextflow GISAID_epiweeker.nf --input /path/to/input_directory --temp_out_dir /path/to/temp_out_directory --output_dir /path/to/output_directory
```



## Other gists


```
tar -xvf *.tar
for file in `ls data/Delta_20220524_linked/ids/`; do cat data/Delta_20220524_linked/ids/$file | tr -d '"' > data/Delta_20220524_linked/ids/rev_$file;  done
for file in `ls data/Delta_20220524_linked/ids/`; do seqkit grep -f data/Delta_20220524_linked/ids/$file /home/gs69042/data/GISAID/TX_Delta_HighCoverage_20210301-20211101/merged.aligned.fasta > data/Delta_20220524_linked/fasta/$file.fasta;  done
for file in `ls data/Delta_20220524_linked/ids/`; do grep ">" data/Delta_20220524_linked/fasta/$file | tr -d ">" | grep data/Delta_20220524_linked/dates/$file > data/Delta_20220524_linked/fasta/$file.fasta;  done
```
