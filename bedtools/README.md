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
# intersect.sh

This command will use the `bedtools intersect` tool to find the overlapping regions between two BED files (`file1.bed` and `file2.bed`) and output the intersecting regions in a new BED file intersections.bed. The `-wa` and `-wb` options are used to include both the original regions in file1.bed and file2.bed in the output file.

Note that the intersection is defined as the overlapping regions on the same chromosome(s). If the two files are from different genomes, or if the chromosomes in the files have different naming conventions, you may need to preprocess the files to ensure that the chromosomes are named consistently before running the bedtools intersect command.

## Example
```bash
bedtools intersect -a file1.bed -b file2.bed -wa -wb > intersections.bed
```
