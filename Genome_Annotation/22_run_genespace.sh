#!/bin/bash

#================================================================

# DESCRIPTION:
#   This script initializes and runs the GeneSpace pipeline using 
#   the `GENESPACE` R library inside an Apptainer container. It processes 
#   the provided input directory containing GeneSpace files and generates 
#   synteny and orthology analyses.
#
# USAGE:
#   sbatch 22_run_genespace.sh
#
# REQUIREMENTS:
#   - Preprocessed GeneSpace files ready for input
#   - GeneSpace Apptainer container with R and required dependencies
#
# INPUT:
#   - Path to the GeneSpace input files directory
#
# OUTPUT:
#   - GeneSpace synteny and orthology output files
#
# NOTES:
#   - Ensure all required directories are properly mounted using `--bind`.
#   - Check and update the paths if needed (e.g., `GENESPACE_FILES_DIR`).
#================================================================

#SBATCH --time=1-0
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=genespace
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/22_genespace_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/22_genespace_error_%j.e
#SBATCH --partition=pibu_el8

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"
GENESPACE_FILES_DIR="$WORKDIR/outputs/22_genespace"

apptainer exec \
    --bind $COURSEDIR \
    --bind $WORKDIR \
    --bind $SCRATCH:/temp \
    $COURSEDIR/containers/genespace_latest.sif Rscript $WORKDIR/scripts/22_genespace.R $GENESPACE_FILES_DIR

# apptainer shell \
#     --bind $COURSEDIR \
#     --bind $WORKDIR \
#     --bind $SCRATCH:/temp \
#     $COURSEDIR/containers/genespace_latest.sif