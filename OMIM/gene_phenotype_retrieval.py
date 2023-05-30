import requests
import json
import re

api_key = 'api_key'

# Open output file for writing
output_file = open('result.tsv', 'w')

# Write header to the output file
output_file.write("Gene\tneurologicCentralNervousSystem_clinicalSynopsis\tphenotype\tpheno_id\n")

# Open gene list file
with open('57_list.txt', 'r') as file:
    for line in file.readlines():
        search_terms = line.strip()

        # Perform gene search using OMIM API
        url = f'https://api.omim.org/api/geneMap/search?search={search_terms}&format=json&start=0&apiKey={api_key}'
        response = requests.get(url)
        data = response.json()

        # Check if geneMapList and phenotypeMapList exist in the response
        if data['omim']['searchResponse'].get('geneMapList') and data['omim']['searchResponse']['geneMapList'][0]['geneMap'].get('phenotypeMapList'):
            gene = data['omim']['searchResponse']['geneMapList'][0].get('geneMap').get('approvedGeneSymbols')

            # Iterate over the phenotypeMapList
            for pheno in data['omim']['searchResponse']['geneMapList'][0]['geneMap'].get('phenotypeMapList'):
                pheno_id = pheno.get('phenotypeMap').get('phenotypeMimNumber')
                phenotype = pheno.get('phenotypeMap').get('phenotype')

                # Perform clinicalSynopsis search using phenotype ID
                url = f'https://api.omim.org/api/clinicalSynopsis?mimNumber={pheno_id}&include=clinicalSynopsis&format=json&apiKey={api_key}'
                response = requests.get(url)
                data2 = response.json()

                # Iterate over the clinicalSynopsisList
                for clin in data2['omim']['clinicalSynopsisList']:
                    if clin.get('clinicalSynopsis').get('neurologicCentralNervousSystem'):
                        pheno_nerv = clin.get('clinicalSynopsis').get('neurologicCentralNervousSystem')
                        pheno_nerv = pheno_nerv.split(";\n")
                        
                        # Iterate over each term in neurologicCentralNervousSystem
                        for term in pheno_nerv:
                            pattern = re.search('(.*?)\s*\{', term)
                            if pattern:
                                # Write data to the output file
                                output_file.write(f"{gene}\t{pattern.group(1).strip()}\t{phenotype}\t{pheno_id}\n")

# Close the gene list file
file.close()

# Close the output file
output_file.close()
