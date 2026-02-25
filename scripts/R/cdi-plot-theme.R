# Global CDI ggplot theme + helpers
# Keep ggplot2 namespaces explicit

cdi_palette <- function(){
  list(
    teal = "#0B5C73",        # darker primary
    teal_light = "#1F7A8C",  # stronger secondary
    highlight = "#E6A317",   # slightly deeper highlight
    ink = "#0f172a",
    muted = "#334155",
    grid = "#d9e2ec",        # slightly darker grid
    panel = "#ffffff"
  )
}

cdi_theme <- function(base_size = 14){
  pal <- cdi_palette()

  ggplot2::theme_light(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", color = pal$ink),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, color = pal$muted),
      plot.caption = ggplot2::element_text(hjust = 1, color = pal$muted),

      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = pal$grid, linewidth = 0.4),

      axis.title = ggplot2::element_text(face = "bold", color = pal$ink),
      axis.text = ggplot2::element_text(color = pal$ink),

      legend.title = ggplot2::element_text(face = "bold", color = pal$ink),
      legend.position = "top"
    )
}

# Histogram layer with CDI styling.
# Use colored = TRUE to color bars by bin position (gradient), with legend removed.
cdi_geom_histogram <- function(
  bins = 30,
  colored = FALSE,
  alpha = 0.85,
  border_color = "white",
  border_linewidth = 0.35,
  ...
){
  pal <- cdi_palette()

  if (isTRUE(colored)){
    ggplot2::geom_histogram(
      bins = bins,
      ggplot2::aes(fill = ggplot2::after_stat(x)),
      color = border_color,
      linewidth = border_linewidth,
      alpha = alpha,
      ...
    )
  } else {
    ggplot2::geom_histogram(
      bins = bins,
      fill = pal$teal_light,
      color = border_color,
      linewidth = border_linewidth,
      alpha = alpha,
      ...
    )
  }
}

# Scale for colored histograms (gradient). Pair with cdi_geom_histogram(colored = TRUE).
# Legend is removed by default to keep the plot clean.
cdi_scale_histogram_fill <- function(show_legend = FALSE){
  pal <- cdi_palette()

  ggplot2::scale_fill_gradient(
    low = pal$teal_light,
    high = pal$teal,
    guide = if (isTRUE(show_legend)) "colourbar" else "none"
  )
}
