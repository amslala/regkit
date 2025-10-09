
# Logger ------------------------------------------------------------------



test_that("writes to log", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |>
    dplyr::rename("year"= "y_diagnosis_first")

  incidence_df <- calculate_incidence(linked_df,
                                      type = "cumulative",
                                      id_col = "id",
                                      date_col = "year",
                                      pop_data = pop_df,
                                      pop_col = "population",
                                      time_p = c(2012,2013),
                                      only_counts = FALSE,
                                      suppression = TRUE,
                                      suppression_threshold = 10,
                                      log_path = l_path)

  # Test that logging works
  expect_true(file.exists(l_path))
  expect_gt(file.info(l_path)$size, 0)

})


test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |>
    dplyr::rename("year"= "y_diagnosis_first")

  incidence_df <- calculate_incidence(linked_df,
                                      type = "cumulative",
                                      id_col = "id",
                                      date_col = "year",
                                      pop_data = pop_df,
                                      pop_col = "population",
                                      time_p = c(2012,2013),
                                      only_counts = FALSE,
                                      suppression = TRUE,
                                      suppression_threshold = 10,
                                      log_path = NULL)


  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})



# Input validation --------------------------------------------------------



test_that("input validation works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  # Test grouping col
  expect_error(calculate_incidence(linked_df,
                                   type = "cumulative",
                                   id_col = "id",
                                   date_col = "year",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   grouping_vars = "grouping_var",
                                   time_p = c(2012,2013),
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   log_path = l_path), "The linked dataset must contain the specified 'grouping variables': grouping_var")

  # Test date col
  expect_error(calculate_incidence(linked_df,
                                   type = "cumulative",
                                   id_col = "id",
                                   date_col = "years",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   time_p = c(2012,2013),
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   log_path = l_path), "The linked dataset must contain the specified 'date' column: years")

  # Test id col
  expect_error(calculate_incidence(linked_df,
                                   type = "cumulative",
                                   id_col = "ids",
                                   date_col = "year",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   time_p = c(2012,2013),
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   log_path = l_path), "The linked dataset must contain the specified 'id' column: ids")

  # Test type col

  expect_error(calculate_incidence(linked_df,
                                   type = "rate_cumulative",
                                   id_col = "id",
                                   date_col = "year",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   time_p = c(2012,2013),
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   log_path = l_path), "rate_cumulative not supported. Please specify 'cumulative' for computing cumulative incidence, or 'rate' for incidence rate.")

})


#  Rate vs cumulative -----------------------------------------------------


test_that("Rate vs cumulative specific requirements", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  # Rate and no person-time values
  expect_error(calculate_incidence(linked_df,
                                   type = "rate",
                                   id_col = "id",
                                   date_col = "year",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   time_p = c(2012,2013),
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   log_path = l_path), "To compute incidence rates it is necessary to provide person-time values")

  expect_error(calculate_incidence(linked_df,
                                   type = "cumulative",
                                   id_col = "id",
                                   date_col = "year",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   log_path = l_path), "Time input should be either a single year or a vector of two years for a range")

})



# Only counts -------------------------------------------------------------


test_that("only gives out counts", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  incidence_df <- calculate_incidence(linked_df,
                                       type = "cumulative",
                                       id_col = "id",
                                       date_col = "year",
                                       pop_data = pop_df,
                                       pop_col = "population",
                                       time_p = c(2012,2013),
                                       only_counts = TRUE,
                                       suppression = TRUE,
                                       suppression_threshold = 10,
                                       log_path = l_path)

  # Should not have any prev_rate column

  expect_false("cum_incidence" %in% colnames(incidence_df))
  expect_equal(ncol(incidence_df), 2)

})


# Suppression -------------------------------------------------------------



