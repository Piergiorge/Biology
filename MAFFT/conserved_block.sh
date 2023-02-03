#!/bin/bash

mafft sequences.fasta > aligned_sequences.fasta;
trimal -in aligned_sequences.fasta -out conserved_block.fasta -gappyout;
