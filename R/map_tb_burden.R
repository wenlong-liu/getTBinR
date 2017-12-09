#' Map TB Burden
#'
#' @description Plot measures of TB burden by country by specifying a metric from the TB burden data.
#' Specify a country or vector of countries in order to plot them (otherwise it will plot all countries).
#' Various other options are available for tuning the plot further.
#' @param conf Character vector specifying the name variations to use to specify the upper
#' and lower confidence intervals. Defaults to c("_lo", "_hi"), if set to \code{NULL}
#' then no confidence intervals are shown.
#' @param scales Character string, see ?ggplot2::facet_wrap for details. Defaults to "fixed",
#' alternatives are "free_y", "free_x", or "free".
#' @param interactive Logical, defaults to \code{FALSE}. If \code{TRUE} then an interactive plot is 
#' returned.
#' @inheritParams prepare_df_plot
#' @seealso get_tb_burden search_data_dict
#' @return A plot of TB Incidence Rates by Country
#' @export
#' @import ggplot2
#' @import magrittr
#' @importFrom dplyr filter
#' @importFrom purrr map
#' @importFrom plotly ggplotly
#' @examples
#' 
#' tb_burden <- get_tb_burden()
#' 
#' sample_countries <- sample(unique(tb_burden$country), 9)
#' 
#' plot_tb_burden(facet = "country", countries = sample_countries)
#' 
map_tb_burden <- function(df = NULL, metric = "e_inc_100k",
                           metric_label = NULL,
                           countries = NULL,
                           compare_to_region = FALSE,
                           facet = NULL, year = 2016, scales = "fixed",
                           interactive = FALSE, ...) {

  df_prep <- prepare_df_plot(df = df,
                             metric = metric,
                             metric_label = metric_label,
                             countries = countries,
                             compare_to_region = compare_to_region,
                             facet = facet)
  
  ## Bind in world data
  world <- gworld
  
  df_prep$df <- df_prep$df %>% 
    left_join(world, c("iso3" = "id")) %>% 
    filter(year == year)
  
  country <- NULL
  
  plot <- ggplot(df_prep$df, aes_string(x = "long", y = "lat", fill = metric)) +
    geom_polygon(aes_string(group = "group")) + 
    scale_fill_viridis_c(end = 0.9) +
    theme_minimal() +
    theme(legend.position = "bottom",
          axis.ticks = NULL) +
    guides(fill = guide_legend(title = df_prep$metric_label)) + 
    labs(x = "", y = "")
  
  if (!is.null(df_prep$facet)) {
    plot <- plot + 
      facet_wrap(df_prep$facet, scales = scales)
  }
  
  if (interactive) {
    plot <- plotly::ggplotly(plot)
  }
  
  return(plot)
}