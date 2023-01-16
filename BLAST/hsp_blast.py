import pandas as pd

# Read the tabular BLAST file into a DataFrame
df = pd.read_csv('blast_results.txt', sep='\t')

# Group the rows by query and subject IDs
grouped = df.groupby(['query', 'subject'])

# Define a function to select the best hit based on e-value
def select_best_hit(group):
    return group.nsmallest(1, 'evalue')

# Apply the function to each group and concatenate the results
best_hits = pd.concat(grouped.apply(select_best_hit))
