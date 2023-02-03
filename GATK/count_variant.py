import pysam

filename = "path/to/your/vcf/file.vcf"

# Open the VCF file using pysam
vcf = pysam.VariantFile(filename)

# Initialize a counter for the number of variants
num_variants = 0

# Read the file line by line
for variant in vcf:
    num_variants += 1

# Print the number of variants
print("Number of variants:", num_variants)
