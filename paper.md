# Summary

The use of health and administrative registers, often in combination, is
an essential component of modern epidemiological research. Among the
Nordic countries, in particular, an array of registry sources offers
high-quality, broad-coverage data collected across many years
\[@Laugesen_2021\]. The use of existing data from registers in research
circumvents the data collection process, thus making research more cost
and time effective \[@Thygesen_2014\]. Moreover, health and
administrative registers offer enormous sample sizes and high
representativeness that are much needed, particularly in epidemiological
research. Although registers are rich sources of information,
pre–processing and working with the large datasets they produce can be
challenging and time-consuming – especially for researchers with limited
programming experience – and the process is vulnerable to both
unintended variations across projects and highly consequential errors.

The `regkit` R package is an open-source toolkit designed to aid
researchers in performing efficient and well-documented manipulation,
analysis and visualization of individual-level data from Norwegian
health and population registers. With it, we aim to facilitate
reproducible descriptive epidemiology based on Norwegian health data,
supplemented with sociodemographic information, such as income and
education information, from other registry sources. The package includes
functions to validate, filter, and link health (diagnostic) and
administrative (sociodemographic) data. For transparency, each function
creates a log that documents the function’s internal data processing,
warnings/errors, and corresponding outputs. Finally, considering the
extensive use of registers in epidemiological research, `regkit`
includes functions intended to help users compute common descriptive
epidemiology statistics, such as prevalence and incidence rates, and
visualize the underlying data.

# Statement of need

Due to their characteristics, Nordic registers are highly regarded for
their unique potential in current epidemiological research
\[@Jervelund_2020; @Maret-Ouda_2017\]. In the last decades,
epidemiological research in the Nordic countries has harnessed the
advantages of registry data, such as primary and secondary health care
registers \[@Miettunen_2011;  @Thygesen_2014\]. In part, this is due to
the introduction of personal identification numbers into the Nordic
population-based health registers, which enables linkage to other data
sources, allowing long-term, multi-dimensional follow-up of individuals
in the population. Registry data from national statistical institutes
(NSIs) are a widely-used source of auxiliary information in this regard.

In Norway, the Norwegian Patient Registry (NPR) is used in a large
variety of research projects \[@Bakken_2020\]. As of 2025, more than
1000 research papers have been published based on data from the NPR
\[@NorwegianInstituteofPublicHealth_2024\]. Statistics Norway (SSB)
provides sociodemographic individual-level data on various topics, such
as social welfare, education and income. For instance, between 2021 and
2024, SSB delivered around 900 individual-level data assignments to both
public authorities and research institutes for analytic and research
purposes  \[@StatisticsNorway_2024; @StatisticsNorway_2025\]. Despite
their relatively widespread use in research, health and administrative
registers are not designed with research or statistical purposes in
mind. This creates numerous potential challenges, inefficiencies, and
vulnerabilities in the process of carrying out epidemiological research
using linked register data.

Considering the wide range of researchers using individual-level
registers in Norway, it is highly likely that there are differences in
the way researchers pre-process and prepare their data for analysis.
Access to register individual-level data is regulated by strict
confidentiality laws, which makes “hands-on” training or tutorials hard
to access and standardize. The use of proprietary software to manipulate
and analyze the data further hinders efforts to ensure reproducibility
and transparency across research projects working with the same data
\[@Mathur_2023\]. In this context, we have identified the need for an
open-source toolkit to assist researchers working with Norwegian
individual-level registry data to prepare, manipulate, and analyze it in
a robust, transparent, and reproducible way.

# State of the field

Considering the confidential nature of health and administrative
register data, a large proportion of the code used in research is not
publicly available. Nonetheless, some few open-source software solutions
have been developed to dealt with the processing and analysis of
Norwegian survey and register data. For instance, `phenotools`
\[@Hannigan_2021\] is an R package that aims to facilitate efficient and
reproducible use of survey information from Norwegian cohort data.
Similarly, `csverse` \[@White_2025\] is a suite of packages focusing on
the preparation and analysis of Norwegian disease surveillance and
linked register data. Finally, the Norwegian statistics bureau
(Statistics Norway) has developed a handful of packages addressing
statistical disclosure control, retrieval of publicly available data,
classification standards and survey weighting and estimation
\[@Jentof_2026; @Langsrud_2025; @Langsrud_2026\].

In summary, these existing projects have showcased the potential of
using open-source R packages to assist researchers working with
Norwegian survey and register data. The justification for building
`regkit` as a new package, rather than contributing to existing
packages, is that currently available software focuses on relatively
narrow, well-defined use-cases (e.g. tabular suppression, disease
surveillance) as opposed to broad operations with large, linked
individual-level datasets aimed at facilitating descriptive
epidemiological analyses. In addition, building a new package has
enabled us to create a streamlined framework including only functions
relevant to this research area. For instance, it integrates relevant
functions originally developed by Statistics Norway to facilitate the
creation of realistic simulated data.

