#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script extracts Copia and Gypsy retrotransposon sequences from the RepBase library 
#   and prepares reverse transcriptase (RT) sequences for Arabidopsis and Brassicaceae 
#   using TEsorter and SeqKit. The sequences are classified, extracted, and stored for 
#   downstream analysis.
#
# USAGE:
#   sbatch 10_prepare_rt_sequences.sh
#
# REQUIREMENTS:
#   - SeqKit version 2.6.1 (via module system)
#   - TEsorter version 1.3.0 (via Apptainer container)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - RepBase TE sequences (FASTA): $INPUT_FILE
#   - TEsorter output files for Gypsy and Copia families
#
# OUTPUT:
#   - Copia and Gypsy sequences from RepBase in Brassicaceae: $OUTDIR
#   - Extracted RT sequences for Arabidopsis: ${OUTDIR}/copia_RT_arabidopsis.fasta and ${OUTDIR}/gypsy_RT_arabidopsis.fasta
#   - Extracted RT sequences for Brassicaceae: ${OUTDIR}/copia_RT_brassicaceae.fasta and ${OUTDIR}/gypsy_RT_brassicaceae.fasta
#
# NOTES:
#   - Ensure the input files and directories are available in the specified locations.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=prepare_rt_sequences
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/10_prepare_rt_sequences_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/10_prepare_rt_sequences_error_%j.e
#SBATCH --partition=pibu_el8

# Load necessary modules
module load SeqKit/2.6.1

# Set paths
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"
OUTDIR="$WORKDIR/outputs/10_rt_sequences"

# Create output directories
mkdir -p $OUTDIR
echo "Output directories created: $OUTDIR"

# -- Step 1: Extract Copia and Gypsy sequences from Brassicaceae --
# Paths for RepBase file and output directories
INPUT_FILE="/data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta"
OUTDIR_COPIA_BRAS="$OUTDIR/tesorter_copia_brassicaceae"
OUTDIR_GYPSY_BRAS="$OUTDIR/tesorter_gypsy_brassicaceae"
CONTAINER="/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif"

# Create directories for TEsorter output
mkdir -p $OUTDIR_COPIA_BRAS $OUTDIR_GYPSY_BRAS
echo "Created directories for Copia and Gypsy sequences: $OUTDIR_COPIA_BRAS, $OUTDIR_GYPSY_BRAS"

# Extract Copia and Gypsy sequences using SeqKit
echo "Extracting Copia sequences from RepBase file..."
seqkit grep -r -p "Copia" $INPUT_FILE > $OUTDIR_COPIA_BRAS/copia_sequences_brassicaceae.fa
echo "Extracting Gypsy sequences from RepBase file..."
seqkit grep -r -p "Gypsy" $INPUT_FILE > $OUTDIR_GYPSY_BRAS/gypsy_sequences_brassicaceae.fa

# Run TEsorter for Copia sequences
apptainer exec -C -H $WORKDIR --writable-tmpfs -u $CONTAINER \
  TEsorter $OUTDIR_COPIA_BRAS/copia_sequences_brassicaceae.fa -db rexdb-plant
mv $WORKDIR/copia_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_COPIA_BRAS
if [ $? -eq 0 ]; then
    echo "TEsorter successfully completed for Copia sequences."
    mv copia_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_COPIA_BRAS
else
    echo "Error running TEsorter for Copia sequences." >&2
    exit 1
fi

# Run TEsorter for Gypsy sequences
apptainer exec -C -H $WORKDIR --writable-tmpfs -u $CONTAINER \
  TEsorter $OUTDIR_GYPSY_BRAS/gypsy_sequences_brassicaceae.fa -db rexdb-plant
mv $WORKDIR/gypsy_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_GYPSY_BRAS
if [ $? -eq 0 ]; then
    echo "TEsorter successfully completed for Gypsy sequences."
    mv gypsy_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_GYPSY_BRAS
else
    echo "Error running TEsorter for Gypsy sequences." >&2
    exit 1
fi

