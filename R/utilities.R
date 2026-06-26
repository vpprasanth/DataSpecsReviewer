#' Return a Default Value When Missing
#'
#' Returns a fallback value when the supplied object is NULL,
#' empty, or contains only missing values.
#'
#' @param x Object to evaluate.
#' @param y Fallback value returned when \code{x} is NULL,
#' empty, or entirely missing.
#'
#' @return Either \code{x} or \code{y}.
#'
#' @examples
#' or_else(NULL, "ABC")
#' or_else("", "ABC")
#'
#' @export
#' 
or_else <- function(x, y) {
  if (is.null(x) || length(x) == 0 || all(is.na(x))) y else x
}

safe_name <- function(x) {
  x <- as.character(or_else(x, ""))
  x <- gsub("[^A-Za-z0-9_]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_|_$", "", x)
  ifelse(nchar(x) == 0, "dataset", x)
}

shorten_sheet <- function(x, max_len = 31) {
  substr(safe_name(x), 1, max_len)
}

make_unique_sheet <- function(wb, proposed_name) {
  sh <- shorten_sheet(proposed_name)
  base <- sh
  k <- 1
  while (sh %in% openxlsx::sheets(wb)) {
    k <- k + 1
    suffix <- paste0("_", k)
    sh <- paste0(substr(base, 1, 31 - nchar(suffix)), suffix)
  }
  sh
}

#' Clean Text for Excel Export
#'
#' Removes unsupported control characters and truncates text
#' exceeding Excel cell limits.
#'
#' @param s Character value.
#'
#' @return Cleaned character string.
#'
#' @export
#' 
clean_one_text <- function(s) {
  if (is.na(s)) return(NA_character_)
  s <- as.character(s)
  ints <- utf8ToInt(s)
  if (length(ints) > 0) {
    keep <- ints == 9 | ints == 10 | ints == 13 | ints >= 32
    s <- intToUtf8(ints[keep], multiple = FALSE)
  }
  s <- gsub("
|
", "
", s)
  if (nchar(s) > 32000) {
    s <- paste0(substr(s, 1, 32000), "
[Truncated for Excel cell limit]")
  }
  s
}

#' Clean Character Values for Excel
#'
#' Applies Excel-safe text cleaning to a vector.
#'
#' @param x Vector.
#'
#' @return Cleaned vector.
#'
#' @export
#' 
clean_excel_text <- function(x) {
  if (is.factor(x)) x <- as.character(x)
  if (is.character(x)) {
    x <- vapply(x, clean_one_text, character(1), USE.NAMES = FALSE)
    x <- enc2utf8(x)
  }
  x
}

#' Clean Data Frame for Excel Export
#'
#' Applies Excel-safe text cleaning across all columns.
#'
#' @param dat Data frame.
#'
#' @return Cleaned data frame.
#'
#' @export
#' 
clean_excel_df <- function(dat) {
  if (is.null(dat) || nrow(dat) == 0) return(dat)
  dat[] <- lapply(dat, clean_excel_text)
  dat
}
#' Safe DT Data Preparation
#'
#' Converts data frames into DT-friendly tibbles while handling
#' dates, factors, labelled variables, list columns, and
#' character encoding issues.
#'
#' @param dat Input data frame.
#' @param max_rows Optional maximum number of rows.
#'
#' @return Tibble suitable for DT rendering.
#'
#' @export
#' 
safe_dt_df <- function(dat, max_rows = NULL) {
  if (is.null(dat)) return(dat)
  dat <- as.data.frame(dat, stringsAsFactors = FALSE, check.names = FALSE)
  dat[] <- lapply(dat, function(x) {
    if (inherits(x, "haven_labelled") || inherits(x, "labelled")) x <- as.character(x)
    if (inherits(x, "Date")) x <- as.character(x)
    if (inherits(x, "POSIXct") || inherits(x, "POSIXt")) x <- as.character(x)
    if (is.list(x)) x <- vapply(x, function(z) paste(as.character(z), collapse = "; "), character(1), USE.NAMES = FALSE)
    if (is.factor(x)) x <- as.character(x)
    if (is.character(x)) {
      x <- clean_excel_text(x)
      x <- enc2utf8(x)
    }
    x
  })
  if (!is.null(max_rows) && nrow(dat) > max_rows) dat <- dat[seq_len(max_rows), , drop = FALSE]
  tibble::as_tibble(dat, .name_repair = "unique")
}

estimate_excel_row_height <- function(x, col_width = 120, base_height = 18, line_height = 13, max_height = 180) {
  x <- as.character(or_else(x, ""))
  x[is.na(x)] <- ""
  explicit_lines <- stringr::str_count(x, "
") + 1
  wrapped_lines <- ceiling(nchar(x, type = "width") / max(1, col_width * 1.15))
  total_lines <- pmax(explicit_lines, wrapped_lines, 1)
  pmin(max_height, pmax(base_height, total_lines * line_height))
}
