#' Plot spatial data
#'
#' @param data A data frame with the prevalence/incidence rates and auxiliary information.
#' @param level A character string. Type geographical level, can be "kommune" or "fylke".
#' * Kommune 2025 geojson file retrieved from https://kartkatalog.geonorge.no/metadata/administrative-enheter-kommuner/041f1e6e-bdbc-4091-b48f-8a5990f3cc5b
#' * Fylke 2024 geojson file retrieved from https://kartkatalog.geonorge.no/metadata/administrative-enheter-fylker/6093c8a8-fa80-11e6-bc64-92361f002671
#' @param rate_col A character string.  Name of the column in `data` containing the information (e.g. rates) to map.
#' @param region_number_col A character string. Name of the column in `data` containing fylke or kommune identification numbers in 2024 standard (harmonized series). For more information please consult the vignette("other_useful_fun")
#' @param legend_title A character string. Title for the legend box.
#' @param map_title Character string. Title of the plot.
#' @param percent Logical. Do the numbers in rate_col represent proportions or percentages? If `TRUE` formats scale as percentage. Default is `FALSE`.
#' @param auto_transform Logical. Sometimes if your data is skewed, the color palette and scale in the map might not look right. If `TRUE`, applies log10 transformation. Default is `FALSE`.
#'
#' @returns Choropleth map
#' @examples
#' pop_kommuner_2024 <- get_population_ssb(
#' regions = "kommuner",
#' years = 2024,
#' ages = c(0:18),
#' aggregate_age = TRUE,
#' by_sex = FALSE)
#'
#' pop_kommuner_2024 <- harmonize_municipality_codes(
#' data = pop_kommuner_2024,
#' municipality_col = "region_code") |>
#' dplyr::filter(age == "Total")
#'
#' plot_map(pop_kommuner_2024,
#' level = "kommune",
#' rate_col = "population",
#' map_title = "Population children in Norway 2024",
#' legend_title = "Population",
#' region_number_col = "harmonized_code",
#' auto_transform = TRUE)

#' @export
#'
plot_map <- function(data, level = c("kommune", "fylke"), rate_col, region_number_col, legend_title = "", map_title = "", percent = FALSE, auto_transform = FALSE) {

  if(!requireNamespace("sf", quietly = TRUE)){
    stop("Package \"sf\" must be installed and loaded to use this function.",call. = FALSE)
  }

  if(!requireNamespace("scales", quietly = TRUE)){
    stop("Package \"scales\" must be installed to use this function.",call. = FALSE)
  }

  map_type <- match.arg(level, several.ok = FALSE)

  if(percent == TRUE && auto_transform == TRUE){
    cli::cli_abort("Only one of 'percent' or 'auto_transform' can be set to TRUE.")
  }

  suppressMessages({
    geo <- switch(map_type,
                  kommune = kommuner_sf |>
                    regtools::harmonize_municipality_codes(municipality_col = "kommunenummer") |>
                    dplyr::left_join(data, by = c("harmonized_code" = region_number_col)),
                  fylke = fylker_sf |>
                    dplyr::left_join(data, by = c("fylkesnummer" = region_number_col)),
                  stop("Unknown geographical level")
    )

  })


  quantile_skewed <- function(x){
    quantiles <- stats::quantile(x, probs = c(0.25, 0.5, 0.75), na.rm = TRUE, names = FALSE)
    bowley <- (quantiles[3] + quantiles[1] - 2*quantiles[2])/stats::IQR(x)
    }

  map <- ggplot2::ggplot(geo) +
    ggplot2::geom_sf(aes(fill = !!rlang::sym(rate_col)),color = "white") +
    ggplot2::labs(fill = legend_title) +
    ggplot2::ggtitle(map_title) +
    ggplot2::theme_void() +
    ggplot2::theme(
      legend.position = c(0.9, 0.2),
      plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
      legend.key.height = ggplot2::unit(10, "pt"),
      legend.background = ggplot2::element_rect(
        fill = "white",
        color = "transparent"
      )
    )


  if(auto_transform == TRUE){
    bowley <- quantile_skewed(data[[rate_col]])
    if(bowley >=0.3){
      cli::cli_alert_warning("Skewed data, applying log10 transformation for better visualization.")
      map <- map +
        ggplot2::scale_fill_viridis_c(
          direction = -1,
          trans = "log10",
          labels = scales::label_number(),
          guide = ggplot2::guide_colorbar(
            barheight = 0.5, barwidth = 12,
            ticks = FALSE, direction = "horizontal",
            title.position = "top", title.hjust = 0.5,
            theme = ggplot2::theme(legend.text = ggplot2::element_text(size = 13))
          ))
    }
  }

  if (percent == TRUE){
    map <- map +
      ggplot2::scale_fill_viridis_c(
        direction = -1,
        labels = scales::percent_format(accuracy = .1),
        guide = ggplot2::guide_colorbar(
          barheight = 0.5, barwidth = 12,
          ticks = FALSE, direction = "horizontal",
          title.position = "top", title.hjust = 0.5,
          theme = ggplot2::theme(legend.text = ggplot2::element_text(size = 13))
        ))
  }

  if(auto_transform == FALSE && percent == FALSE){
    map <- map +
      ggplot2::scale_fill_viridis_c(
        direction = -1,
        labels = scales::label_number(),
        guide = ggplot2::guide_colorbar(
          barheight = 0.5, barwidth = 12,
          ticks = FALSE, direction = "horizontal",
          title.position = "top", title.hjust = 0.5,
          theme = ggplot2::theme(legend.text = ggplot2::element_text(size = 13))
        ))
  }

  map
}
