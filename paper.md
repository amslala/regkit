---
title: 'regtools: facilitating manipulation, analysis and visualization of data from Norwegian health and population registers' 
tags:
  - R
  - epidemiology
  - registers 
  - health data
authors:
  - name: 
      given-names: Alejandra
      surname: Martinez Sanchez
    orcid: 0009-0002-8282-6529
    corresponding: true
    affiliation: 1
  - name:
      given-names: Johanne Hagen
      surname: Pettersen
    orcid: 0009-0004-4546-9037
    affiliation: 3
  - name: Helga Ask 
    orcid: 0000-0003-0149-5319
    affiliation: 1
  - name: Alexandra Havdahl 
    orcid: 0000-0002-9268-0423
    affiliation: "1, 4"
  - name: 
      given-names: Laurie John
      surname: Hannigan 
    orcid: 0000-0003-3123-5411
    affiliation: "1, 2"
affiliations:
 - name: PsychGen Centre for Genetic Epidemiology and Mental Health, Norwegian Institute of Public Health
   index: 1
   ror: 046nvst19
 - name: Psychiatric Genetic Epidemiology Group, Research Department, Lovisenberg Diaconal Hospital
   index: 2
   ror: 03ym7ve89
 - name:  Center for Precision Psychiatry, University of Oslo
   index: 3
   ror: 01xtthb56
 - name: PROMENTA Research Center, Department of Psychology, University of Oslo
   index: 4
   ror: 01xtthb56
date: 16 September 2025
bibliography: paper.bib
---

# Summary

<!-- Summary describing the high-level functionality and purpose of the software for a diverse, non-specialist audience -->

The combined use of health and administrative registers is an essential component of modern epidemiological research. Among the Nordic countries, in particular, an array of registry sources offers high-quality, broad-coverage data collected across many years [@Laugesen_2021]. The use of data in existing registers in research circumvents the data collection process, thus making research more cost and time effective [@Thygesen_2014]. Moreover, health and administrative registers offer enormous sample sizes and high representativeness that are much needed, particularly in epidemiological research. Although registers are rich sources of information, pre–processing and working with the large datasets they produce can be challenging and time-consuming – especially for researchers with limited programming experience – and the process is vulnerable to both unintended variations across projects and highly consequential errors.

The `regtools` R package is an open-source toolkit designed to aid researchers in performing efficient and well-documented manipulation, analysis and visualization of individual-level data from Norwegian health and population registers. With it, we aim to facilitate reproducible descriptive epidemiology based on Norwegian health data, supplemented with sociodemographic information, such as income and education information, from other registry sources. The package includes functions to validate, filter, and link health (diagnostic) and administrative (sociodemographic) data. For transparency, each function creates a log that documents the function's internal data processing, warnings/errors, and corresponding outputs. Finally, considering the extensive of use of registers in epidemiological research, `regtools` includes functions intended to help users compute common descriptive epidemiology statistics, such as prevalence and incidence rates, and visualize the underlying data.

# Statement of need

<!-- Statement of need section that clearly illustrates the research purpose of the software and places it in the context of related work -->

In the last decades, epidemiological research in the Nordic countries has harnessed the advantages of registry data, such as primary and secondary health registers [@Miettunen_2011;  @Thygesen_2014]. In part, this is because population-based health registers in the Nordic countries include personal identification numbers, which facilitate linkage to other data sources, allowing long-term, multi-dimensional follow-up of individuals in the population. Registry data from national statistical institutes (NSIs) are a widely-used source of auxiliary information in this regard. Due to their characteristics, Nordic registers are highly regarded for their unique potential in current epidemiological research [@Jervelund_2019; @Maret-Ouda_2017].

