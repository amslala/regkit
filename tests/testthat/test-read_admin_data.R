
# Logger ------------------------------------------------------------------


test_that("reads a supported format into the same reference .rds and log file",{
            l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
            test_csv <- system.file("extdata", "invar_data.csv", package = "regkit")

            # Test CSV reading and validation
            output_csv <- read_admin_data(
              file_path = test_csv,
              data_type = "t_invariant",
              id_col = "id",
              date_col = "diag_year",
              log_path = l_path
            )

            output_csv$sex <- as.factor(output_csv$sex)
            expect_equal(output_csv, invar_df)

            # Test that logging works
            expect_true(file.exists(l_path))
            expect_gt(file.info(l_path)$size, 0)

          })

test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  test_csv <- system.file("extdata", "invar_data.csv", package = "regkit")

  # Test CSV reading and validation
  output_csv <- read_admin_data(
    file_path = test_csv,
    data_type = "t_invariant",
    id_col = "id",
    date_col = "diag_year",
    log_path = NULL
  )

  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})



# Columns -----------------------------------------------------------------


test_that("Error when missing required columns", {
  td <- withr::local_tempdir()
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # create and save wrong CSV (no id)
  wrong_csv <- var_df
  wrong_csv$id <- NULL
  wrong_path <- file.path(td, "wrong.csv")

  utils::write.csv(wrong_csv, wrong_path, row.names = FALSE)

  expect_error(
    read_admin_data(
      wrong_path,
      data_type = "t_variant",
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "The dataset must contain a column named id"
  )

  # create and save wrong CSV (no date and variant)
  wrong_csv_date <- var_df
  wrong_csv_date $year_varying <- NULL
  wrong_path_date <- file.path(td, "wrong.csv")

  utils::write.csv(wrong_csv_date, wrong_path_date, row.names = FALSE)

  expect_error(
    read_admin_data(
      wrong_path_date,
      data_type = "t_variant",
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "The dataset must contain a column named: year_varying"
  )

})

# Unsupported files -------------------------------------------------------



test_that("Error when unsupported file extensions and nonexistent files", {
  td <- withr::local_tempdir()
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # create and save xslx file
  tp <- file.path(td, "invar.xlsx")
  file.create(tp)

  expect_error(
    read_admin_data(
      tp,
      data_type = "t_invariant",
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "File type not supported. Please provide a .csv, .rds, .parquet or .sav file."
  )

  tp_empty <- file.path(td, "empty.csv")

  expect_error(
    read_admin_data(
      tp_empty,
      data_type = "t_invariant",
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "File does not exist in the specified path."
  )

})


# Data type ---------------------------------------------------------------


test_that("Error when not valid data type given", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log") # Temporal log path, should delete itself at the end
  test_csv <- system.file("extdata", "invar_data.csv", package = "regkit") #Read example csv

  expect_error(
    read_admin_data(
      test_csv,
      data_type = "demographic",
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "demographic not supported."
  )

  expect_error(
    read_admin_data(
      test_csv,
      data_type,
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "object 'data_type' not found"
  )


})

test_that("Error duplicated ids when invariant type", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  sample_var_df <- head(var_df, 100)
  td <- withr::local_tempdir()
  t_path <- file.path(td, "sample_var_df.csv")
  utils::write.csv(sample_var_df, t_path, row.names = FALSE)

  expect_error(
    read_admin_data(
      t_path,
      data_type = "t_invariant",
      id_col = "id",
      date_col = "year_varying",
      log_path = l_path
    ),
    "The dataset contains duplicate IDs. Verify that this dataset only contains persistent characteristics."
  )
})


# CLI ---------------------------------------------------------------------



# test_that("CLI stable for sample CSV", {
#   log_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
#   test_csv <- system.file("extdata", "invar_data.csv", package = "regkit")
#   expect_snapshot({
#     invisible(
#       read_admin_data(
#         file_path = test_csv,
#         data_type = "t_invariant",
#         id_col = "id",
#         log = log_path
#       )
#     )
#   }, transform = snap_redact_paths)
# })
