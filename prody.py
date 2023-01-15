import matplotlib.pyplot as plt
import prody

# Read the protein sequence from a FASTA file
structure = prody.parsePDB("3c2i.pdb")
# Print the sequence
print(structure.getSequence())
sequence = structure.getSequence()

# parser header
prody.parsePDBHeader("3c2i.pdb")

# Create a 3D plot
prody.showProtein(structure)
