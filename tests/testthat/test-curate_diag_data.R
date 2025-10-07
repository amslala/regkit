test_that("writes to log", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  curated_diag_df <- curate_diag_data(data = diag_df,
                                 min_diag = 1,
                                 first_diag = TRUE,
                                 id_col = "id",
                                 code_col = "code",
                                 date_col = "diag_year",
                                 log_path = l_path)

  # Test that logging works
  expect_true(file.exists(l_path))
  expect_gt(file.info(l_path)$size, 0)

})


test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  curated_diag_df <- curate_diag_data(data = diag_df,
                                 min_diag = 1,
                                 first_diag = TRUE,
                                 id_col = "id",
                                 code_col = "code",
                                 date_col = "diag_year",
                                 log_path = NULL)

  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})



test_that("input validation works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Test id col
  expect_error(curate_diag_data(data = diag_df,
                           min_diag = 1,
                           first_diag = TRUE,
                           id_col = "ids",
                           code_col = "code",
                           date_col = "diag_year",
                           log_path = l_path), "The specified id column does not exist in the dataset")
  # Test code col
  expect_error(curate_diag_data(data = diag_df,
                           min_diag = 1,
                           first_diag = TRUE,
                           id_col = "id",
                           code_col = "codes",
                           date_col = "diag_year",
                           log_path = l_path),  "The specified code column does not exist in the dataset")

  # Test date col
  expect_error(curate_diag_data(data = diag_df,
                           min_diag = 1,
                           first_diag = TRUE,
                           id_col = "id",
                           code_col = "code",
                           date_col = "diag_years",
                           log_path = l_path), "The specified date column does not exist in the dataset")
})


test_that("Keeps only cases with min diagnostic observations", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  #In the sample dataset, we know there are not individuals that have more than 10 rep diagnosis
  expect_error(curate_diag_data(data = diag_df,
              min_diag = 10,
              first_diag = TRUE,
              id_col = "id",
              code_col = "code",
              date_col = "diag_year",
              log_path = l_path), "There were zero observations that had at least 10 diagnostic event")


  # We know that there are at least 1 individual with reapeated diagnosis in sample dataset
  expect_gt(nrow(curate_diag_data(data = diag_df,
                                min_diag = 2,
                                first_diag = TRUE,
                                id_col = "id",
                                code_col = "code",
                                date_col = "diag_year",
                                log_path = l_path)), 0)

})

# First diagnosis

test_that("Summarized by first diagnosis", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Sample diag_df only includes diagnosis given between 2012-2020
  new_diag <- head(diag_df, 50)
  new_diag$diag_year <- 2022

  repeated_diag <- rbind(new_diag, diag_df)

  curated_diag <- curate_diag_data(data = repeated_diag,
                              min_diag = 2,
                              first_diag = TRUE,
                              id_col = "id",
                              code_col = "code",
                              date_col = "diag_year",
                              log_path = l_path)

  expect_false(2022 %in% curated_diag$y_diagnosis_first)

})
