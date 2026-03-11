test_that("error when no url", {
expect_error(get_population_ssb(url = NULL, regions = "norway",
                                        years = c(2020:2022),
                                        ages = c(10:15),
                                        aggregate_age = TRUE,
                                        by_sex = TRUE,
                                        save_xslx = FALSE),
             "Requires SSB population table URL")
})


test_that("error when unsupported regions", {
  expect_error(get_population_ssb(regions = "all",
                                  years = c(2020:2022),
                                  ages = c(10:15),
                                  aggregate_age = TRUE,
                                  by_sex = TRUE,
                                  save_xslx = FALSE),
               "all not supported. Please specify 'norway' for country-wise population, 'fylker' for county populations or 'kommuner' for municipality populations.")
})



test_that("Correct region output", {
  norway_pop <- get_population_ssb(regions = "norway",
                                   years = c(2020:2022),
                                   ages = c(10:15),
                                   aggregate_age = TRUE,
                                   by_sex = TRUE,
                                   save_xslx = FALSE)

  expect_equal(unique(norway_pop$region_code), "0")


  fylke_pop <- get_population_ssb(regions = "fylker",
                                  years = c(2020:2022),
                                  ages = c(10:15),
                                  aggregate_age = TRUE,
                                  by_sex = TRUE,
                                  save_xslx = FALSE)

  expect_equal(unique(stringr::str_length(fylke_pop$region_code)), 2)


  komm_pop <- get_population_ssb(regions = "kommuner",
                                 years = c(2020:2022),
                                 ages = c(10:15),
                                 aggregate_age = TRUE,
                                 by_sex = TRUE,
                                 save_xslx = FALSE)

  expect_equal(unique(stringr::str_length(komm_pop$region_code)), 4)

  # Need to deal with Svalvard Jan Mayer and Kontinentalsokkelen



})



# Age

test_that("correct age (dis)aggregation", {
  disaggregated <- get_population_ssb(regions = "norway",
                                      years = c(2020:2022),
                                      ages = c(10:15),
                                      aggregate_age = FALSE,
                                      by_sex = TRUE,
                                      save_xslx = FALSE)
  expect_length(which(disaggregated$age == "Total"), 0)

  aggregated <- get_population_ssb(regions = "norway",
                                      years = c(2020:2022),
                                      ages = c(10:15),
                                      aggregate_age = TRUE,
                                      by_sex = TRUE,
                                      save_xslx = FALSE)
  expect_gt(length(which(aggregated$age == "Total")), 0)
})


# Sex
test_that("correct sex (dis)aggregation", {
  disaggregated <- get_population_ssb(regions = "norway",
                                      years = c(2020:2022),
                                      ages = c(10:15),
                                      aggregate_age = TRUE,
                                      by_sex = TRUE,
                                      save_xslx = FALSE)

  expect_length(which(names(disaggregated) == "sex_code"), 1)

  aggregated <- get_population_ssb(regions = "norway",
                                   years = c(2020:2022),
                                   ages = c(10:15),
                                   aggregate_age = TRUE,
                                   by_sex = FALSE,
                                   save_xslx = FALSE)

  expect_length(which(names(aggregated) == "sex"), 0)
})

# Saves excel correctly

test_that("save as xslx file",{
  td <- withr::local_tempdir()
  withr::local_dir(td)
  excel_test <- get_population_ssb(regions = "norway",
                     years = c(2020:2022),
                     ages = c(10:15),
                     aggregate_age = FALSE,
                     by_sex = FALSE,
                     save_xslx = TRUE)
  expect_true("population_ssb_norway.xlsx" %in% list.files(td))
}
)

# Snapshot for stable request

test_that("CLI stable for sample request", {
  expect_snapshot({get_population_ssb(regions = "norway",
                                               years = c(2020:2022),
                                               ages = c(10:15),
                                               aggregate_age = FALSE,
                                               by_sex = FALSE,
                                               save_xslx = FALSE)})
}
)


