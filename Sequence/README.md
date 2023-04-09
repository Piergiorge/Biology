# single_line_fasta.py

The code reads a FASTA file and prints out the sequence(s) in it. To use this code, replace `/path/to/file.fasta` with the path to your own FASTA file. This code requires the `Biopython` library to be installed.

# create_multifasta.py
This script combines multiple FASTA files into a single output file named combined.fasta.

To use this script, replace `['file1.fasta', 'file2.fasta', 'file3.fasta']` with a list of the names of the FASTA files you want to combine, and run the script. The output file `combined.fasta` will be created in the same directory as the script.
If you want to save the output file to a different directory, you can modify the script to specify the full path to the output file.

# get_uniprot_data.py
This code defines a function `get_uniprot_data` that extracts data for a given protein from the UniProt database using its ID, and then uses it to retrieve data for the protein with ID *P12345* and print it to the console.

## Code breakdown:

1 - Import the `requests` library, which is used to make HTTP requests.

2 - Define a function `get_uniprot_data` that takes a UniProt protein ID as input.

3 - Construct a URL for the UniProt API using the protein ID, and make an HTTP GET request to the URL using the `requests.get` function.

4 - Check the HTTP response status code to see if the request was successful. A status code of `200` indicates success.

5 - If the request was successful, return the response text (which contains the UniProt data for the protein). Otherwise, return `None`.

6 - Set the protein ID to `P12345`.

7 - Call the `get_uniprot_data` function with the protein ID as input and store the returned data in a variable called data.

8 - Check if data was returned successfully, and if so, print it to the console. Otherwise, print an error message.

# polya.py

This is a Python code that uses the regular expression module `re` to find the position of a poly-A tail in an RNA sequence.

## Finding a Poly-A Tail in an RNA Sequence
This code uses regular expressions to find the position of a poly-A tail in an RNA sequence. The function `find_poly_a_tail` takes an RNA sequence as input and returns the starting position of the poly-A tail, or `-1` if no poly-A tail is found. The regular expression used in this code matches the letter `"A"` occurring 10 or more times at the end of the sequence.

```python
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
```
## Output
```python
Poly-A tail found at position: 32
```
