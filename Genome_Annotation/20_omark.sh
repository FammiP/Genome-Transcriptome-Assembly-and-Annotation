#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs orthologous mapping using the OMArk tool. It uses the OMA 
#   (Orthologous MAtrix) database to annotate protein sequences from MAKER gene models.
#   The results include functional annotations for the longest isoforms.
#
# USAGE:
#   sbatch 20_omark.sh
#
# REQUIREMENTS:
#   - OMA database file (LUCA.h5)
#   - Conda environment configured with OMArk and dependencies
#   - Access to a compute cluster with SLURM scheduler
#
# SETUP (Initial Steps):
#   1. Start an interactive session on the cluster:
#      ```
#      srun --time=02:00:00 --mem=4G --ntasks=1 --cpus-per-task=1 --partition=pibu_el8 --pty bash
#      ```
#   2. Load the Conda module:
#      ```
#      module load Anaconda3/2022.05
#      ```
#   3. Initialize Conda for use in the current shell:
#      ```
#      eval "$(conda shell.bash hook)"
#      ```
#   4. Create the necessary Conda environment:
#      ```
#      conda env create -f /data/courses/assembly-annotation-course/CDS_annotation/containers/OMArk.yaml
#      ```
#   5. Activate the Conda environment:
#      ```
#      conda activate OMArk
#      ```
#   6. Install additional packages within the environment:
#      ```
#      pip install omadb
#      pip install gffutils
#      ```
#
#   Future Use:
#   - To activate the environment before running this script:
#     ```
#     module load Anaconda3/2022.05
#     eval "$(conda shell.bash hook)"
#     conda activate OMArk
#     ```
#   - To deactivate the environment after use:
#     ```
#     conda deactivate
#     ```
#
# INPUT:
#   - Protein FASTA file from MAKER output: $protein
#
# OUTPUT:
#   - OMArk results in: $OUTDIR
#   - List of isoforms for each gene in: $isoform_list
#
# PROCESS:
#   1. Download the OMA database (LUCA.h5) if not already present.
#   2. Run `omamer` to search for orthologous matches.
#   3. Prepare the isoform list from the protein FASTA file.
#   4. Run OMArk to refine the functional annotations using the OMA database.
#
# NOTES:
#   - Ensure the Conda environment is activated before running this script.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --time=10:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=omark
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/20_omark_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/20_omark_error_%j.e
#SBATCH --partition=pibu_el8


module add Anaconda3/2022.05

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/16_final_GENE"
OUTDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/20_omark"

protein="$WORKDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
isoform_list="$OUTDIR/isoform_list.txt"

mkdir -p $OUTDIR
cd $OUTDIR

# Download OMA database if necessary
if [ ! -f LUCA.h5 ]; then
    wget https://omabrowser.org/All/LUCA.h5
fi

# This command uses the omamer tool to perform a search in the LUCA.h5 database with the provided protein FASTA file ($protein)
omamer search --db "LUCA.h5" --query "$protein" --out "$OUTDIR/$(basename "$protein").omamer"

# Prepare isoform list
awk '/^>/ { 
    gene = gensub(/-[A-Z]+.*/, "", "g", substr($1, 2));
    isoform = substr($1, 2);
    genes[gene] = (genes[gene] ? genes[gene] ";" : "") isoform;
} END {
    for (g in genes) print genes[g];
}' "$protein" > "$isoform_list"

# Run OMArk
omark -f "$OUTDIR/$(basename "$protein").omamer" \
      -of "$protein" \
      -i "$isoform_list" \
      -d "LUCA.h5" \
      -o "$OUTDIR"



