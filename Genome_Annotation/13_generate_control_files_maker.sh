#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script generates the control files for genome annotation using the MAKER pipeline.
#   It runs MAKER with the '-CTL' flag to create the necessary control files, which are used 
#   for configuring the genome annotation process.
#
# USAGE:
#   sbatch 13_generate_control_files_maker.sh
#
# REQUIREMENTS:
#   - MAKER version 3.01.03 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - No direct input; generates control files required for annotation.
#
# OUTPUT:
#   - Control files (maker_opts.ctl, maker_exe.ctl, maker_bopts.ctl) in: $WORKDIR
#
# PROCESS:
#   1. Create the working directory if it does not exist.
#   2. Use the MAKER '-CTL' option to generate control files inside the container.
#
# NOTES:
#   - Ensure the working directory is writable and accessible.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=05:00:00
#SBATCH --job-name=control_files_maker
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/13_control_files_maker_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/13_control_files_maker_error_%j.e
#SBATCH --partition=pibu_el8

# Define the working directory where all annotation-related files will be stored
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/13_control_files_maker"
# Define the location of the MAKER container image
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"
# Create the working directory if it does not exist
mkdir -p $WORKDIR
# Change to the working directory
cd $WORKDIR

# Run the MAKER pipeline with the '-CTL' flag to generate the control files for annotation
# The 'apptainer' command is used to run the MAKER container, binding the current working directory 
# to the container environment to ensure all necessary files are accessible.

# Explanation of the command:
# - apptainer exec: Executes a command inside the container.
# - --bind $WORKDIR: Binds the current working directory ($WORKDIR) to the container.
# - $CONTAINER: The container image that contains the MAKER pipeline (MAKER_3.01.03.sif).
# - maker -CTL: The MAKER command to generate the control files needed for genome annotation.
apptainer exec --bind $WORKDIR \
$CONTAINER maker -CTL