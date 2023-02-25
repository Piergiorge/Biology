#!/bin/bash

# A script that retrieves the names and descriptions of all genes located on a specific chromosome of a given organism

# Usage information
usage() {
  echo "Usage: $(basename "$0") [-h] -o organism -c chromosome"
  echo "Example: ./retrieve_genes.sh -o "Homo sapiens" -c X"
  echo "Retrieves the names and descriptions of all genes located on the specified chromosome of the given organism"
  echo ""
  echo "Options:"
  echo "  -h, --help          display this help message"
  echo "  -o, --organism      the name of the organism"
  echo "  -c, --chromosome    the name of the chromosome"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) usage; exit 0 ;;
    -o|--organism) organism="$2"; shift ;;
    -c|--chromosome) chromosome="$2"; shift ;;
    *) echo "Unknown option: $1. Use -h or --help for usage information."; exit 1 ;;
  esac
  shift
done

# Check if organism and chromosome were provided
if [[ -z "${organism}" ]] || [[ -z "${chromosome}" ]]; then
  echo "Organism and chromosome names are required. Use -h or --help for usage information."
  exit 1
fi

# Retrieve gene information using NCBI E-Utilities
esearch -db gene -query "${organism} [ORGN] AND ${chromosome} [CHR]" | \
  efilter -status alive -type coding | \
  efetch -format docsum | \
  xtract -pattern DocumentSummary -NAME Name -DESC Description \
    -block GenomicInfoType -if ChrLoc -equals "${chromosome}" \
      -min ChrStart,ChrStop -element "&NAME" "&DESC"
