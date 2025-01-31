#================================================================
#
# DESCRIPTION:
#   This script analyzes the LTR identity data and generates multiple plots, 
#   including distribution plots, bar plots, and a centromeric TEs distribution plot. 
#   The analysis highlights the percentage identity of LTRs across different clades.
#
# USAGE:
#       srun --time=01:00:00 --mem=4G --cpus-per-task=1 --pty /bin/bash
#       Rscript 04_plot_ltr_clade_data.R
#
# REQUIREMENTS:
#   - R environment with the following libraries installed:
#     `ggplot2`, `dplyr`, `tidyr`
#
# SETUP:
#   1. Load R module:
#      ```
#      module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2
#      ```
#
# INPUT:
#   - Data file: `03_ltr_extracted_data.tsv` containing LTR-TE annotations.
#
# OUTPUT:
#   - Distribution plots (`04_LTR_percent_identity_distribution_.png`)
#   - Bar plot of identity categories (`04_LTR_category_frequency.png`)
#   - Centromeric TE distribution plot (`04_Athila_CRM_percent_identity_distribution.png`)
#
#================================================================

# Load required packages
library(ggplot2)
library(dplyr)
library(tidyr)

# Read the data
df <- read.table("/data/users/fparokkaran/assembly_annotation_course/annotation/outputs/03_ltr_extracted_data.tsv", header = TRUE, sep = "\t")

# Check the data structure
cat("\nData structure:\n")
print(str(df))
cat("#########################################\n")

# ------------------------------------------------------------------------------
# Plot the distribution of Percent_Identity for each Clade
# ------------------------------------------------------------------------------
dist_plot <- ggplot(df, aes(x = Percent_Identity)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "identity", color = "black", fill="steelblue") +
  facet_wrap(~ Clade) + 
  scale_y_continuous(breaks = scales::breaks_pretty(), expand = expansion(mult = c(0, 0.1))) +
  theme_minimal() +
  labs(title = "Distribution of Percent Identity by Clade",
       x = "Percent Identity",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        legend.position = "none")

# Save the distribution plot
dist_plot_file <- paste0("04_LTR_percent_identity_distribution_.png")
ggsave(dist_plot_file, dist_plot, width = 12, height = 8)
print(paste("Distribution plot saved as:", dist_plot_file))

# ------------------------------------------------------------------------------
# Create and Save a Bar Plot of LTR Identity Categories for Each Clade
# ------------------------------------------------------------------------------
# Create identity categories based on Percent_Identity
df <- df %>%
  mutate(Identity_Category = case_when(
    Percent_Identity >= 0.99 ~ "High (99-100%)",
    Percent_Identity < 0.90 & Percent_Identity >= 0.70 ~ "Low",
    TRUE ~ "Other (<70%)"
  ))

# Group by Clade and Identity_Category to count frequencies
df_grouped <- df %>%
  group_by(Clade, Identity_Category) %>%
  summarise(Frequency = n(), .groups = "drop")

# ------------------------------------------------------------------------------
# Check and print the total number of LTR-RTs for each clade
# ------------------------------------------------------------------------------
clade_totals <- df %>%
  group_by(Clade) %>%
  summarise(Total_LTR_RTs = n(), .groups = "drop") %>%
  arrange(desc(Total_LTR_RTs))
cat("\nClades sorted by total number of LTR-RTs:\n")
print(clade_totals)
cat("#########################################\n")

# ------------------------------------------------------------------------------
# Count the number of Low and High identity LTR-RTs for each Clade
# ------------------------------------------------------------------------------
clade_counts <- df_grouped %>%
  filter(Identity_Category %in% c("High (99-100%)", "Low")) %>%
  group_by(Clade, Identity_Category) %>%
  summarise(Count = sum(Frequency), .groups = "drop")


# Print the counts to the console
cat("\nFrequency of Low and High Identity LTR-RTs for each Clade:\n")
print(clade_counts)
cat("#########################################\n")

# ------------------------------------------------------------------------------
# Check and print the total number of High Identity (99-100%) LTR-RTs for each clade
# ------------------------------------------------------------------------------
high_identity_totals <- df %>%
  filter(Percent_Identity >= 0.99) %>%
  group_by(Clade) %>%
  summarise(High_Identity_LTR_RTs = n(), .groups = "drop") %>%
  arrange(desc(High_Identity_LTR_RTs))
cat("\nClades sorted by number of High Identity (99-100%) LTR-RTs:\n")
print(high_identity_totals)
cat("#########################################\n")

# ------------------------------------------------------------------------------
# Check for missing "Low" or "High" categories for each Clade
# ------------------------------------------------------------------------------
expected_categories <- c("High (99-100%)", "Low")
missing_categories <- df_grouped %>%
  filter(Identity_Category %in% expected_categories) %>%
  complete(Clade, Identity_Category = expected_categories, fill = list(Frequency = 0)) %>%
  filter(Frequency == 0)

# Print warnings for any missing categories
if (nrow(missing_categories) > 0) {
  cat("\nWarning: Missing identity categories detected!\n")
  print(missing_categories)
} else {
  cat("\nAll Clades have both 'Low' and 'High' categories represented.\n")
}

# ------------------------------------------------------------------------------
# Create a bar plot for each Clade showing the frequency of Identity Categories
# ------------------------------------------------------------------------------
bar_plot <- ggplot(df_grouped, aes(x = Identity_Category, y = Frequency, fill = Identity_Category)) +
  geom_bar(stat = "identity", color="black") +
  facet_wrap(~ Clade, scales = "fixed") +
  scale_fill_brewer(palette = "Paired") +
  theme_minimal() +
  labs(title = "Frequency of LTR Identity Categories by Clade",
       x = "Identity Category", 
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Save the bar plot
bar_plot_file <- paste0("04_LTR_category_frequency.png")
ggsave(bar_plot_file, bar_plot, width = 12, height = 8)

# Optional: Print the filenames to the console
print(paste("Bar plot saved as:", bar_plot_file))

# ------------------------------------------------------------------------------
# Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae)
# ------------------------------------------------------------------------------
# Filter the dataset for Athila and CRM clades
centromeric_df <- df %>%
  filter(Clade %in% c("Athila", "CRM"))

# Plot the distribution for Athila and CRM clades
centromeric_dist_plot <- ggplot(centromeric_df, aes(x = Percent_Identity, fill = Clade)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "identity", color = "black") +
  facet_wrap(~ Clade, scales = "free_y") + 
  scale_fill_brewer(palette = "Paired") +
  theme_minimal() +
  labs(title = "Distribution of Percent Identity for Centromeric TEs (Athila and CRM)",
       x = "Percent Identity",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        legend.position = "none")  # Remove the legend

# Save the centromeric distribution plot
centromeric_plot_file <- paste0("04_Athila_CRM_percent_identity_distribution.png")
ggsave(centromeric_plot_file, centromeric_dist_plot, width = 12, height = 8)

# Optional: Print the filename to the console
print(paste("Centromeric distribution plot saved as:", centromeric_plot_file))