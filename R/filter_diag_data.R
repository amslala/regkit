#' Validate and filter diagnostic data by selected ICD-10 or ICPC-2 codes
#'
#' @param data A data frame containing pre-processed diagnostic data.
#' @param codes A character vector. ICD-10 or ICPC-2 codes to validate and filter in `data`
#' @param pattern_codes A character vector. Pattern of ICD-10 or ICPC-2 codes to validate and filter in `data`. For example, F84 will use all codes starting with F84 (F840, F841, F842, F844, etc).
#' @param classification A character string. Classification used in diagnostic codes: ICD-10  or ICPC-2. Options are "icd" or "icpc". Default is "icd".
#' @param id_col A character string. Name of the ID column in `data`, default is "id"
#' @param code_col A character string. Name of the column containing the ICD-10 or ICPC-2 codes in `data`, default is "code"
#' @param date_col A character string. Name of the column containing the date of the diagnostic event. Only needed i if you want to filter by diagnosis date. Default is `NULL`.
#' @param diag_dates A character vector. Dates (years, months, etc) that you want to filter the diagnostic data by.
#' @param rm_na Logical. Should rows with NA in the non-filtered columns be removed? Default is `FALSE`
#' @param add_description Logical. If `TRUE` new column will be added with description of ICD-10 or ICPC-2 code. Note: not all code descriptions are available.
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`.
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#'
#' @return Filtered and validated diagnostic data frame containing only relevant observations based on diagnostic codes of interest.
#'
#' @examples
#' # Validate that F45 and F84 are real codes/family of codes in ICD-10.
#' # Keep only rows with codes containing F45 and F84.
#'
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' filtered_diag_df <-  filter_diag_data(data = diag_df,
#'                                  pattern_codes = c("F45", "F84"),
#'                                  id_col = "id",
#'                                  code_col = "code",
#'                                  log_path = log_file,
#'                                  rm_na = FALSE
#'                                  )
#'
#' @export
#' @importFrom rlang .data

filter_diag_data <- function(data, codes = NULL, pattern_codes = NULL, classification = "icd", id_col = "id", code_col = "code", date_col = NULL, diag_dates = NULL, rm_na = TRUE, add_description = FALSE, log_path = NULL){

# Set up logging ----------------------------------------------------------


  logger::log_threshold(logger::DEBUG)
  logger::log_formatter(logger::formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    logger::log_appender(logger::appender_file(glue::glue("log/filter_diag_data_{formatted_date}.log")))
    logger::log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    logger::log_appender(logger::appender_file(log_path))
  }

  function_call <- deparse(match.call())
  logger::log_info("Call : {function_call}")


# Validate Input ----------------------------------------------------------


  if(!code_col %in% colnames(data)){
    logger::log_error("The specified code column does not exist in the dataset")
    cli::cli_abort("The specified code column does not exist in the dataset")
  }

  if(!id_col %in% colnames(data)){
    logger::log_error("The specified id column does not exist in the dataset")
    cli::cli_abort("The specified id column does not exist in the dataset")
  }

  if(!is.null(pattern_codes) && !is.null(codes)){
    logger::log_error("Only one of 'pattern_codes' or 'codes' should be specified.")
    cli::cli_abort("Only one of 'pattern_codes' or 'codes' should be specified.")
  }

  if(is.null(pattern_codes) && is.null(codes)){
    logger::log_error("One of 'pattern_codes' or 'codes' should be specified.")
    cli::cli_abort("One of 'pattern_codes' or 'codes' should be specified.")
  }

  if(!classification %in% c("icd", "icpc")){
    logger::log_error("Classification code {classification} not valid.")
    cli::cli_abort("Classification code not valid")
  }


# Remove NAs helper -------------------------------------------------------

  remove_na <- function(data){
    n_missing <- length(which(!stats::complete.cases(data)))

    if(sum(n_missing) > 0){
      cat("\n")
      message(glue::glue("Removing observations containing NAs in any column... "))
      data_no_na <- data |>
        tidyr::drop_na()
      cli::cli_alert_success("Removed {.val {sum(n_missing)}} rows with NAs.")
      logger::log_info("Removed {sum(n_missing)} rows with NAs.")
    } else {
      cat("\n")
      cli::cli_alert_warning("The dataset has no NAs or they are coded in a different format.")
      logger::log_warn("The dataset has no NAs or they are coded in a different format.")
      data_no_na <- data
    }
    return(data_no_na)
  }

# Parquet check -----------------------------------------------------------

if (inherits(data, what = c("ArrowObject"))){
  cli::cli_alert_info("Your data is a Arrow dataset, due to nature of this data object the output in the console and log will be minimal.")
}

# Check if desired code exists in ICD-10 or ICPC-2 database ---------------


  message("Checking that code exists in ICD-10 or ICPC-2 code list...")

  if(!is.null(pattern_codes)){
    type_code <- "pattern"
    codes_found <- switch(classification,
                          icd = purrr::map_lgl(pattern_codes, function(code) {
                            any(purrr::map_lgl(npr[,1], ~ any(startsWith(as.character(.x), code))))
                          }),
                          icpc = purrr::map_lgl(pattern_codes, function(code) {
                            any(purrr::map_lgl(icpc_2[,1], ~ any(startsWith(as.character(.x), code))))
                          }),
                          stop("unknown classification type")
                          )
  } else if (is.null(pattern_codes)){
    type_code <- "exact"
    codes_found <- switch(classification,
                          icd = purrr::map_lgl(codes, function(code){
                            any(purrr::map_lgl(npr[,1], ~ code %in% .x))}),
                          icpc = purrr::map_lgl(codes, function(code){
                            any(purrr::map_lgl(icpc_2[,1], ~ code %in% .x))}),
                          stop("unknown classification type"))
  }


  if (!(all(codes_found))) {
    missing_codes <- switch(
      type_code,
      "pattern" = pattern_codes[!codes_found],
      "exact"   = codes[!codes_found])
    logger::log_warn("{paste(missing_codes, collapse = ', ')} code(s) not valid")
    warning(paste0(paste0(missing_codes, collapse = ", "), " code(s) not valid or not mandated to be reported in NPR"))
    } else {
      valid_codes <- switch(
        type_code,
        "pattern" = stringr::str_subset(npr[[1]], paste0("^(", paste(pattern_codes, collapse = "|"), ")")),
        "exact"   = stringr::str_subset(npr[[1]], paste0("(", paste(codes, collapse = "|"), ")")))
      cli::cli_alert_success("Selected codes/pattern are valid: {paste(valid_codes, collapse = ', ')}")
      logger::log_info("Selected codes/pattern ({paste(valid_codes, collapse = ', ')}) are valid")
      cat("\n")
    }


# Check if desired code exists in data set and filter ---------------------


  message("Filtering data by selected codes...")

  if (!(all(codes %in% data[[code_col]]))){
    cli::cli_alert_warning("Warning: The following codes are not found in the dataset: {paste(codes[!codes %in% data[[code_col]]], collapse = ', ')}")
    logger::log_warn("The following codes are not found in the dataset: {paste(codes[!codes %in% data[[code_col]]], collapse = ', ')}")

    if(!is.null(pattern_codes)){
      pattern <- paste0("^(", paste(pattern_codes, collapse = "|"), ")")
      filtered_data <- data |>
        dplyr::filter(stringr::str_detect(!!rlang::sym(code_col), pattern))
      } else if (is.null(pattern_codes)){
      filtered_data <- data |>
        dplyr::filter(.data[[code_col]] %in% codes)
      }

  } else{
    if(!is.null(pattern_codes)){
      pattern <- paste0("^(", paste(pattern_codes, collapse = "|"), ")")
      filtered_data <- data |>
        dplyr::filter(stringr::str_detect(!!rlang::sym(code_col), pattern))
    } else if (is.null(pattern_codes)){
      filtered_data <- data |>
        dplyr::filter(.data[[code_col]] %in% codes)
    }
  }



# Filter by date of diagnosis ---------------------------------------------


  if(!is.null(date_col)){
    message("Filtering observations by date of diagnosis...")
    if(!date_col %in% colnames(data)){
      logger::log_error("The specified date column does not exist in the dataset")
      cli::cli_abort("The specified date column does not exist in the dataset")
    }
    filtered_data[[date_col]] <- as.character(filtered_data[[date_col]])
    filtered_data <- filtered_data |>
      dplyr::filter(.data[[date_col]] %in% diag_dates)
  }



# Filter NAs --------------------------------------------------------------

  if(inherits(filtered_data, what = "arrow_dplyr_query")){
    filtered_data<- filtered_data |> dplyr::collect()
  }

  if(rm_na) {
    filtered_data <- remove_na(filtered_data)
  }

# Add description  --------------------------------------------------------

  if(add_description == TRUE){
    filtered_data <- switch(classification,
                            icd = dplyr::left_join(filtered_data, npr, dplyr::join_by({{code_col}} == "Kode")),
                            icpc = dplyr::left_join(filtered_data, icpc_2, dplyr::join_by({{code_col}} == "Kode")),
                            stop("unknown classification type"))
  }

# Summary data: CLI  -------------------------------------------------------


  cli::cli_h1("")
  cat(crayon::green$bold("Diagnostic dataset successfully filtered\n"))
  cat("\n")
  cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data)}} rows ({.strong {round((nrow(data) - nrow(filtered_data)) / nrow(data) * 100, 1)}%} removed)")
  cli::cli_h1("Data Summary")
  cli::cli_h3("After filtering:")
  cli::cli_alert_info("Remaining number of rows: {.val {nrow(filtered_data)}}")
  cli::cli_alert_info("Remaining number of columns: {.val {ncol(filtered_data)}}")

  unique_ids <- filtered_data |>
    dplyr::summarise(n = dplyr::n_distinct(!!rlang::sym(id_col))) |>
    dplyr::collect() |>
    dplyr::pull(n)

  cli::cli_alert_info("Unique IDs in dataset: {.val {unique_ids}}")

  unique_codes <- filtered_data |>
    dplyr::summarise(n = dplyr::n_distinct(!!rlang::sym(code_col))) |>
    dplyr::collect() |>
    dplyr::pull(n)

  cli::cli_alert_info("Unique codes in dataset: {.val {unique_codes}}")
  cli::cli_alert_info("Codes in dataset: {.val {unique(filtered_data[[code_col]], fromLast = T)}}")



  cat("\n")
  dplyr::glimpse(filtered_data)

  # Logs
  logger::log_with_separator("Diagnostic dataset '{substitute(data)}' successfully filtered")
  logger::log_info("Remaining number of rows: {nrow(filtered_data)}")
  logger::log_info("Remaining number of columns: {ncol(filtered_data)}")
  logger::log_info("Unique IDs in dataset: {dplyr::n_distinct(filtered_data[[id_col]])}")
  logger::log_info("Unique codes in dataset: {length(unique(filtered_data[[code_col]], fromLast = T))}")
  logger::log_info("Codes in dataset: {paste(unique(filtered_data[[code_col]], fromLast = T), collapse = ', ')}")


  return(filtered_data)
}
