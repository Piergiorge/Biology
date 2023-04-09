# parser_tmalign.py
This Python script parses the output of a protein structure alignment tool called `TM-align` and extracts the aligned residues and their distance scores.
The output is printed to the console in a tab-separated format.

## Usage
* Save the output of a `TM-align` run to a text file (e.g., `output_tmalign.txt`).

* Run the script with the following command:
```python
python parse_tmalign_output.py output_tmalign.txt
```

# bio3d.R

This R script analyzes protein sequences by performing a BLAST search against the PDB database, downloading matching structures, aligning the structures, calculating sequence conservation, annotating structures, finding the invariant core, and clustering structures based on RMSD. It also generates various plots to visualize the results.

## Required Packages
This script requires the following packages to be installed and loaded:

`bio3d`
`ggplot2`
`ggrepel`

## Inputs
The script takes a vector of protein sequence IDs (sequences) and a vector of reference PDB IDs (references) as inputs.

## Outputs
The script generates several output files for each protein sequence analyzed:

* A FASTA file of the amino acid sequence
* A PDF file of the schematic alignment plot
* A PDF file of the sequence conservation plot
* Two PDF files of the taxonomic plot
* Two SVG files of the PCA plot
* A SVG file of the cluster plot

## How to use
To use this script, first make sure that the required packages are installed and loaded. Then, define the protein sequences to analyze and the reference PDBs for structure alignment. Finally, run the script and wait for the results.

It is recommended to modify the file paths and plot sizes as necessary before running the script.

## Example
```R
# Load required packages
library(bio3d)
library(ggplot2)
library(ggrepel)

# Define protein sequences to analyze
sequences <- c("P04179")

# Define reference PDBs for structure alignment
references <- c("1LUV")

# Loop over protein sequences
for (seq_id in sequences) {
  
  # Retrieve amino acid sequence and save to file
  aa_seq <- get.seq(seq_id)
  file_name <- paste(seq_id, ".fasta", sep="")

  # Perform BLAST search against PDB database
  blast_results <- blast.pdb(aa_seq)
  
  # Extract list of PDB IDs with significant matches
  hits <- plot(blast_results)$pdb.id
  hits_count <- length(unique(hits))
  
  # Proceed only if at least 2 PDB structures were found
  if (hits_count >= 2) {
    
    # Download PDB structures and perform sequence alignment
    pdb_files <- get.pdb(hits, path = "pdbs", split = TRUE, gzip = TRUE)
    aligned_pdbs <- pdbaln(pdb_files, file.out = paste(seq_id, "_aligned.pdb", sep=""), web.args=list(email='email@email.com'))
    pdb_ids <- basename.pdb(aligned_pdbs$id)
    
    # Draw schematic alignment plot
    alignment_plot <- plot(aligned_pdbs, labels=pdb_ids)
    alignment_file <- paste("alignment_", seq_id, ".pdf", sep="")
    pdf(file = alignment_file, width=14, height=7)
    alignment_plot
    dev.off()
    
    # Calculate sequence conservation and draw conservation plot
    cons <- conserv(aligned_pdbs, method="entropy22")
    sse <- pdbs2sse(aligned_pdbs, ind=1, rm.gaps=FALSE)
    conservation_file <- paste("conservation_", seq_id, ".pdf", sep="")
    pdf(file = conservation_file, width=14, height=7)
    plotb3(cons, sse=sse, ylab="Sequence entropy")
    dev.off()
    
    # Annotate collected PDB structures
    anno <- pdb.annotate(pdb_ids)
    taxonomic_plot1 <- ggplot(anno, aes(x=source)) + geom_bar() + theme_bw()
    taxonomic_file1 <- paste("Taxonomic_1_", seq_id, ".pdf", sep
```
