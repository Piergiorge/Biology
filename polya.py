import re

def find_poly_a_tail(sequence):
    match = re.search("A{10,}$", sequence)
    if match:
        return match.start()
    return -1

rna_sequence = "AGCAGUAGCAGUAGCAGUAGCAGUAGCAGUAGCAGUAGCAGUAGCAGUAAAAAA"
poly_a_tail_start = find_poly_a_tail(rna_sequence)
if poly_a_tail_start != -1:
    print("Poly-A tail found at position:", poly_a_tail_start)
else:
    print("Poly-A tail not found.")
