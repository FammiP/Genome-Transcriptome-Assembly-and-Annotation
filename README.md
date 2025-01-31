# Assembly and Annotation Workflow

This project is developed as part of the following courses:
- 473637 - Genome and Transcriptome Assembly - University of Bern, Switzerland
- SBL.30004 - Organisation and Annotation of Eukaryote Genomes - University of Fribourg, Switzerland

The project is designed to streamline the process of genome assembly, gene annotation, and downstream analyses using a suite of automated scripts and powerful computational tools. Whether you are assembling a new genome or re-annotating an existing one, this pipeline provides a modular, step-by-step framework to handle raw sequence processing, genome assembly, annotation refinement, and evaluation.
The pipeline includes robust preprocessing and quality control steps, multiple assembly options, transposable element identification, and gene orthology mapping to ensure comprehensive genomic insights. 

## Installation

1. Clone this repository to your local machine.

```shell
https://github.com/FammiP/Genome-Transcriptome-Assembly-and-Annotation
```

## Step-by-Step Workflow

### Preprocessing and Quality Control

- 01_run_fastqc_apt.sh --> Runs quality control using FastQC to assess raw read quality. 
- 02_run_fastp.sh --> Performs quality filtering and trimming of sequencing reads using fastp.
- 03_kmer_count.sh --> Estimates genome size and k-mer distributions.

### Assembly Phase
- 04_flye_assembly.sh --> Assembles long-read data using the Flye assembler.
- 05_hifiasm_assembly.sh --> ssembles PacBio HiFi data with Hifiasm for high-quality genome reconstruction.
- 06_LJA_assembly.sh --> Utilizes the LJA assembler for efficient genome assembly.
- 07_trinity_assembly.sh --> Assembles transcriptome data using Trinity.


### Assembly Evaluation
- 08_run_BUSCO_evaluation.sh --> Assesses assembly completeness using BUSCO.
- 8_run_merqury_evaluation.sh --> Quality evaluation of assemblies using Merqury for k-mer-based validation.
- 08_run_QUAST_evaluation.sh --> Structural comparison and quality assessment using QUAST.
- 09_comparing_genomes.sh --> Performs genome comparison analysis to identify structural differences.

### Annotation Pipeline
- 01_edta_annotation.sh --> Executes the EDTA pipeline for transposable element (TE) annotation.
- 02_get_clades_tesorter.sh --> Identifies TE clades using Tesorter.
- 03_ltr_identity_clades.sh --> Analyzes LTR retrotransposon clades and structural features.
- 04_plot_ltr_clade_data.R --> Generates visual plots for LTR clade analysis.
- 05_generate_fai_index.sh --> Creates .fai index for reference sequences.

### TE and Structural Variant Analysis
- 06_plot_TE_density_circlize.R --> Plots TE density using Circlize for genomic visualization.
- 07_classify_copia_gypsy_tesorter.sh --> Classifies Copia and Gypsy retrotransposons.
- 08_parse_repeatmasker_output.sh --> Processes RepeatMasker output for TE annotation.
- 09_analyze_te_divergence_age.R --> Analyzes TE divergence and age estimates.
- 10_prepare_rt_sequences.sh --> Prepares reverse transcriptase sequences for phylogenetic analysis.
- 11_run_phylogenetic_analysis.sh --> Performs phylogenetic reconstruction for annotated elements.

### Maker Annotation Pipeline
- 12_generate_color_strip_template.sh --> Generates template files for visualization of annotation output.
- 13_generate_control_files_maker.sh --> Creates configuration files for the Maker annotation tool.
- 14_run_maker.sh --> Runs the Maker annotation pipeline.
- 15_prepare_maker_output.sh --> Processes Maker outputs for downstream analysis.
- 16_refine_gene_annotations.sh --> Refines and filters predicted gene annotations.

### Final Analysis and Isoform Extraction
- 17_extract_longest_isoforms.sh --> Extracts the longest isoforms from annotated genes.
- 18_run_busco_GENE.sh --> Runs BUSCO on gene models for functional completeness.
- 19_blast.sh --> Conducts BLAST searches for gene validation.
- 20_omark.sh --> Performs marker-based annotation refinement.
- 21_refine_gene_annotation.sh --> Final step in refining gene models based on multiple evidence sources.
- 22_create_genespace_folders.sh / .R --> Prepares folders and input data for Genespace orthology analysis.
- 22_run_genespace.sh --> Executes Genespace to identify orthologous regions.
- 23_parse_orthofinder.R --> Processes Orthofinder output for ortholog assignment.

### Custom Python and Perl Utilities

- omark_contextualize.py: Custom utility for marker-based contextual refinement.
- parseRM.pl: Parses RepeatMasker outputs for summary statistics.

## How to Run

1. First, cd into scripts directory 
```
sbatch 01-run_fastqc_apt.sh
```


