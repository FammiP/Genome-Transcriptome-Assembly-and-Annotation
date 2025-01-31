#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   21_refine_gene_annotation.sh
#
# DESCRIPTION:
#   This script refines gene annotations by leveraging Hierarchical Orthologous 
#   Groups (HOGs) to identify and correct fragmented or missing gene models. 
#   It performs the following tasks:
#   1. Extracts sequences of conserved HOGs for fragmented gene models.
#   2. Extracts sequences of conserved HOGs for missing gene models.
#   3. Maps the HOG sequences to the genome using MiniProt for annotation refinement.
#   4. Outputs two separate GFF files for visualization and comparison of gene models.
#
# USAGE:
#   sbatch 21_refine_gene_annotation.sh
#
#   IMPORTANT!
#   Ensure you submit this script while in the OMArk conda environment that you created to run OMArk.
#   If you haven't set up the environment yet, refer to the previous script (20_omark.sh) for guidance.
#   If you have already created it, make sure it is activated before running the script.
#
# SETUP (Activating Conda Environment):
#   1. Start an interactive session (only needed for initial setup):
#      ```
#      srun --time=02:00:00 --mem=4G --ntasks=1 --cpus-per-task=1 --partition=pibu_el8 --pty bash
#      ```
#   2. Load the Conda module:
#      ```
#      module load Anaconda3/2022.05
#      ```
#   3. Initialize Conda:
#      ```
#      eval "$(conda shell.bash hook)"
#      ```
#   4. Activate the OMArk environment:
#      ```
#      conda activate OMArk
#      ```
#
#   After finishing your work, deactivate the environment with:
#      ```
#      conda deactivate
#      ```
#
# INPUT:
#   - Genome FASTA file: $GENOMIC_FASTA
#   - OMAMER output file containing orthologous group mappings: $OMAMER_FILE
#
# OUTPUT:
#   - GFF files containing MiniProt mappings for fragmented and missing gene models
#   - Log files with MiniProt mapping outputs
#
# REQUIREMENTS:
#   - The script `omark_contextualize.py` must be located in the `scripts` directory
#     or accessible via the PATH. You can find it at:
#     /data/courses/assembly-annotation-course/CDS_annotation/softwares/OMArk-0.3.0/utils
#
#   - MiniProt binary must be available at $MINIPROT_PATH.
#
# NOTES:
#   - Update all file paths to match your specific file system and input data locations.
#================================================================

#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=refine_annotation
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/21_refine_annotation_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/21_refine_annotation_error_%j.e
#SBATCH --partition=pibu_el8

# Set paths and directories
WORKDIR="/data/users/fparokkaran/assembly_annotation_course"
GENOMIC_FASTA="$WORKDIR/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta" 
OMAMER_FILE="$WORKDIR/genome_annotation/outputs/20_omark/assembly.all.maker.proteins.fasta.renamed.filtered.fasta.omamer"
OUTPUT_DIR="$WORKDIR/genome_annotation/outputs/21_miniprot"
FRAGMENTED_HOGS="$OUTPUT_DIR/fragment_HOGs"
MISSING_HOGS="$OUTPUT_DIR/missing_HOGs"

MINIPROT_PATH="/data/courses/assembly-annotation-course/CDS_annotation/containers/miniprot_conda/bin"
MINIPROT_OUTPUT="$OUTPUT_DIR/miniprot_output.gff"


# Create output directory
mkdir -p $OUTPUT_DIR


# Extract HOGs for fragmented gene models
echo "Extracting fragmented HOG sequences..."
python omark_contextualize.py fragment -m $OMAMER_FILE -o $WORKDIR/genome_annotation/outputs/20_omark -f $FRAGMENTED_HOGS
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract fragmented HOG sequences."
    exit 1
fi

# Extract HOGs for missing gene models
echo "Extracting missing HOG sequences..."
python omark_contextualize.py missing -m $OMAMER_FILE -o $WORKDIR/genome_annotation/outputs/20_omark -f $MISSING_HOGS
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract missing HOG sequences."
    exit 1
fi

# Run MiniProt for fragmented HOGs
echo "Running MiniProt for fragmented HOGs..."
MINIPROT_OUTPUT_FRAG="$OUTPUT_DIR/miniprot_fragmented.gff"
$MINIPROT_PATH/miniprot -I --gff --outs=0.95 "${GENOMIC_FASTA}" "${FRAGMENTED_HOGS}" > "${MINIPROT_OUTPUT_FRAG}"
if [ $? -ne 0 ]; then
    echo "Error: MiniProt mapping for fragmented HOGs failed."
    exit 1
fi
echo "MiniProt mapping for fragmented HOGs completed. Output saved to ${MINIPROT_OUTPUT_FRAG}"

# Run MiniProt for missing HOGs
echo "Running MiniProt for missing HOGs..."
MINIPROT_OUTPUT_MISS="$OUTPUT_DIR/miniprot_missing.gff"
$MINIPROT_PATH/miniprot -I --gff --outs=0.95 "${GENOMIC_FASTA}" $OUTPUT_DIR/missing_HOGs.fa > "${MINIPROT_OUTPUT_MISS}"
if [ $? -ne 0 ]; then
    echo "Error: MiniProt mapping for missing HOGs failed."
    exit 1
fi
echo "MiniProt mapping for missing HOGs completed. Output saved to ${MINIPROT_OUTPUT_MISS}"


echo "Gene annotation refinement completed. Use genome visualization tools like JBrowse 2 or Geneious to view the GFF file and compare the mappings."
exit 0
