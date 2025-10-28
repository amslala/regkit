#' Filter administrative (sociodemographic) data by selected filtering parameters
#'
#' @param data A data frame containing pre-processed administrative (sociodemographic) data.
#' @param data_type A character string. Type of administrative (sociodemographic) data: "t_variant" or "t_invariant"
#' @param filter_param A named list containing filtering parameters. The names in the list are the column names and the values are vectors of values to keep.
#' @param id_col A character string. Name of ID column in data set.
#' * Optional, necessary only when `any = TRUE`
#' @param rm_na Logical. Should rows with NA in the non-filtered columns be removed? Default is `FALSE`
#' * If `TRUE`, removes observations that have NA in any of the non-filtered columns.
#' @param any Logical. Filtering option, keeps individuals that have ever fulfilled any of the filtering parameters. \bold{Not supported in parquet datasets.} Default is `FALSE`
#' @param log_path A character string. Path to the log file to append function logs. Default is `NULL`
#' * If `NULL`, a new directory `/log` and file is created in the current working directory.
#'
#' @return Filtered administrative (sociodemographic) dataframe containing only relevant observations based on the filtering parameters.
#' @examples
#' # Filter varying and unvarying datasets
#'
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' filtered_var <- filter_admin_data(data = var_df,
#' data_type = "t_variant",
#' filter_param = list("year_varying" = c(2012:2015), "varying_code" = c("1146")),
#' log_path = log_file)
#'
#'
#' filtered_invar <- filter_admin_data(data = invar_df, data_type = "t_invariant",
#' filter_param = list("y_birth" = c(2006:2008),
#' "innvandringsgrunn" = c("FAMM", "UTD")),
#' rm_na = FALSE,
#' log_path = log_file)
#'
#' @export
#' @import logger

filter_admin_data <- function(data, data_type = c("t_variant", "t_invariant"), filter_param, id_col = NULL, any = FALSE, rm_na = TRUE, log_path = NULL){

# Set up logging ----------------------------------------------------------
  log_threshold(DEBUG)
  log_formatter(formatter_glue)

  if (is.null(log_path) || !file.exists(log_path)){
    if(!dir.exists("log")){
      dir.create("log")
    }
    formatted_date <- format(Sys.Date(), "%d_%m_%Y")
    log_appender(appender_file(glue::glue("log/filter_admin_data_{formatted_date}.log")))
    log_info("Log file does not exist in specified path: {log_path}. Created file in log directory")
    cli::cli_alert_warning("Log file does not exist in specified path. Creating .log file in log directory")
    cat("\n")
  } else {
    log_appender(appender_file(log_path))
  }

  function_call <- deparse(match.call())
  logger::log_info("Call : {function_call}")

# Validate Input ----------------------------------------------------------

  if(any(!names(filter_param) %in% colnames(data))){
    log_error("Not all the specified variables exist in the dataset")
    stop("Not all the specified variables exist in the dataset")
  }



  # Parquet check -----------------------------------------------------------

  if (inherits(data, what = c("ArrowObject"))){
    cli::cli_alert_info("Your data is a Arrow dataset, due to nature of this data object the output in the console and log will be minimal.")
    if(any == TRUE){
      cli::cli_abort("Filtering option 'any' not supported yet for parquet datasets \U2639")
    }
  }

# Helper functions --------------------------------------------------------


  remove_na <- function(data){
    n_missing <- length(which(!stats::complete.cases(data)))

    if(sum(n_missing) > 0){
      cat("\n")
      message(glue::glue("Removing observations containing NAs in any column... "))
      data_no_na <- data |>
        tidyr::drop_na()
      cli::cli_alert_success("Removed {.val {sum(n_missing)}} rows with NAs.")
      log_info("Removed {sum(n_missing)} rows with NAs.")
      } else {
        cat("\n")
        cli::cli_alert_warning("The dataset has no NAs or they are coded in a different format.")
        log_warn("The dataset has no NAs or they are coded in a different format.")
        data_no_na <- data
      }
    return(data_no_na)
  }

  do_filter <- function(data, filter_param, id_col = NULL, any = FALSE){
    filtered_data <- purrr::reduce(names(filter_param), function(df, col) {
      if(any){
        df |>
          dplyr::group_by(!!rlang::sym(id_col)) |>
          dplyr::filter(any(!!rlang::sym(col) %in% filter_param[[col]])) |>
          dplyr::ungroup()
      } else {
        df |>  dplyr::filter(!!rlang::sym(col) %in% filter_param[[col]])
      }
    }, .init = data)
  }




# Main filtering ----------------------------------------------------------

  if(data_type == "t_invariant"){
    filtered_data <- do_filter(data, filter_param)
    message("Filtering time-invariant dataset...")
    cli::cli_alert_success("Filtered time-invariant dataset by '{names(filter_param)}' column(s)")
    cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data)}} rows ({.strong {round((nrow(data) - nrow(filtered_data)) / nrow(data) * 100, 1)}%} removed)")
    log_info("Filtering time-invariant by '{names(filter_param)}' column(s)")
  } else if (data_type == "t_variant"){
    filtered_data <- do_filter(data, filter_param, id_col, any)
    message("Filtering time-variant dataset...")
    cli::cli_alert_success("Filtered time-variant by '{names(filter_param)}' column(s)")
    cli::cli_alert_info("Filtered {.val {nrow(data) - nrow(filtered_data)}} rows ({.strong {round((nrow(data) - nrow(filtered_data)) / nrow(data) * 100, 1)}%} removed)")
    log_info("Filtering time-variant by '{names(filter_param)}' column(s)")
  } else {
    log_error("Invalid data type specified")
    stop("Invalid data type specified")
  }



# NA filtering ------------------------------------------------------------

  if(inherits(filtered_data, what = "arrow_dplyr_query")){
    filtered_data<- filtered_data |> dplyr::collect()
  }

  if(rm_na) {
    filtered_data <- remove_na(filtered_data)
  }

# Data summary  -----------------------------------------------------------

  cli::cli_h1("")
  cat(crayon::green$bold("administrative (sociodemographic) dataset successfully filtered\n"))
  cat("\n")
  cli::cli_h1("Data Summary")
  cli::cli_h3("After filtering:")
  cli::cli_alert_info("Remaining number of rows: {.val {nrow(filtered_data)}}")
  cli::cli_alert_info("Remaining number of columns: {.val {ncol(filtered_data)}}")
  cat("\n")
  dplyr::glimpse(filtered_data)

  # Logs
  log_with_separator(glue::glue("Diagnostic dataset '{substitute(data)}' successfully filtered"))
  log_info("Remaining number of rows: {nrow(filtered_data)}")
  log_info("Remaining number of columns: {ncol(filtered_data)}")

  return(filtered_data)
}
