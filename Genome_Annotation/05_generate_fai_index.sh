#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script generates an FAI index file for a genome assembly in FASTA format 
#   using SAMtools. The FAI index allows for efficient random access to specific 
#   sequences or regions within the assembly.
#
# USAGE:
#   sbatch 05_generate_fai_index.sh
#
# REQUIREMENTS:
#   - SAMtools version 1.13 or higher (via the loaded module)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Genome assembly (FASTA): $ASSEMBLY
#
# OUTPUT:
#   - FAI index file in: $OUTDIR
#
# NOTES:
#   - Ensure the input FASTA file is available and properly formatted.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --job-name=fai_index
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/05_fai_index_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/05_fai_index_error_%j.e
#SBATCH --partition=pibu_el8

# Set working directory and input file
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"
ASSEMBLY="/data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta"
OUTDIR="$WORKDIR/outputs"

# Load the SAMtools module
module load SAMtools/1.13-GCC-10.3.0

# Generate the FAI index file
samtools faidx $ASSEMBLY

# Move the output FAI file to the specified output directory
FAI_FILE="${ASSEMBLY}.fai"
OUTFILE="$OUTDIR/05_$(basename $FAI_FILE)"
mkdir -p $OUTDIR
mv $FAI_FILE $OUTFILE