# Software design

The package `regkit` was built following the principles of modularity
and flexibility, as such the functions included in the package operate
independently from one another, which increases their possible
application in various research projects. Given the potential of
multinational registry-based cohort studies \[@Maret-Ouda_2017\], it is
important to note that, while the package workflow is originally
designed for Norwegian data sources, its flexibility may allow for use
with other national registries. Similarly, to improve interoperability
across projects, `regkit` depends primarily on widely used `tidyverse`
packages that many users working with register data are likely to have
installed already. In addition, packages used in functions only relevant
to a specific use case
(e.g. [`plot_map()`](https://amslala.github.io/regkit/reference/plot_map.md))
are listed as *Suggest*, keeping the core installation as lean as
possible. The current unit test suite provides good coverage of the main
functions, helping to ensure the reliability of the package.

Considering that the target user base of `regkit` (social scientists,
epidemiologists) might have limited programming experience, we aimed to
provide a user-friendly and educational framework and functions. For
instance, one of the first challenges researchers working with
population-based registers encounter is that of efficiently manipulating
very large datasets into smaller and tidier datasets with which they can
work analytically. The `regkit` package includes reading and filtering
functions
(e.g. [`read_diag_data()`](https://amslala.github.io/regkit/reference/read_diag_data.md),
[`filter_diag_data()`](https://amslala.github.io/regkit/reference/filter_diag_data.md))
that support files in parquet format \[@ApacheParquet_2025\], which
seamlessly enables users to efficiently work with larger-than-memory
files in R without requiring deeper knowledge on the inner workings of
parquet format objects. Furthermore, most functions automatically
generate a log file that records and timestamps the function call,
internal data transformations, warnings, errors, and general outputs.
These logs can help researchers keep track of and document all
manipulation or processing steps applied to their datasets.

The package also includes functions that are particularly useful for
descriptive epidemiology analyses, such as the computation of prevalence
and incidence rates, along with the function
[`plot_rates()`](https://amslala.github.io/regkit/reference/plot_rates.md)
for visualizing the results. There are some specific challenges related
to Norwegian registry data that are addressed in the helper functions of
`regkit`, such as harmonizing municipality codes and retrieving
population counts from SSB’s open data.

In addition to helping solve practical challenges associated with
processing, manipulation, and analysis of Norwegian register data,
`regkit` provides “hands-on” guidance on how to efficiently work with
individual-level registry data for epidemiological research. The
functions in the package are intended to serve as a loose framework that
can be adapted by researchers working with similar data and research
questions. The package includes a series of vignettes explaining the
main functions and real-life examples of descriptive epidemiology. The
vignettes and possibility of creating simulated individual-level
datasets with the function
[`simulate_data()`](https://amslala.github.io/regkit/reference/simulate_data.md)
also allow research-groups to use the package as zero-risk training
material for new members, and to plan and structure analytic projects
prior to obtaining data access.

# Research impact statement

The most prominent use of the `regkit` package to date has been in
providing analyses on time trends in autism diagnoses in Norway over
recent years, published as part of a national public health report
\[@MartinezSanchez_2025a\]. The report received approximately 500,000
unique visits throughout 2025, and the analytic component based on work
carried out using `regkit` was the most visited section. Core features
of this report, which included regional breakdowns and visualization of
autism incidence spanning 12 years and prevalence analyses with
stratification by demographic characteristics retrieved from Statistics
Norway, showcase the key advantages of the software. The package has
additionally been used for analyses of time trends in other conditions
(e.g., anxiety and depression), with publication of results forthcoming.
Moreover, community-readiness has been demonstrated by the acceptance of
talks and posters presenting `regkit` at conferences in the fields of
epidemiology, autism research, and reproducibility in scientific
publishing \[e.g. @MartinezSanchez_2025b\].

# AI Usage Disclosure

No generative AI tools were used in the development of this software or
the writing of this manuscript.

# Acknowledgements

Due to the sensitive nature of the data used to develop and test
`regkit`, the core development of the package was performed on the TSD
(Tjeneste for Sensitive Data) facilities, owned by the University of
Oslo, operated and developed by the TSD service group at the University
of Oslo, IT Department (USIT) (<tsd-drift@usit.uio.no>). TSD is a secure
research platform with limited internet access, therefore the commit
history in the publicly available repository does not reflect
contributions made within TSD. All the co-authors contributed
conceptually to the iterative development of the package.

AMS was supported by the Research Council of Norway (#336085). JHP and
HA were supported by the Research Council of Norway (#324620), and
NordForsk(#156298). LJH was supported by the South-Eastern Norway
Regional Health Authority (#2922083). AH was supported by the Research
Council of Norway (#336085), the South Eastern Norway Regional Health
Authority (#2020022), and the European Union’s Horizon Europe Research
and Innovation programme (FAMILY \#101057529). Thanks to Guido Biele and
Lasse Bang for their assistance during the early stages of this project.

# References
