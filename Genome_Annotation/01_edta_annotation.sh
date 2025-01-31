#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script runs the EDTA pipeline to annotate transposable elements (TEs) in a genome 
#   assembly using Apptainer. The output includes detailed TE annotations, leveraging CDS 
#   (Coding Sequence) data to improve gene-related predictions.
#
# USAGE:
#   sbatch 01_edta_annotation.sh
#
# REQUIREMENTS:
#   - EDTA version 1.9.6 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Genome assembly (FASTA): $ASSEMBLY
#   - CDS annotation file: $CDS
#
# OUTPUT:
#   - TE annotation files in: $OUTDIR
#   - Logs in: $LOGDIR
#
# NOTES:
#   - Ensure the input genome assembly and CDS annotation file are available at the specified locations.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --time=24:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=20
#SBATCH --job-name=EDTA_annotation
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/01_edta_annotation_output_%A.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/01_edta_annotation_error_%A.e
#SBATCH --partition=pibu_el8

# Set the working directory
WORKDIR="/data/users/fparokkaran/assembly_annotation_course"

# The path to the genome assembly file in FASTA format that will be annotated for transposable elements.
# Modify this variable to change the path to your input genome assembly file.
# You can update this path manually depending on the genome you want to analyze.
ASSEMBLY="$WORKDIR/genome_assembly/assemblies/flye/flye_assembly_output/assembly.fasta" 
# The directory where the EDTA output files will be stored.
OUTDIR="$WORKDIR/genome_annotation/EDTA/outputs/01_EDTA"
LOGDIR="$WORKDIR/genome_annotation/logfile"

# Path to the CDS (Coding Sequence) annotation file used in EDTA for gene identification.
# This annotation helps EDTA detect genes for TE prediction.
CDS="/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated"
# The path to the Apptainer container that includes the EDTA software and its dependencies.
CONTAINER="/data/courses/assembly-annotation-course/containers2/EDTA_v1.9.6.sif EDTA.pl"

# Create the output and logs directories if they do not exist
mkdir -p $OUTDIR $LOGDIR

# Change to the output directory before running the pipeline
cd $OUTDIR

# Run EDTA using Apptainer
# - The --bind /data option ensures that the /data directory is accessible inside the container
# - -H ${pwd}:/work binds the current directory to /work inside the container
# - --writable-tmpfs allows the container to write temporary data to memory
# - --genome specifies the genome assembly file to analyze
# - --species specifies the species; "others" is used here for species not in the default list
# - --step all specifies that all steps of EDTA should be executed
# - --cds specifies the CDS annotation file to be used for gene prediction
# - --anno 1 enables annotation of the TEs
# - --threads specifies the number of threads to be used by the pipeline (20 in this case)
apptainer exec -C --bind /data -H ${pwd}:/work \
    --writable-tmpfs -u $CONTAINER \
    --genome $ASSEMBLY \
    --species others \
    --step all \
    --cds $CDS \
    --anno 1 \
    --threads 20