
<!-- README.md is generated from README.Rmd. Please edit that file -->

# regtools

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/amslala/regtools/graph/badge.svg)](https://app.codecov.io/gh/amslala/regtools)
<!-- badges: end -->

The goal of regtools is to assist researchers in performing efficient
and well-documented manipulation, analysis and visualization of data
from Norwegian health and population registers. The package includes
functions for data pre-processing, linkage, and the computation of
relevant statistics and visualizations, such as stratified frequencies,
incidence and prevalence rates.

The regtools package will be of most use to you if you are a researcher
with access to microdata from health and/or administrative registers in
Norway. However, the package also includes simulated registry datasets,
as well as functionality simulate your own datasets with custom
characteristics. As such, it can also be used to explore the
possibilities associated with analyses of data from Norwegian health and
population registries prior to accessing real data.

## Installation

You can install the development version of regtools from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("amslala/regtools")


# or 
# install.packages("devtools")
devtools::install_github("amslala/regtools")
```

### TSD

Researchers working with sensitive individual-level data in Norway will
most likely have their projects (and data) set up in
[TSD](https://www.uio.no/english/services/it/research/sensitive-data/access/)
with no internet access. Although all the main function in `regtools`
work inside of TSD, it is not possible to install R packages directly
from GitHub without internet access. Instead, you can download the
binary for the latest working version from the [Releases
section](https://github.com/amslala/regtools/releases) and import it to
TSD. You can then install it specifying the path of the binary within
TSD:

``` r
install.packages(path =, 
                 repos = NULL,
                 type = "binary")
```
