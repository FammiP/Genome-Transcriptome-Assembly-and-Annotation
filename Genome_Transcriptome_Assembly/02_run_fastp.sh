#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs quality control and filtering of RNA-seq reads 
#   using Fastp. It processes paired-end and single-end FASTQ files, 
#   filters low-quality reads, trims adapters, and generates summary 
#   reports in HTML and JSON formats.
#
# USAGE:
#   sbatch 02_run_fastp.sh
#
# REQUIREMENTS:
#   - Fastp version 0.23.4 (loaded via the module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - RNA-seq FASTQ files located in: $WORKDIR/RNAseq_Sha/ and $WORKDIR/Nemrut-1/
#
# OUTPUT:
#   - Filtered FASTQ files in: 
#     $WORKDIR/genome_assembly/read_QC/fastqc/fastp_output/
#   - Fastp quality reports in both HTML and JSON formats
#
# NOTES:
#   - Ensure input FASTQ files are available in the specified directories.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=fastp_analysis
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_fastp/output_fastp_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_fastp/error_fastp_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

module load fastp/0.23.4-GCC-10.3.0

WORKDIR="/data/users/fparokkaran/assembly_annotation_course"

mkdir -p $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output


fastp -i $WORKDIR/RNAseq_Sha/ERR754081_1.fastq.gz -I $WORKDIR/RNAseq_Sha/ERR754081_2.fastq.gz -o $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output/RNAseq_Sha_R1_filtered.fastq.gz -O $WORKDIR/fastp_output/RNAseq_Sha_R2_filtered.fastq.gz --html $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output/RNAseq_Sha_fastp_report.html --json $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output/RNAseq_Sha_fastp_report.json --thread 4 --detect_adapter_for_pe -q 15 -l 50   

                                


fastp -i $WORKDIR/Nemrut-1/ERR11437351.fastq.gz -o $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output/Nemrut-1_no_filter.fastq.gz --html $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output/Nemrut-1_fastp_report.html --json $WORKDIR/genome_assembly/read_QC/fastqc/fastqc_output/fastp_output/Nemrut-1_fastp_report.json --thread 4 -A -L -Q                               
                         
