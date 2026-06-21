#' Plot prevalence/incidence rates
#'
#' @description
#' The `plot_rates()` plots prevalence/incidence rates
#'
#' @param data A data frame with the prevalence/incidence rates and auxiliary information.
#' @param date_col A character string. Name  of the date column in `data`. Default is "date".
#' @param rate_col A character string. Name  of the rate column in `data`.
#' @param grouping_var A character string. Name of the variable/column in `data` used to group rates.
#' @param facet_var A character string. Name  of the variable/column in `data` used to facet plots.
#' @param plot_type A character string. Type of plot, options are "line", "bar_chart", "lollipop", "jitter"
#' @param percent Logical. Do you want axis to be in percent? Default set to TRUE.
#' @param palette A character string. Color palette to be used in the plots, options are: "fhi_colors", "viridis", "okabe_ito"
#' @param annotated_line Character string. Position of annotated line. Default is NULL.
#' @param CI_lower A character string. Name of the column containing the lower confidence interval in `data`.
#' @param CI_upper A character string. Name of the column containing the upper confidence interval in `data`.
#' @param plot_title Character string. Title of the plot.
#' @param start_end_points Logical. Want to annotate the start and end points of a line plot? Default is set to `FALSE`.
#' * If `TRUE`, the start and end point of a line plot are annotated with their corresponding numerical values.
#' @param interactive Logical. Do you want to make the plot interactive with plotly? Default is set to FALSE.
#' @param single_color A character string. Single color applied to all the plot. Default is set to "black"
#' @param x_name A character string. Title of the x axis.
#' @param y_name A character string. Title of the y axis.
#' @param legend_title A character string. Title for the legend box.
#' @param coord_flip Logical. Default is set to `FALSE`
#' * For lollipop, bar charts and jitter `TRUE` it flips the orientation of the plot.
#'
#' @returns A ggplot object
#' @examples
#' # Set up a temporary log file
#' log_file <- tempfile()
#' cat("Example log file", file = log_file)
#'
#' # Set seed for reproducibility
#' set.seed(123)
#'
#' pop_df <- tidyr::expand_grid(year = 2012:2020,
#'   sex = as.factor(c(0, 1)),
#'   innvandringsgrunn = c("ARB", "UKJ", "NRD")) |>
#'     dplyr::mutate(population = floor(runif(dplyr::n(), min = 3000, max = 4000)))
#'
#' linked_df <- linked_df |> dplyr::rename("year"= "y_diagnosis_first")
#'
#' prev_series <- regkit::calculate_prevalence_series(linked_df,
#'   time_points = c(2012:2020),
#'   id_col = "id",
#'   date_col = "year",
#'   pop_data = pop_df,
#'   pop_col = "population",
#'   grouping_vars = c("sex", "innvandringsgrunn"),
#'   only_counts = FALSE,
#'   suppression = FALSE,
#'   CI = TRUE,
#'   CI_level = 0.95,
#'   log_path = log_file)
#'
#' plot_rates(prev_series,
#'  date_col = "year",
#'  rate_col = "prev_rate",
#'  plot_type = "line",
#'  grouping_var = "sex",
#'  facet_var = "innvandringsgrunn",
#'  palette = "fhi_colors",
#'  CI_lower = "ci_results_lower",
#'  CI_upper = "ci_results_upper",
#'  plot_title = "Prevalence by sex and reason of immigration",
#'  x_name = "Year",
#'  start_end_points = TRUE)
#
#'
#' @export
#' @importFrom ggplot2 theme element_blank element_text unit ggplot aes geom_line geom_point geom_bar geom_segment geom_jitter facet_wrap scale_y_continuous vars
#'


