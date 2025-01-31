#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script extracts Copia and Gypsy transposable element (TE) sequences 
#   from an EDTA-generated TE library using SeqKit, and classifies them into 
#   their respective clades using TEsorter. The results are saved in dedicated 
#   output directories for Copia and Gypsy sequences.
#
# USAGE:
#   sbatch 07_classify_copia_gypsy_tesorter.sh
#
# REQUIREMENTS:
#   - SeqKit version 2.6.1 (via module system)
#   - TEsorter version 1.3.0 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - EDTA TE library (FASTA): $INPUT_FILE
#
# OUTPUT:
#   - Classified Copia TE sequences: $OUTDIR_COPIA
#   - Classified Gypsy TE sequences: $OUTDIR_GYPSY
#
# NOTES:
#   - Ensure the input TE library file is available in the specified location.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --job-name=copia_gypsy_tesorter
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/07_copia_gypsy_tesorter_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/07_te_copia_gypsy_tesorter_error_%j.e
#SBATCH --partition=pibu_el8

# Load the SeqKit module (for sequence manipulation)
module load SeqKit/2.6.1

# Set up working directories for input files and output results
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"
OUTDIR_COPIA="$WORKDIR/outputs/07_tesorter_copia"
OUTDIR_GYPSY="$WORKDIR/outputs/07_tesorter_gypsy"
CONTAINER="/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif"
INPUT_FILE="$WORKDIR/outputs/01_EDTA/assembly.fasta.mod.EDTA.TElib.fa"

# Create directory to save outputs
mkdir -p $OUTDIR_COPIA $OUTDIR_GYPSY
cd $WORKDIR

# Extract Copia sequences from the EDTA TE library using SeqKit
seqkit grep -r -p "Copia" $INPUT_FILE > $OUTDIR_COPIA/copia_sequences.fa
# Extract Gypsy sequences from the EDTA TE library using SeqKit
seqkit grep -r -p "Gypsy" $INPUT_FILE > $OUTDIR_GYPSY/gypsy_sequences.fa

# Run TEsorter for Copia sequences using the Apptainer container
apptainer exec -C -H $WORKDIR \
  --writable-tmpfs -u $CONTAINER  \
  TEsorter $OUTDIR_COPIA/copia_sequences.fa -db rexdb-plant
# Move the classified Copia output files to the appropriate directory
mv copia_sequences.fa.rexdb-plant.* $OUTDIR_COPIA

# Run TEsorter for Gypsy sequences using the Apptainer container
apptainer exec -C -H $WORKDIR \
  --writable-tmpfs -u $CONTAINER  \
  TEsorter $OUTDIR_GYPSY/gypsy_sequences.fa -db rexdb-plant
# Move the classified Gypsy output files to the appropriate directory
mv gypsy_sequences.fa.rexdb-plant.* $OUTDIR_GYPSY