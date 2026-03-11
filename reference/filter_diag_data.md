# Validate and filter diagnostic data by selected ICD-10 or ICPC-2 codes

Validate and filter diagnostic data by selected ICD-10 or ICPC-2 codes

## Usage

``` r
filter_diag_data(
  data,
  codes = NULL,
  pattern_codes = NULL,
  classification = "icd",
  id_col = "id",
  code_col = "code",
  date_col = NULL,
  diag_dates = NULL,
  rm_na = TRUE,
  add_description = FALSE,
  log_path = NULL
)
```

## Arguments

- data:

  A data frame containing pre-processed diagnostic data.

- codes:

  A character vector. ICD-10 or ICPC-2 codes to validate and filter in
  `data`

- pattern_codes:

  A character vector. Pattern of ICD-10 or ICPC-2 codes to validate and
  filter in `data`. For example, F84 will use all codes starting with
  F84 (F840, F841, F842, F844, etc).

- classification:

  A character string. Classification used in diagnostic codes: ICD-10 or
  ICPC-2. Options are "icd" or "icpc". Default is "icd".

- id_col:

  A character string. Name of the ID column in `data`, default is "id"

- code_col:

  A character string. Name of the column containing the ICD-10 or ICPC-2
  codes in `data`, default is "code"

- date_col:

  A character string. Name of the column containing the date of the
  diagnostic event. Only needed i if you want to filter by diagnosis
  date. Default is `NULL`.

- diag_dates:

  A character vector. Dates (years, months, etc) that you want to filter
  the diagnostic data by.

- rm_na:

  Logical. Should rows with NA in the non-filtered columns be removed?
  Default is `FALSE`

- add_description:

  Logical. If `TRUE` new column will be added with description of ICD-10
  or ICPC-2 code. Note: not all code descriptions are available.

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

## Value

Filtered and validated diagnostic data frame containing only relevant
observations based on diagnostic codes of interest.

## Examples

``` r
# Validate that F45 and F84 are real codes/family of codes in ICD-10.
# Keep only rows with codes containing F45 and F84.

log_file <- tempfile()
cat("Example log file", file = log_file)

filtered_diag_df <-  filter_diag_data(data = diag_df,
                                 pattern_codes = c("F45", "F84"),
                                 id_col = "id",
                                 code_col = "code",
                                 log_path = log_file,
                                 rm_na = FALSE
                                 )
#> Checking that code exists in ICD-10 or ICPC-2 code list...
#> ✔ Selected codes/pattern are valid: F450, F451, F452, F453, F4530, F4531, F4532, F4533, F4534, F4538, F454, F458, F459, F840, F841, F842, F843, F844, F845, F848, F849
#> 
#> Filtering data by selected codes...
#> 
#> ────────────────────────────────────────────────────────────────────────────────
#> Diagnostic dataset successfully filtered
#> 
#> ℹ Filtered 117717 rows (97.9% removed)
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> 
#> ── After filtering: 
#> ℹ Remaining number of rows: 2539
#> ℹ Remaining number of columns: 3
#> ℹ Unique IDs in dataset: 2464
#> ℹ Unique codes in dataset: 28
#> ℹ Codes in dataset: "F4520", "F454", "F840", "F845", "F4529", "F456", "F4541", "F841", "F4522", "F844", "F842", "F849", "F457", "F846", "F455", "F452", "F45", "F847", …, "F459", and "F843"
#> 
#> Rows: 2,539
#> Columns: 3
#> $ id        <chr> "P000000704", "P000000704", "P000000886", "P000001615", "P00…
#> $ code      <chr> "F4522", "F840", "F450", "F845", "F4520", "F455", "F457", "F…
#> $ diag_year <int> 2016, 2017, 2017, 2020, 2019, 2016, 2019, 2020, 2013, 2019, …
```
