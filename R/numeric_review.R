#' Generate Numeric Review Statistics
#'
#' Calculates descriptive statistics for all numeric variables.
#'
#' Includes:
#' \itemize{
#'   \item N
#'   \item Missing count
#'   \item Mean
#'   \item Standard deviation
#'   \item Median
#'   \item Quartiles
#'   \item Minimum
#'   \item Maximum
#'   \item Potential outlier counts
#' }
#'
#' @param df Input data frame.
#'
#' @return Data frame containing numeric review statistics.
#'
#' @export
#' 
numeric_profile <- function(df) {
  nums <- names(df)[vapply(df, is.numeric, logical(1))]
  if (length(nums) == 0) return(tibble::tibble())
  purrr::map_dfr(nums, function(v) {
    x <- df[[v]]
    vals <- x[!is.na(x)]
    if (length(vals) == 0) {
      return(tibble::tibble(variable = v, n = 0, n_missing = length(x), mean = NA_real_, sd = NA_real_, median = NA_real_, q1 = NA_real_, q3 = NA_real_, min = NA_real_, max = NA_real_, outlier_n = NA_integer_))
    }
    q1 <- stats::quantile(vals, 0.25, names = FALSE)
    q3 <- stats::quantile(vals, 0.75, names = FALSE)
    iqr <- q3 - q1
    tibble::tibble(variable = v, n = length(vals), n_missing = sum(is.na(x)), mean = mean(vals), sd = stats::sd(vals), median = stats::median(vals), q1 = q1, q3 = q3, min = min(vals), max = max(vals), outlier_n = sum(vals < q1 - 1.5 * iqr | vals > q3 + 1.5 * iqr, na.rm = TRUE))
  })
}
