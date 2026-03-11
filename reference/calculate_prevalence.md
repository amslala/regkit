# Calculate prevalence rates

The `calculate_prevalence()` function calculates prevalence rates based
on the given diagnostic and demographic information. Prevalence
represents the number of cases of a given diagnosis that exist in a
population of interest at a specified point or period in time.

## Usage

``` r
calculate_prevalence(
  linked_data,
  id_col = "id",
  date_col = "date",
  pop_data = NULL,
  pop_col = "pop_count",
  time_p,
  grouping_vars = NULL,
  CI = TRUE,
  CI_level = 0.99,
  only_counts = FALSE,
  suppression = TRUE,
  suppression_threshold = 5,
  log_path = NULL
)
```

## Arguments

- linked_data:

  A data frame containing linked relevant diagnostic and demographic
  information.

- id_col:

  A character string. Name of ID (unique personal identifier) column in
  `linked_data`. Default is "id".

- date_col:

  A character string. Name of the date column in `linked_data`. Default
  is "date".

- pop_data:

  A data frame containing corresponding population count information.

- pop_col:

  A character string. Name of the column containing population counts in
  `pop_data`.

- time_p:

  A numeric value or numeric vector. Time point or time period used to
  calculate the incidence.

  - For period prevalence, specify as a range. The first value of the
    vector is the period's lower bound, and the second element is the
    period's upper bound. Example: `time_p = c(2010,2015)`

  - For point prevalence, single numeric value. Example: `time_p = 2010`

- grouping_vars:

  Character vector (optional). Grouping variables for the aggregation of
  diagnostic counts (e.g. sex, education).

- CI:

  Logical. Want to compute binomial confidence intervals? Default is
  `TRUE`.

  - If `TRUE`, add two new columns with the upper and lower CI bound
    with significance level defined by `CI_level`. Uses the
    Pearson-Klopper method.

- CI_level:

  A numerical value between 0 and 1. Level for confidence intervals,
  default is set to 0.99

- only_counts:

  Logical. Only want diagnostic counts? Default is `FALSE`.

  - If `TRUE`, return only counts.

- suppression:

  Logical. Suppress results (counts and rates) in order to maintain
  statistical confidentiality? Default is `TRUE`.

  - If `TRUE`, applies primary suppression (NA) to any value under the
    threshold defined by `suppression_threshold`

- suppression_threshold:

  Integer. Threshold used for suppression, default is set to 5 (NPR
  standard).

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

## Value

Prevalence rate table

## Examples

``` r
log_file <- tempfile()
cat("Example log file", file = log_file)

pop_df <- tibble::tibble(year = "2012-2020", population = 30024)
linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

prevalence_df <- calculate_prevalence(linked_df,
  id_col = "id",
  date_col = "year",
  pop_data = pop_df,
  pop_col = "population",
  time_p = c(2012,2020),
  CI = TRUE,
  CI_level = 0.95,
  only_counts = FALSE,
  suppression = TRUE,
  suppression_threshold = 10,
  log_path = log_file)
#> Computing prevalence rates/counts...
#> ✔ Suppressed counts using 10 threshold
#> ℹ Removed 0 cells out of 1
#> Joining with `by = join_by(year)`
#> 
#> ✔ Prevalence rates ready!
#> 
#> ── Summary ─────────────────────────────────────────────────────────────────────
#> ℹ Diagnostic and demographic data: linked_df
#> ℹ Population data: pop_df
#> ℹ Grouped by variables: 
#> ℹ For time point/period:  2012 and 2020
```
