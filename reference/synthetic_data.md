# Create synthetic diagnostic, time-varying and time-invariant individual level data

The `synthetic_data()` function creates individual-level data sets. It
simulates the structure of diagnostic, time-varying and time-invariant
data you might commonly encounter when working with Norwegian medical
and sociodemographic data (e.g. NPR and SSB)

## Usage

``` r
synthetic_data(
  population_size,
  prefix_ids,
  length_ids,
  seed = "123",
  family_codes,
  diag_code_type = "icd",
  pattern = c("increase", "decrease", "random"),
  prevalence = NULL,
  diag_years,
  incidence = NULL,
  sex_vector,
  y_birth,
  filler_codes,
  filler_y_birth,
  invariant_queries = NULL,
  invariant_codes = NULL,
  invariant_codes_filler,
  varying_query = NULL,
  varying_codes = NULL,
  varying_codes_filler = NULL,
  date_classifications = NULL
)
```

## Arguments

- population_size:

  An integer. Number of total population size (individual).

- prefix_ids:

  A character string. Prefix used to construct unique IDs. Default is
  "P000".

- length_ids:

  An integer. Total character length of each ID. Default is 6.

- seed:

  A numerical value. Seed used to ensure reproducible results. Default
  is `seed = 123`

- family_codes:

  A character vector. Relevant diagnostic (either ICD-10 or ICPC-2 codes
  or family of codes. Example: `family_codes = c("F84", "G")`

- diag_code_type:

  A character string. Desired code classification, options are "icd" or
  "icpc". Default is "icd"

- pattern:

  A character string. Pattern of incidence or prevalence rates in
  simulated data. Possible options are "increase", "decrease" or
  "random".

- prevalence:

  A numeric value between 0 and 1. Prevalence rate expressed as a
  proportion.

- diag_years:

  A numeric vector. Years to be used as relevant diagnostic years.

- incidence:

  A numeric value between 0 and 1. Incidence rate expressed as a
  proportion.

- sex_vector:

  A factor or character vector. Factors used to represent sex in the
  simulated data sets.

- y_birth:

  A numeric vector. Years to be used as relevant years of birth.

- filler_codes:

  A character vector. Diagnostic codes or family of codes used as
  fillers. Example: `filler_codes = c("R", "P20")`

- filler_y_birth:

  A numeric vector. Years to be used as filler years of birth.

- invariant_queries:

  A character vector. Uses Statistics Norway API to retrieve desired
  invariant variable classification(s). Example:
  `invariant_queries = c("innvandringsgrunn")`

- invariant_codes:

  Data frame or named list. Codes to be used as relevant invariant codes
  in dataset.

  - If a data frame is provided, column names will be considered as the
    names of the invariant variables.

  - If a named list is provided, the name of each element will be
    consider as the invariant variable name. Example:
    `invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ"), "blodtype" = c("A", "B", "AB", "O"))`

- invariant_codes_filler:

  Data frame or named list. Codes to be used as filler invariant codes
  in dataset.

- varying_query:

  A character string. Uses Statistics Norway API to retrieve desired
  varying variable classification(s). Example:
  `varying_query = c("sivilstand")`

- varying_codes:

  A character vector. Codes to be used as relevant varying codes in
  dataset. Example: `varying_codes = as.character(0:4)`

- varying_codes_filler:

  A character vector. Codes to be used as filler varying codes in
  dataset. Example: `varying_codes_filler = as.character(5:9)`

- date_classifications:

  Date used to retrieve classification system from SSB. Format must be
  **"yyyy-mm-dd"**

## Value

Named list containing two lists. The first list named 'datasets'
includes the data frames with individual level diagnostic and
sociodemographic data. The second list named 'metadata' includes the
exact function call and arguments given by the user

## Examples

``` r
simulated_list <- synthetic_data(
  population_size = 1000,
  prefix_ids = "P000",
  length_ids = 6,
  family_codes = c("F45", "F84"),
  pattern = "increase",
  prevalence = .023,
  diag_years  = c(2012:2020),
  sex_vector = c(0, 1),
  y_birth = c(2010:2018),
  filler_codes = "F",
  filler_y_birth = c(2000:2009),
 invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
  invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
  varying_query = "fylke"
)
#> 
#> ℹ Creating relevant cases with the following characteristics:
#> • Population size = 1000
#> • Prefix IDs = P000
#> • Length IDs = 6
#> • Diagnostic relevant codes = F45 and F84
#> • Pattern of incidence = increase
#> • Prevalence = 0.023
#> • Diagnostic years = 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, and 2020
#> • Incidence =
#> • Coding sex = 0 and 1
#> • Relevant years of birth = 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, and
#> 2018
#> 
#> ℹ Creating filler cases with the following characteristics:
#> • Filler diagnostic codes = F
#> • Filler years of birth = 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008,
#> and 2009
#> • Pattern for filler incidence = 'random'
#> • Number of filler cases to generate = 977
#> 
#> ! This process can take some minutes...
#> 
#> ✔ Succesfully generated diagnostic, time-varying and time-invariant datasets!
```
