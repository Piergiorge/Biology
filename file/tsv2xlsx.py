import pandas as pd

# Read the TSV file into a DataFrame
df = pd.read_csv('data.tsv', sep='\t')

# Write the DataFrame to an Excel file
df.to_excel('data.xlsx', index=False)
