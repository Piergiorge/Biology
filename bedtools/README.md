# getfasta.sh
This code generates a fasta file containing the sequences corresponding to the intervals specified in a BED file, using the reference genome in fasta format.

## Steps:

Index the reference genome with `samtools faidx` to create a .fai index file.
Use `bedtools getfasta` to extract the sequences corresponding to the intervals in a BED file, using the indexed reference genome.
## Inputs:

* reference_genome.fasta: The reference genome in fasta format.
* intervals.bed: A BED file containing the intervals of interest.
## Outputs:
* output.fasta: A fasta file containing the sequences corresponding to the intervals specified in the intervals.bed file.

* - Note: `bedtools` must be installed and available in the command line path to use this code.

## Example
```bash
# index generation:
samtools faidx reference_genome.fasta
bedtools getfasta -fi reference_genome.fasta -bed intervals.bed -fo output.fasta
```