In Norway, the Norwegian Patient Registry (NPR) is widely used in a large variety of research projects [@Bakken_2020]. As of 2025, more than 1000 research papers have been published based on data from the NPR [@NorwegianInstituteofPublicHealth_2024]. Statistics Norway (SSB) provides sociodemographic individual-level data from various topics, such as social welfare, education and income. For instance, from 2021 to 2024, SSB has delivered around 900 individual-level data assignments to both public authorities and rearch insitutions for analytic and research purposes  [@StatisticsNorway_2024; @StatisticsNorway_2025]. Despite their relatively widespread use in research, health and administrative registers are not designed with research or statistical purposes in mind. This creates numerous potential challenges, inefficiencies, and vulnerabilities in the process of carrying out epidemiological research using linked register data.

Considering the wide range of researchers using individual-level registers in Norway, it is highly likely that there are differences in the way researchers pre-process and prepare their data for analysis. Access to register individual-level data is regulated by strict confidentiality laws, which makes "hands-on" training or tutorials hard to access and standardize. The use of proprietary software to manipulate and analyze the data further hinders efforts to ensure reproducibility and transparency across research projects working with the same microdata [@Mathur_2023]. In this context, we have identified the need for an open-source toolkit to assist researchers working with Norwegian individual-level registry data to prepare, manipulate, and analyze it in a robust, transparent, and reproducible way.

While other projects (e.g., `phenotools` [@Hannigan_2021], `csverse` [@White_2025]) have showcased the potential of using open source R packages to assist researchers working with Norwegian survey and register data, the `regtools` package is the first to focus on larger individual-level data with descriptive epidemiological analyses in mind. As an example of a likely use case for `regtools`, the package has been successfully used to analyse time trends in autism diagnoses in Norway over recent years for a public health report [@MartinezSanchez_2025]. The functions included in the package are modular and operate independently from one another, which increases their possible application in various research projects. Given the potential of multinational registry-based cohort studies [@Maret-Ouda_2017], it is important to note that, while the package worflow is originally designed for Norwegian data sources, its flexibility may allow for use with other national registries. 

One of the first challenges researchers working with population-based registers encounter is that of efficiently manipulating very large datasets into smaller and tidier datasets with which they can work analytically. The `regtools` package includes reading and filtering functions that support parquet files <!--# citation? readers may not know what these are or why they are advantageous -->, which seamlessly enables users to efficiently work with larger-than-memory files in R without requiring deeper knowledge on the inner workings of parquet objects. Furthermore, the logs created by each function can help researchers to keep track of and document all manipulation or processing steps applied to their datasets. <!--# Need a sentence here on some of the other main functions, before you get to the helpers - visualisation and prevalence etc - so that this para represents a complete summary of the functionality -->There are also some specific challenges related to Norwegian registry data that are also addressed in the helper functions of `regtools`, such as harmonizing municipality codes and getting population counts from SSB's open data.

In addition to helping solve practical challenges associated with processing, manipulation, and analysis of Norwegian register data, `regtools` also seeks provide some "hands-on" guidance on how to efficiently work with individual-level registry data for epidemiological research. The functions in this package are intended to serve as a loose framework that can be adapted by researchers working with similar data and research questions. The package includes a series of vignettes explaining the main functions, and real-life examples in descriptive epidemiology that can be addressed. The vignettes and possibility of creating synthetic individual-level datasets (`synthetic_data()`) also allow research-groups to use the package as low-risk <!--# zero-risk? It's entirely simulated so...? --> training material for new members, and to plan and structure analytic projects prior to obtaining data access.

# Acknowledgements

<!-- Acknowledgment of any financial support, grant numbers? -->

<!--# “This work was performed on the TSD (Tjeneste for Sensitive Data) facilities, owned by the University of Oslo, operated and developed by the TSD service group at the University of Oslo, IT Department (USIT). (tsd-drift@usit.uio.no).” 

AMS was supported by the Research Council of Norway (#336085). LJH was supported by the South-Eastern Norway Regional Health Authority (#2922083). 

Funding from other (Helga, Alex and Johanne). 

I would also suggest thinking about whether Guido/others from the TSD project in which you were working need to be acknowledged here -->
