#' Link diagnostic and demographic datasets using unique personal identifiers
#'
#' @param data_diag A data frame containing pre-processed and pre-validated diagnostic data.
#' @param data_admin_inv A data frame containing validated time-invariant administrative (sociodemographic) data.
#' @param data_admin_var A data frame containing validated time-variant administrative (sociodemographic) data.
#' @param id_col A character string. Name of ID (unique personal identifier) column in all of the provided datasets. Default is "id".
#' @param date_col A character string. Name  of the date column in time-variant data and diagnostic data.
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`.
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#' @returns Linked dataset including relevant diagnostic and administrative (sociodemographic) variables.
#' @examples
#' # Link diagnostic and time invariant datasets
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' linked_diag_inv <- link_diag_admin(data_diag = diag_df,
#'                                   data_admin_inv = invar_df,
#'                                   id_col = "id",
#'                                   log_path = log_file)
#'
#' # Link diagnostic and time variant datasets
#' names(var_df)[names(var_df) == 'year_varying'] <- 'year'
#' names(diag_df)[names(diag_df) == 'diag_year'] <- 'year'
#'
#' linked_diag_var <- link_diag_admin(data_diag = diag_df,
#'                                   data_admin_var = var_df,
#'                                   id_col = "id",
#'                                   date_col = "year",
#'                                   log_path = log_file)
#'
#' # Link diagnostic, time invariant and variant datasets
#' linked_diag_inv_var <- link_diag_admin(data_diag = diag_df,
#'                                       data_admin_var = var_df,
#'                                       data_admin_inv = invar_df,
#'                                       id_col = "id",
#'                                       date_col = "year",
#'                                       log_path = log_file)
#'
#' @export
#'
link_diag_admin <- function(data_diag, data_admin_inv = NULL, data_admin_var = NULL, id_col= "id", date_col = "year", log_path = NULL){

  ##### Set up logging #####
  logger::log_threshold(logger::DEBUG)
  logger::log_formatter(logger::formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    logger::log_appender(logger::appender_file(glue::glue("log/link_diag_admin_{formatted_date}.log")))
    logger::log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    logger::log_appender(logger::appender_file(log_path))
  }

  function_call <- deparse(match.call())
  logger::log_info("Call : {function_call}")

  ###Input validation#####
  if(is.null(data_admin_inv) && is.null(data_admin_var)) {
    logger::log_error("At least one of data_admin_inv or data_admin_var must be provided")
    stop("At least one of data_admin_inv or data_admin_var must be provided")
  }

  if(!is.null(data_admin_var) && !all(c(id_col,date_col) %in% names(data_admin_var))) {
    logger::log_error("data_admin_var must contain the specified 'date' and 'id' columns")
    stop("data_admin_var must contain the specified 'date' and 'id' columns")
  }


  ###Main linking ####
  linked_df <- data_diag
  joined_datasets <- c(substitute(data_diag))

  if(!is.null(data_admin_inv)){
    if(!id_col %in% names(data_admin_inv)){
      logger::log_error("{data_admin_inv} must contain specified 'id' column")
      stop(glue::glue("data_admin_inv must contain specified 'id' column"))
    }
    message("Joining diagnostic data with time-invariant administrative data...")
    linked_df <- linked_df |>
      dplyr::inner_join(data_admin_inv, by = id_col)

    joined_datasets <- c(joined_datasets, substitute(data_admin_inv))
    cli::cli_alert_success("Datasets successfully linked: {paste(joined_datasets, collapse = ', ')}")
    logger::log_info("Datasets successfully linked: {paste(joined_datasets, collapse = ', ')}")
  }

  ##add check for 'date' column in last linked_df or directly from diag data

  if(!is.null(data_admin_var)){
    message("Joining with time-variant administrative data...")
    linked_df <- linked_df |>
      dplyr::inner_join(data_admin_var, by = c(id_col, date_col))

    joined_datasets <- c(joined_datasets, substitute(data_admin_var))
    cli::cli_alert_success("Datasets successfully linked: {paste(joined_datasets, collapse = ', ')}")
    logger::log_info("Datasets successfully linked: {paste(joined_datasets, collapse = ', ')}")
  }

  ###### Summary data #####
  cli::cli_h1("Data Summary")
  cli::cli_alert_info("After joining added {.val {ncol(linked_df)-ncol(data_diag)}} columns to '{substitute(data_diag)}': {setdiff(names(linked_df), names(data_diag))}")
  logger::log_info("After joining added {ncol(linked_df)-ncol(data_diag)} columns to '{substitute(data_diag)}': {paste(setdiff(names(linked_df), names(data_diag)), collapse = ', ')}")

  cli::cli_alert_info("Rows in '{substitute(data_diag)}': {.val {nrow(data_diag)}}")
  logger::log_info("Rows in '{substitute(data_diag)}': {nrow(data_diag)}")

  if(!is.null(data_admin_var)){
    cli::cli_alert_info("Rows in '{substitute(data_admin_var)}': {.val {nrow(data_admin_var)}}")
    logger::log_info("Rows in '{substitute(data_admin_var)}': {nrow(data_admin_var)}")
    if(!is.null(data_admin_inv)){
      cli::cli_alert_info("Rows in '{substitute(data_admin_inv)}': {.val {nrow(data_admin_inv)}}")
      logger::log_info("Rows in '{substitute(data_admin_inv)}': {nrow(data_admin_inv)}")
    }
  } else if (is.null(data_admin_var)){
    cli::cli_alert_info("Rows in '{substitute(data_admin_inv)}': {.val {nrow(data_admin_inv)}}")
    logger::log_info("Rows in '{substitute(data_admin_inv)}': {nrow(data_admin_inv)}")
  }

  cli::cli_alert_success("Total matched rows: {.val {nrow(linked_df)}}")
  logger::log_info("Total matched rows: {nrow(linked_df)}")

  return(linked_df)
}
