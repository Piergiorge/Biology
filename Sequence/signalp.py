import re

def find_signal_peptide(sequence):
    match = re.search(r"^[^M]*M", sequence)
    if match:
        return match.start()
    return -1

protein_sequence = "MDSDPGGRRRQQQQQQQQQQQQQQQQQQQQ"
signal_peptide_start = find_signal_peptide(protein_sequence)
if signal_peptide_start != -1:
    print("Signal peptide found starting at position:", signal_peptide_start)
else:
    print("Signal peptide not found.")
