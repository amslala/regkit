# Layers ggplot

test_that("Correct type of plot in layers ggplot object", {
  log_file <- tempfile()
  cat("Example log file", file = log_file)

  pop_df <- tidyr::expand_grid(year = 2012:2020,
                               sex = as.factor(c(0, 1)),
                               innvandringsgrunn = c("ARB", "UKJ", "NRD")) |>
    dplyr::mutate(population = floor(runif(dplyr::n(), min = 3000, max = 4000)))

  linked_df <- linked_df |>
    dplyr::rename("year"= "y_diagnosis_first")

  prev_series <- regkit::calculate_prevalence_series(linked_df,
                                                       time_points = c(2012:2020),
                                                       id_col = "id",
                                                       date_col = "year",
                                                       pop_data = pop_df,
                                                       pop_col = "population",
                                                       grouping_vars = c("sex", "innvandringsgrunn"),
                                                       only_counts = FALSE,
                                                       suppression = FALSE,
                                                       CI = TRUE,
                                                       CI_level = 0.95,
                                                       log_path = log_file)


  plot_line <- plot_rates(prev_series,
                          date_col = "year",
                          rate_col = "prev_rate",
                          plot_type = "line",
                          grouping_var = "sex",
                          facet_var = "innvandringsgrunn",
                          palette = "fhi_colors",
                          CI_lower = "ci_results_lower",
                          CI_upper = "ci_results_upper",
                          plot_title = "Prevalence by sex and reason of immigration",
                          x_name = "Year",
                          start_end_points = TRUE)

  type_aes <- as.character(plot_line$layers[[1]]$constructor[[1]])
  expect_equal(type_aes, "geom_line")




  plot_bar <- plot_rates(prev_series,
                          date_col = "year",
                          rate_col = "prev_rate",
                          plot_type = "bar_chart",
                          grouping_var = "sex",
                          facet_var = "innvandringsgrunn",
                          palette = "fhi_colors",
                          CI_lower = "ci_results_lower",
                          CI_upper = "ci_results_upper",
                          plot_title = "Prevalence by sex and reason of immigration",
                          x_name = "Year",
                          start_end_points = TRUE)

  type_aes <- as.character(plot_bar$layers[[1]]$constructor[[1]])
  expect_equal(type_aes, "geom_bar")


  plot_lollipop <- plot_rates(prev_series,
                              date_col = "year",
                              rate_col = "prev_rate",
                              plot_type = "lollipop",
                              grouping_var = "sex",
                              facet_var = "innvandringsgrunn",
                              palette = "fhi_colors",
                              CI_lower = "ci_results_lower",
                              CI_upper = "ci_results_upper",
                              plot_title = "Prevalence by sex and reason of immigration",
                              x_name = "Year",
                              start_end_points = TRUE)

  type_aes <- as.character(plot_lollipop$layers[[1]]$constructor[[1]])
  expect_equal(type_aes, "geom_segment")


  plot_jitter <- plot_rates(prev_series,
                            date_col = "year",
                            rate_col = "prev_rate",
                            plot_type = "jitter",
                            grouping_var = "sex",
                            facet_var = "innvandringsgrunn",
                            palette = "fhi_colors",
                            CI_lower = "ci_results_lower",
                            CI_upper = "ci_results_upper",
                            plot_title = "Prevalence by sex and reason of immigration",
                            x_name = "Year",
                            start_end_points = TRUE)

type_aes <- as.character(plot_jitter$layers[[1]]$constructor[[1]])
expect_equal(type_aes, "geom_jitter")


})




# Expect it outputs a ggplot object
# invisible


 #plot_2$layers[[1]]$constructor[[1]]










# Visual test

# test_that("output of ggplot() is stable", {
#   vdiffr::expect_doppelganger("A blank plot")
# })
