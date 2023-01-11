makeblastdb -in goodProteins.fasta -dbtype prot -out db;
blastp -query query.fasta -db db -evalue 1e-5 -out out.blast -soft_masking true -outfmt 6 -seg yes -max_target_seqs 9999999 -dbsize 8525;
