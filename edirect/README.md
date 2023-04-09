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

# scan_for_diseases.sh

## Bash script to scan for occurrences of specified diseases in PubMed articles within a given date range
This script takes disease names as arguments and scans PubMed articles for occurrences of each disease within a specified date range. It uses the `NCBI E-Utilities` to perform the searches and retrieve the counts.

```yaml
./scan_for_diseases.sh [-m mindate] [-M maxdate] disease1 disease2 ...
```
## Arguments
* `-m` mindate: The earliest year to include in the search. Default is 1900.
* `-M` maxdate: The latest year to include in the search. Default is 2020.
* `disease1 disease2 ...`: Names of the diseases to search for. Disease names should be in lowercase.

## Output
The script outputs a table showing the number of articles found for each disease in each decade within the specified date range.

The table has the following format:
```markdown
Years    Dise1    Dise2    Dise3
-------------------------------
2020s      123      456      789
2010s      234      567      890
...
```

## Example
```yaml
./scan_for_diseases.sh -m 1950 -M 1990 diphtheria pertussis tetanus
```
## Output

```yaml
Scanning for the following diseases: diphtheria pertussis tetanus
Using a date range of 1950 to 1990
Years   Diph    Pert    Teta
---------------------------
1990s       3      35      42
1980s      26     184     150
1970s      46     469     315
1960s     165    1025     620
1950s     509    2769    1488
```
