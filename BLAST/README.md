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
