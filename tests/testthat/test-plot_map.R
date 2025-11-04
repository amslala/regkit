# Layers ggplot

test_that("Correct type of plot in layers ggplot object", {

  pop_kommuner_2024 <- regtools::get_population_ssb(regions = "kommuner", years = 2024, ages = c(0:18), aggregate_age = TRUE, by_sex = FALSE)

  pop_kommuner_2024 <- regtools::harmonize_municipality_codes(data = pop_kommuner_2024, municipality_col = "region_code") |>
    dplyr::filter(age == "Total")

  map_population <- plot_map(pop_kommuner_2024, level = "kommune", rate_col = "population", region_number_col = "harmonized_code", auto_transform = TRUE)


  type_aes <- as.character(map_population$layers[[1]]$constructor[[1]])
  expect_equal(type_aes[3], "geom_sf")

})


test_that("Correctly joins kommune or fylke geographical data", {

  pop_kommuner_2024 <- regtools::get_population_ssb(regions = "kommuner", years = 2024, ages = c(0:18), aggregate_age = TRUE, by_sex = FALSE)

  pop_kommuner_2024 <- regtools::harmonize_municipality_codes(data = pop_kommuner_2024, municipality_col = "region_code") |>
    dplyr::filter(age == "Total")


  pop_fylker_2024 <- regtools::get_population_ssb(regions = "fylker", years = 2024, ages = c(0:18), aggregate_age = TRUE, by_sex = FALSE) |>
    dplyr::filter(age == "Total")

  map_population_fylker <- plot_map(pop_fylker_2024, level = "fylke", rate_col = "population", region_number_col = "region_code", auto_transform = TRUE)

  map_population_kommuner <- plot_map(pop_kommuner_2024, level = "kommune", rate_col = "population", region_number_col = "harmonized_code", auto_transform = TRUE)

  expect_true(inherits(map_population_kommuner$data, what = "sf"))
  expect_true(inherits(map_population_fylker$data, what = "sf"))

  expect_true("kommunenummer" %in% names(map_population_kommuner$data))
  expect_true("fylkesnavn" %in% names(map_population_fylker$data))

})
