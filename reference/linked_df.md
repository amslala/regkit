# Example linked individual-level data

A simulated dataset including individual information such as unique ID,
ICD-10 and diagnosis date (year), year of birth, and reason for
immigration

## Usage

``` r
linked_df
```

## Format

`linked_df` A data frame with 30,024 rows and 3 columns:

- id:

  Unique personal identifier

- code:

  ICD-10 codes

- y_diagnosis_first :

  Year of first diagnosis

- sex:

  Sex (code)

- y_birth:

  Year of birth

- innvandringsgrunn:

  Reason for immigration (https://www.ssb.no/klass/klassifikasjoner/355)

## Source

Code used to simulate this dataset can be found in /data-raw directory
