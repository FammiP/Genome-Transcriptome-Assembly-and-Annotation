#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs k-mer counting and histogram generation using Jellyfish. 
#   It processes paired-end and single-end RNA-seq data to generate k-mer frequency 
#   distributions, which can be used for genome size estimation and assembly analysis.
#
# USAGE:
#   sbatch 03_kmer_count.sh
#
# REQUIREMENTS:
#   - Jellyfish version 2.3.0 (loaded via the module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Filtered FASTQ files from: $WORKDIR/genome_assembly/read_QC/fastqc/fastp_output/
#
# OUTPUT:
#   - K-mer count files in: $WORKDIR/kmer_countingkmer_output/
#   - K-mer histograms in: $WORKDIR/kmer_counting/kmer_output/
# 
# NOTES:
#   - Ensure that the input FASTQ files are generated and available in the specified directory.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=kmer_count_analysis
#SBATCH --time=02:00:00
#SBATCH --mem=50G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_kmer/output_kmer_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_kmer/error_kmer_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

module load Jellyfish/2.3.0-GCC-10.3.0

WORKDIR=/data/users/fparokkaran/assembly_annotation_course/genome_assembly

mkdir -p $WORKDIR/kmer_counting/kmer_output

### K-mer counting on RNAseq_Sha (Paired-End) ###
jellyfish count -C -m 21 -s 5G -t 4 \
    -o $WORKDIR/read_QC/kmer_counting/kmer_output/RNAseq_Sha_kmer_count.jf \
    <(zcat $WORKDIR/read_QC/fastp/fastp_output/RNAseq_Sha_R1_filtered.fastq.gz) \
    <(zcat $WORKDIR/read_QC/fastp/fastp_output/RNAseq_Sha_R2_filtered.fastq.gz)

### K-mer counting on Nemrut-1 (Single-End) ###
jellyfish count -C -m 21 -s 5G -t 4 \
    -o $WORKDIR/kmer_counting/kmer_output/Nemrut-1_kmer_count.jf \
    <(zcat $WORKDIR/read_QC/fastp/fastp_output/Nemrut-1_no_filter.fastq.gz)


### Generate k-mer histogram for RNAseq_Sha
jellyfish histo -t 4 $WORKDIR/kmer_counting/kmer_output/RNAseq_Sha_kmer_count.jf > $WORKDIR/kmer_counting/kmer_output/RNAseq_Sha_kmer_histogram.txt

### Generate k-mer histogram for Nemrut-1
jellyfish histo -t 4 $WORKDIR/kmer_counting/kmer_output/Nemrut-1_kmer_count.jf > $WORKDIR/kmer_counting/kmer_output/Nemrut-1_kmer_histogram.txt
