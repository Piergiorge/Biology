import requests

def get_uniprot_data(protein_id):
    """
    Extracts data for a given protein from UniProt.
    """
    uniprot_url = f"https://www.uniprot.org/uniprot/{protein_id}.txt"
    response = requests.get(uniprot_url)
    if response.status_code == 200:
        return response.text
    else:
        return None

protein_id = "P12345"
data = get_uniprot_data(protein_id)
if data:
    print("Data retrieved successfully:")
    print(data)
else:
    print(f"Unable to retrieve data for protein {protein_id}.")
