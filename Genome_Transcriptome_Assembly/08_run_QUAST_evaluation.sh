#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script evaluates genome assembly quality using QUAST. It compares multiple 
#   genome assemblies (Flye, Hifiasm, and LJA) either with or without a reference 
#   genome and produces summary reports on assembly metrics.
#
# USAGE:
#   sbatch 10_run_quast_assembly_evaluation.sh /path/to/flye_assembly.fasta /path/to/hifiasm_assembly.fasta /path/to/lja_assembly.fasta /path/to/output_directory [--with-reference]
#
    # flye path:  /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta 
    # hifiasm path:  /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/hifiasm/hifiasm_assembly_output/Nemrut1_asm.bp.p_ctg.fa 
    # lja path:  /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/lja/LJA_assembly_output/k5001/final_dbg.fasta 
    # output_directory_with_reference = /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/QUAST/Evaluation_with_reference_genome
    # output_directory_without_reference = /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assembly_evaluation/QUAST/Evaluation_without_reference_genome
#
# REQUIREMENTS:
#   - QUAST version 5.2.0 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Genome assemblies: $FLYE_ASSEMBLY, $HIFIASM_ASSEMBLY, $LJA_ASSEMBLY
#   - Optional reference genome: Arabidopsis thaliana (if --with-reference is specified)
#
# OUTPUT:
#   - Assembly evaluation reports in: $OUTPUT_DIR
#
# NOTES:
#   - Ensure input assemblies and the optional reference genome are available in the specified locations.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=quast_assembly_evaluation
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch


# Load the QUAST container
CONTAINER=/containers/apptainer/quast_5.2.0.sif

# Input parameters
FLYE_ASSEMBLY=$1        
HIFIASM_ASSEMBLY=$2     
LJA_ASSEMBLY=$3        
OUTPUT_DIR=$4           
REFERENCE=$5            # --with-reference if you want to run with the Arabidopsis reference

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Run QUAST without reference by default
if [[ "$REFERENCE" == "--with-reference" ]]; then
    # Run QUAST with the Arabidopsis reference genome and annotation
    apptainer exec $CONTAINER quast.py \
        $FLYE_ASSEMBLY \
        $HIFIASM_ASSEMBLY \
        $LJA_ASSEMBLY \
        -r /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
        -o $OUTPUT_DIR \
        --threads 16
else
    # Run QUAST without a reference genome
    apptainer exec $CONTAINER quast.py \
        $FLYE_ASSEMBLY \
        $HIFIASM_ASSEMBLY \
        $LJA_ASSEMBLY \
        -o $OUTPUT_DIR \
        --threads 16
fi

