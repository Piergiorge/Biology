from Bio import SeqIO

# Open the FASTA file
with open('/path/to/file.fasta', 'r') as f:
    # Iterate over the sequences in the FASTA file
    for record in SeqIO.parse(f, "fasta"):
        # Remove the end-of-line characters from the sequence
        sequence = str(record.seq).replace('\n','')
        # Print the sequence
        print(sequence)
