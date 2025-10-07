#' Curate diagnostic data
#'
#' @param data A data frame containing pre-processed and validated diagnostic data.
#' @param min_diag Integer. Number of minimum amount of diagnostic events. Default is 1.
#' @param first_diag Logical. If `TRUE`, keep only information from the first recorded diagnostic event. Default set to TRUE. Default is `TRUE`.
#' @param id_col A character string. Name of ID column in `data`, default is "id"
#' @param code_col A character string. Name of column containing the ICD-10 codes in `data`, default is "icd_code"
#' @param date_col A character string. Name of column containing the diagnostic date in `data`, default is "date"
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`.
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#'
#' @return Curated diagnostic data: minimum diagnostic events, and/or first ever diagnosis information
#' @examples
#' # Keep only curated diagnostic data
#' # for example minimum diagnostic events or first recorded diagnosis
#'
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' curated_diag_df <- curate_diag_data(data = diag_df,
#'                                min_diag = 1,
#'                                first_diag = TRUE,
#'                                id_col = "id",
#'                                code_col = "code",
#'                                date_col = "diag_year",
#'                                log_path = log_file)
#' @export
#' @import logger
#'
curate_diag_data <- function(data, min_diag = 1, first_diag = TRUE, id_col = "id", code_col = "icd_code", date_col = "date", log_path = NULL){

  ##### Set up logging #####
  log_threshold(DEBUG)
  log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    log_appender(appender_file(glue::glue("log/curate_diag_data_{formatted_date}.log")))
    log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    log_appender(appender_file(log_path))
  }

  ##### Validate input #####

  if(!code_col %in% colnames(data)){
    log_error("The specified code column does not exist in the dataset")
    stop("The specified code column does not exist in the dataset")
  }

  if(!id_col %in% colnames(data)){
    log_error("The specified id column does not exist in the dataset")
    stop("The specified id column does not exist in the dataset")
  }

  if(!date_col %in% colnames(data)){
    log_error("The specified date column does not exist in the dataset")
    stop("The specified date column does not exist in the dataset")
  }


  ####Keep only observations that comply with minimum diagnostic events###

  filtered_data_min <- data |>
    dplyr::group_by_at(c(id_col, code_col)) |> #could include option for time grouping variable, certain amount of cases in the same year or irrelevant of year?
    dplyr::filter(dplyr::n() >= min_diag)

  cli::cli_alert_success("Filtered observations that do not have at least {min_diag} diagnostic event")
  log_info("Filtered observations that do not have at least {min_diag} diagnostic event")

  if(nrow(filtered_data_min)==0){
    stop(glue::glue("There were zero observations that had at least {min_diag} diagnostic event"))
    }

  ####Summarize first diagnostic information####
  if (first_diag){
    id_col_sym <- rlang::sym(id_col)
    code_col_sym <- rlang::sym(code_col)
    date_col_sym <- rlang::sym(date_col)

    filtered_data_min <- filtered_data_min |>
      dplyr::arrange(!!id_col_sym, !!date_col_sym) |>
      dplyr::group_by(!!id_col_sym) |>
      dplyr::summarise(code = dplyr::first(!!code_col_sym),
                     y_diagnosis_first = min(!!date_col_sym),
                     diagnosis_count = dplyr::n(),
                     dplyr::across(!c(!!code_col_sym, !!date_col_sym), dplyr::first),
                     .groups = 'drop')
    cli::cli_alert_success("Summarized first diagnostic event information")
    log_info("Summarized first diagnostic event information")
  }

  ###### Summary data #####
  cli::cli_h1("")
  cat(crayon::green$bold("Diagnostic dataset successfully curated and summarized\n"))
  cat("\n")
  cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data_min)}} rows ({.strong {round((nrow(data) - nrow(filtered_data_min)) / nrow(data) * 100, 1)}%} removed)")
  cli::cli_h1("Data Summary")
  cli::cli_h3("After filtering:")
  cli::cli_alert_info("Remaining number of rows: {.val {nrow(filtered_data_min)}}")
  cli::cli_alert_info("Remaining number of columns: {.val {ncol(filtered_data_min)}}")
  cli::cli_alert_info("Unique IDs in dataset: {.val {dplyr::n_distinct(filtered_data_min[[id_col]])}}")
  cli::cli_alert_info("ICD-10 codes in dataset: {.pkg {unique(filtered_data_min$code, fromLast = T)}}")
  cat("\n")
  cat(utils::str(filtered_data_min))

  # Logs
  log_with_separator(glue::glue("Diagnostic dataset '{substitute(data)}' successfully curated and summarized"))
  log_info("Remaining number of rows: {nrow(filtered_data_min)}")
  log_info("Remaining number of columns: {ncol(filtered_data_min)}")
  log_info("Unique IDs in dataset: {dplyr::n_distinct(filtered_data_min[[id_col]])}")
  log_info("ICD-10 codes in dataset: {paste(unique(filtered_data_min$code, fromLast = T), collapse = ', ')}")

  return(filtered_data_min)
}
