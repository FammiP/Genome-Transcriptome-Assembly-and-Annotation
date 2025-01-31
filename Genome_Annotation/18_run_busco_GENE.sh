#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script runs BUSCO (Benchmarking Universal Single-Copy Orthologs) to assess 
#   the completeness of gene annotations based on the longest protein and transcript 
#   isoforms derived from the MAKER pipeline. BUSCO compares the input sequences 
#   against a lineage-specific ortholog dataset.
#
# USAGE:
#   sbatch 18_run_busco_GENE.sh 
#
# REQUIREMENTS:
#   - BUSCO version 5.4.2 (via module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Longest protein isoforms: $PROTEIN_FILE
#   - Longest transcript isoforms: $TRANSCRIPT_FILE
#   - Lineage dataset: $LINEAGE
#
# OUTPUT:
#   - BUSCO results for proteins and transcripts in $OUTDIR
#
# PROCESS:
#   1. Create the output directory if it doesn’t exist.
#   2. Run BUSCO on longest protein isoforms.
#   3. Run BUSCO on longest transcript isoforms.
#   4. Review key output files (e.g., short_summary.txt, full_table.tsv).
#
# NOTES:
#   - Ensure that BUSCO is properly loaded and lineage datasets are available.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --cpus-per-task=50
#SBATCH --mem=20G
#SBATCH --time=4:00:00
#SBATCH --job-name=busco_annotation
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/18_busco_annotation_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/18_busco_annotation_error_%j.e
#SBATCH --partition=pibu_el8

module load BUSCO/5.4.2-foss-2021a

# User-defined variables
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
OUTDIR="$WORKDIR/18_busco_GENE"
PROTEIN_FILE="$WORKDIR/17_longest_isoforms/assembly_longest_protein_isoforms.fasta"
TRANSCRIPT_FILE="$WORKDIR/17_longest_isoforms/assembly_longest_transcript_isoforms.fasta"
LINEAGE="brassicales_odb10"  # Specify lineage dataset (e.g., embryophyta_odb10)

mkdir -p $OUTDIR
cd $OUTDIR

# Remember to get the longest isoform from the maker annotation

busco \
    -i $PROTEIN_FILE \
    -l $LINEAGE \
    -o maker_proteins \
    -m proteins \
    --cpu 50 \
    --download_path $OUTDIR \
    --force

busco \
    -i $TRANSCRIPT_FILE \
    -l $LINEAGE \
    -o maker_transcripts \
    -m transcriptome \
    --cpu 50 \
    --download_path $OUTDIR \
    --force

