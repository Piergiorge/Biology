#!/bin/bash

# This script uses eSearch to search the PubMed database for articles related to cancer and therapy.
# The script then extracts specific data from the eSearch XML output using grep and outputs it as tab-delimited text.

# Usage: ./pubmed_search.sh

# Perform the eSearch query and extract data using grep and tr
esearch -db pubmed -query "cancer AND therapy" | grep -oP '<\S+>\K[^<]+' | tr '\n' '\t'
