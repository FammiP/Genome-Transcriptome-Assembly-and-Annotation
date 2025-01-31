#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script extracts the longest isoform for each gene from filtered protein and transcript 
#   FASTA files using SeqKit. It identifies the longest isoforms based on sequence length and 
#   creates output files containing the selected sequences.
#
# USAGE:
#   sbatch 17_extract_longest_isoforms.sh
#
# REQUIREMENTS:
#   - SeqKit version 2.6.1 (via module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Filtered protein FASTA file: $PROTEIN_INPUT
#   - Filtered transcript FASTA file: $TRANSCRIPT_INPUT
#
# OUTPUT:
#   - Longest protein isoforms: $OUTDIR/$PROTEIN_OUTPUT
#   - Longest transcript isoforms: $OUTDIR/$TRANSCRIPT_OUTPUT
#
# PROCESS:
#   1. Compute sequence lengths using SeqKit.
#   2. Sort by gene ID and length, and select the longest isoform per gene.
#   3. Filter the longest isoforms using SeqKit and save them to output files.
#
# NOTES:
#   - Ensure that input files exist and SeqKit is properly loaded.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=longest_isoforms
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/17_longest_isoforms_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/17_longest_isoforms_error_%j.e
#SBATCH --partition=pibu_el8

module load SeqKit/2.6.1

WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs"
OUTDIR="$WORKDIR/17_longest_isoforms"

PROTEIN_INPUT="assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
PROTEIN_OUTPUT="assembly_longest_protein_isoforms.fasta"
TRANSCRIPT_INPUT="assembly.all.maker.transcripts.fasta.renamed.filtered.fasta"
TRANSCRIPT_OUTPUT="assembly_longest_transcript_isoforms.fasta"

cd "$WORKDIR/16_final_GENE"

# Create output directories if they don't exist
mkdir -p "$OUTDIR"

# Filter to get longest proteins
# Step 1: Extract protein lengths and store in a temporary file
seqkit fx2tab -nl "$PROTEIN_INPUT" > "$OUTDIR/protein_lengths.tsv"

# Step 2: Sort by gene ID and sequence length, then select the longest isoform per gene
sort -k1,1 -k2,2nr "$OUTDIR/protein_lengths.tsv" | \
awk '{
    gene = gensub(/-RA.*/, "", "g", $1); # Adjust regex to capture gene ID prefix only
    if (gene != last_gene) {
        print $1;
        last_gene = gene;
    }
}' > "$OUTDIR/longest_proteins.txt"

# Step 3: Use `seqkit grep` to filter the longest protein isoforms and write them to the output file
seqkit grep -f "$OUTDIR/longest_proteins.txt" "$PROTEIN_INPUT" -o "$OUTDIR/$PROTEIN_OUTPUT"


# Filter to get longest transcripts
# Step 1: Extract transcript lengths and store in a temporary file
seqkit fx2tab -nl "$TRANSCRIPT_INPUT" > "$OUTDIR/transcript_lengths.tsv"

# Step 2: Sort by gene ID and sequence length, then select the longest isoform per gene
sort -k1,1 -k2,2nr "$OUTDIR/transcript_lengths.tsv" | \
awk '{
    gene = gensub(/ .*/, "", "g", $1); # Assuming a space separates gene ID in transcripts
    if (gene != last_gene) {
        print $1;
        last_gene = gene;
    }
}' > "$OUTDIR/longest_transcripts.txt"

# Step 3: Use `seqkit grep` to filter the longest transcript isoforms and write them to the output file
seqkit grep -f "$OUTDIR/longest_transcripts.txt" "$TRANSCRIPT_INPUT" -o "$OUTDIR/$TRANSCRIPT_OUTPUT"
