# Calculate incidence rates

The `calculate_incidence()` function calculates incidence rates based on
the given diagnostic and demographic information. Incidence represents
the number of new cases of a given diagnosis that exist in a population
of interest at a specified point or period in time.

## Usage

``` r
calculate_incidence(
  linked_data,
  type = c("cumulative", "rate"),
  id_col = "id",
  date_col = "date",
  pop_data = NULL,
  pop_col = "pop_count",
  person_time_data = NULL,
  person_time_col = NULL,
  time_p = NULL,
  grouping_vars = NULL,
  only_counts = FALSE,
  suppression = TRUE,
  suppression_threshold = 5,
  CI = TRUE,
  CI_level = 0.99,
  log_path = NULL
)
```

## Arguments

- linked_data:

  A data frame containing linked relevant diagnostic and demographic
  information. Should include only first time diagnosis, see
  'curate_diag'

- type:

  Character string. Valid options are "cumulative" or "rate".

- id_col:

  A character string. Name of ID (unique personal identifier) column in
  `linked_data`. Default is "id".

- date_col:

  A character string. Name of the date column in `linked_data`. Default
  is "date".

- pop_data:

  A data frame containing corresponding population at risk information.

- pop_col:

  A character string. Name of the column containing population counts in
  `pop_data`.

- person_time_data:

  A data frame containing corresponding person-time information.

- person_time_col:

  A character string. Name of the column containing person-time counts
  in `person_time_data`.

- time_p:

  A numeric value or numeric vector. Time point or time period used to
  calculate the incidence.

  - For time period, specify as a range. The first value of the vector
    is the period's lower bound, and the second element is the period's
    upper bound. Example: `time_p = c(2010,2015)`

  - For time point, single numeric value. Example: `time_p = 2010`

- grouping_vars:

  Character vector (optional). Grouping variables for the aggregation of
  diagnostic counts (e.g. sex, education).

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

- CI:

  Logical. Want to compute binomial confidence intervals? Default is
  `TRUE`.

  - If `TRUE`, add two new columns with the upper and lower CI bound
    with significance level defined by `CI_level`. Uses the
    Pearson-Klopper method.

- CI_level:

  A numerical value between 0 and 1. Level for confidence intervals,
  default is set to 0.99

- log_path:

  A character string. Path to the log file to append function logs.
  Default is `NULL`.

  - If `NULL`, a new directory `/log` and file is created in the current
    working directory.

## Value

Incidence table

## Examples

``` r
log_file <- tempfile()
cat("Example log file", file = log_file)

pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

incidence_df <- calculate_incidence(linked_df,
  type = "cumulative",
  id_col = "id",
  date_col = "year",
  pop_data = pop_df,
  pop_col = "population",
  time_p = c(2012,2013),
  only_counts = FALSE,
  suppression = TRUE,
  suppression_threshold = 10,
  log_path = log_file)
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 10 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready

```
