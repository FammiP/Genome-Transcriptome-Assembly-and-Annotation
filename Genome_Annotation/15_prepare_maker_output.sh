#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script processes the output from the MAKER genome annotation pipeline by merging 
#   GFF3 files and FASTA sequences into comprehensive output files. It generates both 
#   sequence-inclusive and non-sequence GFF3 files, as well as a merged FASTA file.
#
# USAGE:
#   sbatch 15_prepare_maker_output.sh
#
# REQUIREMENTS:
#   - MAKER version 3.01.03 (gff3_merge and fasta_merge scripts)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - MAKER datastore index file: $INPUT_FILE
#
# OUTPUT:
#   - Merged GFF3 file (with sequences): $OUTDIR/assembly.all.maker.gff
#   - Merged GFF3 file (no sequences): $OUTDIR/assembly.all.maker.noseq.gff
#   - Merged FASTA sequences: $OUTDIR/assembly.maker.proteins.fasta, assembly.maker.transcripts.fasta
#
# PROCESS:
#   1. Create the output directory if it doesn’t exist.
#   2. Merge GFF3 files with and without sequences using `gff3_merge`.
#   3. Merge annotated FASTA sequences using `fasta_merge`.
#
# NOTES:
#   - Ensure that the MAKER output files and binaries are properly installed and accessible.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=05:00:00
#SBATCH --job-name=maker_output_prep
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/15_maker_output_prep_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/15_maker_output_prep_error_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
INPUT_FILE="$WORKDIR/outputs/14_maker_GENE/assembly.maker.output/assembly_master_datastore_index.log"
OUTDIR="$WORKDIR/outputs/15_prepared_maker_output"

mkdir -p $OUTDIR
cd $OUTDIR

$MAKERBIN/gff3_merge -s -d $INPUT_FILE > assembly.all.maker.gff
$MAKERBIN/gff3_merge -n -s -d $INPUT_FILE > assembly.all.maker.noseq.gff
$MAKERBIN/fasta_merge -d $INPUT_FILE -o assembly