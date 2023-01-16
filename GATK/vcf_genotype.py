import vcf

"identify the genotype in a VCF file"

# Open the VCF file
vcf_reader = vcf.Reader(open('/path/to/file.vcf', 'r'))

# Iterate over the variants in the VCF file
for record in vcf_reader:
    # Get the genotype of the individual with ID "Sample1"
    sample1_genotype = record.genotype("Sample1")

    # Print the genotype
    print("Sample1 genotype:", sample1_genotype["GT"])
