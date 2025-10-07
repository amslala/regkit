
test_that("Input validation works", {

  expect_error(synthetic_data(
    population_size = 1000,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("F45", "F84"),
    pattern = "equal",
    prevalence = 0.023,
    diag_years  = c(2012:2020),
    sex_vector = c(0, 1),
    y_birth = c(2010:2018),
    filler_codes = "F",
    filler_y_birth = c(2000:2009),
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
    )
  )


  expect_error(synthetic_data(
    population_size = 1000,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("F45", "F84"),
    pattern = "increase",
    diag_years  = c(2012:2020),
    sex_vector = c(0, 1),
    y_birth = c(2010:2018),
    filler_codes = "F",
    filler_y_birth = c(2000:2009),
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
    ), "Either prevalance or incidence has to be provided"
  )

  expect_error(synthetic_data(
    population_size = 1000,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("F45", "F84"),
    pattern = "increase",
    prevalence = 23,
    diag_years  = c(2012:2020),
    sex_vector = c(0, 1),
    y_birth = c(2010:2018),
    filler_codes = "F",
    filler_y_birth = c(2000:2009),
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
  ), "Prevalence rate is not expressed as a proportion between 0 and 1."
  )

  expect_error(synthetic_data(
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
    varying_query = "fylke"), "Either invariant queries for SSB's API, or invariant codes need to be provided")

  expect_error(synthetic_data(
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
    varying_codes = c("01", "03")),
    "You have provided varying codes. Filler varying codes also need to be provided."
    )

  expect_message(synthetic_data(
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
  ), "Varying query and varying codes arguments are empty. The varying dataset will not be generated.")

expect_error(synthetic_data(
  population_size = 1000,
  prefix_ids = "P000",
  length_ids = 6,
  family_codes = c("F45", "F84"),
  pattern = "increase",
  incidence = c(0.01, 0.02),
  diag_years  = c(2012:2020),
  sex_vector = c(0, 1),
  y_birth = c(2010:2018),
  filler_codes = "F",
  filler_y_birth = c(2000:2009),
  invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
  invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
  varying_query = "fylke"
  ), "Number of elements in incidence vector do not correspond with number of diagnosis years"
)

expect_error(synthetic_data(
  population_size = 1000,
  prefix_ids = "P000",
  length_ids = 6,
  family_codes = c("F45", "F84"),
  pattern = "increase",
  incidence = c(0.01, 2),
  diag_years  = c(2012,2013),
  sex_vector = c(0, 1),
  y_birth = c(2010:2018),
  filler_codes = "F",
  filler_y_birth = c(2000:2009),
  invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
  invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
  varying_query = "fylke"))

expect_error(synthetic_data(
  population_size = 1000,
  prefix_ids = "P000",
  length_ids = 6,
  family_codes = c("F45", "F84"),
  pattern = "increase",
  incidence = c(0.01, 2),
  diag_years  = c(2012,2013),
  sex_vector = c(0, 1),
  y_birth = c(2010:2018),
  filler_codes = "F",
  filler_y_birth = c(2000:2009),
  invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
  invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
  varying_query = "fylke"), "Not all incidence rates are expressed as a proportion between 0 and 1.")

expect_error(synthetic_data(
  population_size = 100,
  prefix_ids = "P000",
  length_ids = 6,
  family_codes = c("F45", "F84"),
  diag_code_type = "NPR",
  pattern = "random",
  prevalence = 0.02,
  diag_years  = c(2012:2020),
  sex_vector = c(0, 1),
  y_birth = c(2010:2018),
  filler_codes = "F",
  filler_y_birth = c(2000:2009),
  invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
  invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
  varying_query = "fylke"
  ), "diag_code_type not valid. Must be either 'icd' or 'icpc'.")


})



 #Test that population size matches with datasets and with diag years


test_that("Correct population size", {
  n_pop <- 100
  diag_years <- c(2012:2020)
  test_simulate <- synthetic_data(
    population_size = n_pop,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("F45", "F84"),
    pattern = "random",
    prevalence = 0.02,
    diag_years  = diag_years,
    sex_vector = c(0, 1),
    y_birth = c(2010:2018),
    filler_codes = "F",
    filler_y_birth = c(2000:2009),
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
  )
  expect_equal(nrow(test_simulate$datasets$invar_df), n_pop)
  expect_equal(nrow(test_simulate$datasets$var_df), n_pop*length(diag_years))
  expect_equal(test_simulate$datasets$diag_df |> dplyr::distinct(id) |> nrow(), n_pop)
})


# Test that diag codes match (use other functions in package)

test_that("Diagnostic codes", {
  icd_simulate <- synthetic_data(
    population_size = 100,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("F45", "F84"),
    diag_code_type = "icd",
    pattern = "random",
    prevalence = 0.02,
    diag_years  = c(2012:2020),
    sex_vector = c(0, 1),
    y_birth = c(2010:2018),
    filler_codes = "F",
    filler_y_birth = c(2000:2009),
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
  )

  df <- icd_simulate$datasets$diag_df

  expect_gt(length(stringr::str_starts(df$code, "F")), 0)


  icpc_simulate <- synthetic_data(
    population_size = 100,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("P"),
    diag_code_type = "icpc",
    pattern = "random",
    prevalence = 0.02,
    diag_years  = c(2012:2020),
    sex_vector = c(0, 1),
    y_birth = c(2010:2018),
    filler_codes = "A",
    filler_y_birth = c(2000:2009),
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
  )

  df <- icpc_simulate$datasets$diag_df

  expect_gt(length(stringr::str_starts(df$code, "P")), 0)


})


#Test that y birth match

test_that("Year of birth", {
  years_birth <-c(2010:2018)
  filler_years_birth <- c(2000:2009)

  test <- synthetic_data(
    population_size = 100,
    prefix_ids = "P000",
    length_ids = 6,
    family_codes = c("F45", "F84"),
    diag_code_type = "icd",
    pattern = "random",
    prevalence = 0.02,
    diag_years  = c(2012:2020),
    sex_vector = c(0, 1),
    y_birth = years_birth,
    filler_codes = "F",
    filler_y_birth = filler_years_birth,
    invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
    invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
    varying_query = "fylke"
  )

  all_years <- test$invar_df$y_birth

  expect_true(all(all_years %in% c(years_birth, filler_years_birth)))

  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  filtered_df <- regtools::filter_diag_data(test$datasets$diag_df, pattern_codes = c("F45", "F84"), code_col = "code", id_col = "id", log_path = l_path)

  curated_df <- regtools::curate_diag_data(filtered_df, min_diag = 1, first_diag = TRUE, code_col = "code", date_col = "diag_year", log_path = l_path)

  invar_test <- test$datasets$invar_df

  filtered_df_2 <- regtools::filter_admin_data(invar_test, data_type = "t_invariant", filter_param = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")), id_col = "id", rm_na = FALSE, log_path = l_path)

  linked_df <- regtools::link_diag_admin(curated_df, data_admin_inv = filtered_df_2, id_col = "id", log_path = l_path)

  expect_true(all(linked_df$y_birth %in% years_birth))

})


#Test that invariant codes are ok (and queries)

#Test that varying codes are ok (and queries)

#Test that prevalence is correct

#Test that incidence is correct
