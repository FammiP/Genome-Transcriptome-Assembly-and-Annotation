#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script evaluates genome assembly accuracy using Merqury by generating 
#   k-mers from high-accuracy reads and comparing them to multiple genome assemblies 
#   (Flye, Hifiasm, and LJA). The output includes assembly evaluation metrics such as 
#   completeness and error rates.
#
# USAGE:
#   sbatch 09_run_merqury_evaluation.sh /path/to/high_accuracy_reads.fastq /path/to/flye.fasta /path/to/hifiasm.fasta /path/to/lja.fasta /path/to/output_directory /path/to/work_directory
# 
# READS              /data/users/fparokkaran/assembly_annotation_course/genome_assembly/read_QC/fastp/fastp_output/Nemrut-1_no_filter.fastq.gz
# FLYE_ASSEMBLY      /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta
# HIFIASM_ASSEMBLy   /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/hifiasm/hifiasm_assembly_output/Nemrut1_asm.bp.p_ctg.fa 
# LJA_ASSEMBLY       /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/lja/LJA_assembly_output/k5001/final_dbg.fasta 
# OUTPUT_DIR         /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/merqury
# WORK_DIR           /data/users/fparokkaran/assembly_annotation_course/genome_assembly/
#
# REQUIREMENTS:
#   - Merqury version 1.3 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - High-accuracy reads in FASTQ format: $READS
#   - Genome assemblies: $FLYE_ASSEMBLY, $HIFIASM_ASSEMBLY, $LJA_ASSEMBLY
#
# OUTPUT:
#   - Merqury evaluation results for each assembly in: $OUTPUT_DIR
#
# NOTES:
#   - Ensure input reads and genome assemblies are available in the specified locations.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --job-name=merqury_evaluation
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=%5/merqury/%x_%j.out
#SBATCH --error=%5/merqury/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

# This script generates new k-mers from high-accuracy reads using meryl, then runs Merqury evaluation for multiple genome assemblies (Flye, Hifiasm, LJA).
# Usage: sbatch 08_run_merqury_evaluation.sh /path/to/high_accuracy_reads.fastq /path/to/flye.fasta /path/to/hifiasm.fasta /path/to/lja.fasta /path/to/output_directory



# Input parameters
READS=$1
FLYE_ASSEMBLY=$2
HIFIASM_ASSEMBLY=$3
LJA_ASSEMBLY=$4
OUTPUT_DIR=$5
WORK_DIR=$6
# Load Merqury container
CONTAINER=/containers/apptainer/merqury_1.3.sif


# Create output directory if not present
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/logs/flye
mkdir -p $OUTPUT_DIR/logs/hifiasm
mkdir -p $OUTPUT_DIR/logs/lja

export MERQURY="/usr/local/share/merqury"


# Step 1: Generate k-mers from high-accuracy reads using meryl
apptainer exec --bind $WORK_DIR $CONTAINER meryl k=21 count $READS output ${OUTPUT_DIR}/genome.kmers.meryl  


# Step 2: Run Merqury on each genome assembly
cd $OUTPUT_DIR

# Flye Assembly
mkdir -p flye
apptainer exec --bind $WORK_DIR $CONTAINER sh $MERQURY/merqury.sh genome.kmers.meryl $FLYE_ASSEMBLY flye/out

# Hifiasm Assembly
mkdir -p hifiasm
apptainer exec --bind $WORK_DIR $CONTAINER sh $MERQURY/merqury.sh genome.kmers.meryl $HIFIASM_ASSEMBLY hifiasm/out

# LJA Assembly
mkdir -p lja
apptainer exec --bind $WORK_DIR $CONTAINER sh $MERQURY/merqury.sh genome.kmers.meryl $LJA_ASSEMBLY lja/out


