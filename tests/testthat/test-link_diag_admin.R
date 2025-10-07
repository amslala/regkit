test_that("writes to log", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")
  linked_diag_inv <- link_diag_admin(data_diag = diag_df,
                                    data_admin_inv = invar_df,
                                    id_col = "id",
                                    log_path = l_path)

  # Test that logging works
  expect_true(file.exists(l_path))
  expect_gt(file.info(l_path)$size, 0)

})

# Check that logger is creating directory and file if NULL

test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  link_diag_admin(data_diag = diag_df,
                 data_admin_inv = invar_df,
                 id_col = "id",
                 log_path = NULL)
  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})


test_that("input validation works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Test at least one demo dataset is given
  expect_error(link_diag_admin(data_diag = diag_df,
                              id_col = "id",
                              log_path = l_path), "At least one of data_admin_inv or data_admin_var must be provided")

  # Test date and id in demo dataset
  expect_error(link_diag_admin(data_diag = diag_df,
                              data_admin_var = var_df,
                              id_col = "id",
                              date_col = "diag_year",
                              log_path = l_path), "data_admin_var must contain the specified 'date' and 'id' columns")

  # Test id in invar demo dataset
  expect_error(link_diag_admin(data_diag = diag_df,
                              data_admin_inv = invar_df,
                              id_col = "ids",
                              log_path = l_path), "data_admin_inv must contain specified 'id' column")

  names(var_df)[names(var_df) == 'year_varying'] <- 'year'
  names(diag_df)[names(diag_df) == 'diag_year'] <- 'year'


})

# check that joins work on sample data

test_that("link invar with diag works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Using the sample datasets, we know that these linkages work

  linked_diag_inv <- link_diag_admin(data_diag = diag_df,
                                    data_admin_inv = invar_df,
                                    id_col = "id",
                                    log_path = l_path)

  expect_equal(nrow(linked_diag_inv), nrow(diag_df))

  # Link diagnostic and time variant datasets
  names(var_df)[names(var_df) == 'year_varying'] <- 'year'
  names(diag_df)[names(diag_df) == 'diag_year'] <- 'year'

  linked_diag_var <- link_diag_admin(data_diag = diag_df,
                                    data_admin_var = var_df,
                                    id_col = "id",
                                    date_col = "year",
                                    log_path = l_path)

  expect_equal(nrow(linked_diag_var), nrow(diag_df))


  # Link diagnostic, time invariant and variant datasets
  linked_diag_inv_var <- link_diag_admin(data_diag = diag_df,
                                        data_admin_var = var_df,
                                        data_admin_inv = invar_df,
                                        id_col = "id",
                                        date_col = "year",
                                        log_path = l_path)

  expect_equal(nrow(linked_diag_inv_var), nrow(diag_df))

})



