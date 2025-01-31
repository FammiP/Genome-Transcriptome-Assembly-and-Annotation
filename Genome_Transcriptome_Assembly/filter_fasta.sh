#!/bin/bash

#================================================================
#
# DESCRIPTION:
#   This script filters sequences from a given FASTA file based on a minimum length threshold. 
#   It uses SAMtools to index the input FASTA and extract sequences longer than or equal 
#   to the specified length. The filtered sequences are saved in a new FASTA file.
#
# USAGE:
#   sbatch filter_fasta.sh
#
# REQUIREMENTS:
#   - SAMtools version 1.13 or higher (via module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - FASTA file: $FASTA_FILE
#   - Minimum sequence length: $MIN_LENGTH
#
# OUTPUT:
#   - Filtered sequences in: $OUTPUT_FILE
#
# NOTES:
#   - Ensure the input FASTA file is available at the specified location.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=filtering_lja_fasta
#SBATCH --time=01:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=%x_%A_%a.out   
#SBATCH --error=%x_%A_%a.err    
#SBATCH --mail-type=END
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

ml SAMtools/1.13-GCC-10.3.0
# Input variables
FASTA_FILE="/data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/lja/LJA_assembly_output/k5001/final_dbg.fasta"
MIN_LENGTH=10000

# Output file for filtered sequences
OUTPUT_FILE="/data/users/fparokkaran/assembly_annotation_course/genome_assembly/filtered_sequences.fasta"

# Index the FASTA file (generates .fai index)
samtools faidx "$FASTA_FILE"

# Create a list of sequence IDs with length greater than or equal to MIN_LENGTH
awk -v min_len="$MIN_LENGTH" '$2 > min_len {print $1}' "${FASTA_FILE}.fai" > seq_ids_to_keep.txt

# Extract filtered sequences from the FASTA file
xargs samtools faidx "$FASTA_FILE" < seq_ids_to_keep.txt > "$OUTPUT_FILE"

# Clean up
rm seq_ids_to_keep.txt

