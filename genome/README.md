# compare.sh

This script is a series of commands in Bash for analyzing two genomes. Here is a brief description of each step:

1 - Genome assembly: The script uses SPAdes to assemble the reads for both genomes with different k-mer sizes and sets the number of threads to 8. It creates two output directories: "genome1_assembly" and "genome2_assembly".

2 - Genome annotation: The script uses Prokka to annotate the assembled genomes, creating two output directories: "genome1_annotation" and "genome2_annotation".

3 - Genome synteny map: The script uses MCScanX to generate a synteny map between the two genomes based on their gene annotations.

4 - Phylogenetic tree: The script uses FastTree to generate a phylogenetic tree for each genome.

5 - Synonymous and non-synonymous analysis: The script uses BEDTools to extract the coding sequences (CDS) from the annotated genomes and creates two output files: "genome1_cds.fasta" and "genome2_cds.fasta".

6 - Genome comparison: The script uses MUMmer to compare the CDS sequences from both genomes and generates a delta file. It then uses show-coords to extract the coordinates of the matching regions and stores them in "genome1_genome2.coords".

# genome_assembly.sh
This is a shell script that performs quality control, trimming and filtering of reads, read error correction, genome assembly, and assembly evaluation using various bioinformatics tools. Overall, this script is useful for processing and analyzing raw sequencing data to generate high-quality genome assemblies.

## Code breakdown

1 - Quality control using `FastQC`: This step uses the `FastQC` tool to assess the quality of the raw reads and generate a report.

2 - Trim and filter reads using `Trimmomatic`: This step uses Trimmomatic to remove adapter sequences, trim low-quality bases, and filter out reads that are too short or too long.

3 - Read error correction using `SPAdes`: This step uses `SPAdes` to correct errors in the reads, such as substitutions, insertions, and deletions.

4 - Assembly using `SPAdes`: This step uses `SPAdes` to perform de novo genome assembly, which involves assembling the reads into contiguous sequences called contigs.

5 - Assembly evaluation using `QUAST`: This step uses `QUAST` to evaluate the quality of the genome assembly by comparing it to a reference genome or using various assembly quality metrics.
