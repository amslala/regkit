# Harmonize old municipality codes in Norway to 2024 municipality codes

Harmonize old municipality codes in Norway to 2024 municipality codes

## Usage

``` r
harmonize_municipality_codes(data, municipality_col = "code", fylke = FALSE)
```

## Arguments

- data:

  Data frame, or data frame extensions (e.g. tibble).

- municipality_col:

  Character vector. Name of column containing the original municipality
  codes.

- fylke:

  Logical. If `TRUE`, output data frame also includs a column with the
  name of the corresponding fylke in 2024. Default is `FALSE`.

## Value

Data frame with the old and equivalent municipal codes in 2024.

## Examples

``` r
# Harmonize municipality codes from 2016 to 2024

harmonized_codes <- harmonize_municipality_codes(data = kommuner_2016, municipality_col = "code")
#> ! NAs in municipality code column in kommuner_2016: 0
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Successfully matched old municipality codes with harmonized municipality codes
#> ℹ Total matched rows: 429
```
