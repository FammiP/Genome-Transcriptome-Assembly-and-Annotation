#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script runs the MAKER genome annotation pipeline using MPI for parallel execution.
#   MAKER combines evidence from multiple gene predictors and sequence databases to annotate 
#   protein-coding genes and other genomic features.
#
# USAGE:
#   sbatch 14_run_maker.sh
#
# REQUIREMENTS:
#   - MAKER version 3.01.03 (via Apptainer container)
#   - OpenMPI for parallel processing
#   - RepeatMasker and Augustus installed and configured
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - MAKER control files (maker_opts.ctl, maker_bopts.ctl, maker_evm.ctl, maker_exe.ctl)
#     located in: $CONTROL_FILES_DIR
#
# OUTPUT:
#   - Genome annotation results in: $OUTDIR
#
# PROCESS:
#   1. Load necessary modules (OpenMPI, Augustus).
#   2. Create output directory if it doesn’t exist.
#   3. Run MAKER with MPI, binding necessary directories to the container.
#
# NOTES:
#   - Ensure that all control files and necessary tools (e.g., RepeatMasker, Augustus) 
#     are available and properly configured.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --time=4-0
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --job-name=maker
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/14_maker_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/14_maker_error_%j.e
#SBATCH --partition=pibu_el8

# Define directories
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation" # Path to course directory with resources
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/" # Path to working directory
CONTROL_FILES_DIR="$WORKDIR/genome_annotation/outputs/13_control_files_maker" # Path to the directory containing MAKER control files
OUTDIR="$WORKDIR/genome_annotation/outputs/14_maker_GENE" # Path where output files will be saved

REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker" # Path to RepeatMasker
export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker" # Add RepeatMasker to PATH

# Load necessary modules
module load OpenMPI/4.1.1-GCC-10.3.0 # Load OpenMPI for parallel execution
module load AUGUSTUS/3.4.0-foss-2021a # Load Augustus for gene prediction

# Create output directory if it doesn't exist
mkdir -p $OUTDIR # Make output directory
cd $OUTDIR # Navigate to output directory

# Run MAKER with MPI for parallel execution
mpiexec --oversubscribe -n 50 apptainer exec \
    --bind $SCRATCH:/TMP --bind $COURSEDIR --bind $AUGUSTUS_CONFIG_PATH --bind $REPEATMASKER_DIR --bind $WORKDIR \
    ${COURSEDIR}/containers/MAKER_3.01.03.sif \
    maker -mpi --ignore_nfs_tmp -TMP /TMP \
    $CONTROL_FILES_DIR/maker_opts.ctl \
    $CONTROL_FILES_DIR/maker_bopts.ctl \
    $CONTROL_FILES_DIR/maker_evm.ctl \
    $CONTROL_FILES_DIR/maker_exe.ctl