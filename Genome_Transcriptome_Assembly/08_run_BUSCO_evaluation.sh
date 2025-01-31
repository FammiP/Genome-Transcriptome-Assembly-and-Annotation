#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script evaluates the completeness of genome or transcriptome assemblies 
#   using BUSCO. It automatically determines the optimal lineage dataset and 
#   outputs a summary of assembly quality.
#
# USAGE:
#   sbatch 08_run_BUSCO_evaluation.sh /path/to/assembly.fasta /path/to/output_folder
#
#   flye path: sbatch 08_run_BUSCO_evaluation.sh /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/BUSCO/flye/flye_busco_output
#   hifiasm path: sbatch 08_run_BUSCO_evaluation.sh /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/hifiasm/hifiasm_assembly_output/Nemrut1_asm.bp.p_ctg.fa /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/BUSCO/hifiasm/hifiasm_busco_output
#   lja path: sbatch 08_run_BUSCO_evaluation.sh /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/lja/LJA_assembly_output/k5001/final_dbg.fasta /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/BUSCO/LJA/lja_busco_output
#   trinity path: sbatch 08_run_BUSCO_evaluation.sh /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/Trinity/trinity_assembly_output.Trinity.fasta /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/BUSCO/Trinity/trinity_busco_output -m transcriptome --auto-lineage -f
#
# REQUIREMENTS:
#   - BUSCO version 5.7.1 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Assembly file (FASTA format): $ASSEMBLY
#   - Optional lineage dataset (default: auto-lineage)
#
# OUTPUT:
#   - BUSCO evaluation results in: $OUTDIR
#
# NOTES:
#   - Ensure that the input assembly file is properly formatted and accessible.
#   - Use the transcriptome mode for RNA-seq assemblies or genome mode for genome assemblies.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=busco_assembly_evaluation
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch


# Load BUSCO container
CONTAINER=/containers/apptainer/busco_5.7.1.sif

# Input parameters
ASSEMBLY=$1        # path to the input assembly file 
OUTDIR=$2          # path to the output directory
LINEAGE=${3:-brassicales_odb10}  # lineage dataset (default: brassicales_odb10)

# Create output directory if not already present
mkdir -p $OUTDIR

# # Run BUSCO - comment this out when you need to run Busco for transcriptome
# apptainer exec $CONTAINER busco \
#     -i $ASSEMBLY \
#     -l $LINEAGE \
#     -o $OUTDIR \
#     -m genome \
#     --cpu 16 

# Run BUSCO transcriptome 
apptainer exec $CONTAINER busco \
    -i $ASSEMBLY \
    --auto-lineage \
    -o $OUTDIR \
    -m transcriptome \
    --cpu 16 \
    -f

