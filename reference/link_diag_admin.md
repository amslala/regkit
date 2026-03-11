# Link diagnostic and demographic datasets using unique personal identifiers

Link diagnostic and demographic datasets using unique personal
identifiers

## Usage

``` r
link_diag_admin(
  data_diag,
  data_admin_inv = NULL,
  data_admin_var = NULL,
  id_col = "id",
  date_col = "year",
  log_path = NULL
)
```

## Arguments

- data_diag:

  A data frame containing pre-processed and pre-validated diagnostic
  data.

- data_admin_inv:

  A data frame containing validated time-invariant administrative
  (sociodemographic) data.

- data_admin_var:

  A data frame containing validated time-variant administrative
  (sociodemographic) data.

- id_col:

  A character string. Name of ID (unique personal identifier) column in
  all of the provided datasets. Default is "id".

- date_col:

  A character string. Name of the date column in time-variant data and
  diagnostic data.

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

## Value

Linked dataset including relevant diagnostic and administrative
(sociodemographic) variables.

## Examples

``` r
# Link diagnostic and time invariant datasets
log_file <- tempfile()
cat("Example log file", file = log_file)

linked_diag_inv <- link_diag_admin(data_diag = diag_df,
                                  data_admin_inv = invar_df,
                                  id_col = "id",
                                  log_path = log_file)
#> Joining diagnostic data with time-invariant administrative data...
#> ✔ Datasets successfully linked: diag_df, invar_df
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> ℹ After joining added 3 columns to 'diag_df': sex, y_birth, and innvandringsgrunn
#> ℹ Rows in 'diag_df': 120256
#> ℹ Rows in 'invar_df': 30024
#> ✔ Total matched rows: 120256

# Link diagnostic and time variant datasets
names(var_df)[names(var_df) == 'year_varying'] <- 'year'
names(diag_df)[names(diag_df) == 'diag_year'] <- 'year'

linked_diag_var <- link_diag_admin(data_diag = diag_df,
                                  data_admin_var = var_df,
                                  id_col = "id",
                                  date_col = "year",
                                  log_path = log_file)
#> Joining with time-variant administrative data...
#> ✔ Datasets successfully linked: diag_df, var_df
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> ℹ After joining added 1 columns to 'diag_df': varying_code
#> ℹ Rows in 'diag_df': 120256
#> ℹ Rows in 'var_df': 270216
#> ✔ Total matched rows: 120256

# Link diagnostic, time invariant and variant datasets
linked_diag_inv_var <- link_diag_admin(data_diag = diag_df,
                                      data_admin_var = var_df,
                                      data_admin_inv = invar_df,
                                      id_col = "id",
                                      date_col = "year",
                                      log_path = log_file)
#> Joining diagnostic data with time-invariant administrative data...
#> ✔ Datasets successfully linked: diag_df, invar_df
#> Joining with time-variant administrative data...
#> ✔ Datasets successfully linked: diag_df, invar_df, var_df
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> ℹ After joining added 4 columns to 'diag_df': sex, y_birth, innvandringsgrunn, and varying_code
#> ℹ Rows in 'diag_df': 120256
#> ℹ Rows in 'var_df': 270216
#> ℹ Rows in 'invar_df': 30024
#> ✔ Total matched rows: 120256
```
