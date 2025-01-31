#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs genome assembly using Flye on PacBio HiFi reads. 
#   It generates a draft genome assembly and stores the results in the 
#   specified output directory.
#
# USAGE:
#   sbatch 04_flye_assembly.sh
#
# REQUIREMENTS:
#   - Flye version 2.9.5 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - PacBio HiFi FASTQ file: $READS
#
# OUTPUT:
#   - Draft genome assembly and logs in: $OUTDIR
#
# NOTES:
#   - Ensure the input reads are properly filtered and available in the specified location.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --job-name=Flye_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_flye/out_flye_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_flye/err_flye_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

# Load Flye container and set up working directories
WORKDIR=/data/users/fparokkaran/assembly_annotation_course/genome_assembly
READS=$WORKDIR/read_QC/fastp/fastp_output/Nemrut-1_no_filter.fastq.gz   # Input file
OUTDIR=$WORKDIR/assemblies/flye/flye_assembly_output  # Output directory for Flye
# Create output directory if not already present
mkdir -p $OUTDIR

# Run Flye assembly
apptainer exec /containers/apptainer/flye_2.9.5.sif \
flye --pacbio-hifi $READS --out-dir $OUTDIR --threads 16

