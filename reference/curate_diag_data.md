# Curate diagnostic data

Curate diagnostic data

## Usage

``` r
curate_diag_data(
  data,
  min_diag = 1,
  first_diag = TRUE,
  id_col = "id",
  code_col = "icd_code",
  date_col = "date",
  log_path = NULL
)
```

## Arguments

- data:

  A data frame containing pre-processed and validated diagnostic data.

- min_diag:

  Integer. Number of minimum amount of diagnostic events. Default is 1.

- first_diag:

  Logical. If `TRUE`, keep only information from the first recorded
  diagnostic event. Default set to TRUE. Default is `TRUE`.

- id_col:

  A character string. Name of ID column in `data`, default is "id"

- code_col:

  A character string. Name of column containing the ICD-10 codes in
  `data`, default is "icd_code"

- date_col:

  A character string. Name of column containing the diagnostic date in
  `data`, default is "date"

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

## Value

Curated diagnostic data: minimum diagnostic events, and/or first ever
diagnosis information

## Examples

``` r
# Keep only curated diagnostic data
# for example minimum diagnostic events or first recorded diagnosis

log_file <- tempfile()
cat("Example log file", file = log_file)

curated_diag_df <- curate_diag_data(data = diag_df,
                               min_diag = 1,
                               first_diag = TRUE,
                               id_col = "id",
                               code_col = "code",
                               date_col = "diag_year",
                               log_path = log_file)
#> ✔ Filtered observations that do not have at least 1 diagnostic event
#> ✔ Summarized first diagnostic event information
#> 
#> ────────────────────────────────────────────────────────────────────────────────
#> Diagnostic dataset successfully curated and summarized
#> 
#> ℹ Filtered 90232 rows (75% removed)
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> 
#> ── After filtering: 
#> ℹ Remaining number of rows: 30024
#> ℹ Remaining number of columns: 4
#> ℹ Unique IDs in dataset: 30024
#> ℹ ICD-10 codes in dataset: F726, F639, F543, F872, F868, F150, F323, F115, F959, F182, F913, F1620, F060, F337, F1319, F701, F8181, F965, …, F923, and F075
#> 
#> tibble [30,024 × 4] (S3: tbl_df/tbl/data.frame)
#>  $ id               : chr [1:30024] "P000000037" "P000000052" "P000000059" "P000000111" ...
#>  $ code             : chr [1:30024] "F750" "F035" "F198" "F230" ...
#>  $ y_diagnosis_first: int [1:30024] 2018 2012 2013 2012 2013 2012 2013 2013 2013 2013 ...
#>  $ diagnosis_count  : int [1:30024] 2 5 2 2 5 6 3 4 4 5 ...
```
