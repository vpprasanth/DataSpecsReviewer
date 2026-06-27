# DataSpecsReviewer

An R package and Shiny application for generating dataset specification workbooks and performing data quality reviews for SAS, Excel, XLSB, and CSV datasets.

## Installation

```r
# install.packages("remotes")
remotes::install_github("vpprasanth/DataSpecsReviewer")
```

## Launch

```r
library(DataSpecsReviewer)
data_review() # or
# dsr() # or
# DSR()
```

## Features

- Dataset inventory and metadata profiling
- Specification workbook generation
- Missingness review
- Duplicate ID checks
- Cardinality review
- Sentinel value and sentinel date detection
- Numeric outlier review
- Interactive Shiny exploration
- Formatted Excel workbook export with index navigation

## Supported Input Files

- SAS7BDAT
- XLS
- XLSX
- XLSM
- XLSB
- CSV, including comma-, semicolon-, and tab-delimited files

## Credits

The DataSpecsReviewer package was inspired by Jeffrey Meyers’ SAS-based macro for summarizing data.

Package and Shiny App Author: Prasanth V.P.
Email: prasanth.stat@gmail.com
