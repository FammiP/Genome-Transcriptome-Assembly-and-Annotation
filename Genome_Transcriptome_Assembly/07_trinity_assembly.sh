#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs de novo transcriptome assembly using Trinity on 
#   paired-end RNA-seq reads. The assembled transcriptome and logs are 
#   stored in the specified output directory.
#
# USAGE:
#   sbatch 07_trinity_assembly.sh 
#
# REQUIREMENTS:
#   - Trinity version 2.15.1 (via module system)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Filtered paired-end RNA-seq reads: $READS_R1 and $READS_R2
#
# OUTPUT:
#   - Assembled transcriptome in: $OUTDIR
#
# NOTES:
#   - Ensure the input reads are properly filtered and available in the specified locations.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --job-name=Trinity_assembly
#SBATCH --time=2-00:00:00   
#SBATCH --mem=128G          
#SBATCH --cpus-per-task=16  
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_trinity/out_trinity_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_trinity/err_trinity_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

# Load the Trinity module
module load Trinity/2.15.1-foss-2021a

# Set up working directories and input files
WORKDIR=/data/users/fparokkaran/assembly_annotation_course/genome_assembly
READS_R1=$WORKDIR/read_QC/fastp/fastp_output/RNAseq_Sha_R1_filtered.fastq.gz  # Input RNA-seq read 1
READS_R2=$WORKDIR/read_QC/fastp/fastp_output/RNAseq_Sha_R2_filtered.fastq.gz  # Input RNA-seq read 2
OUTDIR=$WORKDIR/assemblies/Trinity/trinity_assembly_output  # Output directory for Trinity

# Create output directory if it does not exist
mkdir -p $OUTDIR

# Run Trinity for paired-end reads
Trinity --seqType fq --max_memory 128G --CPU 16 \
        --left $READS_R1 --right $READS_R2 \
        --output $OUTDIR
