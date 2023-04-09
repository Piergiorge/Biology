# conserved_block.sh

This is a bash script that performs multiple sequence alignment and trimming on a set of nucleotide or amino acid sequences in a FASTA file format using the `MAFFT` and `trimal` software tools.

The script first uses the `MAFFT` program to align the sequences in the input file `"sequences.fasta"`, producing an output file `"aligned_sequences.fasta"` that contains the aligned sequences.

The script then uses the `trimal` program to trim the aligned sequences in the `"aligned_sequences.fasta"` file, removing columns with gaps and producing an output file `"conserved_block.fasta"` that contains the conserved regions of the alignment.

```bash
mafft sequences.fasta > aligned_sequences.fasta;
trimal -in aligned_sequences.fasta -out conserved_block.fasta -gappyout;
```
* Note that to run this script, you need to have `MAFFT` and `trimal` installed on your system and accessible from the `command line`.
