#!/bin/bash

# Step 1: Quality control using FastQC
fastqc raw_reads.fastq -o qc_output

# Step 2: Trim and Filter reads using Trimmomatic
java -jar trimmomatic.jar PE -threads 8 -phred33 raw_reads_1.fastq raw_reads_2.fastq trimmed_reads_1.fastq trimmed_reads_1_unpaired.fastq trimmed_reads_2.fastq trimmed_reads_2_unpaired.fastq ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Step 3: Read error correction using SPAdes
spades.py --pe1-1 trimmed_reads_1.fastq --pe1-2 trimmed_reads_2.fastq -t 8 -o corrected_reads

# Step 4: Assembly using SPAdes
spades.py -o assembly_output --careful -k 55,77,99,127 -t 8 -m 64 --pe1-1 corrected_reads/trimmed_reads_1_cor.fastq --pe1-2 corrected_reads/trimmed_reads_2_cor.fastq 

# Step 5: Assembly Evaluation using QUAST
quast.py -o assembly_eval assembly_output/contigs.fasta

