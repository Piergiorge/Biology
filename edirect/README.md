# pubmed_search_text.sh

This script searches PubMed for articles related to cancer and therapy using `eSearch`, and then extracts specific data from the XML output using grep and outputs it as tab-delimited text.

## Usage
```bash
./pubmed_search_text.sh
```

# retrieve_genes.sh

This is a Bash script that retrieves the names and descriptions of all genes located on a specific chromosome of a given organism using `NCBI E-utilities`. The script takes in two arguments: the name of the organism and the name of the chromosome.

The script starts by defining a function that provides usage information when called with the "`-h`" or "`--help`" option. It then uses a while loop to parse the command-line arguments and store them in variables. The script checks if both the organism and chromosome names were provided, and if not, it displays the usage information and exits.

The script then uses NCBI E-utilities to retrieve gene information. It first uses "`esearch`" to search the gene database for the specified organism and chromosome. It then filters the results using "`efilter`" to only include genes that are alive and are coding genes. It uses "`efetch`" to retrieve the document summaries for the resulting gene IDs in XML format. Finally, it uses "`xtract`" to extract the name and description of each gene that is located on the specified chromosome, using the "`ChrLoc`" field in the "`GenomicInfoType`" block to filter the results. The extracted gene names and descriptions are then printed to the console in tab-separated format.

## Example
```bash
./retrieve_genes.sh -o "Homo sapiens" -c 11
```