# -- Step 2: Extract RT sequences for Arabidopsis --
# Arabidopsis RT sequences are already available, so we directly extract them
echo "Extracting RT sequences for Arabidopsis..."
for FAMILY in "gypsy" "copia"; do
    INPUT_FILE="$WORKDIR/outputs/07_tesorter_${FAMILY}/${FAMILY}_sequences.fa.rexdb-plant.dom.faa"
    OUTPUT_LIST="$OUTDIR/${FAMILY}_list_arabidopsis.txt"
    OUTPUT_FASTA="$OUTDIR/${FAMILY}_RT_arabidopsis.fasta"
    
    # Check which family we're processing and set the RT type accordingly
    if [ "$FAMILY" == "gypsy" ]; then
        RT_TYPE="Ty3-RT"  # Gypsy uses Ty3-RT
    elif [ "$FAMILY" == "copia" ]; then
        RT_TYPE="Ty1-RT"  # Copia uses Ty1-RT
    fi

    # Extract RT sequences for Arabidopsis (Ty1-RT for Copia, Ty3-RT for Gypsy)
    echo "Extracting RT sequences for Arabidopsis $FAMILY..."
    grep "$RT_TYPE" $INPUT_FILE > $OUTPUT_LIST
    sed -i 's/>//' $OUTPUT_LIST #remove ">" from the header
    sed -i 's/ .\+//' $OUTPUT_LIST #remove all characters following "empty space" from the header
    seqkit grep -f $OUTPUT_LIST $INPUT_FILE -o $OUTPUT_FASTA
    if [ $? -eq 0 ]; then
        echo "Successfully extracted RT sequences for Arabidopsis $FAMILY."
    else
        echo "Error extracting RT sequences for Arabidopsis $FAMILY." >&2
        exit 1
    fi
done

# -- Step 3: Extract RT sequences for Brassicaceae --
# Extract RT sequences for Gypsy and Copia in Brassicaceae using TEsorter output
echo "Extracting RT sequences for Brassicaceae..."
for FAMILY in "gypsy" "copia"; do
    # Correct the path based on TEsorter output for Brassicaceae
    if [ "$FAMILY" == "gypsy" ]; then
        INPUT_FILE="$OUTDIR/tesorter_gypsy_brassicaceae/gypsy_sequences_brassicaceae.fa.rexdb-plant.dom.faa"
    elif [ "$FAMILY" == "copia" ]; then
        INPUT_FILE="$OUTDIR/tesorter_copia_brassicaceae/copia_sequences_brassicaceae.fa.rexdb-plant.dom.faa"
    fi
    
    OUTPUT_LIST="$OUTDIR/${FAMILY}_list_brassicaceae.txt"
    OUTPUT_FASTA="$OUTDIR/${FAMILY}_RT_brassicaceae.fasta"
    
    # Check which family we're processing and set the RT type accordingly
    if [ "$FAMILY" == "gypsy" ]; then
        RT_TYPE="Ty3-RT"  # Gypsy uses Ty3-RT
    elif [ "$FAMILY" == "copia" ]; then
        RT_TYPE="Ty1-RT"  # Copia uses Ty1-RT
    fi

    # Extract RT sequences for Brassicaceae (Ty3-RT for Gypsy, Ty1-RT for Copia)
    echo "Extracting RT sequences for Brassicaceae $FAMILY..."
    grep "$RT_TYPE" $INPUT_FILE > $OUTPUT_LIST
    sed -i 's/>//' $OUTPUT_LIST
    sed -i 's/ .\+//' $OUTPUT_LIST
    seqkit grep -f $OUTPUT_LIST $INPUT_FILE -o $OUTPUT_FASTA
    if [ $? -eq 0 ]; then
        echo "Successfully extracted RT sequences for Brassicaceae $FAMILY."
    else
        echo "Error extracting RT sequences for Brassicaceae $FAMILY." >&2
        exit 1
    fi
done

echo "RT sequence preparation completed for both Arabidopsis and Brassicaceae!"