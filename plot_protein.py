import requests
from Bio import SeqIO
import matplotlib.pyplot as plt
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.SeqFeature import SeqFeature, FeatureLocation

# Define the protein sequence
sequence = "MVHLTPEEKSAVTALWGKVNVDEVGGEALGRLLVVYPWTQRFFESFGDLSTPDAVMGNPKVKAHGKKVLGAFSDGLAHLDNLKGTFATLSELHCDKLHVDPENFRLLGNVLVCVLAHHFGKEFTPPVQAAYQKVVAGVANALAHKYH"

# Send a request to the InterProScan web service to get the domain information
response = requests.post("http://www.ebi.ac.uk/Tools/services/rest/iprscan5/run", data={"sequence": sequence, "outputformat": "xml"})

# Parse the response to get the domain information
domains = []
for record in SeqIO.parse(io.StringIO(response.text), "interpro"):
    for domain in record.features:
        domains.append((domain.location.start, domain.location.end, domain.type))

# Create a Biopython object representing the protein
protein = SeqRecord(Seq(sequence), id="Protein", description="Example protein")

# Add the domain information to the Biopython object
for start, end, type in domains:
    feature = SeqFeature(FeatureLocation(start, end), type=type)
    protein.features.append(feature)

# Plot the protein architecture
plt.figure(figsize=(10, 2))
for feature in protein.features:
    plt.hlines(1, feature.location.start, feature.location.end, color="red")

# Identify residues as lollipops
residues = [1, 10, 20, 30]  # Example residues of interest
for i, residue in enumerate(residues):
    plt.plot([residue, residue], [0, 2], "k-")
    plt.scatter(residue, 2, marker="o", s=30, color="k")
    plt.text(residue, 3, protein.seq[residue - 1], ha="center", va="bottom")

plt.axis([0, len(sequence), 0, 4])
plt.show()
