# Filter administrative (sociodemographic) data by selected filtering parameters

Filter administrative (sociodemographic) data by selected filtering
parameters

## Usage

``` r
filter_admin_data(
  data,
  data_type = c("t_variant", "t_invariant"),
  filter_param,
  id_col = NULL,
  any = FALSE,
  rm_na = TRUE,
  log_path = NULL
)
```

## Arguments

- data:

  A data frame containing pre-processed administrative
  (sociodemographic) data.

- data_type:

  A character string. Type of administrative (sociodemographic) data:
  "t_variant" or "t_invariant"

- filter_param:

  A named list containing filtering parameters. The names in the list
  are the column names and the values are vectors of values to keep.

- id_col:

  A character string. Name of ID column in data set.

  - Optional, necessary only when `any = TRUE`

- any:

  Logical. Filtering option, keeps individuals that have ever fulfilled
  any of the filtering parameters. **Not supported in parquet
  datasets.** Default is `FALSE`

- rm_na:

  Logical. Should rows with NA in the non-filtered columns be removed?
  Default is `FALSE`

  - If `TRUE`, removes observations that have NA in any of the
    non-filtered columns.

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

## Value

Filtered administrative (sociodemographic) dataframe containing only
relevant observations based on the filtering parameters.

## Examples

``` r
# Filter varying and unvarying datasets

log_file <- tempfile()
cat("Example log file", file = log_file)

filtered_var <- filter_admin_data(data = var_df,
data_type = "t_variant",
filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("1146")),
log_path = log_file)
#> Filtering time-variant dataset...
#> ✔ Filtered time-variant by 'year_varying and varying_code' column(s)
#> ℹ Filtered 270216 rows (100% removed)
#> 
#> ! The dataset has no NAs or they are coded in a different format.
#> 
#> ────────────────────────────────────────────────────────────────────────────────
#> administrative (sociodemographic) dataset successfully filtered
#> 
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> 
#> ── After filtering: 
#> ℹ Remaining number of rows: 0
#> ℹ Remaining number of columns: 3
#> 
#> Rows: 0
#> Columns: 3
#> $ id           <chr> 
#> $ year_varying <int> 
#> $ varying_code <chr> 


filtered_invar <- filter_admin_data(data = invar_df, data_type = "t_invariant",
filter_param = list("y_birth" = c(2006:2008),
"innvandringsgrunn" = c("FAMM", "UTD")),
rm_na = FALSE,
log_path = log_file)
#> Filtering time-invariant dataset...
#> ✔ Filtered time-invariant dataset by 'y_birth and innvandringsgrunn' column(s)
#> ℹ Filtered 21140 rows (70.4% removed)
#> 
#> ────────────────────────────────────────────────────────────────────────────────
#> administrative (sociodemographic) dataset successfully filtered
#> 
#> 
#> ── Data Summary ────────────────────────────────────────────────────────────────
#> 
#> ── After filtering: 
#> ℹ Remaining number of rows: 8884
#> ℹ Remaining number of columns: 4
#> 
#> Rows: 8,884
#> Columns: 4
#> $ id                <chr> "P000000037", "P000000059", "P000000431", "P00000083…
#> $ sex               <fct> 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1…
#> $ y_birth           <int> 2008, 2007, 2007, 2006, 2006, 2008, 2007, 2006, 2008…
#> $ innvandringsgrunn <chr> "FAMM", "FAMM", "UTD", "UTD", "UTD", "UTD", "FAMM", …
```
