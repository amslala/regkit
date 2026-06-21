

# Logger ------------------------------------------------------------------



test_that("reads a supported format into the same reference .rds and log file",{
            l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
            test_csv <- system.file("extdata", "diag_data.csv", package = "regkit")

            # Test CSV reading and validation
            output_csv <- read_diag_data(
              file_path = test_csv,
              id_col = "id",
              date_col = "diag_year",
              log_path = l_path
            )

            expect_equal(output_csv, diag_df)

            # Test that logging works
            expect_true(file.exists(l_path))
            expect_gt(file.info(l_path)$size, 0)


          })

test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  test_csv <- system.file("extdata", "diag_data.csv", package = "regkit")

  output_csv <- read_diag_data(
    file_path = test_csv,
    id_col = "id",
    date_col = "diag_year",
    log_path = NULL
  )

  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})


# Column validation -------------------------------------------------------



test_that("Error when missing required columns", {
  td <- withr::local_tempdir()
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # create and save wrong CSV, no id
  wrong_csv <- diag_df
  wrong_csv$id <- NULL
  wrong_path <- file.path(td, "wrong.csv")

  utils::write.csv(wrong_csv, wrong_path, row.names = FALSE)

  expect_error(
    read_diag_data(
      wrong_path,
      id_col = "id",
      date_col = "diag_year",
      code_col = "code",
      log_path = l_path
    ),
    "The dataset must contain a column named id"
  )

  # create and save wrong CSV, no code
  wrong_csv <- diag_df
  wrong_csv$code <- NULL
  wrong_path <- file.path(td, "wrong.csv")

  utils::write.csv(wrong_csv, wrong_path, row.names = FALSE)

  expect_error(
    read_diag_data(
      wrong_path,
      id_col = "id",
      date_col = "diag_year",
      code_col = "code",
      log_path = l_path
    ),
    "The dataset must contain a column named: code"
  )

  # create and save wrong CSV, no date
  wrong_csv <- diag_df
  wrong_csv$diag_year <- NULL
  wrong_path <- file.path(td, "wrong.csv")

  utils::write.csv(wrong_csv, wrong_path, row.names = FALSE)

  expect_error(
    read_diag_data(
      wrong_path,
      id_col = "id",
      date_col = "diag_year",
      code_col = "code",
      log_path = l_path
    ),
    "The dataset must contain a column named: diag_year"
  )


})




# Extra columns -----------------------------------------------------------


test_that("Handles correctly extra columns ", {
  td <- withr::local_tempdir()
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  extra_csv <- diag_df
  extra_csv$sex <- 1
  extra_path <- file.path(td, "wrong.csv")

  utils::write.csv(extra_csv, extra_path, row.names = FALSE)

  no_extra_df <- read_diag_data(
    extra_path,
    id_col = "id",
    date_col = "diag_year",
    code_col = "code",
    log_path = l_path,
    remove_extra = TRUE
    )

  expect_equal(ncol(no_extra_df), 3)

  expect_warning(extra_df <-
    read_diag_data(
      extra_path,
      id_col = "id",
      date_col = "diag_year",
      code_col = "code",
      log_path = l_path,
      remove_extra = FALSE
    ), "The dataset contains extra columns that were not removed."
  )

  expect_gt(ncol(extra_df), 3)

})






# Read file ---------------------------------------------------------------


test_that("Error when unsupported file extensions and nonexistent files", {
  td <- withr::local_tempdir()
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # create and save xslx file
  tp <- file.path(td, "diag.xlsx")
  file.create(tp)

  expect_error(
    read_diag_data(
      tp,
      id_col = "id",
      date_col = "diag_year",
      code_col = "code",
      log_path = l_path
    ),
    "File type not supported. Please provide a .csv, .rds, .parquet or .sav file."
  )

  tp_empty <- file.path(td, "empty.csv")

  expect_error(
    read_diag_data(
      tp_empty,
      id_col = "id",
      date_col = "diag_year",
      code_col = "code",
      log_path = l_path
    ),
    "File does not exist in the specified path."
  )

})


# CLI ---------------------------------------------------------------------



# test_that("CLI stable for sample CSV", {
#   l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
#   test_csv <- system.file("extdata", "diag_data.csv", package = "regkit")
#   expect_snapshot({
#     invisible(
#       read_diag_data(
#         file_path = test_csv,
#         id_col = "id",
#         date_col = "diag_year",
#         code_col = "code",
#         log_path = l_path
#       )
#     )
#   }, transform = snap_redact_paths)
# })
