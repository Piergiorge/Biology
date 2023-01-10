# Open the FASTA file
with open('/path/to/file.fasta', 'r') as f:
    # Initialize an empty string to store the current sequence
    sequence = ''
    # Iterate over the lines in the FASTA file
    for line in f:
        # Check if the line starts with a ">"
        if line.startswith(">"):
            # If it does, it's a header line
            # If there is a sequence stored, print it
            if sequence:
                # Remove the end-of-line characters from the sequence
                sequence = sequence.replace('\n','')
                print(sequence)
            # Reset the sequence variable
            sequence = ''
        else:
            # If it doesn't, it's a sequence line
            # Append it to the current sequence
            sequence += line
    # Print the last sequence 
    if sequence:
        # Remove the end-of-line characters from the sequence
        sequence = sequence.replace('\n','')
        print(sequence)
