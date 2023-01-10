import pandas as pd

# Read the VCF file into a DataFrame
df = pd.read_csv('data.vcf', sep='\t', comment='#', header=None, names=['chrom', 'pos', 'ID', 'ref', 'alt', 'qual', 'filter', 'info', 'format', 'sample'])

# Count the number of rows
num_variants = len(df)
print(num_variants)
