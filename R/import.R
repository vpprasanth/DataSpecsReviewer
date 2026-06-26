#' Read Supported Data Files
#'
#' Imports SAS, Excel, XLSB, and CSV files.
#'
#' @param path File path.
#' @param original_name Original file name.
#' @param read_all_sheets Logical.
#' If TRUE, all worksheets in an Excel workbook are imported.
#' If FALSE, only the first worksheet is imported.
#'
#' @return Named list of datasets.
#'
#' @export
#' 
read_one_file <- function(path, original_name, read_all_sheets = TRUE) {
  ext <- tolower(tools::file_ext(original_name))
  base <- safe_name(tools::file_path_sans_ext(basename(original_name)))

  if (ext == "sas7bdat") {
    # return(setNames(list(tibble::as_tibble(haven::read_sas(path), .name_repair = "unique")), base))
    return(stats::setNames(
      list(
        tibble::as_tibble(
          haven::read_sas(path),
          .name_repair = "unique"
        )
      ),
      base
    ))
  }

  if (ext %in% c("xls", "xlsx", "xlsm")) {
    sheets <- readxl::excel_sheets(path)
    if (!isTRUE(read_all_sheets)) sheets <- sheets[1]
    out <- lapply(sheets, function(sh) tibble::as_tibble(readxl::read_excel(path, sheet = sh, .name_repair = "unique")))
    names(out) <- paste0(base, "__", safe_name(sheets))
    return(out)
  }

  if (ext == "xlsb") {
    if (!requireNamespace("readxlsb", quietly = TRUE)) {
      stop("XLSB file detected, but package 'readxlsb' is not installed. Install it using install.packages('readxlsb').")
    }
    sheets <- NULL
    exports <- getNamespaceExports("readxlsb")
    if ("excel_sheets" %in% exports) sheets <- readxlsb::excel_sheets(path)
    if (is.null(sheets) && "list_sheets" %in% exports) sheets <- readxlsb::list_sheets(path)
    if (is.null(sheets) || length(sheets) == 0) sheets <- 1
    if (!isTRUE(read_all_sheets)) sheets <- sheets[1]
    out <- lapply(sheets, function(sh) tibble::as_tibble(readxlsb::read_xlsb(path, sheet = sh), .name_repair = "unique"))
    names(out) <- paste0(base, "__", safe_name(as.character(sheets)))
    return(out)
  }

  if (ext == "csv") {
    
    first_line <- readLines(path, n = 1, warn = FALSE)
    
    comma_count <- stringr::str_count(first_line, ",")
    semi_count  <- stringr::str_count(first_line, ";")
    tab_count   <- stringr::str_count(first_line, "\t")
    
    delim <- if (semi_count > comma_count) {
      ";"
    } else if (tab_count > comma_count) {
      "\t"
    } else {
      ","
    }
    
    df <- utils::read.table(
      path,
      sep = delim,
      header = TRUE,
      quote = "\"",
      stringsAsFactors = FALSE,
      check.names = FALSE,
      fill = TRUE,
      comment.char = ""
    )
    
    return(stats::setNames(
      list(
        tibble::as_tibble(
          df,
          .name_repair = "unique"
        )
      ),
      base
    ))
  }

  stop("Unsupported file type: ", ext, ". Supported: sas7bdat, xls, xlsx, xlsm, xlsb, csv.")
}
