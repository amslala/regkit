#' Get yearly population data from SSB, by region, sex and age.
#'
#' @param url_api Character string. URL used for the SSB API call. *Do not modify*.
#' @param regions Character string. Supported regions:
#' * "norway" for the country-wise population counts
#' * "fylker" for county population counts
#' * "kommuner" for municipality population counts (excluding Svalbard and Jan Mayen). Due to region reforms in Norway, the results are shown using SSB's harmonized county codes (2024)
#' @param years Numerical vector. Year(s) of population counts.
#' @param ages Numerical vector. Age(s) in whole years.
#' @param aggregate_age Logical. Default is `TRUE`.
#' * If `TRUE` and more than one age given, include new row with aggregated population for age group.
#' @param by_sex  Logical. Default is `TRUE`.
#' * If `TRUE` population counts are disaggregated by sex (male, female)
#' @param save_xslx Logical. Want to save the results as a xslx? Default is `FALSE`.
#' * If `TRUE` results are saved as xslx in the current working directory.
#' @returns Data frame with population data from SSB
#' @examples
#' # Population of Norway in 2020 to 2022, for ages 10 to 15,
#' # include total of that age group (10-15) for each year.
#' population_norway <- get_population_ssb(regions = "norway",
#'                                         years = c(2020:2022),
#'                                         ages = c(10:15),
#'                                         aggregate_age = TRUE,
#'                                         by_sex = TRUE,
#'                                         save_xslx = FALSE)
#'
#' @importFrom rlang .data
#' @export
#'
get_population_ssb <- function(url_api = "https://data.ssb.no/api/v0/en/table/07459/", regions = c("norway", "fylker", "kommuner"), years, ages, aggregate_age = TRUE, by_sex = TRUE, save_xslx = FALSE){


  if(!requireNamespace("PxWebApiData", quietly = TRUE)){
    stop("Package \"PxWebApiData\" must be installed to use this function.",call. = FALSE)
  }

  ## Input validation ####
  if(is.null(url_api)){
    cli::cli_abort("Requires SSB population table URL")
  }


  regions <- tolower(regions)
  supported_regions <- c("norway", "fylker", "kommuner")
  if(!regions %in% supported_regions){
    cli::cli_abort("{regions} not supported. Please specify 'norway' for country-wise population, 'fylker' for county populations or 'kommuner' for municipality populations.")
  }


  ## Format input parameters for API call
  age_api <- as.character(ages) |> stringr::str_pad(3, pad = "0")
  years_api <- as.character(years)

  if(regions == "norway"){
    region_api <- "0"
    region_substring <- 1
  } else if (regions == "fylker"){
    region_api <- list("agg:KommFylker", c("F-31", "F-32", "F-03", "F-34", "F-33", "F-39", "F-40", "F-42", "F-11", "F-46", "F-15", "F-50", "F-18", "F-55", "F-56"))
    region_substring <- 3
  } else if (regions == "kommuner"){
    region_api <- list("agg:KommSummer", c( "K-3101","K-3103","K-3105","K-3107","K-3110", "K-3112", "K-3114", "K-3116", "K-3118", "K-3120", "K-3122", "K-3124", "K-3201", "K-3203", "K-3205", "K-3207", "K-3209", "K-3212", "K-3214", "K-3216", "K-3218", "K-3220", "K-3222", "K-3224", "K-3226", "K-3228","K-3230", "K-3232", "K-3234", "K-3236", "K-3238", "K-3240", "K-3242", "K-0301", "K-3301", "K-3303", "K-3305", "K-3310", "K-3312", "K-3314", "K-3316", "K-3318", "K-3320", "K-3322", "K-3324", "K-3326", "K-3328", "K-3330", "K-3332", "K-3334", "K-3336", "K-3338", "K-3401", "K-3403", "K-3405", "K-3407", "K-3411", "K-3412", "K-3413", "K-3414", "K-3415", "K-3416", "K-3417", "K-3418", "K-3419", "K-3420", "K-3421", "K-3422", "K-3423", "K-3424", "K-3425", "K-3426", "K-3427", "K-3428", "K-3429", "K-3430", "K-3431", "K-3432", "K-3433", "K-3434", "K-3435", "K-3436", "K-3437", "K-3438", "K-3439", "K-3440", "K-3441", "K-3442", "K-3443", "K-3446", "K-3447", "K-3448", "K-3449", "K-3450", "K-3451", "K-3452", "K-3453", "K-3454", "K-3901", "K-3903", "K-3905", "K-3907", "K-3909", "K-3911", "K-4001", "K-4003", "K-4005", "K-4010", "K-4012", "K-4014", "K-4016", "K-4018", "K-4020", "K-4022", "K-4024", "K-4026", "K-4028", "K-4030", "K-4032", "K-4034", "K-4036", "K-4201", "K-4202", "K-4203", "K-4204", "K-4205", "K-4206", "K-4207", "K-4211", "K-4212", "K-4213", "K-4214", "K-4215", "K-4216", "K-4217", "K-4218", "K-4219", "K-4220", "K-4221", "K-4222", "K-4223", "K-4224", "K-4225", "K-4226", "K-4227", "K-4228", "K-1101", "K-1103", "K-1106", "K-1108", "K-1111", "K-1112", "K-1114", "K-1119", "K-1120", "K-1121", "K-1122", "K-1124", "K-1127", "K-1130", "K-1133", "K-1134", "K-1135", "K-1144", "K-1145", "K-1146", "K-1149", "K-1151", "K-1160", "K-4601", "K-4602", "K-4611", "K-4612", "K-4613", "K-4614", "K-4615", "K-4616", "K-4617", "K-4618", "K-4619", "K-4620", "K-4621", "K-4622", "K-4623", "K-4624", "K-4625", "K-4626", "K-4627", "K-4628", "K-4629", "K-4630", "K-4631", "K-4632", "K-4633", "K-4634", "K-4635", "K-4636", "K-4637", "K-4638", "K-4639", "K-4640", "K-4641", "K-4642", "K-4643", "K-4644", "K-4645", "K-4646", "K-4647", "K-4648", "K-4649", "K-4650", "K-4651", "K-1505", "K-1506", "K-1508", "K-1511", "K-1514", "K-1515", "K-1516", "K-1517", "K-1520", "K-1525", "K-1528", "K-1531", "K-1532", "K-1535", "K-1539", "K-1547", "K-1554", "K-1557", "K-1560", "K-1563", "K-1566", "K-1573", "K-1576", "K-1577", "K-1578", "K-1579", "K-1580", "K-5001", "K-5006", "K-5007", "K-5014", "K-5020", "K-5021", "K-5022", "K-5025", "K-5026", "K-5027", "K-5028", "K-5029", "K-5031", "K-5032", "K-5033", "K-5034", "K-5035", "K-5036", "K-5037", "K-5038", "K-5041", "K-5042", "K-5043", "K-5044", "K-5045", "K-5046", "K-5047", "K-5049", "K-5052", "K-5053", "K-5054", "K-5055", "K-5056", "K-5057", "K-5058", "K-5059", "K-5060", "K-5061", "K-1804", "K-1806", "K-1811", "K-1812", "K-1813", "K-1815", "K-1816", "K-1818", "K-1820", "K-1822", "K-1824", "K-1825", "K-1826", "K-1827", "K-1828", "K-1832", "K-1833", "K-1834", "K-1835", "K-1836", "K-1837", "K-1838", "K-1839", "K-1840", "K-1841", "K-1845", "K-1848", "K-1851", "K-1853", "K-1856", "K-1857", "K-1859", "K-1860", "K-1865", "K-1866", "K-1867", "K-1868", "K-1870", "K-1871", "K-1874", "K-1875", "K-5501", "K-5503", "K-5510", "K-5512", "K-5514", "K-5516", "K-5518", "K-5520", "K-5522", "K-5524", "K-5526", "K-5528", "K-5530", "K-5532", "K-5534", "K-5536", "K-5538", "K-5540", "K-5542", "K-5544", "K-5546", "K-5601", "K-5603", "K-5605", "K-5607", "K-5610", "K-5612", "K-5614", "K-5616", "K-5618", "K-5620", "K-5622", "K-5624", "K-5626", "K-5628", "K-5630", "K-5632", "K-5634", "K-5636", "K-Rest"))
    # Does not include K-21-22 and K-23 (Svalbard, Jan Mayen and Kontinentalsokkelen)
    region_substring <- 3
  }

  #Main call

  cli::cli_alert_info("Retrieving population of {regions} for the years: {glue::glue_collapse(years, sep = ',')}, and ages: {glue::glue_collapse(ages, sep = ',')}")

  population_api_list <- PxWebApiData::ApiData(url_api,
                                               Region = region_api,
                                               Tid = years_api,
                                               Alder = age_api,
                                               Kjonn = by_sex)

  if (by_sex == TRUE){
    population_api_df <- cbind(population_api_list[[2]], population_api_list[[1]][, 1:2])
    population_api_df$Region <- substring(population_api_df$Region, region_substring)


    population_api_df <- population_api_df |>
      dplyr::rename("region_code" = "Region", "region_name" = "region", "sex_value" = "sex", "sex" = "Kjonn", "year" = "Tid", "age"= "Alder", "population" = "value") |>
      dplyr::select(!c("ContentsCode"))

    if (aggregate_age == TRUE && length(ages)>1){
      cli::cli_alert_info("Aggregating ages...")
      population_api_df <- population_api_df  |>
        dplyr::group_split(.data$region_code, .data$sex, .data$year, .data$region_name)  |>
        purrr::map_df(~dplyr::add_row(.x,
                                      region_code = dplyr::first(.x$region_code),
                                      sex = dplyr::first(.x$sex),
                                      year = dplyr::first(.x$year),
                                      region_name = dplyr::first(.x$region_name),
                                      sex_value = dplyr::first(.x$sex_value),
                                      population = sum(.x$population),
                                      age = 'Total'))
    } else {
      population_api_df <- population_api_df
    }
  } else if (by_sex == FALSE){
    population_api_df <- cbind(population_api_list[[2]], population_api_list[[1]][, 1, drop = FALSE])

    population_api_df$Region <- substring(population_api_df$Region, region_substring)

    population_api_df <- population_api_df |>
      dplyr::rename("region_code" = "Region", "region_name" = "region", "year" = "Tid", "age"= "Alder", "population" = "value") |>
      dplyr::select(!c("ContentsCode"))
    if (aggregate_age == TRUE && length(ages)>1){
      cli::cli_alert_info("Aggregating ages...")
      population_api_df <- population_api_df  |>
        dplyr::group_split(.data$region_code, .data$year)  |>
        purrr::map_df(~dplyr::add_row(.x,
                                      region_code = dplyr::first(.x$region_code),
                                      year = dplyr::first(.x$year),
                                      region_name = dplyr::first(.x$region_name),
                                      population = sum(.x$population),
                                      age = 'Total'))
    } else {
      population_api_df <- population_api_df
    }
  }

  if (save_xslx == TRUE){
    if(!requireNamespace("openxlsx", quietly = TRUE)){
      stop("Package \"openxlsx\" must be installed to save population as xslx file.",call. = FALSE)
    } else {
      openxlsx::write.xlsx(population_api_df, glue::glue("population_ssb_{regions}.xlsx"), overwrite = TRUE)
      cli::cli_alert_success("XLSX file saved as: population_ssb_{regions}.xlsx")
    }
  }

  cli::cli_alert_success("Population dataset ready!")

  return(population_api_df)
}


