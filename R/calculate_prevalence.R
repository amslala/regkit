#' Calculate prevalence rates
#'
#' @description
#'The `calculate_prevalence()` function calculates prevalence rates based on the given diagnostic and demographic information.
#'Prevalence represents the number of cases of a given diagnosis that exist in a population of interest at a specified point or period in time.
#'
#' @param linked_data A data frame containing linked relevant diagnostic and demographic information.
#' @param id_col A character string. Name of ID (unique personal identifier) column in `linked_data`. Default is "id".
#' @param date_col A character string. Name  of the date column in `linked_data`. Default is "date".
#' @param pop_data A data frame containing corresponding population count information.
#' @param pop_col A character string. Name of the column containing population counts in `pop_data`.
#' @param time_p  A numeric value or numeric vector. Time point or time period used to calculate the incidence.
#' * For period prevalence, specify as a range. The first value of the vector is the period's lower bound, and the second element is the period's upper bound. Example:  `time_p = c(2010,2015)`
#' * For point prevalence, single numeric value. Example: `time_p = 2010`
#' @param grouping_vars Character vector (optional). Grouping variables for the aggregation of diagnostic counts (e.g. sex, education).
#' @param only_counts Logical. Only want diagnostic counts? Default is `FALSE`.
#' * If `TRUE`, return only counts.
#' @param suppression Logical. Suppress results (counts and rates) in order to maintain statistical confidentiality? Default is `TRUE`.
#' * If `TRUE`, applies primary suppression (NA) to any value under the threshold defined by `suppression_threshold`
#' @param suppression_threshold Integer. Threshold used for suppression, default is set to 5 (NPR standard).
#' @param CI Logical. Want to compute binomial confidence intervals? Default is `TRUE`.
#' * If `TRUE`, add two new columns with the upper and lower CI bound with significance level defined by `CI_level`. Uses the Pearson-Klopper method.
#' @param CI_level A numerical value between 0 and 1. Level for confidence intervals, default is set to 0.99
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`.
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#'
#' @return Prevalence rate table
#' @examples
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' pop_df <- tibble::tibble(year = "2012-2020", population = 30024)
#' linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")
#'
#' prevalence_df <- calculate_prevalence(linked_df,
#'   id_col = "id",
#'   date_col = "year",
#'   pop_data = pop_df,
#'   pop_col = "population",
#'   time_p = c(2012,2020),
#'   CI = TRUE,
#'   CI_level = 0.95,
#'   only_counts = FALSE,
#'   suppression = TRUE,
#'   suppression_threshold = 10,
#'   log_path = log_file)
#'
#' @export
#' @import logger

calculate_prevalence <- function(linked_data,
                                 id_col = "id",
                                 date_col = "date",
                                 pop_data = NULL,
                                 pop_col = "pop_count",
                                 time_p,
                                 grouping_vars = NULL,
                                 CI = TRUE,
                                 CI_level = 0.99,
                                 only_counts = FALSE,
                                 suppression = TRUE,
                                 suppression_threshold = 5,
                                 log_path= NULL){



  ##### Set up logging #####
  log_threshold(DEBUG)
  log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    log_appender(appender_file(glue::glue("log/calculate_prevalence_{formatted_date}.log")))
    log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    log_appender(appender_file(log_path))
  }


  ## Input validation ####

  if(!all(grouping_vars %in% names(linked_data))) {
    log_error("The linked dataset must contain the specified 'grouping variables': {paste(grouping_vars, collapse = ', ')}")
    cli::cli_abort("The linked dataset must contain the specified 'grouping variables': {grouping_vars}")
  }

  if(!id_col %in% names(linked_data)) {
    log_error("The linked dataset must contain the specified 'id' column: {id_col}")
    cli::cli_abort("The linked dataset must contain the specified 'id' column: {id_col}")
  }

  if(!date_col %in% names(linked_data) & !date_col %in% names(pop_data)){
    log_error("The population and linked data must include the same specified 'date' column: {date_col}")
    cli::cli_abort("The population and linked data must include the same specified 'date' column: {date_col}")
  }

  #### Suppression helper function ####
  suppress_values <- function(data, columns, threshold) {
    data <- data |>
      dplyr::mutate(dplyr::across(tidyselect::all_of(columns), ~ ifelse(. <= threshold, NA, .)))
    n_removed <- data |>
      dplyr::filter(dplyr::if_any(tidyselect::all_of(columns), ~ is.na(.))) |>
      nrow()
    cli::cli_alert_success("Suppressed counts using {.strong {suppression_threshold}} threshold")
    cli::cli_alert_info("Removed {.val {n_removed}} cells out of {nrow(data)}")
    log_info("Suppressed counts using {suppression_threshold} threshold. Removed {n_removed} cells out of {nrow(data)}")
    return(data)
  }

  #### Confidence interval helper function ###

  calculate_ci <- function(data, method = "exact", conf_level, n_col){
    ci_row <- function(x, n, row_num){
      if(is.na(x)){
        return(tibble::tibble(
          method = method,
          x = x,
          n = n,
          mean = NA,
          lower = NA,
          upper = NA,
          row_num = row_num
        ))
      }

    binom::binom.confint(x = x, n = n, methods = method, conf.level = conf_level) |>
      tibble::as_tibble() |>
      dplyr::mutate(row_num = row_num)
  }

  data |>
    dplyr::mutate(row_num = dplyr::row_number()) |>
    dplyr::mutate(
      ci_results = purrr::pmap(
        list(x = .data$unique_id, n = .data[[n_col]], row_num = .data$row_num),
        ci_row
      )
    ) |>
    tidyr::unnest(ci_results, names_sep = "_") |>
    dplyr::select(!c("row_num", "ci_results_row_num", "ci_results_x", "ci_results_n"))
}



  ##### Check for time-point or period and filter ####
  message("Computing prevalence rates/counts...")

  if (length(time_p) == 1){
    filtered_data <- linked_data |>
      dplyr::filter(.data[[date_col]] == time_p)
  } else if (length(time_p) ==2){
    filtered_data <- linked_data |>
      dplyr::filter(.data[[date_col]] >= time_p[1],
                    .data[[date_col]] <= time_p[2])
  } else {
    log_error("Time input should be either a single year or a vector of two years for a range")
    cli::cli_abort("Time input should be either a single year or a vector of two years for a range")
  }


  ## Group by specified grouping variables ####
  if (!is.null(grouping_vars)) {
    data_grouped <- filtered_data |>
      dplyr::group_by(dplyr::across(tidyselect::all_of(grouping_vars)))
  } else {
    data_grouped <- filtered_data
  }

  ## Calculate counts ####
  id_col_sym <- rlang::sym(id_col)
  count_data <- data_grouped |>
    dplyr::summarise(year = paste(as.character(time_p), collapse = '-'),
                     unique_id = dplyr::n_distinct(!!id_col_sym),
                     total_events = dplyr::n(), .groups = 'drop')





  ## Suppression ####
  if (suppression){
    count_data_suppressed <- suppress_values(data = count_data, columns = c("unique_id", "total_events"), threshold = suppression_threshold)
  } else {
    count_data_suppressed <- count_data
    log_warn("No suppression. Confidentiality cannot be assured.")
    cli::cli_alert_warning("No suppression. Confidentiality cannot be assured.")
  }

  ## Intermediate results: only diagnostic counts ####
  if (only_counts){
    cat("\n")
    log_info("Prevalence counts ready")
    cli::cli_alert_success(crayon::green("Prevalence counts ready!"))
    return(count_data_suppressed)
  }

  ## Join with population and calculate rates ####

  # Check data type of date_col and transform for successful joining
  if(!is.character(pop_data[[date_col]])){
    pop_data[[date_col]] <- as.character(pop_data[[date_col]])
  }


  # Check mapping, in case some missing data in pop

  # missing_in_pop <- dplyr::anti_join(count_data_suppressed, pop_data, by =  c(grouping_vars, date_col))
  #
  # if(nrow(missing_in_pop) > 0) {
  #   cat("\n")
  #   log_warn("There are {nrow(missing_in_pop)} cells missing from {substitute(pop_data)}")
  #   cli::cli_alert_warning("Warning: there are {nrow(missing_in_pop)} cells missing from {substitute(pop_data)}. Join with population dataset doesn't have a 'one-to-one' relationship")
  #   }


  prevalence <- tryCatch({
    count_data_suppressed |>
      dplyr::left_join(pop_data, by = c(grouping_vars, date_col), relationship = "one-to-one") |>
      dplyr::mutate(prev_rate = unique_id/.data[[pop_col]])
      },
    error = function(e){
      logger::log_warn("Relationship between population dataset and counts is not one-to-one")
      cli::cli_alert_danger("Relationship between population dataset and counts is not one-to-one")
      count_data_suppressed |>
        dplyr::left_join(pop_data, by = c(grouping_vars, date_col)) |>
        dplyr::mutate(prev_rate = unique_id/.data[[pop_col]])
    })

  cat("\n")
  cli::cli_alert_success(crayon::green("Prevalence rates ready!"))
  log_info("Prevalence rates ready")


  if (CI == TRUE){
    prevalence <- prevalence |> # this requires join pop_col
      calculate_ci(method = "exact", conf_level = CI_level, n_col = pop_col)
  }


  ###### Summary #####
  cli::cli_h1("Summary")
  cli::cli_alert_info("Diagnostic and demographic data: {.pkg {substitute(linked_data)}}")
  cli::cli_alert_info("Population data: {.pkg {substitute(pop_data)}}")
  cli::cli_alert_info("Grouped by variables: {.pkg {grouping_vars}}")
  cli::cli_alert_info("For time point/period:  {.val {time_p}}")


  # Logs
  log_with_separator("Summary")
  log_info("Diagnostic and demographic data: {substitute(linked_data)}")
  log_info("Population data: {substitute(pop_data)}")
  log_info("Grouped by variables: {paste(grouping_vars, collapse = ', ')}")
  log_info("For time point/period: {time_p}")

  return(prevalence)
}

