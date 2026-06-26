#' Create simulated diagnostic, time-varying and time-invariant individual level data
#'
#' @description
#' The `simulate_data()` function creates individual-level data sets.
#' It simulates the structure of diagnostic, time-varying and time-invariant data you might commonly encounter when working with Norwegian medical and sociodemographic data (e.g. NPR and SSB)
#'
#' @param population_size An integer. Number of total population size (individual).
#' @param prefix_ids A character string. Prefix used to construct unique IDs. Default is "P000".
#' @param length_ids An integer. Total character length of each ID. Default is 6.
#' @param seed A numerical value. Seed used to ensure reproducible results. Default is `seed = 123`
#' @param family_codes A character vector. Relevant diagnostic (either ICD-10 or ICPC-2 codes or family of codes. Example: `family_codes = c("F84", "G")`
#' @param diag_code_type A character string. Desired code classification, options are "icd" or "icpc". Default is "icd"
#' @param pattern A character string. Pattern of incidence or prevalence rates in simulated data. Possible options are "increase", "decrease" or "random".
#' @param prevalence A numeric value between 0 and 1. Prevalence rate expressed as a proportion.
#' @param incidence A numeric value between 0 and 1. Incidence rate expressed as a proportion.
#' @param diag_years A numeric vector. Years to be used as relevant diagnostic years.
#' @param sex_vector A factor or character vector. Factors used to represent sex in the simulated data sets.
#' @param y_birth A numeric vector. Years to be used as relevant years of birth.
#' @param filler_codes A character vector. Diagnostic codes or family of codes used as fillers. Example: `filler_codes = c("R", "P20")`
#' @param filler_y_birth A numeric vector. Years to be used as filler years of birth.
#' @param invariant_queries A character vector. Uses Statistics Norway API to retrieve desired invariant variable classification(s). Example: `invariant_queries = c("innvandringsgrunn")`
#' @param invariant_codes Data frame or named list. Codes to be used as relevant invariant codes in dataset.
#' * If a data frame is provided, column names will be considered as the names of the invariant variables.
#' * If a named list is provided, the name of each element will be consider as the invariant variable name. Example: `invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ"), "blodtype" = c("A", "B", "AB", "O"))`
#' @param invariant_codes_filler Data frame or named list. Codes to be used as filler invariant codes in dataset.
#' @param varying_query A character string. Uses Statistics Norway API to retrieve desired varying variable classification(s). Example: `varying_query = c("kommune")`
#' @param varying_codes A character vector. Codes to be used as relevant varying codes in dataset. Example: `varying_codes = as.character(0:4)`
#' @param varying_codes_filler A character vector. Codes to be used as filler varying codes in dataset. Example: `varying_codes_filler = as.character(5:9)`
#' @param date_classifications Date used to retrieve classification system from SSB. Format must be **"yyyy-mm-dd"**
#'
#' @return Named list containing two lists. The first list named 'datasets' includes the data frames with individual level diagnostic and sociodemographic data. The second list named 'metadata' includes the exact function call and arguments given by the user
#' @examples
#' simulated_list <- simulate_data(
#'   population_size = 1000,
#'   prefix_ids = "P000",
#'   length_ids = 6,
#'   family_codes = c("F45", "F84"),
#'   pattern = "increase",
#'   prevalence = .023,
#'   diag_years  = c(2012:2020),
#'   sex_vector = c(0, 1),
#'   y_birth = c(2010:2018),
#'   filler_codes = "F",
#'   filler_y_birth = c(2000:2009),
#'  invariant_codes = list("innvandringsgrunn" = c("ARB", "NRD", "UKJ")),
#'   invariant_codes_filler = list("innvandringsgrunn" = c("FAMM", "UTD")),
#'   varying_query = "fylke"
#' )
#' @importFrom rlang .data
#' @export
#'
simulate_data <- function(
    population_size,
    prefix_ids,
    length_ids,
    seed = "123",
    family_codes,
    diag_code_type = "icd",
    pattern = c("increase", "decrease", "random"),
    prevalence = NULL,
    diag_years,
    incidence = NULL,
    sex_vector,
    y_birth,
    filler_codes,
    filler_y_birth,
    invariant_queries = NULL,
    invariant_codes = NULL,
    invariant_codes_filler,
    varying_query = NULL,
    varying_codes = NULL,
    varying_codes_filler = NULL,
    date_classifications = NULL){




  # Set seed only for function

  withr::with_seed(seed, {

  ### Input validation --------------------------------------------------------

  pattern <- match.arg(pattern, several.ok = FALSE)

  if (is.null(prevalence) && is.null (incidence)){
    stop("Either prevalance or incidence has to be provided")
  } else if (!is.null(prevalence) && !is.null(incidence)){
    stop("Both prevalence and incidence are provided. Only one of those arguments needs to be provided.")
  }

  if (is.null(invariant_queries) && is.null(invariant_codes)){
    cli::cli_abort("Either invariant queries for SSB's API, or invariant codes need to be provided")
  }

  if (!is.null(varying_codes) && is.null(varying_codes_filler)){
    stop("You have provided varying codes. Filler varying codes also need to be provided.")
  }

  if (!diag_code_type %in% c("icd", "icpc")){
    stop("diag_code_type not valid. Must be either 'icd' or 'icpc'.")
  }
  if (is.null(varying_query) && is.null(varying_codes)){
    cli::cli_alert_warning("Varying query and varying codes arguments are empty. The varying dataset will not be generated.")
  }

  if(!is.null(incidence)){
    if(length(incidence) != length(diag_years)){
      stop("Number of elements in incidence vector do not correspond with number of diagnosis years")
    }
  }

  ### Helper functions ---------------------------------------------------------

  # Generate unique ids based on the population size, prefix and length id
  unique_ids <- function(population_size, prefix = "P000", length_id) {

    max_length <- 10^length_id
    if (population_size > max_length){
      cli::cli_abort("Population size exceed possible number of unique ID
                   combinations. Try increasing 'length_id'.")
    }

    random_numbers <- sample(0:(max_length-1), population_size)

    unique_ids <- sprintf(paste0("%0", length_id, "d"), random_numbers)
    paste0(prefix, unique_ids)
  }


  # Extract desired diagnostic codes, validates that they do exist
  diag_codes <- function(family, code_type){
    pattern <- paste0("^(", paste(family, collapse = "|"), ")")

    if(code_type == "icd"){
      matching_codes <- purrr::map(npr[, 1], function(x){
        x[grepl(pattern, x, ignore.case = TRUE)]
      })
    } else if (code_type == "icpc"){
      matching_codes <- purrr::map(icpc_2[, 1], function(x){
        x[grepl(pattern, x, ignore.case = TRUE)]
      })
    }
    matching_codes <- purrr::list_c(matching_codes)

    if (length(matching_codes) == 0){
      cli::cli_abort("No diagnostic codes found matching: {family}")
    }

    return(matching_codes)
  }

  # Calculates number of cases by time period (years) depending on prevalence/incidence and pattern.
  number_cases <- function(population_size, pattern = "random", prevalence = NULL, diag_years, incidence = NULL){

    periods <- length(diag_years)


    if (!is.null(prevalence)){
      if (prevalence < 0 | prevalence > 1){
        stop("Prevalence rate is not expressed as a proportion between 0 and 1.")
      }
      prevalence_cases <- round(population_size * prevalence)
      if (pattern == "random"){
        prob_equal <- rep.int(1 / periods, periods)
        incidence_cases <- as.vector(stats::rmultinom(1, size = prevalence_cases, prob = prob_equal))
      } else if (pattern == "increase"){
        prob_increasing <- 1:periods
        incidence_cases <- as.vector(stats::rmultinom(1, size = prevalence_cases, prob = prob_increasing))
      } else if (pattern == "decrease") {
        prob_decrease <- rev(1:periods)
        incidence_cases <- as.vector(stats::rmultinom(1, size = prevalence_cases, prob = prob_decrease))
      }
      n_cases_list <- list(incidence_cases = incidence_cases,
                           prevalence_cases = round(population_size * prevalence),
                           diag_years = diag_years)

    }

    if (!is.null(incidence)){
      if(any(incidence < 0 | incidence > 1)){
        stop("Not all incidence rates are expressed as a proportion between 0 and 1.")
      }
      incidence_cases <- purrr::map_dbl(incidence, ~round(population_size*.x))
      prevalence <- sum(incidence_cases)
      n_cases_list <- list(incidence_cases = incidence_cases,
                           prevalence_cases = prevalence,
                           diag_years = diag_years)
    }

    return(n_cases_list)
  }

  # Generates individual level data
  generate_cases <- function(ids, codes, cases_list, sex, y_birth){

    prevalence_cases <- cases_list[["prevalence_cases"]]

    cases_df <- dplyr::tibble(
      id = sample(ids, prevalence_cases, replace = FALSE),
      code = sample(codes, prevalence_cases, replace = TRUE),
      sex = as.factor(sample(sex, prevalence_cases, replace = TRUE)),
      y_birth = sample(y_birth, prevalence_cases, replace= TRUE))

    date_df <- purrr::map2_dfr(
      cases_list$diag_years,
      cases_list$incidence_cases,
      ~ dplyr::tibble(diag_year = rep(.x, .y))
    )

    cases_df <- cbind(cases_df, date_df)
    cases_df <- cases_df[,c(1,2,5,3,4)]

    return(cases_df)
  }
  # Retrieves classification of variables from SSB
  get_classifications <- function(queries, date = NULL) {

    if (length(queries) == 1) {
      if(queries == "kommune"){
        search <- klassR::search_klass("kommuneinndeling")
        class_code <- search$klass_nr[1]
        codes_ssb <- klassR::get_klass(classification = class_code,
                                      language = "en",
                                      date = date) |>
          dplyr::select(c("code", "name"))
        return(codes_ssb)
      } else if (queries == "fylke"){
        search <- klassR::search_klass("fylkesinndeling")
        class_code <- search$klass_nr[1]
        codes_ssb <- klassR::get_klass(classification = class_code,
                                      language = "en",
                                      date = date) |>
          dplyr::select(c("code", "name"))
        return(codes_ssb)
      } else {
        search <- klassR::search_klass(queries)
        if(length(search) == 0){
          stop("No results from query search!")
        }
        class_code <- search$klass_nr[1]
        codes_ssb <- klassR::get_klass(classification = class_code,
                                      language = "en",
                                      date = date) |>
          dplyr::select(c("code", "name"))
        return(codes_ssb)
      }
    }

    #Multiple queries
    result_list <- purrr::map(queries, function(query) {
      search <- klassR::search_klass(query)
      class_code <- search$klass_nr[1]
      codes_ssb <- klassR::get_klass(classification = class_code,
                                    language = "en",
                                    date = date) |>
        dplyr::select(c("code", "name"))
      return(codes_ssb)
    })

    names(result_list) <- queries

    return(result_list)
  }

  # Adds invariant SSB codes/classifications to individual level data
  add_invariant_ssb <- function(data, new_info, user_codes) {

    size <- nrow(data)
    if (is.data.frame(new_info)) {
      sampled_idx <- sample(nrow(new_info), size = size, replace = TRUE)
      data[["invariant_code"]] <- new_info$code[sampled_idx]
      data[["description"]] <- new_info$name[sampled_idx]

    } else if (is.list(new_info) && user_codes == FALSE) {
      for (i in seq_along(new_info)) {
        curr_info <- new_info[[i]]
        prefix <- names(new_info)[i]
        new_code_col <- glue::glue("{prefix}_code")
        new_desc_col <- glue::glue("{prefix}_description")
        sampled_idx <- sample(nrow(curr_info), size = size, replace = TRUE)
        data[[new_code_col]] <- curr_info$code[sampled_idx]
        data[[new_desc_col]] <- curr_info$name[sampled_idx]
      }
    } else if (is.list(new_info) && user_codes == TRUE) {
      new_cols <- purrr::imap(new_info, function(codes, var_name){
        sample(codes, size = nrow(data), replace = TRUE)
      })
      #"names(new_cols)[1] <- "invariant_code"
      data <- cbind(data, new_cols)
    }

    return(data)
  }

  construct_yearly <- function(data, years_expand){
    expanded_x <- data |>
      dplyr::mutate(
        year_varying = list(years_expand)) |>
      tidyr::unnest("year_varying")
  }

  # Assign varying codes, simulating also some changes in status for each individual
  assign_regions <- function(data, regions) {
    if (is.vector(regions)){
      codes <- regions
    } else if (is.data.frame(regions)){
      codes <- regions$code
    }

    varying_data_codes <- data |>
      dplyr::group_by(id)  |>
      dplyr::group_modify(~ {
        n_years <- nrow(.x)
        num_moves <- sample(1:3, 1, replace = TRUE)

        if (num_moves == 1) {
          region_assignment <- rep(sample(codes, 1, replace = TRUE), n_years)
        } else {
          moving_year <- sort(sample(1:(n_years - 1), num_moves - 1, replace = TRUE))
          spans <- c(moving_year, n_years) - c(0, moving_year)
          region_assignment <- rep(sample(codes, num_moves, replace = TRUE), times = spans)
        }

        .x$varying_code <- region_assignment
        return(.x)
      })  |>
      dplyr::ungroup()

    return(varying_data_codes)
  }


  add_diag_noise <- function(data, filler_codes, diag_years, diag_code_type){  # It works right now only with filler codes, not with also relevant codes
    n_rep <- sample(1:5, nrow(data), replace = TRUE)
    all_codes <- diag_codes(family = c(filler_codes), code_type = diag_code_type)

    df_noise <- dplyr::tibble(id = rep(data$id, times = n_rep),
                              code = sample(all_codes, sum(n_rep), replace = TRUE),
                              diag_year = sample(diag_years, sum(n_rep), replace = TRUE))


    df_all <- data |> rbind(df_noise) |> dplyr::arrange(id)

  }


  ### Main function call -------------------------------------------------------

  # Generate relevant individual-level diagnostic cases and some of the time invariant information (sex, years of birth)
  unique_id_vector <- unique_ids(population_size, prefix = prefix_ids, length_id = length_ids)
  icd10_vector <- diag_codes(family = family_codes, code_type = diag_code_type)
  list_cases <- number_cases(population_size = population_size, pattern = pattern, prevalence = prevalence, diag_years = diag_years, incidence = incidence)
  cat("\n")
  cli::cli_alert_info("Creating relevant cases with the following characteristics:")
  cli::cli_ul(c("Population size = {population_size}",
                "Prefix IDs = {prefix_ids}",
                "Length IDs = {length_ids}",
                "Diagnostic relevant codes = {family_codes}",
                "Pattern of incidence = {pattern}",
                "Prevalence = {prevalence}",
                "Diagnostic years = {diag_years}",
                "Incidence = {incidence}",
                "Coding sex = {sex_vector}",
                "Relevant years of birth = {y_birth}"
  ))
  cat("\n")
  diagnostic_df <- generate_cases(ids = unique_id_vector, codes = icd10_vector,
                                  cases_list = list_cases, sex = sex_vector, y_birth = y_birth)





  ### Add diagnostic duplicates -----------------------------------------------



  other_codes <- diag_codes(family = filler_codes, code_type = diag_code_type)
  new_codes <- setdiff(other_codes, icd10_vector)

  diagnostic_df_noise <- add_diag_noise(diagnostic_df[1:3],  filler_codes = new_codes, diag_years = diag_years, diag_code_type = diag_code_type)



  # Include relevant time-invariant data. Uses SSB API, unless the user provides their own invariant_codes

  if (is.null(invariant_codes)){
    invariant_codes <- get_classifications(queries = invariant_queries)
    relevant_cases_unvar <- add_invariant_ssb(diagnostic_df[c(1,4,5)], invariant_codes, user_codes = F)
    relevant_cases_unvar <- diagnostic_df_noise |> dplyr::left_join(relevant_cases_unvar, by = c("id"))
  } else if (!is.null(invariant_codes)){
    relevant_cases_unvar <- add_invariant_ssb(diagnostic_df[c(1,4,5)], invariant_codes, user_codes = T)
    relevant_cases_unvar <- diagnostic_df_noise |> dplyr::left_join(relevant_cases_unvar, by = c("id"))
  }


  # Assign regions of residence.

  if(is.null(varying_codes) & is.null(varying_query)){ # if both are NULL, then we dont need to add any varying codes.
    relevant_cases_unvar_region <- relevant_cases_unvar
  } else if (is.null(varying_codes) && !is.null(varying_query)){ # if varying_codes NULL and varying_query provided then use varying_query as query for invariant
    varying_codes_api <- get_classifications(queries = varying_query, date = date_classifications)
    varying_codes_api_relevant <- sample(varying_codes_api$code, size = (length(varying_codes_api$code)*.6))
    relevant_cases_unvar_region <- diagnostic_df |> dplyr::mutate(varying_code = sample(varying_codes_api_relevant, nrow(diagnostic_df), replace = TRUE),
                                                                         year_varying = .data$diag_year)
  } else if (!is.null(varying_codes)){ # if user gives region codes, use those to populate varying codes in the individual level dataset
    relevant_cases_unvar_region <- diagnostic_df |> dplyr::mutate(varying_code = sample(varying_codes, nrow(diagnostic_df), replace = TRUE),
                                                                         year_varying = .data$diag_year)
  }


  ### Filler cases ------------------------------------------------------------



  cli::cli_alert_info("Creating filler cases with the following characteristics:")
  cli::cli_ul(c("Filler diagnostic codes = {filler_codes}",
                "Filler years of birth = {filler_y_birth}",
                "Pattern for filler incidence = 'random'",
                "Number of filler cases to generate = {length(unique_id_vector) - length(relevant_cases_unvar_region$id)}"
  ))
  cat("\n")
  cli::cli_alert_warning("This process can take some minutes...")


  used_ids <- relevant_cases_unvar_region$id
  new_ids <- setdiff(unique_id_vector, used_ids)

  random_incidence <- number_cases(length(new_ids), pattern = "random", prevalence = 1, diag_years = list_cases$diag_years)
  filler_diagnostic_df <- generate_cases(new_ids, new_codes, random_incidence, sex = sex_vector, y_birth= filler_y_birth)

  # Add duplicates to fillers

  filler_diagnostic_df_noise <- add_diag_noise(data = filler_diagnostic_df[1:3], filler_codes = filler_codes, diag_years = list_cases$diag_years, diag_code_type = diag_code_type)


  # Add filler invariant codes

  filler_diagnostic_unvar <- add_invariant_ssb(filler_diagnostic_df[c(1, 4, 5)], invariant_codes_filler, user_codes = T)

  filler_diagnostic_df <- filler_diagnostic_df_noise |> dplyr::left_join(filler_diagnostic_unvar, by = c("id"))

  # all cases (relevant and filler with noise)
  all_cases <- relevant_cases_unvar |>
    dplyr::bind_rows(filler_diagnostic_df)



  # Add filler varying codes

  # If varying_codes_filler NULL, then varying_query need to be given and then use setdiff with varying_codes

  if (is.null(varying_codes) && is.null(varying_query)){
    all_cases_updated <- all_cases
  } else if (is.null(varying_codes_filler) && !is.null(varying_query)) {
    all_cases_var <- all_cases[c(1, 4:6)] |> dplyr::distinct() |> # no noise, only distinct ids
      construct_yearly(years_expand = diag_years)
    varying_codes_filler <- get_classifications(queries = varying_query, date = date_classifications) |> dplyr::select("code")
    varying_codes_filler_unique <- setdiff(unique(varying_codes_filler$code), unique(relevant_cases_unvar_region$varying_code))
    if (length(varying_codes_filler_unique)==0){
      stop("Filler varying codes are not unique, try providing your own filler codes in 'varying_codes_filler'")
    }
    all_cases_var <- assign_regions(all_cases_var, varying_codes_filler_unique)
    all_cases_updated <-dplyr::rows_update(all_cases_var, relevant_cases_unvar_region[c(1, 4:7)], by = c("id", "year_varying"), unmatched = "ignore")
  }
  else if (!is.null(varying_codes_filler)){
    all_cases_var <- all_cases[c(1, 4:6)] |> dplyr::distinct() |>
      construct_yearly(years_expand = diag_years)
    all_cases_var <- assign_regions(all_cases_var, varying_codes_filler)
    all_cases_updated <-dplyr::rows_update(all_cases_var, relevant_cases_unvar_region[c(1, 4:7)], by = c("id", "year_varying"), unmatched = "ignore")
  }
  # Update with relevant codes for diagnostic cases

  if ("varying_code" %in% colnames(all_cases_updated)){
    invar_df <- all_cases_updated |> dplyr::select(!c("year_varying", "varying_code")) |> dplyr::distinct()
    var_df <- all_cases_updated |> dplyr::select("id", "year_varying", "varying_code")
    diag_df <- all_cases |> dplyr::select("id", "code", "diag_year") |> dplyr::as_tibble()
    all_cases_updated_list <- list(invar_df = invar_df, var_df = var_df, diag_df = diag_df)
    cat("\n")
    cli::cli_alert_success("Succesfully generated diagnostic, time-varying and time-invariant datasets!")
  } else {
    invar_df <- all_cases_updated |> dplyr::select(!c("code", "diag_year")) |> dplyr::distinct()
    diag_df <- all_cases |> dplyr::select("id", "code", "diag_year") |> dplyr::distinct() |> dplyr::as_tibble()
    all_cases_updated_list <- list(invar_df = invar_df, diag_df = diag_df)
    cat("\n")
    cli::cli_alert_success("Succesfully generated diagnostic and time-invariant datasets!")
  }

# Add metadata ------------------------------------------------------------

  matched <- rlang::call_match(sys.call(), simulate_data)
  arg_vals <- rlang::call_args(matched)
  final_list <- list(datasets = all_cases_updated_list, metadata = list(call = matched, arguments = arg_vals))
  return(final_list)
}) # withr::with_seed parenthesis
}
