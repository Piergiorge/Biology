from Bio.Blast import NCBIWWW
from Bio.Blast import NCBIXML

# Set the query sequence
query = "AGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGC"

# Perform the BLAST search
result_handle = NCBIWWW.qblast("blastn", "nr", query)

# Parse the results
blast_records = NCBIXML.parse(result_handle)

# Iterate over the BLAST records
for blast_record in blast_records:
    # Print the query information
    print("Query:", blast_record.query)

    # Iterate over the alignments
    for alignment in blast_record.alignments:
    # Print the title of the alignment
        print("Title:", alignment.title)

        # Iterate over the HSPs (high-scoring segment pairs)
        for hsp in alignment.hsps:
            # Print the HSP information
            print("E value:", hsp.expect)
            print("Identity:", hsp.identities)
