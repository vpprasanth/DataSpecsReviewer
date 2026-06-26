

#' Launch Data Specs Reviewer
#'
#' Starts the interactive Shiny application.
#'
#' @export
#' 
data_review <- function() {
  
  options(
    shiny.maxRequestSize = 1024 * 1024^2,
    shiny.autoreload = FALSE
  )
  
  appDir <- system.file(
    "app",
    package = "DataSpecsReviewer"
  )
  
  shiny::runApp(
    appDir,
    display.mode = "normal"
  )
}
