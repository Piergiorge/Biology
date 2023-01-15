import re

def find_transmembrane_regions(sequence):
    matches = re.finditer(r"(?=(M.*M))", sequence)
    regions = []
    for match in matches:
        regions.append((match.start(), match.end() - 1))
    return regions

protein_sequence = "MDDAEMMDDADMDDMDDDMDDDMDD"
transmembrane_regions = find_transmembrane_regions(protein_sequence)
if transmembrane_regions:
    print("Transmembrane regions found:")
    for start, end in transmembrane_regions:
        print("- From position", start, "to", end)
else:
    print("No transmembrane regions found.")
