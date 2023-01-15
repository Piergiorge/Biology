import requests

# Set the API key and base URL
api_key = "YOUR_API_KEY"
base_url = "https://api.omim.org/api"

# Specify the gene to search for
gene = "TAF1"

# Construct the API query URL
query_url = f"{base_url}/entry?mimNumber={gene}&apiKey={api_key}"

# Send the API query and store the response
response = requests.get(query_url)

# Extract the relevant information from the response
data = response.json()

# Extract the clinical Synopsis
for entry in data['omim']['entryList']:
    if entry['entry']['preferredTitle']['mimNumber'] == gene:
        synopsis = entry['entry']['clinicalSynopsis']['textSection']['textSectionContent']

print(synopsis)
