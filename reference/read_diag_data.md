# Read and validate the structure of diagnostic data

`read_diag_data()` validates the general structure and minimum column
requirements for diagnostic data. The input data sets must be CSV, RDS,
RDA or .SAV files.

## Usage

``` r
read_diag_data(
  file_path,
  id_col = "id",
  date_col = "date",
  code_col = "code",
  log_path = NULL,
  remove_extra = FALSE,
  ...
)
```

## Arguments

- file_path:

  A character string. File path to the diagnostic data to read. Supports
  CSV, RDS, RDA, SAV and parquet (database) files.

- id_col:

  A character string. Name of ID column in data set, default is "id".

- date_col:

  A character string. Name of date column in data set, default is
  "date".

- code_col:

  A character string. Name of diagnostic codes column in data set,
  default is "code".

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

- remove_extra:

  Logical. If `TRUE`, removes any extra columns beside id, date and
  diagnostic code. Default is `FALSE`.

- ...:

  Additional arguments passed to methods or underlying functions.

## Value

A data frame with the validated minimum requirements for diagnostic data

## Examples

``` r
# Read and validate CSV file for diagnostic individual level data.
log_file <- tempfile()
cat("Example log file", file = log_file)

diag_csv <- system.file("extdata", "diag_data.csv", package = "regkit")

diag_data_validated <- read_diag_data(diag_csv,
  id_col = "id",
  date_col = "diag_year",
  log_path = log_file)
#> Reading /home/runner/.cache/R/renv/library/regkit-7ae0198c/linux-ubuntu-noble/R-4.6/x86_64-pc-linux-gnu/regkit/extdata/diag_data.csv file...
#> ✔ Successfully read file: /home/runner/.cache/R/renv/library/regkit-7ae0198c/linux-ubuntu-noble/R-4.6/x86_64-pc-linux-gnu/regkit/extdata/diag_data.csv
#> 
#> Checking column requirements:
#> 
#> ✔ ID column
#> ✔ Code column
#> ✔ Date column
#> 
#> 
#> ────────────────────────────────────────────────────────────────────────────────
#> Diagnostic dataset successfully read and columns validated
#> 
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> 
#> ℹ Number of rows: 120256. Number of columns: 3.
#> 
#> 
#> Rows: 120,256
#> Columns: 3
#> $ id        <chr> "P000000704", "P000000704", "P000000704", "P000000704", "P00…
#> $ code      <chr> "F4522", "F305", "F65", "F840", "F728", "F450", "F187", "F73…
#> $ diag_year <int> 2016, 2020, 2014, 2017, 2014, 2017, 2018, 2020, 2016, 2013, …
```
