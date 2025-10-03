#' Read and validate the structure of diagnostic data
#'
#' @description
#'`read_diag_data()` validates the general structure and minimum column requirements for diagnostic data.
#' The input data sets must be CSV, RDS, RDA or .SAV files.
#'
#' @param file_path A character string. File path to the diagnostic data to read. Supports CSV, RDS, RDA, SAV and parquet (database) files.
#' @param id_col A character string. Name of ID column in data set, default is "id".
#' @param date_col A character string. Name of date column in data set, default is "date".
#' @param code_col A character string. Name of diagnostic codes column in data set, default is "code".
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`.
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#' @param ... Additional arguments passed to methods or underlying functions.
#' @param remove_extra Logical. If `TRUE`, removes any extra columns beside id, date and diagnostic code. Default is `FALSE`.
#'
#' @return A data frame with the validated minimum requirements for diagnostic data
#' @examples
#' # Read and validate CSV file for diagnostic individual level data.
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' diag_csv <- system.file("extdata", "diag_data.csv", package = "regtools")
#'
#' diag_data_validated <- read_diag_data(diag_csv,
#'   id_col = "id",
#'   date_col = "diag_year",
#'   log_path = log_file)
#'
#' @export
#'
#'

read_diag_data <- function(file_path, id_col = "id", date_col = "date", code_col = "code", log_path = NULL, remove_extra = FALSE, ...) {


# Logging -----------------------------------------------------------------


  logger::log_threshold(DEBUG)
  logger::log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    logger::log_appender(logger::appender_file(glue::glue("log/read_diag_data_{formatted_date}.log")))
    logger::log_info("Log file does not exist in specified path: {log_path}. Created file in new log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    logger::log_appender(appender_file(log_path))
  }


# Check file existence and type -------------------------------------------

  file_extension <- tolower(tools::file_ext(file_path))
  supported_types <- c("csv", "rds", "rda", "sav", "parquet")

  if(!file.exists(file_path)){
    logger::log_error("Diagnositc file does not exist in the specified path: {file_path}")
    stop("File does not exist in the specified path.")
  }


  if(file_extension == ""){
    recursive_files <- list.files(file_path, recursive = TRUE, pattern = "\\.parquet$")
    if(length(recursive_files > 0)){
      file_extension <- "parquet"
    }
  }

  if(!file_extension %in% supported_types){
    logger::log_error("{file_extension}. File type not supported. Please provide a .csv, .rds, .parquet or .sav file.")
    stop("File type not supported. Please provide a .csv, .rds, .parquet or .sav file.")
  }



# Parquet warning ---------------------------------------------------------

  if (file_extension == "parquet"){
    cli::cli_alert_info("You have provided a parquet file or database. Due to the characteristics of these data objects, the console output and logging will provide minimal information.")
    cat("\n")
    logger::log_warn("You have provided a parquet file or database. Due to the characteristics of these data objects, the console output and logging will provide minimal information.")
  }

# Read files  -------------------------------------------------------------

  message(glue::glue("Reading {file_path} file..."))
  data <- switch(file_extension,
                 csv = utils::read.csv(file_path, ...),
                 rds = readRDS(file_path),
                 rda = load(file_path),
                 sav = haven::read_sav(file_path, ...),
                 parquet = arrow::open_dataset(file_path),
                 stop("Unsupported file type"))

  cli::cli_alert_success("Succesfully read file: {file_path}")
  cat("\n")



# Check columns id  -------------------------------------------------------

  message("Checking column requirements:")
  cat("\n")
  logger::log_info("Checking column requirements:")

  id_column <- which(names(data) == id_col)

  if (length(id_column) == 0) {
    logger::log_error("The dataset must contain a column named {id_col}")
    stop(glue::glue("The dataset must contain a column named {id_col}"))
  }

  cli::cli_alert_success("ID column")
  logger::log_info("ID column \u2713")


# Check columns code ------------------------------------------------------


  code_column <- which(names(data) == code_col)
  if (length(code_column) == 0) {
    logger::log_error("The dataset must contain a column named: {code_col}")
    stop(glue::glue("The dataset must contain a column named: {code_col}"))
  }
  # if (!is.character(data[[code_column]])) {
  #   log_error("The {code_column} column must be of type character.")
  #   stop("The 'code' column must be of type character.")
  # }

  cli::cli_alert_success("Code column")
  logger::log_info("Code column \u2713")


# Check date column -------------------------------------------------------


  date_column <- which(names(data) == date_col)
  if (length(date_column) == 0) {
    logger::log_error("The dataset must contain a column named: {date_col}")
    stop(glue::glue("The dataset must contain a column named: {date_col}"))
  }
  # if (!lubridate::is.Date(data[[date_column]]) && !is.numeric(data[[date_column]])) {
  #   log_error("The {date_column} must be of type date or numeric.")
  #   stop("The 'date' column must be of type date or numeric.")
  # }

  cli::cli_alert_success("Date column")
  logger::log_info("Date column \u2713")
  cat("\n")



# Extra columns -----------------------------------------------------------


  required_columns <- c(date_col, id_col, code_col)
  extra_columns <- setdiff(names(data), required_columns)

  if (length(extra_columns) > 0) {
    cat("The dataset contains additional columns: ", paste(extra_columns, collapse = ", "), "\n")
    logger::log_warn("The dataset contains additional columns")

    if (remove_extra == TRUE) {
      data <- data[, required_columns, drop = FALSE]
      message("Extra columns removed.")
      logger::log_info("User decided to remove extra columns.")
    } else {
      warning("The dataset contains extra columns that were not removed.")
      logger::log_warn("The dataset contains extra columns that were not removed by the user.")
    }
  }



# Summary data ------------------------------------------------------------


  if (file_extension != "parquet"){
    data <- dplyr::as_tibble(data)
  }

  logger::log_with_separator(glue::glue("Diagnostic dataset '{file_path}' succesfully read and columns validated"))
  cli::cli_h1("")
  cat(crayon::green$bold("Diagnostic dataset succesfully read and columns validated\n"))
  cli::cli_h1("Data Summary")
  cat("\n")
  cli::cli_alert_info("Number of rows: {.val {nrow(data)}}. Number of columns: {.val {ncol(data)}}.")
  cat("\n")
  cat("\n")
  dplyr::glimpse(data)
  logger::log_info("Data Summary: ")
  logger::log_info("Number of rows: {nrow(data)}")
  logger::log_info("Numner of columns: {ncol(data)}")
  return(data)
}



