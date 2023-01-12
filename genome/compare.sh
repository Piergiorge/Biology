#!/bin/bash

# Step 1: Genome assembly of both genomes
spades.py -o genome1_assembly -k 55,77,99,127 -t 8 -m 64 --pe1-1 genome1_reads_1.fastq --pe1-2 genome1_reads_2.fastq ;
spades.py -o genome2_assembly -k 55,77,99,127 -t 8 -m 64 --pe1-1 genome2_reads_1.fastq --pe1-2 genome2_reads_2.fastq ;

# Step 2: Annotation of both genomes
prokka --outdir genome1_annotation --prefix genome1 genome1_assembly/contigs.fasta;
prokka --outdir genome2_annotation --prefix genome2 genome2_assembly/contigs.fasta;

# Step 3: Creating a Genome Synteny Map using MCScanX
mcscanx --output=mcscanx_output genome1_annotation/*.gff genome2_annotation/*.gff;

# Step 4: Create a phylogenetic tree 
FastTree -nt genome1_assembly/contigs.fasta > genome1_tree.nwk;
FastTree -nt genome2_assembly/contigs.fasta > genome2_tree.nwk;

# Step 5: Synonymous and non-synonymous analysis
bedtools getfasta -fi genome1_assembly/contigs.fasta -bed genome1_annotation/*.gff -fo genome1_cds.fasta;
bedtools getfasta -fi genome2_assembly/contigs.fasta -bed genome2_annotation/*.gff -fo genome2_cds.fasta;

# Step 6: Compare genomes with MUMmer
nucmer --prefix=genome1_genome2 genome1_cds.fasta genome2_cds.fasta
show-coords -r -c -l genome1_genome2.delta > genome1_genome2.coords