plot_rates <- function(data,
                       date_col = "date",
                       rate_col,
                       grouping_var = NULL,
                       facet_var = NULL,
                       plot_type = c("line", "bar_chart", "lollipop", "jitter"),
                       percent = TRUE, palette = c("fhi_colors", "viridis", "okabe_ito"),
                       single_color = "black",
                       annotated_line = NULL,
                       CI_lower = NULL,
                       CI_upper = NULL,
                       plot_title = "",
                       x_name = "",
                       y_name = "",
                       legend_title = "",
                       coord_flip = FALSE,
                       start_end_points = FALSE,
                       interactive = FALSE){


  # Input validation   ---------------------------------------------------------

  type <- match.arg(plot_type, several.ok = FALSE)

  palette_type <- match.arg(palette, several.ok = FALSE)


  # Set theme   ---------------------------------------------------------------
  regtools_theme <- ggthemes::theme_hc() +
    theme(
      strip.background = element_blank(),
      strip.text = element_text(color = "black", face = "bold", size = 12),
      axis.text.x = element_text(size = 12),
      axis.title.x = element_text(size = 12),
      axis.title.y = element_text(size = 12),
      axis.text.y = element_text(size = 12),
      axis.ticks.x = element_blank(),
      legend.text = element_text(size = 12),
      legend.title = element_text(size = 12),
      panel.spacing = unit(2, "lines"),
      legend.position = "right",
      plot.title = element_text(size = 16, hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
    )


  # Base plots  ---------------------------------------------------------------

  if (!is.null(grouping_var)){
    base_plot <- ggplot(data, aes(x = !!rlang::sym(date_col), y = !!rlang::sym(rate_col),
                                  colour = !!rlang::sym(grouping_var),
                                  group  = !!rlang::sym(grouping_var)))


  plot <- switch(type,
                 line = base_plot + geom_line(linewidth = 1.2) + geom_point(size = 1.5),
                 bar_chart = ggplot(data, aes(x = !!rlang::sym(date_col), y = !!rlang::sym(rate_col), fill = !!rlang::sym(grouping_var)))
                 + geom_bar(position = "dodge", stat = "identity"),
                 lollipop = base_plot + geom_segment(aes(y = 0, yend = !!rlang::sym(rate_col)),linewidth = 1) + geom_point(size = 3),
                 jitter = base_plot + geom_jitter(width = .1, height = 0, alpha = .6),
                 stop("Unknown plot_type")
                 )


  } else if (is.null(grouping_var)){
    base_plot <- ggplot(data, aes(x = !!rlang::sym(date_col), y = !!rlang::sym(rate_col), group = 1))


    plot <- switch(type,

                   line = base_plot + geom_line(linewidth = 1.2, color = single_color) + geom_point(size = 1.5),

                   bar_chart = ggplot(data, aes(x = !!rlang::sym(date_col), y = !!rlang::sym(rate_col)))+ geom_bar(color = single_color, fill = single_color, position = "dodge", stat = "identity"),

                   lollipop = base_plot + geom_segment(aes(y = 0, yend = !!rlang::sym(rate_col)),linewidth = 1) + geom_point(size = 3),

                   jitter = base_plot + geom_jitter(width = .1, height = 0, alpha = .6),

                   stop("Unknown plot_type")
    )
  }

  if(!is.null(facet_var)){
    plot <- plot + facet_wrap(vars(!!rlang::sym(facet_var)))
  }


  if(percent == TRUE){
    if(!requireNamespace("scales", quietly = TRUE)){
      stop("Package \"scales\" must be installed to use percentages in x axis .",call. = FALSE)
    }
    plot <- plot + scale_y_continuous(labels = scales::label_percent())
  }



  # Theme and palette for multiple groups --------------------------------------

  plot <- plot +
    regtools_theme +
    ggplot2::labs(title = plot_title,
                  x = x_name,
                  y = y_name,
                  color = legend_title)

  plot <- switch(palette_type,
                 fhi_colors = plot + ggplot2::scale_colour_manual(values = c("#7176c9","#a93c38","#f9dc8c","#61d2b2")) +
                   ggplot2::scale_fill_manual(values = c("#7176c9","#a93c38","#f9dc8c","#61d2b2")),

                 viridis = plot + ggplot2::scale_colour_viridis_d() +
                   ggplot2::scale_fill_viridis_d(),

                 okabe_ito = plot + ggplot2::scale_colour_manual(values = c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")) +
                   ggplot2::scale_fill_manual(values = c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")),

                 stop("Unknown palette type"))



  # Extra visuals -----------------------------------------------------------

  if(coord_flip && plot_type %in% c("bar_chart", "lollipop")){
    plot <- plot + ggplot2::coord_flip() + theme(panel.grid.major.x = ggplot2::element_line(color = "#D8D8D8"),
                                                 panel.grid.major.y = element_blank())
  }

  if (!is.null(CI_upper) && !is.null(CI_lower)){
    if(plot_type != "bar_chart"){
      if(!is.null(grouping_var)){
        plot <- plot + ggplot2::geom_ribbon(aes(ymin=!!rlang::sym(CI_lower), ymax=!!rlang::sym(CI_upper), fill = !!rlang::sym(grouping_var)),alpha=0.1, linetype = 0, show.legend = FALSE)
      } else if (is.null(grouping_var)){
        plot <- plot + ggplot2::geom_ribbon(aes(ymin=!!rlang::sym(CI_lower), ymax=!!rlang::sym(CI_upper)), fill = single_color, alpha=0.1, linetype = 0, show.legend = FALSE)
      }
    } else if(plot_type == "bar_chart"){
      if(!is.null(grouping_var)){
        plot <- plot + ggplot2::geom_errorbar(aes(ymin=!!rlang::sym(CI_lower), ymax=!!rlang::sym(CI_upper)), position =  ggplot2::position_dodge(0.9), width = 0.2)
      } else if (is.null(grouping_var)){
        plot <- plot + ggplot2::geom_errorbar(aes(ymin=!!rlang::sym(CI_lower), ymax=!!rlang::sym(CI_upper)))
      }
    }
  }

  if(!is.null(annotated_line)){
    plot <- plot + ggplot2::geom_vline(aes(xintercept = as.character(annotated_line)), linetype="dashed", linewidth = 0.6)
  }

  if(start_end_points  == TRUE){
    if(!requireNamespace("ggrepel", quietly = TRUE)){
      stop("Package \"ggrepel\" must be installed to annotate start and end points.",call. = FALSE)
    }
    variables <- c(grouping_var, facet_var)
    data_start_end_points <- data |>
      dplyr::group_by(dplyr::across(tidyselect::all_of(variables))) |>
      dplyr::slice(1, dplyr::n())
    if(percent == TRUE){
      if(!requireNamespace("scales", quietly = TRUE)){
        stop("Package \"scales\" must be installed to annotate percentages in start and end points.",call. = FALSE)
      }
      plot <- plot + ggrepel::geom_text_repel(data = data_start_end_points, aes(label = scales::percent(!!rlang::sym(rate_col), accuracy = 0.01)), color = "black", size = 4.7)
    } else {
      plot <- plot + ggrepel::geom_text_repel(data = data_start_end_points, aes(label = !!rlang::sym(rate_col)), color = "black", size = 4.7)
    }
  }




  if(interactive == TRUE){
    if(!requireNamespace("plotly", quietly = TRUE)){
      stop("Package \"plotly\" must be installed to create interactive plot.",call. = FALSE)
    }
    plot <- plot |> plotly::ggplotly()
  }


  plot


}
