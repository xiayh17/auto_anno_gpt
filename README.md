# GPT-4 Cell Type Annotation for Spatial Transcriptomics

This repository contains an R script demonstrating the use of GPT-4 for cell type annotation in spatial transcriptomics data, specifically for 10x Genomics Visium data.

## Overview

The script `find_marker.Rmd` provides a workflow for:

1. Loading and preprocessing Visium spatial transcriptomics data
2. Performing dimensionality reduction and clustering
3. Finding marker genes for each cluster
4. Preparing data for GPT-4 annotation
5. Simulating GPT-4 cell type annotation (placeholder)
6. Visualizing the GPT-4 annotations
7. Comparing results with a scRNA-seq reference dataset

## Requirements

- R (>= 4.0.0)
- Seurat (>= 5.0.0)
- SeuratData
- ggplot2
- patchwork
- dplyr

## Data

The script uses the following datasets:

- 10x Genomics Visium spatial transcriptomics data of the mouse brain (accessed via SeuratData)
- Allen Brain Atlas scRNA-seq reference data (not included, must be downloaded separately)

## Usage

1. Clone this repository
2. Open `find_marker.Rmd` in RStudio
3. Install required packages
4. Run the script chunk by chunk

Note: The GPT-4 annotation step is a placeholder. To use actual GPT-4 annotations, you would need to implement API calls to the GPT-4 service.

## Contributing

Contributions to improve the script or extend its functionality are welcome. Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This script is based on the Seurat spatial transcriptomics vignette
- Thanks to the developers of Seurat and all other used R packages
