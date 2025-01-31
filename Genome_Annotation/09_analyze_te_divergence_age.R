
#================================================================
#
# DESCRIPTION:
#   This R script analyzes the distribution of transposable element (TE) ages based 
#   on sequence divergence data obtained from a parsed RepeatMasker output. It calculates 
#   the estimated insertion time of TEs and generates visualizations of TE age and 
#   sequence divergence by superfamily.
#
# R SCRIPT DETAILS:
#   - Reads the divergence data and filters unwanted or unclassified elements.
#   - Calculates the age of each TE using a substitution rate specific to Brassicaceae.
#   - Removes helitrons from the analysis, as EDTA cannot annotate them properly.
#   - Produces a histogram showing the distribution of TE ages across superfamilies.
#   - Creates a bar plot showing sequence divergence across TE families.
#   - Saves the processed data and plots to output files.
#
# HOW TO RUN THE R SCRIPT:
#   The R script will be automatically executed using the following command:
#   
#   srun --time=01:00:00 --mem=4G --cpus-per-task=1 --pty /bin/bash
#   Rscript 09_analyze_te_divergence_age.R
#   
#   Ensure that the R script and all input files are correctly specified in the script.
#
# REQUIREMENTS:
#   - R with libraries: ggplot2, dplyr, data.table, cowplot
#   - Access to a compute cluster with SLURM scheduler
#
# INPUT:
#   - Divergence data (tab-delimited): $data
#
# OUTPUT:
#   - Processed TE data with calculated ages: /path/to/09_TE_with_ages.txt
#   - Histogram of TE ages: /path/to/09_TE_ages_distribution.pdf
#   - Bar plot of sequence divergence: /path/to/09_div_output.pdf
#
# NOTES:
#   - Ensure the input divergence data is available in the specified path.
#   - Update paths and email address if necessary.
#================================================================

library(reshape2)
#library(hrbrthemes) # Check if the package is installed; if it is missing, install it in a personal library (see down below).
library(tidyverse)
library(data.table)

# -----------------------------------------------------
# Check if the package is installed in the current R session
if ("hrbrthemes" %in% rownames(installed.packages())) {
    message("Package 'hrbrthemes' is already installed.")
} else {
    message("Package 'hrbrthemes' is not installed. Proceeding to create a personal library and install it.")

    # If not, set the library directory path
    Sys.setenv(R_LIBS_USER = "./R_libs")
    
    # Create the directory if it doesn't exist
    dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE, showWarnings = FALSE)

    # Install the package into your personal library
    install.packages("hrbrthemes", lib = Sys.getenv("R_LIBS_USER"), repos = "http://cran.us.r-project.org")
}

# Load the package from your personal library
library(hrbrthemes, lib.loc = Sys.getenv("R_LIBS_USER"))
#------------------------------------------------------

# get data from parameter
data <- "/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/08_parsed_repeatmasker/assembly.fasta.mod.out.landscape.Div.Rname.tab"

rep_table <- fread(data, header = FALSE, sep = "\t")
rep_table %>% head()
# How does the data look like?
print("Sample of raw data loaded:")
print(head(rep_table))  # Print the first few rows to inspect the data
#------------------------------------------------------

# Rename columns for better readability
colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
# Remove rows where Rfam is "unknown" (invalid family)
rep_table <- rep_table %>% filter(Rfam != "unknown")
# Combine 'Rclass' and 'Rfam' to create a new column 'fam' that represents the family
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

# Print out the counts of elements in each superfamily to see the distribution
print("Number of elements in each superfamily:")
print(table(rep_table$fam))
# How many elements are there in each Superfamily?
# -----------------------------------------------------

# Melt the data to long format, where each row represents a divergence value for a TE family
rep_table.m <- melt(rep_table)

rep_table.m <- rep_table.m[-c(which(rep_table.m$variable == 1)), ] # remove the peak at 1, as the library sequences are copies in the genome, they inflate this low divergence peak
# -----------------------------------------------------

# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM"
))

# NOTE: Check that all the superfamilies in your dataset are included above
# -----------------------------------------------------
# Convert divergence percentage to decimal by dividing by 100
rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100 # Distance is the percent divergence

# -----------------------------------------------------
# Now, we will calculate the age of each transposable element (TE) using the substitution rate formula:
# T = K / 2r, where:
#   - T = insertion time (age) in years
#   - K = sequence divergence (distance)
#   - r = substitution rate (substitutions per site per year)
substitution_rate <- 8.22e-9  # Substitution rate for Brassicaceae in substitutions per site per year (Kagale et al., 2014)

# Calculate the age of each TE using the formula
rep_table.m$age <- rep_table.m$distance / (2 * substitution_rate)

# Disable scientific notation for better readability
options(scipen = 999)
# -----------------------------------------------------

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron")

# -----------------------------------------------------
# Print out a sample of the data, showing the columns Rname, fam (family), distance, and the calculated age
print("Sample data with age column:")
print(head(rep_table.m[, c("Rname", "fam", "distance", "age")]))

# -----------------------------------------------------
# Save the data with the age of each TE to a file so you can inspect it later
write.table(rep_table.m, file = "/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/09_TE_with_ages.txt", sep = "\t", row.names = FALSE)

# -----------------------------------------------------
# Visualization of the ages of the TEs
# Create a histogram of the ages to see their distribution across different TEs
# ggplot(rep_table.m, aes(x = age)) +
#   geom_histogram(binwidth = 1e6) +  # Adjust bin width to control the granularity of the histogram
#   theme_minimal() +
#   xlab("Age of Transposable Elements (years)") +
#   ylab("Count") +
#   ggtitle("Distribution of TE Ages Across Different Superfamilies")

ggplot(rep_table.m, aes(x = age, fill = fam)) +
  geom_histogram(binwidth = 500000, position = "stack", color = "black") +
  labs(title = "Distribution of TE Ages Across Different Superfamilies",
       x = "Age of Transposable Elements (years)",
       y = "Count") +
  theme_minimal() +
  scale_fill_brewer(palette = "Paired")

# -----------------------------------------------------
# Save the histogram plot as a PDF file
ggsave(filename = "/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/09_TE_ages_distribution.pdf", width = 10, height = 5, useDingbats = FALSE)

# -----------------------------------------------------
# Visualization of the sequence divergence by family using a bar plot
# This bar plot shows the sequence divergence by family, weighted by the number of sequences
ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

# -----------------------------------------------------
# Save the sequence divergence plot as a PDF file
ggsave(filename = "/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/09_div_output.pdf", width = 10, height = 5, useDingbats = FALSE)

# Question: Do you have other clades of LTR-RTs not present in the full length elements?