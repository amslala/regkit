
#' Read and validate the structure of administrative (sociodemographic) individual-level data
#'
#' @description
#'`read_admin_data()` validates the general structure and minimum column requirements for administrative (sociodemographic) individual-level data.
#' The input data sets must be CSV, RDS, RDA or .SAV files.
#' @param file_path A character string. File path to the demographic data to read. Supports CSV, RDS, RDA, SAV and parquet (dataset) files.
#' @param data_type A character string. Administrative (sociodemographic) data can either be of type "t_variant" or "t_invariant", necessary to check correct data structure characteristics.
#' @param id_col A character string. Name of ID column in data set. Default is "id".
#' @param date_col A character string. Name of date column in data set, default is "date".
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`.
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#' @param ... Additional arguments passed to methods or underlying functions.
#'
#' @return A data frame with the validated minimum requirements for administrative (sociodemographic) data.
#' @examples
#' # Read and validate CSV file for varying individual level administrative (sociodemographic) data
#' admin_csv <- system.file("extdata", "invar_data.csv", package = "regtools")
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' admin_data_validated <- read_admin_data(admin_csv, data_type = "t_invariant",
#' id_col = "id", log_path = log_file)
#'
#' @export
#' @import logger
#'

read_admin_data <- function(file_path, data_type = c("t_variant", "t_invariant"), id_col = "id", date_col = "date", log_path = NULL, ...) {

# Logging -----------------------------------------------------------------
  log_threshold(DEBUG)
  log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    log_appender(appender_file(glue::glue("log/read_admin_data_{formatted_date}.log")))
    log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
  } else {
    log_appender(appender_file(log_path))
  }

  function_call <- deparse(match.call())
  logger::log_info("Call : {function_call}")


# Data type and extension -------------------------------------------------



  if(!data_type %in% c("t_variant", "t_invariant")){
    log_error("{data_type} not supported.")
    stop(glue::glue("{data_type} not supported."))
  }

  file_extension <- tolower(tools::file_ext(file_path))
  supported_types <- c("csv", "rds", "rda", "sav", "parquet")

# Check file existence and type -------------------------------------------

  if(!file.exists(file_path)){
    log_error("Diagnostic file does not exist in the specified path: {file_path}")
    stop("File does not exist in the specified path.")
  }

  if(file_extension == ""){
    recursive_files <- list.files(file_path, recursive = TRUE, pattern = "\\.parquet$")
    if(length(recursive_files > 0)){
      file_extension <- "parquet"
    }
  }

  if(!file_extension %in% supported_types){
    log_error("{file_extension}. File type not supported. Please provide a .csv, .rds, .parquet or .sav file.")
    stop("File type not supported. Please provide a .csv, .rds, .parquet or .sav file.")
  }


  # Parquet warning ---------------------------------------------------------

  if (file_extension == "parquet"){
    cli::cli_alert_info("You have provided a parquet file or database. Due to the characteristics of these data objects, the console output and logging will provide minimal information.")
    cat("\n")
    logger::log_warn("You have provided a parquet file or database. Due to the characteristics of these data objects, the console output and logging will provide minimal information.")
  }

  # Read files  -------------------------------------------------------------
  cat("\n")
  message(glue::glue("Reading {file_path} file..."))
  data <- switch(file_extension,
                 csv = utils::read.csv(file_path, ...),
                 rds = readRDS(file_path),
                 rda = load(file_path),
                 sav = haven::read_sav(file_path, ...),
                 parquet = arrow::open_dataset(file_path),
                 stop("Unsupported file type"))

  cli::cli_alert_success("Successfully read file: {file_path}")
  log_info("Successfully read file: {file_path}")

  # Check columns id  -------------------------------------------------------

  message("Checking column requirements:")
  log_info("Checking column requirements:")

  id_column <- which(names(data) == id_col)

  if (length(id_column) == 0) {
    log_error("The dataset must contain a column named {id_col}")
    stop(glue::glue("The dataset must contain a column named {id_col}"))
  }

  # if (!is.character(data[[id_column]])) {
  #   log_error("The {id_column} column must be of type character.")
  #   stop("The 'ID' or 'id' column must be of type character.")
  # }

  cli::cli_alert_success("ID column")
  log_info("ID column \u2713")



# Time variant: Check date column  ----------------------------------------

  if (data_type == "t_variant"){
    log_info("Specified data type: t_variant")
    message("Data type: time variant. Checking requirements...")

    date_column <- which(names(data) == date_col)

    if (length(date_column) == 0) {
      log_error("The dataset must contain a column named: {date_col}")
      stop(glue::glue("The dataset must contain a column named: {date_col}"))
    }
    cli::cli_alert_success("Date column")
    cat("\n")
    log_info("Date column \u2713")
  }

# Time invariant: check ID duplicates -------------------------------------

  if (data_type == "t_invariant"){
    log_info("Specified data type: t_invariant")
    message("Data type: time invariant. Checking requirements...")

    if (file_extension == "parquet"){
      dupes <- data  |>
        dplyr::group_by(!!rlang::sym(id_col)) |>
        dplyr::summarise(count = dplyr::n()) |>
        dplyr::filter(count > 1) |>
        dplyr::collect()

      if (nrow(dupes) > 0) {
        stop("The dataset contains duplicate IDs. Verify that this dataset only contains persistent characteristics.")
      }

    } else {
      if (any(duplicated(data[[id_column]]))) {
        log_error("The dataset contains duplicate IDs. Verify that this dataset only contains persistent characteristics.")
        stop("The dataset contains duplicate IDs. Verify that this dataset only contains persistent characteristics.")
      }
    }
    log_info("No duplicate IDs \u2713")
    cli::cli_alert_success("No duplicate IDs")
    cat("\n")
  }



# Summary data ------------------------------------------------------------

  if (file_extension != "parquet"){
    data <- dplyr::as_tibble(data)
  }

  log_with_separator(glue::glue("Administrative (sociodemographic) dataset '{file_path}' successfully read and columns validated"))
  cli::cli_h1("")
  cat(crayon::green$bold("Administrative (sociodemographic) dataset successfully read and columns validated\n"))
  cli::cli_h1("Data Summary")
  cat("\n")
  cli::cli_alert_info("Number of rows: {.val {nrow(data)}}. Number of columns: {.val {ncol(data)}}.")

  unique_ids <- data |>
    dplyr::summarise(n = dplyr::n_distinct(!!rlang::sym(id_col))) |>
    dplyr::collect() |>
    dplyr::pull(n)

  cli::cli_alert_info("Unique IDs in dataset: {.val {unique_ids}}.")

  cat("\n")
  cat("\n")
  dplyr::glimpse(data)
  log_info("Data Summary: ")
  log_info("Number of rows: {nrow(data)}")
  log_info("Numner of columns: {ncol(data)}")

  return(data)
}