test_that("Suppression works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  expect_message(calculate_incidence(linked_df,
                                     type = "cumulative",
                                     id_col = "id",
                                     date_col = "year",
                                     pop_data = pop_df,
                                     pop_col = "population",
                                     time_p = c(2012,2013),
                                     only_counts = FALSE,
                                     suppression = TRUE,
                                     suppression_threshold = 10,
                                     log_path = l_path), "Suppressed counts using 10 threshold")

  # Also know that total relevant diagnostic cases in linked_df is (for that period) is less than 100
  suppressed <- calculate_incidence(linked_df,
                                    type = "cumulative",
                                    id_col = "id",
                                    date_col = "year",
                                    pop_data = pop_df,
                                    pop_col = "population",
                                    time_p = c(2012,2013),
                                    only_counts = FALSE,
                                    suppression = TRUE,
                                    suppression_threshold = 100,
                                    log_path = l_path)

  n_removed <- suppressed |> dplyr::filter(is.na(incidence_cases)) |> nrow()

  expect_gt(n_removed, 0)

})



test_that("Warning when suppression FALSE", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  expect_message(calculate_incidence(linked_df,
                                     type = "cumulative",
                                     id_col = "id",
                                     date_col = "year",
                                     pop_data = pop_df,
                                     pop_col = "population",
                                     time_p = c(2012,2013),
                                     only_counts = FALSE,
                                     suppression = FALSE,
                                     suppression_threshold = 10,
                                     log_path = l_path), "No suppression. Confidentiality cannot be assured.")

})


# Confidence interval -----------------------------------------------------




test_that("calculates CI when it should", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  incidence_df <- calculate_incidence(linked_df,
                                      type = "cumulative",
                                      id_col = "id",
                                      date_col = "year",
                                      pop_data = pop_df,
                                      pop_col = "population",
                                      time_p = c(2012,2013),
                                      only_counts = FALSE,
                                      suppression = TRUE,
                                      suppression_threshold = 10,
                                      CI = TRUE,
                                      CI_level = 0.95,
                                      log_path = l_path)

  # Should include at least two col with ci

  expect_gt(length(which(stringr::str_starts(colnames(incidence_df), "ci"))), 1)

})



# Grouping vars -----------------------------------------------------------

test_that("Grouping vars", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")
  pop_df <- tibble::tibble(year = rep(c("2012-2013"), 2), population = floor(runif(2, min=3000, max=4000)), sex = as.factor(c(0,1)))

  incidence_sex <- calculate_incidence(linked_df,
                                       type = "cumulative",
                                       id_col = "id",
                                       date_col = "year",
                                       pop_data = pop_df,
                                       grouping_vars = "sex",
                                       pop_col = "population",
                                       time_p = c(2012,2013),
                                       only_counts = FALSE,
                                       suppression = TRUE,
                                       suppression_threshold = 10,
                                       CI = TRUE,
                                       CI_level = 0.95,
                                       log_path = l_path)

  expect_contains(names(incidence_sex), "sex")


})


# Population mapping ------------------------------------------------------




test_that("Population mapping", {

  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")


  expect_message(calculate_incidence(linked_df,
                                   type = "cumulative",
                                   id_col = "id",
                                   date_col = "year",
                                   grouping_vars = "sex",
                                   pop_data = pop_df,
                                   pop_col = "population",
                                   time_p = c(2012,2013),
                                   only_counts = FALSE,
                                   suppression = TRUE,
                                   suppression_threshold = 10,
                                   CI = FALSE,
                                   CI_level = 0.95,
                                   log_path = l_path),
               "Warning: there are some cells missing from pop_data. Join with population dataset will not have a 'one-to-one' relationship"
    )
})



# CLI ---------------------------------------------------------------------


test_that("stable CI output for sample incidence", {

  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = "2012-2013", population = 4500)
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")


  expect_snapshot({calculate_incidence(linked_df,
                                       type = "cumulative",
                                       id_col = "id",
                                       date_col = "year",
                                       pop_data = pop_df,
                                       pop_col = "population",
                                       time_p = c(2012,2013),
                                       only_counts = FALSE,
                                       suppression = TRUE,
                                       suppression_threshold = 10,
                                       CI = TRUE,
                                       CI_level = 0.95,
                                       log_path = l_path)
  })
})

