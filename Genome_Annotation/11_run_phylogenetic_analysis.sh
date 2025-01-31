#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs phylogenetic analysis of Copia and Gypsy RT sequences 
#   using Clustal Omega for multiple sequence alignment and FastTree for constructing 
#   phylogenetic trees. The analysis involves concatenating sequences from Arabidopsis 
#   and Brassicaceae, aligning them, and generating phylogenetic trees.
#
# USAGE:
#   sbatch 11_run_phylogenetic_analysis.sh
#
# REQUIREMENTS:
#   - Clustal Omega version 1.2.4 (via module system)
#   - FastTree version 2.1.11 (via module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - RT sequences for Copia and Gypsy from Arabidopsis and Brassicaceae: $INPUT_DIR
#
# OUTPUT:
#   - Concatenated RT sequences: $OUTDIR
#   - Aligned sequences: $OUTDIR_CLUSTALO
#   - Phylogenetic trees: $OUTDIR_FAST_TREE
#
# PROCESS:
#   1. Concatenate Copia and Gypsy RT sequences.
#   2. Clean sequence headers to avoid downstream issues.
#   3. Align sequences using Clustal Omega.
#   4. Construct phylogenetic trees using FastTree.
#
# NOTES:
#   - Ensure input RT sequence files are available in the specified directory.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=phylogenetic_analysis
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/11_phylogenetic_analysis_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/11_phylogenetic_analysis_error_%j.e
#SBATCH --partition=pibu_el8

module load Clustal-Omega/1.2.4-GCC-10.3.0
module load FastTree/2.1.11-GCCcore-10.3.0

# Set paths
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"
INPUT_DIR="$WORKDIR/outputs/10_rt_sequences"
OUTDIR="$WORKDIR/outputs/11_phylogenetic_analysis"
OUTDIR_CLUSTALO="$OUTDIR/clustal_omega"
OUTDIR_FAST_TREE="$OUTDIR/fast_tree"

mkdir -p $OUTDIR $OUTDIR_CLUSTALO $OUTDIR_FAST_TREE

# For Copia and Gypsy RT sequences
for FAMILY in "copia" "gypsy"; do
    # Concatenate RT sequences
    cat "$INPUT_DIR/${FAMILY}_RT_arabidopsis.fasta" "$INPUT_DIR/${FAMILY}_RT_brassicaceae.fasta" > "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    
    # Clean identifiers
    # This line is from the tutorial
    sed -i 's/#.\+//' "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    # Remove everything after the "|" character to shorten the header
    sed -i 's/|.\+//' "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    # This line is from the tutorial: replace ":" with "_" to avoid issues with special characters (like ":" or "|") in downstream tools
    sed -i 's/:/_/g' "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    
    # Extract headers from the FASTA file and check for duplicates
    DUPLICATES=$(grep "^>" "$OUTDIR/${FAMILY}_concatenated_RT.fasta" | sort | uniq -d)
    if [ -n "$DUPLICATES" ]; then
        echo "Duplicate headers found for $FAMILY:"
        echo "$DUPLICATES"
    else
        echo "No duplicate headers found for $FAMILY."
    fi

    # Align sequences
    clustalo -i "$OUTDIR/${FAMILY}_concatenated_RT.fasta" -o "$OUTDIR_CLUSTALO/${FAMILY}_aligned_RT.fasta" --outfmt fasta
    # Check if clustalo succeeded
    if [ $? -eq 0 ]; then
        echo "Clustal-Omega alignment successful for $FAMILY."
    else
        echo "Error: Clustal-Omega alignment failed for $FAMILY."
        break
    fi

    # Infer phylogenetic tree
    FastTree -out "$OUTDIR_FAST_TREE/${FAMILY}_phylogenetic_tree.tree" "$OUTDIR_CLUSTALO/${FAMILY}_aligned_RT.fasta"
    # Check if FastTree construction was successful
    if [ $? -eq 0 ]; then
        echo "FastTree phylogenetic tree construction successful for $FAMILY."
    else
        echo "Error: FastTree phylogenetic tree construction failed for $FAMILY."
        break
    fi
    
done

echo "Phylogenetic analysis completed."
