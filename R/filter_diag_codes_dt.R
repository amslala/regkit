#' Validate and filter diagnostic data by selected ICD-10 codes
#'
#' @param data Data frame containing pre-processed diagnostic data (check minimum requirements in documentation)
#' @param codes Character vector including ICD-10 codes to validate and filter diagnostic data
#' @param id_col Name of ID column in data set, default is "id"
#' @param code_col String containing the name of column containing the diagnostic codes
#' @param log_path File path of the log file to be used
#'
#'
#' @return Filtered diagnostic data frame containing only relevant observations based on diagnostic codes of interest.
#'
#' @export
#'

filter_diag_dt <- function(data, codes, id_col = "id", code_col = "icd_code", log_path = NULL){

  ##### Set up logging #####
  log_threshold(DEBUG)
  log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    log_appender(appender_file(glue::glue("log/filter_diag_{formatted_date}.log")))
    log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    log_appender(appender_file(log_path))
  }

  ##### Validate Input #####

  if(!code_col %in% colnames(data)){
    log_error("The specified code column does not exist in the dataset")
    stop(glue::glue("The specified code column does not exist in the dataset"))
  }

  if(!id_col %in% colnames(data)){
    log_error("The specified id column does not exist in the dataset")
    stop(glue::glue("The specified id column does not exist in the dataset"))
  }


  #### Check if desired code exists in ICD-10 ####
  load("data/npr.rda")

  message("Checking that code exists in ICD-10 code list...")

  codes_found <- purrr::map_lgl(codes, function(code) {
    any(purrr::map_lgl(npr, ~ code %in% .x))
  })

  if (!(all(codes_found))) {
    missing_codes <- codes[!codes_found]
    log_error("{paste(missing_codes, collapse = ', ')} code(s) not valid")
    stop(paste(paste(missing_codes, collapse = ", "), "code(s) not valid"))
    } else {
      cli::cli_alert_success("Selected ICD-10 codes are valid: {paste(codes, collapse = ', ')}")
      log_info("Selected ICD-10 codes ({paste(codes, collapse = ', ')}) are valid")
      cat("\n")
    }

  ####Check if desired code exists in data set and filter####
  message("Filtering data by selected ICD-10 codes...")
  dt <- data.table::as.data.table(data, copy = FALSE)

  if (!(all(codes %in% dt[[code_col]]))){
    cli::cli_alert_warning("Warning: The following codes are not found in the dataset: {paste(codes[!codes %in% dt[[code_col]]], collapse = ', ')}")
    log_warn("The following codes are not found in the dataset: {paste(codes[!codes %in% dt[[code_col]]], collapse = ', ')}")
    filtered_data = dt[dt[[code_col]] %chin% codes, ]
  } else{
    print(code_col)
    filtered_data = dt[dt[[code_col]] %chin% codes, ]
  }

  ###### Summary data #####
  cli::cli_h1("")
  cat(crayon::green$bold("Diagnostic dataset succesfully filtered\n"))
  cat("\n")
  cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data)}} rows ({.strong {round((nrow(data) - nrow(filtered_data)) / nrow(data) * 100, 1)}%} removed)")
  cli::cli_h1("Data Summary")
  cli::cli_h3("After filtering:")
  cli::cli_alert_info("Remaining number of rows: {.val {nrow(filtered_data)}}")
  cli::cli_alert_info("Remaining number of columns: {.val {ncol(filtered_data)}}")
  cli::cli_alert_info("Unique IDs in dataset: {.val {dplyr::n_distinct(filtered_data[[id_col]])}}")
  cli::cli_alert_info("ICD-10 codes in dataset: {.pkg {unique(filtered_data$code, fromLast = T)}}")
  cat("\n")
  cat(utils::str(filtered_data))

  # Logs
  log_with_separator("Diagnostic dataset '{substitute(data)}' succesfully filtered")
  log_info("Remaining number of rows: {nrow(filtered_data)}")
  log_info("Remaining number of columns: {ncol(filtered_data)}")
  log_info("Unique IDs in dataset: {dplyr::n_distinct(filtered_data[[id_col]])}")
  log_info("ICD-10 codes in dataset: {paste(unique(filtered_data$code, fromLast = T), collapse = ', ')}")
  log_formatter(formatter_pander)
  log_info(sapply(filtered_data, class))

  return(filtered_data)
}
