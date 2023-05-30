
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
```

The script will make API calls to retrieve gene-phenotype data for each gene in the list. The results will be saved in a file named `result.tsv`.

## Output Format

The output file `result.tsv` will contain the following columns:

- Gene: The approved gene symbol.
- neurologicCentralNervousSystem_clinicalSynopsis: The neurologicCentralNervousSystem term from the clinical synopsis.
- phenotype: The phenotype associated with the gene.
- pheno_id: The phenotype ID.

## Notes

- Ensure that you have a stable internet connection to access the OMIM API.
- The script may take some time to complete depending on the number of genes and the response time of the API.

## License

This project is licensed under the MIT License.

You can use this README.md file as a starting point and customize it further based on your requirements. Make sure to update the sections with relevant information specific to your project.
