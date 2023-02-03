import pysam

vcf_file = "path/to/your/vcf_file.vcf"

# Open the VCF file
vcf = pysam.VariantFile(vcf_file)

# Get the header information
header = vcf.header

# Get the sample names from the header
samples = header.samples

# Loop through the variants in the VCF file
for variant in vcf:
    # Get the genotype information for each sample
    for sample in samples:
        genotype = variant.samples[sample]["GT"]
        print(f"Sample: {sample}, Genotype: {genotype}")
