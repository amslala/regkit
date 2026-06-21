test_that("writes to log", {
  set.seed(123)
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  pop_df <- tibble::tibble(year = c(2012:2020), population = floor(runif(9, min=3000, max=4000)))
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  prevalence_df <- calculate_prevalence_series(linked_df,
                                               time_points = list(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020),
                                               id_col = "id",
                                               date_col = "year",
                                               pop_data = pop_df,
                                               pop_col = "population",
                                               only_counts = FALSE,
                                               suppression = TRUE,
                                               suppression_threshold = 1,
                                               CI = TRUE,
                                               CI_level = 0.95,
                                               log_path = l_path)

  # Test that logging works
  expect_true(file.exists(l_path))
  expect_gt(file.info(l_path)$size, 0)

})


test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  set.seed(123)
  pop_df <- tibble::tibble(year = c(2012:2020), population = floor(runif(9, min=3000, max=4000)))
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")
  prevalence_df <- calculate_prevalence_series(linked_df,
                                               time_points = list(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020),
                                               id_col = "id",
                                               date_col = "year",
                                               pop_data = pop_df,
                                               pop_col = "population",
                                               only_counts = FALSE,
                                               suppression = TRUE,
                                               suppression_threshold = 1,
                                               CI = TRUE,
                                               CI_level = 0.95,
                                               log_path = NULL)


  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})



# Input validation

test_that("input validation works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  set.seed(123)
  pop_df <- tibble::tibble(year = c(2012:2020), population = floor(runif(9, min=3000, max=4000)))
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")

  # Grouping variables
  expect_error(calculate_prevalence_series(linked_df,
                                           time_points = list(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020),
                                           id_col = "id",
                                           date_col = "year",
                                           pop_data = pop_df,
                                           grouping_vars = "gouping_var",
                                           pop_col = "population",
                                           only_counts = FALSE,
                                           suppression = TRUE,
                                           suppression_threshold = 1,
                                           CI = TRUE,
                                           CI_level = 0.95,
                                           log_path = l_path), "Your data must contain the specified 'grouping variables'.")

  # Test id col
  expect_error(calculate_prevalence_series(linked_df,
                                           time_points = list(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020),
                                           id_col = "ids",
                                           date_col = "year",
                                           pop_data = pop_df,
                                           pop_col = "population",
                                           only_counts = FALSE,
                                           suppression = TRUE,
                                           suppression_threshold = 1,
                                           CI = TRUE,
                                           CI_level = 0.95,
                                           log_path = l_path), "Your data must contain the specified 'id' column.")

})

#Time points/periods

test_that("Correct processing of time points/periods", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  set.seed(123)
  pop_df <- tibble::tibble(year = c(2012:2020), population = floor(runif(9, min=3000, max=4000)))
  linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")
  times <- list(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020)

  prevalence_point <- calculate_prevalence_series(linked_df,
                                               time_points = times,
                                               id_col = "id",
                                               date_col = "year",
                                               pop_data = pop_df,
                                               pop_col = "population",
                                               only_counts = FALSE,
                                               suppression = TRUE,
                                               suppression_threshold = 1,
                                               CI = TRUE,
                                               CI_level = 0.95,
                                               log_path = l_path)

  expect_equal(nrow(prevalence_point), length(times))
  set.seed(123)
  # For time periods
  pop_df <- tibble::tibble(year = c("2012-2014", "2015-2017", "2018-2020"), population = floor(runif(3, min=5000, max=7000)))
  times <- list(c(2012,2014), c(2015,2017), c(2018,2020))

  prevalence_point <- calculate_prevalence_series(linked_df,
                                                  time_points = times,
                                                  id_col = "id",
                                                  date_col = "year",
                                                  pop_data = pop_df,
                                                  pop_col = "population",
                                                  only_counts = FALSE,
                                                  suppression = TRUE,
                                                  suppression_threshold = 1,
                                                  CI = TRUE,
                                                  CI_level = 0.95,
                                                  log_path = l_path)

  expect_equal(nrow(prevalence_point), length(times))

  # Input validation

  times <- list(c(2012:2014), c(2015:2017), c(2018:2020))

  expect_error(calculate_prevalence_series(linked_df,
                                           time_points = times,
                                           id_col = "id",
                                           date_col = "year",
                                           pop_data = pop_df,
                                           pop_col = "population",
                                           only_counts = FALSE,
                                           suppression = TRUE,
                                           suppression_threshold = 1,
                                           CI = TRUE,
                                           CI_level = 0.95,
                                           log_path = l_path), "Each time point should be either a single year or a vector of two years.")


})


