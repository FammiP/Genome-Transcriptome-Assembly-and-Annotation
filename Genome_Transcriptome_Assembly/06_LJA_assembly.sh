#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs genome assembly using LJA (Long-Read de Bruijn Assembler) 
#   on PacBio or long-read sequencing data. The assembly results and logs are 
#   stored in the specified output directory.
#
# USAGE:
#   sbatch 06_LJA_assembly.sh
#
# REQUIREMENTS:
#   - LJA version 0.2 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Long-read sequencing FASTQ file: $READS
#
# OUTPUT:
#   - Genome assembly results in: $OUTDIR
#
# NOTES:
#   - Ensure the input reads are properly filtered and available in the specified location.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=LJA_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_LJA/out_LJA_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_LJA/err_LJA_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

# Load LJA container and set up working directories
WORKDIR=/data/users/fparokkaran/assembly_annotation_course/genome_assembly
READS=$WORKDIR/read_QC/fastp/fastp_output/Nemrut-1_no_filter.fastq.gz   # Input file
OUTDIR=$WORKDIR/assemblies/lja/LJA_assembly_output  # Output directory for LJA
# Create output directory if not already present
mkdir -p $OUTDIR

# Run LJA assembly
apptainer exec \
--bind $WORKDIR \
/containers/apptainer/lja-0.2.sif \
lja -o $OUTDIR --reads  $READS --diploid
