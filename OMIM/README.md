# Gene-Phenotype Data Retrieval

This Python script retrieves gene-phenotype data using the Online Mendelian Inheritance in Man (OMIM) API. It takes a list of genes as input and fetches corresponding phenotype information for each gene. The script saves the retrieved data in a tab-separated values (TSV) file.

## Prerequisites

- Python 3.x
- Requests library: Install using `pip install requests`

## Getting Started

1. Clone the repository or download the script file.
2. Obtain an API key from OMIM by creating an account on their website.
3. Update the `api_key` variable in the script with your OMIM API key.
4. Prepare a list of genes in a text file named `57_list.txt`, with one gene symbol per line.

## Usage

Run the script using the following command:

```shell
python gene_phenotype_retrieval.py
