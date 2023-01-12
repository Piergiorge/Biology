#!/bin/bash

# Step 1: Quality control using FastQC
fastqc raw_reads.fastq -o qc_output;

# Step 2: Read alignment using BWA
bwa mem reference.fa raw_reads.fastq > alignment.sam;

# Step 3: Convert SAM to BAM and sort the BAM file
samtools view -bS alignment.sam | samtools sort -o alignment.bam;

# Step 4: Mark duplicates using GATK MarkDuplicates
java -jar gatk.jar MarkDuplicates -I alignment.bam -O marked_duplicates.bam -M marked_duplicate_metrics.txt;

# Step 5: Base quality score recalibration using GATK BaseRecalibrator
java -jar gatk.jar BaseRecalibrator -I marked_duplicates.bam -R reference.fa -knownSites dbsnp.vcf -O recal_data.table;

# Step 6: Apply the recalibration to the BAM using GATK ApplyBQSR
java -jar gatk.jar ApplyBQSR -R reference.fa -I marked_duplicates.bam --bqsr-recal-file recal_data.table -O recalibrated.bam;

# Step 7: Haplotype Caller using GATK HaplotypeCaller
java -jar gatk.jar HaplotypeCaller -R reference.fa -I recalibrated.bam -O raw_variants.vcf;

# Step 8: Variant filtering using GATK VariantFiltration
java -jar gatk.jar VariantFiltration -R reference.fa -V raw_variants.vcf -filter "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" -O filtered_variants.vcf;

# Step 9: Annotation using SnpEff
java -jar snpEff.jar eff -v GRCh38.86 filtered_variants.vcf > annotated_variants.vcf;

