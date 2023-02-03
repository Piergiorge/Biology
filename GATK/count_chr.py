import pysam

def count_chromosomes(vcf_file):
    with pysam.VariantFile(vcf_file) as vcf:
        chromosomes = set()
        for record in vcf:
            chromosomes.add(record.chrom)
        return len(chromosomes)

vcf_file = "path/to/your/vcf_file.vcf"
chromosome_count = count_chromosomes(vcf_file)
print("Number of chromosomes:", chromosome_count)
