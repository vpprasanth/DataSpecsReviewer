#' Launch Data Specs Reviewer
#'
#' Shortcut for launching the Data Specs Reviewer application.
#'
#' @param ... Arguments passed to `data_review()`.
#'
#' @export
#' 
dsr <- function(...) {
  data_review(...)
}

#' @rdname dsr
#' @export
DSR <- function(...) {
  data_review(...)
}
