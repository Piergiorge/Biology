# index generation:
# samtools faidx reference_genome.fasta
bedtools getfasta -fi reference_genome.fasta -bed intervals.bed -fo output.fasta
