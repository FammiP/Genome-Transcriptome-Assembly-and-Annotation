#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script generates color strip and simple bar template files for visualizing 
#   transposable element (TE) families in iTOL (Interactive Tree of Life). It processes 
#   RT sequence classifications for Copia and Gypsy families from Arabidopsis and Brassicaceae, 
#   assigns colors based on family types, and combines TE family counts for visualization.
#
# USAGE:
#   sbatch 12_generate_color_strip_template.sh
#
# REQUIREMENTS:
#   - curl for downloading iTOL templates
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Copia and Gypsy classification files: $COPIA_ARA, $COPIA_BRA, $GYPSY_ARA, $GYPSY_BRA
#   - TE family summary file: $SUMMARY_DIR
#
# OUTPUT:
#   - Color strip template for iTOL: $OUTPUT_FILE_COLOR
#   - Simple bar template for iTOL: $OUTPUT_FILE_SIMPLEBAR
#
# PROCESS:
#   1. Download iTOL dataset templates.
#   2. Assign colors to each Copia and Gypsy family using predefined color mappings.
#   3. Append classified RT sequences with their corresponding colors.
#   4. Create a simple bar chart template for iTOL using TE family counts.
#
# NOTES:
#   - Ensure input classification files and summary files are available in the specified locations.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=color_strip_template
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/12_color_strip_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/12_color_strip_error_%j.e
#SBATCH --partition=pibu_el8

# Directories
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/annotation/"
COLOR_DIR="$WORKDIR/outputs/12_color_strip"
OUTPUT_FILE_COLOR="$COLOR_DIR/dataset_color_strip_template.txt"
OUTPUT_FILE_SIMPLEBAR="$COLOR_DIR/dataset_simplebar_template.txt"

GYPSY_ARA="$WORKDIR/outputs/07_tesorter_gypsy/gypsy_sequences.fa.rexdb-plant.cls.tsv"
COPIA_ARA="$WORKDIR/outputs/07_tesorter_copia/copia_sequences.fa.rexdb-plant.cls.tsv"

GYPSY_BRA="$WORKDIR/outputs/10_rt_sequences/tesorter_gypsy_brassicaceae/gypsy_sequences_brassicaceae.fa.rexdb-plant.cls.tsv"
COPIA_BRA="$WORKDIR/outputs/10_rt_sequences/tesorter_copia_brassicaceae/copia_sequences_brassicaceae.fa.rexdb-plant.cls.tsv"

SUMMARY_DIR="$WORKDIR/outputs/01_EDTA/assembly.fasta.mod.EDTA.TEanno.sum"

# Create output directory if it doesn't exist
mkdir -p $COLOR_DIR
cd $COLOR_DIR

# Download the templates
curl -o "$OUTPUT_FILE_COLOR" https://itol.embl.de/help/dataset_color_strip_template.txt
curl -o "$OUTPUT_FILE_SIMPLEBAR" https://itol.embl.de/help/dataset_simplebar_template.txt

# Append custom content
cat <<EOF >> $OUTPUT_FILE_COLOR
DATA

# Process COPIA families
EOF

declare -A COPIA_CLASSES=(
    ["Ale"]="#1f77b4"       # Blue
    ["Alesia"]="#ff7f0e"    # Orange
    ["Angela"]="#2ca02c"    # Green
    ["Bianca"]="#d62728 "    # Red
    ["Clade"]="#9467bd"     # Purple
    ["Ikeros"]="#8c564b"    # Brown
    ["Ivana"]="#e377c2"     # Pink
    ["SIRE"]="#7f7f7f "      # Gray
    ["TAR"]="#bcbd22"       # Olive
    ["Tork"]="#17becf"      # Teal
)

for CLASS in "${!COPIA_CLASSES[@]}"; do
    grep -h -e "$CLASS" $COPIA_ARA $COPIA_BRA | \
        cut -f 1 | sed -e 's/:/_/' -e 's/#.*//' -e "s/$/ ${COPIA_CLASSES[$CLASS]} $CLASS/" >> $OUTPUT_FILE_COLOR
done

cat <<EOF >> $OUTPUT_FILE_COLOR
# Process GYPSY families
EOF

declare -A GYPSY_CLASSES=(
    ["Athila"]="#1f77b4"    # Blue
    ["Clade"]="#ff7f0e"     # Orange
    ["CRM"]="#2ca02c"       # Green
    ["Galadriel"]="#d62728" # Red
    ["Reina"]="#9467bd"     # Purple
    ["Retand"]="#8c564b"    # Brown
    ["Tekay"]="#e377c2"     # Pink
    ["unknown"]="#7f7f7f"   # Gray
)

for CLASS in "${!GYPSY_CLASSES[@]}"; do
    grep -h -e "$CLASS" $GYPSY_ARA $GYPSY_BRA | \
        cut -f 1 | sed -e 's/:/_/' -e 's/#.*//' -e "s/$/ ${GYPSY_CLASSES[$CLASS]} $CLASS/" >> $OUTPUT_FILE_COLOR
done

# Create the counts file
tail -n +31 "$SUMMARY_DIR" | head -n -49 | awk '{print $1 "," $2}' > counts.txt

cat counts.txt >> $OUTPUT_FILE_SIMPLEBAR