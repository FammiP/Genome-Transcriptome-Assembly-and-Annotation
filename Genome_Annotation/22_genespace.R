# ---------------------------------------------------------------
# R Script to Run GENESPACE for Comparative Genomics Analysis
#
# Description:
#   This script runs the GENESPACE pipeline, which performs synteny 
#   and orthology-constrained comparative genomics analysis. It initializes 
#   GENESPACE with a specified working directory containing input files 
#   and then executes the pipeline with the provided parameters.
#
#   Specifically, the script:
#   1. Accepts command-line arguments for flexibility:
#      -> The first argument specifies the directory containing 
#         GENESPACE input files (e.g., genome annotation files and config files).
#   2. Initializes GENESPACE with:
#      - The working directory (`wd`) where the input files are stored.
#      - The path to the `MCScanX` binary (`path2mcscanx`) for collinearity analysis.
#      - A specified number of cores (`nCores`) to enable parallel processing.
#      - Verbose logging for detailed output.
#   3. Runs the GENESPACE pipeline using the specified parameters.
#   4. Overwrites any pre-existing outputs if required.
#
# Prerequisites:
#   - Ensure the GENESPACE library is installed in your R environment.
#   - Verify that `MCScanX` is installed and accessible at the provided path.
#   - The working directory should contain properly formatted GENESPACE input files.
#
# How to Run:
#   - Automatically run by script 22_run_genespace.sh.

# ---------------------------------------------------------------

library(GENESPACE)
args <- commandArgs(trailingOnly = TRUE)

# Define input directory for genespace files and output directory
wd <- args[1]  # Input directory containing genespace files

# Initialize genespace parameters
gpar <- init_genespace(
    wd = wd,
    path2mcscanx = "/usr/local/bin",
    nCores = 20,
    verbose = TRUE
)

# Run genespace
out <- run_genespace(gpar, overwrite = TRUE)