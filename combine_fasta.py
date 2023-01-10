import os

# List of FASTA files to combine
fasta_files = ['file1.fasta', 'file2.fasta', 'file3.fasta']

# Open the output file
with open('combined.fasta', 'w') as outfile:
    # Iterate over the input FASTA files
    for file in fasta_files:
        # Open the input file
        with open(file, 'r') as infile:
            # Write the contents of the input file to the output file
            outfile.write(infile.read())
