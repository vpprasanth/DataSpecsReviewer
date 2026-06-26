options(
  shiny.maxRequestSize = 1024 * 1024^2,
  shiny.autoreload = FALSE
)

library(DataSpecsReviewer)

source("ui.R")
source("server.R")

shiny::shinyApp(ui, server)