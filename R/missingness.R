#' Generate Missingness Profile
#'
#' Calculates missing-value statistics for every variable in a dataset.
#'
#' @param df Input data frame.
#'
#' @return A data frame containing:
#' \itemize{
#'   \item \code{variable} - Variable name
#'   \item \code{missing_n} - Number of missing values
#'   \item \code{missing_pct} - Percentage of missing values
#'   \item \code{distinct_n} - Number of distinct values
#'   \item \code{type} - Variable type
#' }
#'
#' @examples
#' \dontrun{
#' dm <- data.frame(
#'   USUBJID = c("01", "02", "03"),
#'   AGE = c(35, NA, 42),
#'   SEX = c("M", "F", NA)
#' )
#'
#' missing_profile(dm)
#' }
#'
#' @export
missing_profile <- function(df) {
  out <- tibble::tibble(
    variable = names(df),
    missing_n = vapply(df, function(x) sum(is.na(x)), numeric(1)),
    missing_pct = vapply(
      df,
      function(x) ifelse(length(x) == 0, NA_real_, 100 * mean(is.na(x))),
      numeric(1)
    ),
    distinct_n = vapply(
      df,
      function(x) dplyr::n_distinct(x, na.rm = FALSE),
      numeric(1)
    ),
    type = vapply(df, var_type, character(1))
  )
  
  dplyr::arrange(
    out,
    dplyr::desc(missing_pct),
    variable
  )
}
