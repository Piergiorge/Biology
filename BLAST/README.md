# blastp.sh

## Running BLAST
To perform a BLAST search, first create a database using the `makeblastdb` command:

```bash
makeblastdb -in goodProteins.fasta -dbtype prot -out db
```
This will create a BLAST database file named `db` using the protein sequences in the `goodProteins.fasta` file.

Next, run the blastp command to perform a BLAST search using a query sequence in the `query.fasta` file:

```bash
blastp -query query.fasta -db db -evalue 1e-5 -out out.blast -soft_masking true -outfmt 6 -seg yes -max_target_seqs 9999999 -dbsize 8525
```
This will generate a tab-delimited output file named `out.blast`, with the top hits for the query sequence against the database. The options used in this command include:

* `-query`: specifies the input query file
* `-db`: specifies the BLAST database file to search against
* `-evalue`: sets the e-value threshold for reporting significant hits
* `-out`: specifies the output file
* `-soft_masking`: enables masking of low-complexity regions in the query sequence
* `-outfmt`: specifies the format of the output file (in this case, tab-delimited)
* `-seg`: enables filtering of query and database sequences for low-complexity regions
* `-max_target_seqs`: sets the maximum number of hits to report
* `-dbsize`: sets the size of the database being searched against (in this case, 8525 sequences)

# hsp_blast.py

## selecting best BLAST hits using pandas

This code is written in Python using the `pandas` library to process BLAST results and output the best hits to a new file.

First, the code imports the pandas library and reads the BLAST results file (`'blast_results.txt'`) into a DataFrame using the `read_csv()` function.

Next, the code groups the rows in the DataFrame by query and subject IDs using the `groupby()` function and assigns the result to the variable `grouped`.

Then, the code defines a function called `select_best_hit()` that takes a group (subset of the DataFrame) and returns the row with the smallest e-value using the `nsmallest()` function.

The `apply()` function is used to apply the `select_best_hit()` function to each group in grouped. The results are then concatenated using the `concat()` function and assigned to the variable `best_hits`.

Finally, `the to_csv()` function is used to save the best hits to a new tab-separated file called '`best_hits.txt`', without including the index column.

# bio.blast.py

This script performs a BLAST search using the Bio.Blast module from Biopython. Here is a brief explanation of what each line does:

```python
from Bio.Blast import NCBIWWW
from Bio.Blast import NCBIXML
```
These lines import the `NCBIWWW` and `NCBIXML` modules from `Bio.Blast`, which allow us to perform a BLAST search and parse the results, respectively.

```python
query = "AGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGC"
```
This line sets the query sequence as a string.

```python
result_handle = NCBIWWW.qblast("blastn", "nr", query)
```
This line performs a BLAST search using the blastn algorithm and the nr database, with the query sequence specified above. The results are returned as a `StringIO` object, which we can parse using the NCBIXML module.

```python
blast_records = NCBIXML.parse(result_handle)
```
This line parses the `StringIO` object returned by the `qblast()` function into a `BlastRecords` object, which can be iterated over to extract information about each hit.

```python
for blast_record in blast_records:
    print("Query:", blast_record.query)

    for alignment in blast_record.alignments:
        print("Title:", alignment.title)

        for hsp in alignment.hsps:
            print("E value:", hsp.expect)
            print("Identity:", hsp.identities)
```
This code iterates over each `blast_record` object in the `blast_records` object, which contains information about each hit. For each `blast_record`, it extracts the query sequence and iterates over each alignment (`alignment`) in the hit. For each alignment, it prints the title of the hit and iterates over each high-scoring segment pair (`hsp`) in the alignment, printing the e-value and identity of each HSP.
