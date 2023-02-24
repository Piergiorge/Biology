#!/bin/bash
OPTIND=1
mindate=1900
maxdate=2020

while getopts ":m:M:" opt; do
  case ${opt} in
    m )
      mindate=$OPTARG
      ;;
    M )
      maxdate=$OPTARG
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

echo "Scanning for the following diseases: $@"
echo "Using a date range of $mindate to $maxdate"

# Search

printf "Years"
  for disease in "$@"
  do
    frst=$( echo -e "${disease:0:1}" | tr [a-z] [A-Z] )
    printf "\t${frst}${disease:1:3}"
  done
  printf "\n"

  for (( yr = 2020; yr >= 1900; yr -= 10 ))
  do
    printf "${yr}s"
    for disease in "$@"
    do
      val=$(
        esearch -db pubmed -query "$disease [TITL]" |
        efilter -mindate "${yr}" -maxdate "$((yr+9))" |
        xtract -pattern ENTREZ_DIRECT -element Count
      )
      printf "\t${val}"
    done
    printf "\n"
  done
