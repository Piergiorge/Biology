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
  write.fasta(aa_seq, file_name)
  
  # Perform BLAST search against PDB database
  blast_results <- blast.pdb(aa_seq)
  
  # Extract list of PDB IDs with significant matches
  hits <- plot(blast_results)$pdb.id
  hits_count <- length(unique(hits))
  
  # Proceed only if at least 2 PDB structures were found
  if (hits_count >= 2) {
    
    # Download PDB structures and perform sequence alignment
    pdb_files <- get.pdb(hits, path = "pdbs", split = TRUE, gzip = TRUE)
    aligned_pdbs <- pdbaln(pdb_files, file.out = paste(seq_id, "_aligned.pdb", sep=""), web.args=list(email='rafaelpiergiorge@gmail.com'))
    pdb_ids <- basename.pdb(aligned_pdbs$id)
    
    # Draw schematic alignment plot
    alignment_plot <- plot(aligned_pdbs, labels=pdb_ids)
    alignment_file <- paste("alignment_", seq_id, ".svg", sep="")
    svg(alignment_file, width=14, height=7)
    alignment_plot
    dev.off()
    
    # Calculate sequence conservation and draw conservation plot
    cons <- conserv(aligned_pdbs, method="entropy22")
    sse <- pdbs2sse(aligned_pdbs, ind=1, rm.gaps=FALSE)
    conservation_file <- paste("conservation_", seq_id, ".svg", sep="")
    svg(conservation_file, width=14, height=7)
    plotb3(cons, sse=sse, ylab="Sequence entropy")
    dev.off()
    
    # Annotate collected PDB structures
    anno <- pdb.annotate(pdb_ids)
    taxonomic_plot1 <- ggplot(anno, aes(x=source)) + geom_bar() + theme_bw()
    taxonomic_file1 <- paste("Taxonomic_1_", seq_id, ".svg", sep="")
    svg(taxonomic_file1, width=14, height=7)
    taxonomic_plot1
    dev.off()
    taxonomic_plot2 <- barplot(table(anno$source))
    taxonomic_file2 <- paste("Taxonomic_2_", seq_id, ".svg", sep="")
    
    svg(taxonomic_file2, width=14, height=7)
      taxonomic_plot2
    dev.off()
    
    # Find invariant core and fit PDBs to core region
    core <- core.find(aligned_pdbs)
    ref_pdb <- read.pdb(references)
    xyz <- pdbfit(ref_pdb, inds=core)
    fitted_pdbs <- aligned_pdbs
    fitted_pdbs$xyz <- pdbfit(fitted_pdbs, ref=xyz)
    
    # Perform PCA and RMSD calculation
    pc_xray <- pca(fitted_pdbs)
    rd <- rmsd(fitted_pdbs)
    
    # Cluster structures based on RMSD
    hc_rd <- hclust(dist(rd))
    grps_rd <- cutree(hc_rd, k=3)
    
    # Generate PCA plots and cluster plots
    pca_file1 <- paste("pca1_", seq_id, ".svg", sep="")
    
    svg(pca_file1, width=14, height=7)
      plot.pc(pc_xray, col=grps_rd, ellipse=TRUE, legend=TRUE)
    dev.off()
    
    pca_file2 <- paste("pca2_", seq_id, ".svg", sep="")
    
    svg(pca_file2, width=14, height=7)
      plot.pc(pc_xray, type="xyz", col=grps_rd, ellipse=TRUE, legend=TRUE)
    dev.off()
    
    cluster_file <- paste("cluster_", seq_id, ".svg", sep="")
    svg(cluster_file, width=14, height=7)
      ggplot(data.frame(x=pc_xray$xyz[,1], y=pc_xray$xyz[,2], group=grps_rd), aes(x=x, y=y, color=factor(group))) +
        geom_point() +
        scale_color_manual(values=c("red", "blue", "green")) +
        theme_bw() +
        geom_text_repel(aes(label=pdb_ids)) +
        ggtitle("Protein structure clusters") +
        theme(plot.title = element_text(hjust = 0.5))
    dev.off()
   } else {
   print(paste("No significant hits found for", seq_id))
}
}
