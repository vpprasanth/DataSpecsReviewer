.onLoad <- function(libname, pkgname) {
  
  options(
    shiny.maxRequestSize = 1024 * 1024^2,
    shiny.autoreload = FALSE
  )
  
}
