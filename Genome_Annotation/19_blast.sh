#!/usr/bin/env bash

#================================================================
#
# DESCRIPTION:
#   This script performs a BLASTP search of the longest protein isoforms against the 
#   UniProt database (Viridiplantae). The results are used to update the protein FASTA 
#   and GFF3 files with functional annotations. The updated files can be used for downstream 
#   analyses or genome browsers.
#
# USAGE:
#   sbatch 19_blast.sh
#
# REQUIREMENTS:
#   - BLAST+ version 2.15.0 (via module system)
#   - MAKER functional annotation tools (maker_functional_fasta, maker_functional_gff)
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Longest protein FASTA file: $protein
#   - GFF3 file with annotations: $gff
#   - UniProt database: $uniprot_fasta
#
# OUTPUT:
#   - Updated protein FASTA file with annotations: ${protein_basename}.Uniprot
#   - Updated GFF3 file with functional annotations: ${gff_basename}.Uniprot.gff3
#
# PROCESS:
#   1. Run BLASTP to compare proteins against UniProt Viridiplantae database.
#   2. Use MAKER utilities to update the protein and GFF3 files with BLAST results.
#
# NOTES:
#   - Ensure that BLAST+ and MAKER tools are properly loaded.
#   - Update paths and email address if necessary.
#================================================================


#SBATCH --time=1-0
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=fammi.parokkaran@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=blast
#SBATCH --output=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/19_blast_output_%j.o
#SBATCH --error=/data/users/fparokkaran/assembly_annotation_course/genome_annotation/logfile/19_blast_error_%j.e
#SBATCH --partition=pibu_el8

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs"
OUTDIR="$WORKDIR/19_blast"

protein="$WORKDIR/16_final_GENE/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
gff="$WORKDIR/16_final_GENE/filtered.genes.renamed.final.gff3"
# Extract filenames for proper output naming
protein_basename=$(basename "$protein")
gff_basename=$(basename "$gff")

MAKERBIN="/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin/"
uniprot_fasta="/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa"

mkdir -p $OUTDIR
cd $OUTDIR

module load BLAST+/2.15.0-gompi-2021a
# makeblastb -in <uniprot_fasta> -dbtype prot # this step is already done

blastp -query $protein -db $uniprot_fasta -num_threads 10 -outfmt 6 -evalue 1e-10 -out blastp_output.txt
cp "$protein" "$OUTDIR/${protein_basename}.Uniprot"
cp "$gff" "$OUTDIR/${gff_basename}.Uniprot"


# Update FASTA file with functional annotations
$MAKERBIN/maker_functional_fasta "$uniprot_fasta" blastp_output.txt "$protein" > "$OUTDIR/${protein_basename}.Uniprot"
# Update GFF3 file with functional annotations
$MAKERBIN/maker_functional_gff "$uniprot_fasta" blastp_output.txt "$gff" > "$OUTDIR/${gff_basename}.Uniprot.gff3"
