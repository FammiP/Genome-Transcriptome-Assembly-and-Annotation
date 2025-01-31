
#================================================================
# DESCRIPTION:
#   This script processes orthogroup data to generate visualizations 
#   using bar plots and upset plots. It performs the following tasks:
#   1. Reads comparative genomics statistics from Orthofinder output.
#   2. Creates bar plots for orthogroup statistics.
#   3. Generates an upset plot to visualize presence/absence of orthogroups.
#
# REQUIREMENTS:
#   - R environment with the following libraries installed:
#     `tidyverse`, `data.table`, `cowplot`, `UpSetR`, `ComplexUpset`
#
# USAGE:
#       srun --time=01:00:00 --mem=4G --cpus-per-task=1 --pty /bin/bash
#       Rscript 23_parse_orthofinder.R

# SETUP:
#   1. Load R module:
#      ```
#      module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2
#      ```
#
# INPUT:
#   - Orthofinder output files (Statistics_PerSpecies.tsv, Orthogroups.GeneCount.tsv)
#
# OUTPUT:
#   - Bar plots for orthogroup statistics (PDF format)
#   - UpSet plot for orthogroup presence/absence (PDF format)
#
# NOTES:
#   - Update paths to Orthofinder output files if needed.
#================================================================


library(tidyverse)
library(data.table)

dat <- fread("/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/22_genespace/orthofinder/Results_Jan22/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv", header = T, fill = TRUE)
genomes <- names(dat)[names(dat) != "V1"]

dat <- dat %>% pivot_longer(cols = -V1, names_to = "species", values_to = "perc")
ortho_ratio <- dat %>%
    filter(V1 %in% c(
        "Number of genes", "Number of genes in orthogroups", "Number of unassigned genes",
        "Number of orthogroups containing species", "Number of species-specific orthogroups", "Number of genes in species-specific orthogroups"
    ))

ortho_percent <- dat %>%
    filter(V1 %in% c(
        "Percentage of genes in orthogroups", "Percentage of unassigned genes", "Percentage of orthogroups containing species",
        "Percentage of genes in species-specific orthogroups"
    ))

p <- ggplot(ortho_ratio, aes(x = V1, y = perc, fill = species)) +
    geom_col(position = "dodge") +
    cowplot::theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Count")
ggsave("23_orthogroup_plots/orthogroup_plot.pdf")


p <- ggplot(ortho_percent, aes(x = V1, y = as.numeric(perc), fill = species)) +
    geom_col(position = "dodge") +
    ylim(c(0, 100)) +
    cowplot::theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Count")
ggsave("23_orthogroup_plots/orthogroup_percent_plot.pdf")


library(UpSetR)


orthogroups <- fread("/data/users/fparokkaran/assembly_annotation_course/genome_annotation/outputs/22_genespace/orthofinder/Results_Jan22/Orthogroups/Orthogroups.GeneCount.tsv")
orthogroups <- orthogroups %>%
    select(-Total)
ogroups_presence_absence <- orthogroups
rownames(ogroups_presence_absence) <- ogroups_presence_absence$Orthogroup

# convert the gene counts to presence/absence
ogroups_presence_absence[ogroups_presence_absence > 0] <- 1
ogroups_presence_absence$Orthogroup <- rownames(ogroups_presence_absence)

str(ogroups_presence_absence)

ogroups_presence_absence <- ogroups_presence_absence %>%
    rowwise() %>%
    mutate(SUM = sum(c_across(!ends_with("Orthogroup"))))

ogroups_presence_absence <- data.frame(ogroups_presence_absence)
ogroups_presence_absence[genomes] <- ogroups_presence_absence[genomes] == 1


# use ComplexUpset package to make an upset plot with a subset of the data
library(ComplexUpset)

pdf("23_orthogroup_plots/one-to-one_orthogroups_plot.complexupset.pdf", height = 5, width = 10, useDingbats = FALSE)

upset(ogroups_presence_absence, genomes, name = "genre", width_ratio = 0.1, wrap = TRUE, set_sizes = FALSE)
dev.off()
