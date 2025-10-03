test_that("writes to log", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  filtered_diag_df <-  filter_diag(data = diag_df,
                                   pattern_codes = c("F45", "F84"),
                                   id_col = "id",
                                   code_col = "code",
                                   log_path = l_path
  )

  # Test that logging works
  expect_true(file.exists(l_path))
  expect_gt(file.info(l_path)$size, 0)

})


test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  filtered_diag_df <-  filter_diag(data = diag_df,
                                   pattern_codes = c("F45", "F84"),
                                   id_col = "id",
                                   code_col = "code",
                                   log_path = NULL
  )

  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})



test_that("input validation works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Test id col
  expect_error(filter_diag(data = diag_df,
                           pattern_codes = c("F45", "F84"),
                           id_col = "ids",
                           code_col = "code",
                           log_path = l_path), "The specified id column does not exist in the dataset")
  # Test code col
  expect_error(filter_diag(data = diag_df,
                           pattern_codes = c("F45", "F84"),
                           id_col = "id",
                           code_col = "codes",
                           log_path = l_path),  "The specified code column does not exist in the dataset")
  # Test only pattern or codes
  expect_error(filter_diag(data = diag_df,
                           pattern_codes = c("F45", "F84"),
                           codes = "F841",
                           id_col = "id",
                           code_col = "code",
                           log_path = l_path), "Only one of 'pattern_codes' or 'codes' should be specified.")

  # Test classification type
  expect_error(filter_diag(data = diag_df,
                           pattern_codes = c("F45", "F84"),
                           id_col = "id",
                           code_col = "code",
                           classification = "npr",
                           log_path = l_path), "Classification code not valid")
})


test_that("identifies (in)valid codes",{
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  #Give code that is not valid
  expect_warning(filter_diag(data = diag_df,
                           codes = "F8499",
                           id_col = "id",
                           code_col = "code",
                           log_path = l_path))

})

test_that("finds codes in data", {
  # We know that in sample dataset (diag_df) there are F45 codes
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  filtered <- filter_diag(data = diag_df,
                          codes = c("F840"),
                          id_col = "id",
                          code_col = "code",
                          log_path = l_path)

  expect_gt(nrow(filtered), 0)
})

test_that("warns when some codes are valid but not in data",{
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  expect_message(filter_diag(data = diag_df,
                          codes = c("H600"),
                          id_col = "id",
                          code_col = "code",
                          log_path = l_path), "Warning: The following codes are not found in the dataset: H600")

  empty_df <- filter_diag(data = diag_df,
                          codes = c("H600"),
                          id_col = "id",
                          code_col = "code",
                          log_path = l_path)
  expect_equal(nrow(empty_df), 0)
})

test_that("Pattern vs exact codes work", {
  #There should be more codes that just start with F84, than exact F84 diagnosis
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  filtered_exact <- filter_diag(data = diag_df,
                                codes = c("F845"),
                                id_col = "id",
                                code_col = "code",
                                log_path = l_path)
  filtered_pattern <- filter_diag(data = diag_df,
                                  pattern_codes = c("F84"),
                                  id_col = "id",
                                  code_col = "code",
                                  log_path = l_path)

  expect_true(nrow(filtered_pattern) > nrow(filtered_exact))


})



# NAs  --------------------------------------------------------------------



test_that("Remove NAs correctly in both dataframes and parquet datasets", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  test_csv <- system.file("extdata", "diag_data.csv", package = "regtools")

  na_diag <- diag_df
  na_diag$diag_year[na_diag$diag_year == 2016] <- NA

  tp <- file.path(withr::local_tempdir(), "dataset_diag.parquet")
  arrow::write_dataset(na_diag, tp)

  df_nas <- read_diag_data(
    tp,
    id_col = "id",
    date_col = "diag_year",
    code_col = "code",
    log_path = l_path,
    remove_extra = FALSE
  )

  df_filtered <- filter_diag(
    data = df_nas,
    pattern_codes = c("F45", "F84"),
    id_col = "id",
    code_col = "code",
    log_path = l_path,
    rm_na = TRUE
  )

  df_filtered_nas <- filter_diag(
    data = df_nas,
    pattern_codes = c("F45", "F84"),
    id_col = "id",
    code_col = "code",
    log_path = l_path,
    rm_na = FALSE
  )

  expect_lt(nrow(df_filtered), nrow(df_filtered_nas))


  })



