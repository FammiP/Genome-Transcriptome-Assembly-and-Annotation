#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script compares genome assemblies using NUCmer and MUMmerplot. 
#   It is designed to run as an array job, where each task performs pairwise 
#   comparisons between a genome assembly and a reference genome or another 
#   assembly. The output includes alignment plots and summaries.
#
# USAGE:
#   sbatch 09_comparing_genomes.sh /path/to/flye.fasta /path/to/hifiasm.fasta /path/to/lja.fasta /path/to/reference_genome.fasta /path/to/output_directory
#   sbatch 09_comparing_genomes.sh /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/hifiasm/hifiasm_assembly_output/Nemrut1_asm.bp.p_ctg.fa /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/lja/LJA_assembly_output/k5001/final_dbg.fasta /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa /data/users/fparokkaran/assembly_annotation_course/genome_assembly/comparing_genomes
#
    # flye path:     /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta 
    # hifiasm path:  /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/hifiasm/hifiasm_assembly_output/Nemrut1_asm.bp.p_ctg.fa 
    # lja path:      /data/users/fparokkaran/assembly_annotation_course/genome_assembly/assemblies/lja/LJA_assembly_output/k5001/final_dbg.fasta 
    # ref_genome:    /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
    # OUTPUT_DIR     /data/users/fparokkaran/assembly_annotation_course/genome_assembly/comparing_genomes
#
# REQUIREMENTS:
#   - MUMmer version 4 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Genome assemblies: $FLYE_ASSEMBLY, $HIFIASM_ASSEMBLY, $LJA_ASSEMBLY
#   - Reference genome: $REF_GENOME
#
# OUTPUT:
#   - Alignment plots and results in: $OUTPUT_DIR
#
# NOTES:
#   - Ensure input assemblies and the reference genome are available in the specified locations.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --job-name=nucmer_mummerplot_array_comparison_genomes
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=%x_%A_%a.out   
#SBATCH --error=%x_%A_%a.err    
#SBATCH --array=0-5            
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

# Input parameters as arguments
FLYE_ASSEMBLY=$1        
HIFIASM_ASSEMBLY=$2     
LJA_ASSEMBLY=$3         
REF_GENOME=$4          
OUTPUT_DIR=$5           
CONTAINER=/containers/apptainer/mummer4_gnuplot.sif            

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Function to run NUCmer and MUMmerplot
run_nucmer_mummerplot() {
    QUERY=$1          # The query assembly
    PREFIX=$2         # Prefix for output files
    REF=$3            # The reference genome or another assembly
    OUTPUT_PREFIX=$OUTPUT_DIR/$PREFIX

    # Run NUCmer
    apptainer exec $CONTAINER nucmer --prefix=$OUTPUT_PREFIX --breaklen 1000 --mincluster 1000 $REF $QUERY
    
    # Run MUMmerplot
    apptainer exec $CONTAINER mummerplot --filter --fat --layout -t png -R $REF -Q $QUERY -p $OUTPUT_PREFIX $OUTPUT_PREFIX.delta
}

# Define comparisons to run based on the array task ID
case "$SLURM_ARRAY_TASK_ID" in
    0)
        # Flye vs Reference
        run_nucmer_mummerplot $FLYE_ASSEMBLY "flye_vs_ref" $REF_GENOME
        ;;
    1)
        # Hifiasm vs Reference
        run_nucmer_mummerplot $HIFIASM_ASSEMBLY "hifiasm_vs_ref" $REF_GENOME
        ;;
    2)
        # LJA vs Reference
        run_nucmer_mummerplot $LJA_ASSEMBLY "lja_vs_ref" $REF_GENOME
        ;;
    3)
        # Flye vs Hifiasm
        run_nucmer_mummerplot $FLYE_ASSEMBLY "flye_vs_hifiasm" $HIFIASM_ASSEMBLY
        ;;
    4)
        # Flye vs LJA
        run_nucmer_mummerplot $FLYE_ASSEMBLY "flye_vs_lja" $LJA_ASSEMBLY
        ;;
    5)
        # Hifiasm vs LJA
        run_nucmer_mummerplot $HIFIASM_ASSEMBLY "hifiasm_vs_lja" $LJA_ASSEMBLY
        ;;
esac




