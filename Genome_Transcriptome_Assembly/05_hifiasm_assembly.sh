#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs genome assembly using Hifiasm on PacBio HiFi reads. 
#   It generates assembly outputs in the GFA format and converts them to FASTA 
#   files if available. The assembly results and logs are stored in the 
#   specified output directory.
#
# USAGE:
#   sbatch 05_hifiasm_assembly.sh
#
# REQUIREMENTS:
#   - Hifiasm version 0.19.8 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - PacBio HiFi FASTQ file: $READS
#
# OUTPUT:
#   - GFA files in: $OUTDIR
#   - FASTA files converted from GFA files: $OUTDIR
#
# NOTES:
#   - Ensure the input reads are properly filtered and available in the specified location.
#   - The script automatically converts GFA files to FASTA if they exist after assembly.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --job-name=Hifiasm_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/out_hifiasm/out_hifiasm_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/err_hifiasm/err_hifiasm_%j.e
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch

# Load Flye container and set up working directories
WORKDIR=/data/users/fparokkaran/assembly_annotation_course/genome_assembly
READS=$WORKDIR/read_QC/fastp/fastp_output/Nemrut-1_no_filter.fastq.gz   # Input file
OUTDIR=$WORKDIR/assemblies/hifiasm/hifiasm_assembly_output  # Output directory for Flye
# Create output directory if not already present
mkdir -p $OUTDIR

# Run Flye assembly
apptainer exec /containers/apptainer/hifiasm_0.19.8.sif \
hifiasm -o $OUTDIR/Nemrut1_asm -t 16 $READS

# Since Hifiasm generates assemblies in the GFA format. 
# To convert these files to FASTA format use following command: 

# But check if the GFA files exist before conversion
if [ -f $OUTDIR/Nemrut1_asm.p_ctg.gfa ]; then # -f checks if a file exists
    # Convert 
    awk '/^S/{print ">"$2;print $3}' $OUTDIR/Nemrut1_asm.p_ctg.gfa > $OUTDIR/Nemrut1_asm.p_ctg.fa
fi

if [ -f $OUTDIR/Nemrut1_asm.h_ctg.gfa ]; then
    # Convert haplotigs GFA to FASTA
    awk '/^S/{print ">"$2;print $3}' $OUTDIR/Nemrut1_asm.h_ctg.gfa > $OUTDIR/Nemrut1_asm.h_ctg.fa
fi
# if the previous one is not working use in the folder of interest: 
#awk '/^S/{print ">"$2;print $3}' FILE.gfa > FILE.fa
