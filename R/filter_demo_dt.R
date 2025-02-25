#' Filter demographic data by selected filtering parameters
#'
#' @param data Data frame containing pre-processed demographic data
#' @param data_type Type of demographic data: "t_variant" or "t-variant"
#' @param filter_param Named list containing filtering parameters. The names in the list are the column names and the values are vectors of values to keep.
#' @param id_col Optional flag, necessary for "any" filtering option.
#' @param rm_na Removes observations that have NA in the non-filtered columns.
#' @param data_type Type of demographic data: "t_variant" or "t-variant"
#' @param any Filtering option, any year. Default = FALSE.
#' @param log_path File path of the log file to be used
#'
#' @return Filtered demographic dataframe containing only relevant observations based on the filtering parameters.
#'
#' @export
#' @import logger data.table

filter_demo_dt <- function(data, data_type, filter_param, id_col = NULL, any = FALSE, rm_na = TRUE, log_path = NULL){

  ##### Set up logging #####
  log_threshold(DEBUG)
  log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    log_appender(appender_file(glue::glue("log/filter_demo_{formatted_date}.log")))
    log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    log_appender(appender_file(log_path))
  }

  ###Validate input ####

  missing_cols <- names(filter_param)[!names(filter_param) %in% colnames(data)]
  if(length(missing_cols) > 0){
    log_error("The following variables do not exist in the dataset: {paste(missing_cols, collapse = ', ')}")
    stop(glue::glue("The following variables do not exist in the dataset: {paste(missing_cols, collapse = ', ')}"))
  }

  if(missing(data_type)) {
    log_error("Data type not specified")
    stop("Data type not specified")
  }

  ###Helper functions####
  remove_na <- function(filtered_data) {
    data_no_na <- filtered_data[complete.cases(filtered_data), ]
    n_missing <- nrow(filtered_data) - nrow(data_no_na)

    if (n_missing > 0) {
      cli::cli_alert_success("Removed {.val {n_missing}} rows with NAs.")
      log_info("Removed {n_missing} rows with NAs.")
    } else {
      cli::cli_alert_warning("The dataset has no NAs or they are coded in a different format.")
      log_warn("The dataset has no NAs or they are coded in a different format.")
    }
    return(data_no_na)
  }

  do_filter_dt <- function(data, filter_param, id_col = NULL, any = FALSE) {
    for (col in names(filter_param)) {
      if (any && !is.null(id_col)) {
        id_symbol <- as.name(id_col)
        data <- data[, .SD[any(get(col) %in% filter_param[[col]])], by = id_symbol]
      } else {
        data <- data[get(col) %in% filter_param[[col]], ]
      }
    }
    return(data)
  }


  ####Main filtering####
  if(data_type == "t_invariant"){
    filtered_data <- do_filter_dt(data, filter_param)
    message("Filtering time-invariant dataset...")
    cli::cli_alert_success("Filtered time-invariant dataset by '{names(filter_param)}' column(s)")
    cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data)}} rows ({.strong {round((nrow(data) - nrow(filtered_data)) / nrow(data) * 100, 1)}%} removed)")
    log_info("Filtering time-invariant by '{names(filter_param)}' column(s)")
  } else if (data_type == "t_variant"){
    filtered_data <- do_filter_dt(data, filter_param, id_col, any)
    message("Filtering time-variant dataset...")
    cli::cli_alert_success("Filtered time-variant by '{names(filter_param)}' column(s)")
    cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data)}} rows ({.strong {round((nrow(data) - nrow(filtered_data)) / nrow(data) * 100, 1)}%} removed)")
    log_info("Filtering time-variant by '{names(filter_param)}' column(s)")
  } else {
    log_error("Invalid data type specified")
    stop("Invalid data type specified")
  }



  ####NA filtering####
  if(rm_na) {
    filtered_data <- remove_na(filtered_data)
  }

  #### Data summary ####
  cli::cli_h1("")
  cat(crayon::green$bold("Demographic dataset succesfully filtered\n"))
  cat("\n")
  cli::cli_h1("Data Summary")
  cli::cli_h3("After filtering:")
  cli::cli_alert_info("Remaining number of rows: {.val {nrow(filtered_data)}}")
  cli::cli_alert_info("Remaining number of columns: {.val {ncol(filtered_data)}}")
  cat("\n")
  cat(utils::str(filtered_data))

  # Logs
  log_with_separator(glue::glue("Diagnostic dataset '{substitute(data)}' succesfully filtered"))
  log_info("Remaining number of rows: {nrow(filtered_data)}")
  log_info("Remaining number of columns: {ncol(filtered_data)}")
  log_info("ICD-10 codes in dataset: {paste(unique(filtered_data$code, fromLast = T), collapse = ', ')}")
  log_formatter(formatter_pander)
  log_info(sapply(filtered_data, class))

  return(filtered_data)
}
