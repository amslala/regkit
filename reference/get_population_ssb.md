# Get yearly population data from SSB, by region, sex and age.

Get yearly population data from SSB, by region, sex and age.

## Usage

``` r
get_population_ssb(
  url_api = "https://data.ssb.no/api/v0/en/table/07459/",
  regions = c("norway", "fylker", "kommuner"),
  years,
  ages,
  aggregate_age = TRUE,
  by_sex = TRUE,
  save_xslx = FALSE
)
```

## Arguments

- url_api:

  Character string. URL used for the SSB API call. *Do not modify*.

- regions:

  Character string. Supported regions:

  - "norway" for the country-wise population counts

  - "fylker" for county population counts

  - "kommuner" for municipality population counts (excluding Svalbard
    and Jan Mayen). Due to region reforms in Norway, the results are
    shown using SSB's harmonized county codes (2024)

- years:

  Numerical vector. Year(s) of population counts.

- ages:

  Numerical vector. Age(s) in whole years.

- aggregate_age:

  Logical. Default is `TRUE`.

  - If `TRUE` and more than one age given, include new row with
    aggregated population for age group.

- by_sex:

  Logical. Default is `TRUE`.

  - If `TRUE` population counts are disaggregated by sex (male, female)

- save_xslx:

  Logical. Want to save the results as a xslx? Default is `FALSE`.

  - If `TRUE` results are saved as xslx in the current working
    directory.

## Value

Data frame with population data from SSB

## Examples

``` r
# Population of Norway in 2020 to 2022, for ages 10 to 15,
# include total of that age group (10-15) for each year.
population_norway <- get_population_ssb(regions = "norway",
                                        years = c(2020:2022),
                                        ages = c(10:15),
                                        aggregate_age = TRUE,
                                        by_sex = TRUE,
                                        save_xslx = FALSE)
#> ℹ Retrieving population of norway for the years: 2020,2021,2022, and ages: 10,11,12,13,14,15
#> ℹ Aggregating ages...
#> ✔ Population dataset ready!
```
