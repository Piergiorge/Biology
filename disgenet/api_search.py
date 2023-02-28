import requests
import csv

def get_api_key(api_host, email, password):
    """
    Given the API host, email, and password, authenticate with the DisGeNET API
    and return the API key.

    Parameters:
    - api_host (str): The base URL of the DisGeNET API.
    - email (str): The email address associated with your DisGeNET account.
    - password (str): The password associated with your DisGeNET account.

    Returns:
    - str: The API key to use for accessing the DisGeNET API.
    """
    auth_params = {"email": email, "password": password}
    with requests.Session() as s:
        try:
            r = s.post(f"{api_host}/auth/", data=auth_params)
            if r.status_code == 200:
                json_response = r.json()
                api_key = json_response.get("token")
                print(f"{api_key} This is your user API key.")
                return api_key
            else:
                print(f"Error: {r.status_code} - {r.text}")
                return None
        except requests.exceptions.RequestException as e:
            print("Something went wrong with the request.")
            print(e)
            return None

def print_response(response):
    """
    Given an HTTP response object, print the status code and response text.

    Parameters:
    - response (requests.Response): The HTTP response object to print.
    """
    print(f"Status code: {response.status_code}")
    print(f"Response text: {response.text}")
    
gene_list = [
    'APP',
    'FMR1',
    'SOD1',
    'SOD2',
    'SOD3',
    'TP53',
    'PSN1',
    'PSN2',
]

def main():
    # Define the API host and your DisGeNET account credentials
    api_host = "https://www.disgenet.org/api"
    email = "email@email.com"
    password = "password"

    # Authenticate with the DisGeNET API and retrieve the API key
    api_key = get_api_key(api_host, email, password)
    if api_key is None:
        return

    # Set the API key as an Authorization header in the requests Session object
    with requests.Session() as s:
      s.headers.update({"Authorization": f"Bearer {api_key}"})
      with open("output.tsv", "w", newline="") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow(["Gene Symbol", "Disease Name", "Score"])
        
        for gene in gene_list:
          gene_symbol = gene
          source = "CURATED"
          gda_response = s.get(
                f"{api_host}/gda/gene/{gene_symbol}",
                params={"source": source},
            )
          gda_data = gda_response.json()
                    
          for item in gda_data:
            if isinstance(item, dict):
              print(item.get('geneid'),
                    item.get('gene_symbol'),
                    item.get('gene_dsi'),
                    item.get('gene_dpi'),
                    item.get('gene_pli'),                    
                    item.get('disease_name'),
                    item.get('disease_class_name'),
                    item.get('score')
                  )

            else:
              row = f"No info for gene {gene_symbol}"
              writer.writerow(row)

if __name__ == "__main__":
    main()
