#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script parses the output of RepeatMasker using the `parseRM.pl` script. 
#   It ensures the necessary script is available, downloads it if needed, and 
#   processes the RepeatMasker output to produce tab-delimited summary files.
#
# USAGE:
#   sbatch 08_parse_repeatmasker_output.sh
#
# REQUIREMENTS:
#   - BioPerl version 1.7.8 (via module system)
#   - parseRM.pl script (automatically downloaded if not present)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - RepeatMasker output: $INPUT_DIR/assembly.fasta.mod.out
#
# OUTPUT:
#   - Parsed RepeatMasker results (tab-delimited): $OUTPUT_DIR
#
# NOTES:
#   - Ensure the RepeatMasker output file is available in the specified location.
#   - The parseRM.pl script is downloaded from GitHub if not found locally.
#   - Update paths and email address if necessary.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --job-name=parseRM
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/08_parseRM_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/annotation/logfile/08_parseRM_error_%j.e
#SBATCH --partition=pibu_el8

# Load BioPerl module required for running the parseRM.pl script
module add BioPerl/1.7.8-GCCcore-10.3.0

# Set working directory
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation"

# Define input directory where RepeatMasker output files are stored
INPUT_DIR="$WORKDIR/outputs/01_EDTA/assembly.fasta.mod.EDTA.anno"

# --------------------------------------
# Check if the parseRM.pl script is available, and download it if not
pushd "$WORKDIR/scripts"

if [[ ! -f ./parseRM.pl ]]; then
    echo "parseRM.pl script doesn't exist. Download process started"
    
    # Download the parseRM.pl script from GitHub
    wget https://raw.githubusercontent.com/4ureliek/Parsing-RepeatMasker-Outputs/master/parseRM.pl

    # Make the script executable
    chmod +x parseRM.pl

    echo "parseRM.pl script ready to be used"

fi

popd
# --------------------------------------

# Path to parseRM.pl script
PARSERM_SCRIPT=$WORKDIR/scripts/parseRM.pl

# Define output directory for parsed RepeatMasker results
OUTPUT_DIR="$WORKDIR/outputs/08_parsed_repeatmasker"
mkdir -p "$OUTPUT_DIR"

# Run the parseRM.pl script with specified options
perl $PARSERM_SCRIPT -i "$INPUT_DIR/assembly.fasta.mod.out" -l 50,1 -v

# Move the output `.tab` files to the specified output directory
mv $INPUT_DIR/*.tab "$OUTPUT_DIR"

# Inform the user that the output files have been successfully moved