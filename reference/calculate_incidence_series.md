# Calculate incidence series rates

The `calculate_incidence_series()` function calculates incidence rates
series based on the given diagnostic and demographic information. Use
[`calculate_incidence()`](https://amslala.github.io/regkit/reference/calculate_incidence.md)
function for only one time period or time point. incidence represents
the number of new cases of a given diagnosis in a population of interest
at a specified point or period in time.

## Usage

``` r
calculate_incidence_series(
  linked_data,
  type,
  time_points,
  id_col = "id",
  date_col = "date",
  pop_data = NULL,
  pop_col = "pop_count",
  person_time_data = NULL,
  person_time_col = NULL,
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
  information.

- type:

  Character string. Valid options are "cumulative" or "rate".

- time_points:

  A list containing either individual time points or time period
  (range).

  - For time points, each element of the list should be an individual
    year. For example, `time_points = list(2012, 2013, 2014)`

  - For time periods, each element of the list should have two years
    representing the range of years in the desired period. For example,
    `time_points <- list(c(2012,2014), c(2014,2016), c(2016,2018))`

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

- person_time_data:

  A data frame containing corresponding person-time information.

- person_time_col:

  A character string. Name of the column containing person-time counts
  in `person_time_data`.

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

incidence series for specified time points/periods

## Examples

``` r
# Set up a temporary log file
log_file <- tempfile()
cat("Example log file", file = log_file)

# Set seed for reproducibility
set.seed(123)

pop_df <- tibble::tibble(year = c(2012:2020), population = floor(runif(9, min=3000, max=4000)))
linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

incidence_df <- calculate_incidence_series(linked_df,
  time_points = list(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020),
  type = "cumulative",
  id_col = "id",
  date_col = "year",
  pop_data = pop_df,
  pop_col = "population",
  only_counts = FALSE,
  suppression = TRUE,
  suppression_threshold = 1,
  CI = TRUE,
  CI_level = 0.95,
  log_path = log_file)
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
#> 
#> ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
#> 
#> 
#> ✔ Suppressed counts using 1 threshold
#> ℹ Removed 0 cells out of 1
#> 
#> Joining with `by = join_by(year)`
#> 
#> ✔ Cumulative incidence ready
```
