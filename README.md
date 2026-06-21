
<!-- README.md is generated from README.Rmd. Please edit that file -->

# regkit

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/amslala/regkit/graph/badge.svg)](https://app.codecov.io/gh/amslala/regkit)
<!-- badges: end -->

The goal of regkit is to assist researchers in performing efficient and
well-documented manipulation, analysis and visualization of data from
Norwegian health and population registers. The package includes
functions for data pre-processing, linkage, and the computation of
relevant statistics and visualizations, such as stratified frequencies,
incidence and prevalence rates.

The regkit package will be of most use to you if you are a researcher
with access to microdata from health and/or administrative registers in
Norway. However, the package also includes simulated registry datasets,
as well as functionality simulate your own datasets with custom
characteristics. As such, it can also be used to explore the
possibilities associated with analyses of data from Norwegian health and
population registries prior to accessing real data.

For detailed information about the workflow and functions in the package
please refer to the vignettes or [Get
Started](https://amslala.github.io/regkit/articles/regkit.html).

## Installation

You can install the development version of regkit from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("amslala/regkit")


# or 
# install.packages("devtools")
devtools::install_github("amslala/regkit")
```

### TSD

Researchers working with sensitive individual-level data in Norway will
most likely have their projects (and data) set up in
[TSD](https://www.uio.no/english/services/it/research/sensitive-data/access/)
with no internet access. Although all the main function in `regkit` work
inside of TSD, it is not possible to install R packages directly from
GitHub without internet access. Instead, you can download the binary for
the latest working version from the [Releases
section](https://github.com/amslala/regkit/releases) and import it to
TSD. You can then install it specifying the path of the binary within
TSD:

``` r
install.packages(path, 
                 repos = NULL,
                 type = "binary")
```

## Report issues and contribute

To submit bug reports or request features, open an issue in
[GitHub](https://github.com/amslala/regkit/issues).

Pull requests are welcomed! To streamline the process, first open an
issue and make sure to include unit tests covering any new features. You
can also send an email to the
[Maintainer](mailto:alejandra.martinez.sanchez@fhi.no) for more
information.
