test_that("writes to log", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  filtered_var_df <-  filter_admin_data(data = var_df,
                                  data_type = "t_variant",
                                  filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("03")),
                                  log_path = l_path)

  # Test that logging works
  expect_true(file.exists(l_path))
  expect_gt(file.info(l_path)$size, 0)

})


test_that("creates dir and file log", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  filtered_var_df <-  filter_admin_data(data = var_df,
                                  data_type = "t_variant",
                                  filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("03")),
                                  log_path = NULL)

  expect_true("log" %in% list.files(td))
  expect_length(list.files(file.path(td, "log")), 1)
})



test_that("input validation works", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Filtering col exists
  expect_error(filter_admin_data(data = var_df,
                           data_type = "t_variant",
                           filter_param = list("year_varying" = c(2012:2015), "code" = c("03")),
                           log_path = l_path), "Not all the specified variables exist in the dataset")

  # Data type is valid
  expect_error(filter_admin_data(data = var_df,
                           data_type = NULL,
                           filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("03")),
                           log_path = l_path))

  expect_error(filter_admin_data(data = var_df,
                           data_type = "demographic",
                           filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("03")),
                           log_path = l_path), "Invalid data type specified")

})

test_that("correct data-type filtering is done", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Time variant data
  expect_message(filter_admin_data(data = var_df,
                           data_type = "t_variant",
                           filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("1146")),
                           log_path = l_path), "Filtering time-variant dataset...")

  # Time invariant data
  expect_message(filter_admin_data(data = invar_df,
                             data_type = "t_invariant",
                             filter_param = list("y_birth" = c(2006:2008), "innvandringsgrunn" = c("FAM")),
                             log_path = l_path), "Filtering time-invariant dataset...")
})


#Check that filtering works

test_that("finds codes in data", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # We know that in sample data some codes exits/dont exist

  # Time variant data
  municipality_code <- var_df$varying_code[1]
  expect_gt(nrow(filter_admin_data(data = var_df,
                             data_type = "t_variant",
                             filter_param = list("year_varying" = c(2012:2015), "varying_code" = municipality_code),
                             log_path = l_path)), 0)

  expect_equal(nrow(filter_admin_data(data = var_df,
                             data_type = "t_variant",
                             filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("03")),
                             log_path = l_path)), 0)

  # Time invariant data
  expect_gt(nrow(filter_admin_data(data = invar_df,
                             data_type = "t_invariant",
                             filter_param = list("y_birth" = c(2001:2004), "innvandringsgrunn" = c("FAMM")),
                             log_path = l_path)), 0)

  expect_equal(nrow(filter_admin_data(data = invar_df,
                             data_type = "t_invariant",
                             filter_param = list("y_birth" = c(2006:2008), "innvandringsgrunn" = c("FAMILY")),
                             log_path = l_path)), 0)

})

# Check that removes NAs correctly

test_that("identify and remove NAs", {
  l_path <- withr::local_tempfile(fileext = ".log", lines = "Test log")

  # Add NAs to sample var_df
  var_df_nas<- var_df
  var_df_nas$varying_code[var_df_nas$varying_code == var_df_nas$varying_code[1]] <- NA

  expect_message(filter_admin_data(data = var_df_nas,
                             data_type = "t_variant",
                             filter_param = list("year_varying" = c(2012:2015)),
                             rm_na = TRUE,
                             log_path = l_path), "Removing observations containing NAs in any column...")

  # Add NAs to sample invar_df
  invar_df_nas<- invar_df
  invar_df_nas$innvandringsgrunn[invar_df_nas$innvandringsgrunn == "UTD"] <- NA

  expect_message(filter_admin_data(data = invar_df_nas,
                             data_type = "t_invariant",
                             filter_param = list("y_birth" = c(2006:2008)),
                             rm_na = TRUE,
                             log_path = l_path), "Removing observations containing NAs in any column...")


  filtered_demo_nas <- filter_admin_data(data = invar_df_nas,
                                 data_type = "t_invariant",
                                 filter_param = list("y_birth" = c(2006:2008)),
                                 rm_na = TRUE,
                                 log_path = l_path)


  expect_equal(nrow(filtered_demo_nas |>
                 dplyr::filter(dplyr::if_any(tidyselect::everything(), is.na))), 0)
})


