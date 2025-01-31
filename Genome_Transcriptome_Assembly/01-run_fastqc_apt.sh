#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs quality control checks on RNA-seq FASTQ files 
#   using FastQC. It scans all FASTQ files in the specified directory 
#   and generates reports to assess read quality, adapter content, and 
#   overall sequencing quality.
#
# USAGE:
#   sbatch 01-run_fastqc_apt.sh
#
# REQUIREMENTS:
#   - FastQC version 0.12.1 (via the specified Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - RNA-seq FASTQ files located in: $WORKDIR/RNAseq_Sha/
#
# OUTPUT:
#   - FastQC reports (HTML and zip files) in:
#     $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output
#
# NOTES:
#   - Ensure the FASTQ files are located in the specified input directory.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --job-name=fastqc
#SBATCH --time=01:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_QC/output_RNAseq_Sha_fastqc_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_QC/error_RNAseq_Sha_fastqc_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch



WORKDIR=/data/users/fparokkaran/assembly_annotation_course
mkdir -p $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastqc_output

apptainer exec \
--bind $WORKDIR \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc -t 8 -o $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastqc_output $WORKDIR/RNAseq_Sha/*.fastq.gz
