# ---------------------------------------------------------------
# R Script to Process Gene Annotation and Protein Sequence Data
#
# Description:
#   This script processes genomic annotation and protein sequence data 
#   to prepare input files for further comparative genomics analysis. 
#   The script focuses on extracting genes from the top 20 largest scaffolds 
#   in a genome assembly and generates BED files and filtered peptide files 
#   for subsequent synteny and orthology analyses.
#
#   Specifically, the script:
#   1. Loads required libraries (data.table and tidyverse).
#   2. Reads input data files from environment variables for flexibility.
#      -> Ensure the environment variables (e.g., WORKDIR, OUTDIR, ANNO_FILE, 
#         FASTA_FAI, LONGEST_PROTEINS, ACCESSION_NAME) are correctly set.
#   3. Filters genomic annotations to extract only gene information.
#   4. Identifies the top 20 largest scaffolds in the genome assembly 
#      and filters the genes accordingly.
#   5. Writes gene IDs to a text file for later use.
#   6. Creates output directories for BED and peptide files if they do not exist.
#   7. Generates a BED file containing the coordinates of filtered genes.
#   8. Cleans protein FASTA headers by removing unwanted suffixes.
#   9. Filters the protein FASTA file to include only sequences corresponding 
#      to the filtered gene IDs.
#   10. Copies reference data (TAIR10) into the appropriate directories.
#
# How to Run:
#   - This R script is designed to be executed via the accompanying bash script
#     `22_create_genespace_folders.sh`.
#   - Ensure the bash script sets the required environment variables and 
#     invokes this R script with the correct inputs and outputs.
# ---------------------------------------------------------------

library(data.table)
library(tidyverse)

# Set working directory from environment variable
WORKDIR <- Sys.getenv("WORKDIR")
OUTDIR <- Sys.getenv("OUTDIR")
ANNO_FILE <- Sys.getenv("ANNO_FILE")
FASTA_FAI <- Sys.getenv("FASTA_FAI")
LONGEST_PROTEINS <- Sys.getenv("LONGEST_PROTEINS")
ACCESSION_NAME <- Sys.getenv("ACCESSION_NAME")

# Load the annotation
annotation <- fread(ANNO_FILE, header = FALSE, sep = "\t")
bed_genes <- annotation %>%
    filter(V3 == "gene") %>%
    select(V1, V4, V5, V9) %>%
    mutate(gene_id = as.character(str_extract(V9, "ID=[^;]*"))) %>%
    mutate(gene_id = as.character(str_replace(gene_id, "ID=", ""))) %>%
    select(-V9)

top20_scaff <- fread(FASTA_FAI, header = FALSE, sep = "\t") %>%
    select(V1, V2) %>%
    arrange(desc(V2)) %>%
    head(20)

# Filter bed_genes to include only genes from top 20 scaffolds
bed_genes <- bed_genes %>%
    filter(V1 %in% top20_scaff$V1)

# Write the gene IDs to a file for later filtering
gene_id <- bed_genes$gene_id
write.table(gene_id, file.path(OUTDIR, "genespace_genes1.txt"), quote = FALSE, row.names = FALSE, col.names = FALSE)

# Make a genespace specific directory if not existing
if (!dir.exists(file.path(OUTDIR, "bed"))) {
    dir.create(file.path(OUTDIR, "bed"))
}
if (!dir.exists(file.path(OUTDIR, "peptide"))) {
    dir.create(file.path(OUTDIR, "peptide"))
}

# Save the BED file in the appropriate directory
write.table(bed_genes, file.path(OUTDIR, "bed", paste0(ACCESSION_NAME, ".bed")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

# Remove "-R.*" from fasta headers of proteins, to get only gene IDs
protein_fasta_cleaned <- file.path(OUTDIR, "peptide", paste0(ACCESSION_NAME, "_peptide.fa"))
system(paste("sed 's/-R.*//' ", LONGEST_PROTEINS, " > ", protein_fasta_cleaned))

# Filter to select only proteins of the top 20 scaffolds
output_peptide_fasta <- file.path(OUTDIR, "peptide", paste0(ACCESSION_NAME, ".fa"))
system(paste("faSomeRecords ", protein_fasta_cleaned, " ", file.path(OUTDIR, "genespace_genes1.txt"), " ", output_peptide_fasta))
file.remove(protein_fasta_cleaned)

#--------------------------------------------------------

# Copy TAIR10 data to the genespace directory only if not already present
tair_bed_dest <- file.path(OUTDIR, "bed", "TAIR10.bed")
tair_fa_dest <- file.path(OUTDIR, "peptide", "TAIR10.fa")

# Check if the TAIR10.bed file already exists in the output directory
if (!file.exists(tair_bed_dest)) {
  system(paste("cp /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.bed ", tair_bed_dest))
} else {
  message("TAIR10.bed already exists, skipping copy.")
}

# Check if the TAIR10.fa file already exists in the output directory
if (!file.exists(tair_fa_dest)) {
  system(paste("cp /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.fa ", tair_fa_dest))
} else {
  message("TAIR10.fa already exists, skipping copy.")
}
