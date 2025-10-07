#' Harmonize old municipality codes in Norway to 2024 municipality codes
#'
#' @param data Data frame, or data frame extensions (e.g. tibble).
#' @param municipality_col Character vector. Name of column containing the original municipality codes.
#' @param fylke Logical. If `TRUE`, output data frame also includs a column with the name of the corresponding fylke in 2024. Default is `FALSE`.
#'
#' @returns Data frame with the old and equivalent municipal codes in 2024.
#' @examples
#' # Harmonize municipality codes from 2016 to 2024
#'
#' harmonized_codes <- harmonize_municipality_codes(data = kommuner_2016, municipality_col = "code")
#' @export
#'
harmonize_municipality_codes <- function(data, municipality_col = "code", fylke = FALSE){


  check_municipality <- which(names(data) == municipality_col)

  if (length(check_municipality) == 0) {
    stop(glue::glue("The dataset must contain a column named {municipality_col}"))
  }

  cli::cli_alert_warning("NAs in municipality code column in {substitute(data)}: {.val {sum(is.na(data[[municipality_col]]))}}")

  data_harmonized <- data |>
    dplyr::left_join(kommuner, by = stats::setNames("original_code", municipality_col))

  data_harmonized <- data_harmonized |> dplyr::select(!c("harmonized_code_clean", "original_name", "start_year", "end_year"))

  if (fylke == FALSE){
    data_harmonized <- data_harmonized |> dplyr::select(!c("fylke_code", "fylke_name"))
  }
  cli::cli_rule("")
  cli::cli_alert_success("Successfully matched old municipality codes with harmonized municipality codes")

  #Check not matched rows
  no_na <- stats::na.omit(data)
  not_matched <- no_na |> dplyr::anti_join(kommuner, by = stats::setNames("original_code", municipality_col))
  cli::cli_alert_info("Total matched rows: {.val {nrow(data)-nrow(not_matched)}}")
  return(data_harmonized)
}
