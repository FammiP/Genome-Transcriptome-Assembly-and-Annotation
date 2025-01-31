#!/bin/bash

#================================================================
# DESCRIPTION:
#   This script prepares files and directories for running the 
#   GeneSpace pipeline by processing genome annotations and 
#   protein sequences. It performs the following tasks:
#   1. Filters gene annotations to include only the top 20 largest scaffolds.
#   2. Creates BED files for the filtered annotations.
#   3. Prepares a peptide FASTA file by filtering proteins for the top scaffolds.
#   4. Copies required reference files to the output directory.
#
# USAGE:
#   sbatch 22_create_genespace_folders.sh
#
# REQUIREMENTS:
#   - R and the following R libraries: `data.table`, `tidyverse`
#   - Input files (gene annotation GFF3, FASTA index file, protein sequences)
#
# OUTPUT:
#   - Filtered BED file for GeneSpace input.
#   - Filtered peptide FASTA file for GeneSpace input.
#
# NOTES:
#   - Edit the `ACCESSION_NAME` variable appropriately for each dataset.
#   - Choose the appropriate section (first or second accession) by uncommenting the relevant block.
#================================================================

#SBATCH --time=05:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=genespace_folders
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/22_genespace_folders_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/22_genespace_folders_error_%j.e
#SBATCH --partition=pibu_el8

# Load R module
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2
module load MariaDB/10.6.4-GCC-10.3.0
module load UCSC-Utils/448-foss-2021a

# Set working directory and file paths
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs"
R_SCRIPT="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/scripts/22_create_genespace_folders.R"
OUTDIR="$WORKDIR/22_genespace"

# ############################################################################################
# # FIRST ACCESSION - Uncomment the following block if you want to process the first accession. 
# ############################################################################################

# ANNO_FILE="$WORKDIR/16_final_GENE/filtered.genes.renamed.final.gff3"
# FASTA_FAI="$WORKDIR/05_assembly.fasta.fai"
# LONGEST_PROTEINS="$WORKDIR/17_longest_isoforms/assembly_longest_protein_isoforms.fasta"

# # Replace this with the desired accession name. 
# # Use only alphanumeric characters, underscores (_), or dots (.), and avoid spaces, hyphens (-), or other special characters.
# ACCESSION_NAME="Nemrut_1" 

-------------------------------------------------------------------------------------------


###############################################################################################
# SECOND ACCESSION - Uncomment the following block if you want to process the second accession. 
###############################################################################################

# Be sure to comment out the first accession block.
# Set working directory and file paths for the second accession. 
ANNO_FILE="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/16_final_GENE/filtered.genes.renamed.final.gff3"
FASTA_FAI="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/05_assembly.fasta.fai"
LONGEST_PROTEINS="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/17_longest_isoforms/assembly_longest_protein_isoforms.fasta"

# Replace this with the desired accession name. 
# Use only alphanumeric characters, underscores (_), or dots (.), and avoid spaces, hyphens (-), or other special characters.
ACCESSION_NAME="Qar_8a"

# # ---------------------------------------------------------------------------------------------


# Prepare directories2
mkdir -p "$OUTDIR"
mkdir -p "$OUTDIR/bed"
mkdir -p "$OUTDIR/peptide"
cd $OUTDIR

# Export variables to be used in R script
export WORKDIR="$WORKDIR"
export OUTDIR="$OUTDIR"
export ANNO_FILE="$ANNO_FILE"
export FASTA_FAI="$FASTA_FAI"
export LONGEST_PROTEINS="$LONGEST_PROTEINS"
export ACCESSION_NAME="$ACCESSION_NAME"

# Run the R script
Rscript $R_SCRIPT

# Confirmation
echo "GeneSpace preparation completed successfully. Outputs are saved in $OUTDIR."
