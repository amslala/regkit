# Read and validate the structure of administrative (sociodemographic) individual-level data

`read_admin_data()` validates the general structure and minimum column
requirements for administrative (sociodemographic) individual-level
data. The input data sets must be CSV, RDS, RDA or .SAV files.

## Usage

``` r
read_admin_data(
  file_path,
  data_type = c("t_variant", "t_invariant"),
  id_col = "id",
  date_col = "date",
  log_path = NULL,
  ...
)
```

## Arguments

- file_path:

  A character string. File path to the demographic data to read.
  Supports CSV, RDS, RDA, SAV and parquet (dataset) files.

- data_type:

  A character string. Administrative (sociodemographic) data can either
  be of type "t_variant" or "t_invariant", necessary to check correct
  data structure characteristics.

- id_col:

  A character string. Name of ID column in data set. Default is "id".

- date_col:

  A character string. Name of date column in data set, default is
  "date".

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

- ...:

  Additional arguments passed to methods or underlying functions.

## Value

A data frame with the validated minimum requirements for administrative
(sociodemographic) data.

## Examples

``` r
# Read and validate CSV file for varying individual level administrative (sociodemographic) data
admin_csv <- system.file("extdata", "invar_data.csv", package = "regtools")
log_file <- tempfile()
cat("Example log file", file = log_file)

admin_data_validated <- read_admin_data(admin_csv, data_type = "t_invariant",
id_col = "id", log_path = log_file)
#> 
#> Reading /home/runner/.cache/R/renv/library/regtools-66178653/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu/regtools/extdata/invar_data.csv file...
#> ✔ Successfully read file: /home/runner/.cache/R/renv/library/regtools-66178653/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu/regtools/extdata/invar_data.csv
#> Checking column requirements:
#> ✔ ID column
#> Data type: time invariant. Checking requirements...
#> ✔ No duplicate IDs
#> 
#> 
#> ────────────────────────────────────────────────────────────────────────────────
#> Administrative (sociodemographic) dataset successfully read and columns validated
#> 
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> 
#> ℹ Number of rows: 30024. Number of columns: 4.
#> ℹ Unique IDs in dataset: 30024.
#> 
#> 
#> Rows: 30,024
#> Columns: 4
#> $ id                <chr> "P000000037", "P000000052", "P000000059", "P00000011…
#> $ sex               <int> 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1…
#> $ y_birth           <int> 2008, 2000, 2007, 2003, 2000, 2003, 2009, 2005, 2004…
#> $ innvandringsgrunn <chr> "FAMM", "FAMM", "FAMM", "FAMM", "UTD", "FAMM", "UTD"…
```
