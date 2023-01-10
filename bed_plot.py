import pybedtools
import matplotlib.pyplot as plt

# Define the GTF file containing the transcript annotations
gtf_file = 'path_gtf'

# Create a BedTool object from the GTF file
gtf = pybedtools.BedTool(gtf_file)

# Define the region of interest
region = ('1', 1, 1000000)

# Extract the exon-intron structure of the transcripts in the region
exon_intron = gtf.filter(lambda x: x.fields[0] == region[0] and \
                                 int(x.fields[3]) <= region[2] and \
                                 int(x.fields[4]) >= region[1]).sort().saveas()

# Plot the exon-intron pattern
fig, ax = plt.subplots()
for feature in exon_intron:
    if feature.fields[2] == "exon":
        color = "blue"
    elif feature.fields[2] == "intron":
        color = "red"
    ax.broken_barh([(int(feature.fields[3]), int(feature.fields[4]) - int(feature.fields[3]))], (0, 9), facecolors=color)

plt.show()
