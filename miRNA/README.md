# expression.R
This code reads in a miRNA expression table (counts), filters out miRNAs with low expression, and outputs a list of retained miRNAs.

## Input
* miRNA_table.csv: a miRNA expression table in CSV format with column headers and row names.
## Output
* miRNA_expr_filt.txt: a list of miRNAs retained after filtering.
 
## Code breakdown:

1 - `miRNA_table <- read.table("miRNA_table.csv", header = TRUE, sep = "\t", check.names = FALSE)`: This reads in the miRNA expression table from a CSV file called "miRNA_table.csv" with a header and tab-separated values. The `check.names = FALSE` argument prevents R from modifying the column names.

2 - `miRNA_cols <- grep("^hsa-.", colnames(miRNA_table))`: This identifies the columns of the miRNA expression table that contain miRNA expression data by searching for column names that start with "hsa-".

3 - `miRNA_expr <- miRNA_table[, miRNA_cols]`: This subsets the miRNA expression table to include only the columns that contain miRNA expression data.

4 - `median_counts <- apply(miRNA_expr, 2, median)`: This calculates the median expression count value for each miRNA by applying the median function to each column of miRNA_expr.

5 - `quantile_counts <- apply(miRNA_expr, 2, quantile, probs = 0.25)`: This calculates the 25th percentile value for each miRNA by applying the quantile function with the probs argument set to 0.25.

6 - `miRNA_expr_filt <- miRNA_expr[, median_counts > quantile_counts[2]]`: This subsets the miRNA expression table to include only the columns for which the median expression count value is greater than the 25th percentile value for that miRNA.

7 - `write.table(colnames(miRNA_expr_filt), file = 'miRNA_expr_filt.txt', row.names = F)`: This writes the column names of miRNA_expr_filt to a text file called "miRNA_expr_filt.txt" without row names.

8 - `num_miRNAs_retained <- dim(miRNA_expr_filt)[2]`: This calculates the number of miRNAs retained after filtering by getting the number of columns in miRNA_expr_filt.

9 - `cat(sprintf("Number of miRNAs retained after filtering: %d\n", num_miRNAs_retained))`: This prints out the number of miRNAs retained after filtering to the console using sprintf to format the output string.
