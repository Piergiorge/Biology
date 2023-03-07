# Summary
This code reads in a miRNA expression table, filters out miRNAs with low expression, and outputs a list of retained miRNAs.

# Input
miRNA_table.csv: a miRNA expression table in CSV format with column headers and row names.
# Output
miRNA_expr_filt.txt: a list of miRNAs retained after filtering.
# Code
read.table(): reads in the miRNA expression table from a CSV file.
grep(): identifies columns containing miRNA expression data based on their column names.
apply(): calculates the median count value for each miRNA and the 25th percentile count value for each miRNA.
[, ]: subsets the miRNA expression table to include only the miRNA columns and to filter out miRNAs with low expression (count < 25th percentile value for that miRNA).
length(): gets the number of miRNAs retained after filtering.
write.table(): outputs the list of retained miRNAs to a text file.
cat(): prints the number of miRNAs retained after filtering to the console.
