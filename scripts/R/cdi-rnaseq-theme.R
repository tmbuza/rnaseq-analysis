cdi_rnaseq_theme <- function(base_size = 12){
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5),
      panel.grid.minor = ggplot2::element_blank()
    )
}