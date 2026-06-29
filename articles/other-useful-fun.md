# Other useful functions

This vignette describes some additional function in `regkit` that can be
useful when working with registry data in Norway. It is important to
note that the
[`get_population_ssb()`](https://amslala.github.io/regkit/reference/get_population_ssb.md)
function requires an internet connection and therefore only works
outside of TSD (Services for sensitive data).

## Harmonize municipality codes

In general terms, Norway is administratively divided in two main levels:
counties (fylker) and municipalities (kommuner). During the past 10
years, Norway has undergone a municipal structural reform with the
purpose of building larger local governments. Starting in 2016, several
Norwegian municipalities have merged with each other and in some cases
have changed counties. The amount of municipalities was progressively
reduced from 428 to 357 municipalities in the period between 2017-2020.
Similarly, the amount of counties has been reduced from 19 counties in
2018 to 11 counties in 2020, before being increased again to 15 counties
in 2024.

The constant changes in the administrative structure of Norway exemplify
common challenges of working with registry data. For instance, the
merging of municipalities and counties hinders analyses with
geographical components, as the population composition of the different
regions in Norway has significantly changed. This problem is specially
evident in longitudinal analysis as the ability to compare between
different time periods can be affected by changes in the classification
systems.

One way of ensuring the comparability between different time points is
to use harmonized classifications. As most of the changes in the
structural reforms represent the merging of municipalities or counties,
it is possible to know what the municipality code in 2010 would be in
the new merged municipalities in 2024. However, in the case of
municipalities that split up through the years, it is not possible to
know exactly what there equivalent would be. For important time series,
Statistics Norway currently publishes results using this harmonized
classifications.

For example, imagine you have individual-level data for your population
of interest including place of residence in the year 2017 and 2024.
However, you want to determine whether the prevalence of a certain
disease has significantly changed between 2024 and 2017 by place of
residence. The first step would be to ensure that all the codes and
classifications in your data have stayed consistent and are comparable
between 2017 and 2024. The function
[`harmonize_municipality_codes()`](https://amslala.github.io/regkit/reference/harmonize_municipality_codes.md)
aids researchers to harmonize municipality codes (between 1994-2024):

``` r


# Silenced CLI output for this example
simulated_list <- regkit::simulate_data(
  population_size = 100,
  prefix_ids = "P000",
  length_ids = 6,
  family_codes = c("F45", "F84"),
  pattern = "increase",
  prevalence = .023,
  diag_years  = 2017,
  sex_vector = c(0,1),
  y_birth = c(2010:2018),
  filler_codes = "F",
  filler_y_birth = c(2000:2009),
  invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
  invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
  varying_query = "kommune",
  date_classifications = "2017-01-01", 
  seed = 123
)

residence_df <- simulated_list$datasets$var_df 
```

The `residence_df` includes then a column varying_code with the
municipality codes in 2017.

``` r


head(residence_df)
#> # A tibble: 6 × 3
#>   id         year_varying varying_code
#>   <chr>             <dbl> <chr>       
#> 1 P000025558         2017 1868        
#> 2 P000037543         2017 1003        
#> 3 P000043041         2017 1233        
#> 4 P000053240         2017 1502        
#> 5 P000090076         2017 0402        
#> 6 P000117065         2017 0833
```

Using
[`harmonize_municipality_codes()`](https://amslala.github.io/regkit/reference/harmonize_municipality_codes.md)
you can easily get the harmonized codes (standard 2024), harmonized name
and corresponding county in 2024.

``` r

residence_df_harmonized <- regkit::harmonize_municipality_codes(
  data = residence_df,
  municipality_col = "varying_code", 
  fylke = TRUE)
#> ! NAs in municipality code column in residence_df: 0
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Successfully matched old municipality codes with harmonized municipality codes
#> ℹ Total matched rows: 100

head(residence_df_harmonized)
#> # A tibble: 6 × 7
#>   id        year_varying varying_code harmonized_code harmonized_name fylke_code
#>   <chr>            <dbl> <chr>        <chr>           <chr>           <chr>     
#> 1 P0000255…         2017 1868         K.1868          Øksnes          18        
#> 2 P0000375…         2017 1003         K.4206          Farsund         42        
#> 3 P0000430…         2017 1233         K.4620          Ulvik           46        
#> 4 P0000532…         2017 1502         K.1506          Molde           15        
#> 5 P0000900…         2017 0402         K.3401          Kongsvinger     34        
#> 6 P0001170…         2017 0833         K.4034          Tokke           40        
#> # ℹ 1 more variable: fylke_name <chr>
```

## Get population SSB

[`get_population_ssb()`](https://amslala.github.io/regkit/reference/get_population_ssb.md)
is a useful wrapper of the function ApiData() from the package
PxWebApiData. The main goal of this function its to facilitate
retrieving population information from Statistics Norway, and performing
some handy operations like aggregating ages or sex. As mentioned before,
this function requires an internet connection and will most likely not
work inside of a secure environment (like TSD).

If you would want to get the population in 2020 and 2021 for every
county in Norway using the harmonized codes we have previously mentioned
for individuals aged 10-15:

``` r

population_fylke<- get_population_ssb(
  regions = "fylker", 
  years = c(2020, 2021), 
  ages = c(10:15),
  aggregate_age = TRUE,
  by_sex = TRUE,
  save_xslx = FALSE)
#> ℹ Retrieving population of fylker for the years: 2020,2021, and ages: 10,11,12,13,14,15
#> ℹ Aggregating ages...
#> ✔ Population dataset ready!

head(population_fylke, 10)
#> # A tibble: 10 × 7
#>    region_code sex_code age   year  population region_name   sex_value
#>    <chr>       <chr>    <chr> <chr>      <int> <chr>         <chr>    
#>  1 03          1        010   2020        3742 Oslo - Oslove Males    
#>  2 03          1        011   2020        3678 Oslo - Oslove Males    
#>  3 03          1        012   2020        3645 Oslo - Oslove Males    
#>  4 03          1        013   2020        3365 Oslo - Oslove Males    
#>  5 03          1        014   2020        3291 Oslo - Oslove Males    
#>  6 03          1        015   2020        3249 Oslo - Oslove Males    
#>  7 03          1        Total 2020       20970 Oslo - Oslove Males    
#>  8 03          1        010   2021        3687 Oslo - Oslove Males    
#>  9 03          1        011   2021        3702 Oslo - Oslove Males    
#> 10 03          1        012   2021        3658 Oslo - Oslove Males
```
