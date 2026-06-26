get_var_label <- function(x) {
  lab <- attr(x, "label", exact = TRUE)
  if (is.null(lab)) "" else clean_one_text(as.character(lab)[1])
}

get_sas_format <- function(x) {
  fmt <- attr(x, "format.sas", exact = TRUE)
  if (!is.null(fmt)) return(as.character(fmt)[1])
  if (is.numeric(x)) return("BEST12.")
  if (is.character(x)) {
    lx <- nchar(x)
    lx <- lx[!is.na(lx)]
    return(paste0("$", max(1, ifelse(length(lx) == 0, 1, max(lx))), "."))
  }
  ""
}

var_type <- function(x) {
  if (inherits(x, "Date")) return("Date")
  if (inherits(x, "POSIXct") || inherits(x, "POSIXt")) return("Datetime")
  if (is.numeric(x)) return("Numeric")
  if (is.logical(x)) return("Logical")
  "Character"
}

var_length <- function(x) {
  if (is.character(x)) {
    lx <- nchar(x)
    lx <- lx[!is.na(lx)]
    return(as.character(ifelse(length(lx) == 0, 0, max(lx))))
  }
  if (is.numeric(x)) return("8")
  if (is.logical(x)) return("1")
  ""
}

#' Format Display Values
#'
#' Converts missing values to a printable string.
#'
#' @param x Vector of values.
#'
#' @return Character vector where missing values are
#' represented as "Missing".
#'
#' @export
#' 
display_value <- function(x) ifelse(is.na(x), "Missing", as.character(x))

format_levels <- function(x, threshold = 10) {
  n <- length(x)
  nonmiss <- sum(!is.na(x))
  miss <- sum(is.na(x))
  if (n == 0) return("N (N Missing): . (.)")
  distinct_n <- dplyr::n_distinct(x, na.rm = FALSE)
  if (is.numeric(x) && distinct_n > threshold) {
    vals <- x[!is.na(x)]
    if (length(vals) == 0) return(paste0("N (N Missing): 0 (", miss, ")"))
    return(paste0("N (N Missing): ", format(nonmiss, big.mark = ","), " (", format(miss, big.mark = ","), ")",
                  "
Median: ", signif(stats::median(vals), 6),
                  "
Range: ", signif(min(vals), 6), " - ", signif(max(vals), 6)))
  }
  if (distinct_n <= threshold) {
    tmp <- tibble::tibble(value = display_value(x))
    tmp <- dplyr::count(tmp, value, name = "n")
    tmp <- dplyr::mutate(tmp, pct = 100 * n / sum(n), txt = paste0(value, ": ", format(n, big.mark = ","), " (", sprintf("%.1f", pct), "%)"))
    return(clean_one_text(paste(tmp$txt, collapse = "
")))
  }
  paste0("N (N Missing): ", format(nonmiss, big.mark = ","), " (", format(miss, big.mark = ","), ")")
}

#' Build Dataset Specifications
#'
#' Generates dataset-level and variable-level metadata used by
#' Data Specs Reviewer.
#'
#' Extracts information such as variable names, labels,
#' lengths, formats, missingness statistics, cardinality,
#' and representative values.
#'
#' @param datasets A named list of datasets.
#' @param cat_threshold Integer. Maximum number of unique values
#' displayed before categorical values are summarized.
#' @param index_vars Optional character vector of subject/index variables.
#' @param order Variable ordering method. Either `"varnum"`
#' or `"name"`.
#'
#' @return A list containing:
#' \describe{
#'   \item{lib_summary}{Dataset-level summary.}
#'   \item{var_summary}{Variables found across multiple datasets.}
#'   \item{specs_long}{Long-format specification table.}
#'   \item{specs_condensed}{Variable-level metadata table.}
#' }
#'
#' @export
#' 
build_specs <- function(datasets, cat_threshold = 10, index_vars = character(), order = "varnum") {
  dataset_names <- names(datasets)
  lib_summary <- purrr::map_dfr(seq_along(datasets), function(i) {
    df <- datasets[[i]]
    idx_names <- names(df)[toupper(names(df)) %in% toupper(index_vars)]
    unique_index <- 0
    if (length(idx_names) > 0 && nrow(df) > 0) unique_index <- nrow(dplyr::distinct(df, dplyr::across(dplyr::all_of(idx_names))))
    tibble::tibble(dataset = dataset_names[i], observations = nrow(df), unique_index_values = unique_index, variables = ncol(df))
  })

  specs_condensed <- purrr::map_dfr(seq_along(datasets), function(i) {
    df <- datasets[[i]]
    vars <- names(df)
    if (tolower(order) == "name") vars <- sort(vars)
    purrr::map_dfr(vars, function(v) {
      x <- df[[v]]
      tibble::tibble(
        data_id = i, dataset = dataset_names[i], var_name = v,
        type = var_type(x), length = var_length(x), format = get_sas_format(x), label = get_var_label(x),
        distinct_n = dplyr::n_distinct(x, na.rm = FALSE), missing_n = sum(is.na(x)),
        missing_pct = ifelse(length(x) == 0, NA_real_, 100 * mean(is.na(x))),
        category_values = format_levels(x, threshold = cat_threshold)
      )
    })
  })

  specs_long <- dplyr::transmute(
    specs_condensed,
    data_id = data_id, dataset = dataset, var_name = var_name,
    Variable = var_name,
    Label = label,
    Format = ifelse(type == "Numeric", paste0("Numeric with format ", ifelse(format == "", "BEST12.", format)), paste0("Character string of length ", length, " and format ", ifelse(format == "", paste0("$", length, "."), format))),
    Values = category_values
  )
  specs_long <- tidyr::pivot_longer(specs_long, cols = c("Variable", "Label", "Format", "Values"), names_to = "spec", values_to = "value")

  var_summary <- dplyr::mutate(specs_condensed, var_upper = toupper(var_name))
  var_summary <- dplyr::filter(var_summary, !(var_upper %in% toupper(index_vars)))
  var_summary <- dplyr::group_by(var_summary, var_upper)
  var_summary <- dplyr::summarise(var_summary, variable_name = dplyr::first(var_upper), dataset_count = dplyr::n_distinct(dataset), datasets_containing_variable = paste(unique(dataset), collapse = ", "), labels = paste(unique(label[label != ""]), collapse = "
"), .groups = "drop")
  var_summary <- dplyr::filter(var_summary, dataset_count > 1)
  var_summary <- dplyr::arrange(var_summary, dplyr::desc(dataset_count), variable_name)

  list(lib_summary = lib_summary, var_summary = var_summary, specs_long = specs_long, specs_condensed = specs_condensed)
}
