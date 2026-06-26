server <- function(input, output, session) {
  # session$onSessionEnded(function() gc())
  session$onSessionEnded(function() {
    gc()
    try(stopApp(), silent = TRUE)
  })
  make_dt <- function(
    dat,
    pageLength = 10,
    scrollX = FALSE,
    filter = "none",
    columnDefs = NULL
  ) {
    
    opts <- list(
      pageLength = pageLength,
      scrollX = scrollX,
      autoWidth = FALSE,
      ordering = TRUE
    )
    
    if (!is.null(columnDefs)) {
      opts$columnDefs <- columnDefs
    }
    
    DT::datatable(
      dat,
      class = "compact stripe row-border",
      filter = filter,
      options = opts,
      rownames = FALSE
    )
  }

  uploaded_data <- shiny::reactive({
    shiny::req(input$files)
    files <- input$files
    out <- list()
    errors <- character()
    shiny::withProgress(message = "Reading uploaded files", value = 0, {
      for (i in seq_len(nrow(files))) {
        shiny::incProgress(1 / nrow(files), detail = files$name[i])
        res <- tryCatch(read_one_file(files$datapath[i], files$name[i], read_all_sheets = input$all_sheets), error = function(e) e)
        if (inherits(res, "error")) {
          errors <- c(errors, paste(files$name[i], ":", conditionMessage(res)))
        } else {
          nm <- names(res)
          for (j in seq_along(res)) {
            new_nm <- nm[j]
            k <- 1
            while (new_nm %in% names(out)) {
              k <- k + 1
              new_nm <- paste0(nm[j], "_", k)
            }
            out[[new_nm]] <- res[[j]]
          }
        }
      }
    })
    shiny::validate(shiny::need(length(out) > 0, paste(c("No readable datasets found.", errors), collapse = "\n")))
    out
  })

  get_index_vars <- shiny::reactive({
    
    idx <- strsplit(
      or_else(input$index_vars, ""),
      "|",
      fixed = TRUE
    )[[1]]
    
    idx <- trimws(idx)
    
    idx[nzchar(idx)]
    
  })

  specs <- shiny::reactive(build_specs(uploaded_data(), cat_threshold = input$cat_threshold, index_vars = get_index_vars(), order = input$order))
  quality_flags <- shiny::reactive(build_quality_flags(uploaded_data(), index_vars = get_index_vars(), high_missing_cutoff = input$high_missing_cutoff, high_cardinality_cutoff = input$high_cardinality_cutoff))

  output$dataset_picker <- shiny::renderUI({
    shiny::req(uploaded_data())
    shiny::selectInput("selected_dataset", "Dataset", choices = names(uploaded_data()), selected = names(uploaded_data())[1])
  })

  selected_df <- shiny::reactive({ shiny::req(uploaded_data(), input$selected_dataset); uploaded_data()[[input$selected_dataset]] })

  # output$lib_summary <- DT::renderDT({ shiny::req(specs()); DT::datatable(safe_dt_df(specs()$lib_summary), options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  # output$var_summary <- DT::renderDT({ shiny::req(specs()); DT::datatable(safe_dt_df(specs()$var_summary), options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$spec_title <- shiny::renderText({ paste("Specifications:", or_else(input$selected_dataset, "")) })

  # output$dataset_specs <- DT::renderDT({
  #   shiny::req(specs(), input$selected_dataset)
  #   dat <- specs()$specs_long |> dplyr::filter(dataset == input$selected_dataset) |> dplyr::select(Specification = spec, Value = value)
  #   dat <- safe_dt_df(dat)
  #   dat$Value <- gsub("\n", "<br>", dat$Value, fixed = TRUE)
  #   DT::datatable(dat, escape = FALSE, options = list(pageLength = 25, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE)
  # })
  
  output$lib_summary <- DT::renderDT({
    shiny::req(specs())
    
    make_dt(
      safe_dt_df(specs()$lib_summary),
      pageLength = 10,
      scrollX = FALSE,
      columnDefs = list(
        list(width = "35%", targets = 0),
        list(width = "20%", targets = 1),
        list(width = "25%", targets = 2),
        list(width = "20%", targets = 3)
      )
    )
  })

  output$var_summary <- DT::renderDT({
    shiny::req(specs())
    
    make_dt(
      safe_dt_df(specs()$var_summary),
      pageLength = 10,
      scrollX = TRUE,
      columnDefs = list(
        list(width = "20%", targets = 0),
        list(width = "20%", targets = 1),
        list(width = "15%", targets = 2),
        list(width = "30%", targets = 3),
        list(width = "30%", targets = 4)
      )
    )
  })
  
  output$dataset_specs <- DT::renderDT({
    
    shiny::req(specs(), input$selected_dataset)
    
    dat <- specs()$specs_long |>
      dplyr::filter(dataset == input$selected_dataset) |>
      dplyr::select(
        Specification = spec,
        Value = value
      )
    
    dat <- safe_dt_df(dat)
    
    DT::datatable(
      dat,
      escape = FALSE,
      rownames = FALSE,
      class = "compact stripe row-border",
      options = list(
        pageLength = 25,
        scrollX = FALSE,
        autoWidth = FALSE,
        columnDefs = list(
          list(width = "20%", targets = 0),
          list(width = "80%", targets = 1)
        )
      )
    )
  })
  
  # output$quality_flags <- DT::renderDT({ shiny::req(quality_flags()); DT::datatable(safe_dt_df(quality_flags()), filter = "top", options = list(pageLength = 15, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$quality_flags <- DT::renderDT({
    shiny::req(quality_flags())
    
    make_dt(
      safe_dt_df(quality_flags()),
      pageLength = 15,
      scrollX = TRUE,
      filter = "top",
      columnDefs = list(
        list(width = "18%", targets = 0),
        list(width = "18%", targets = 1),
        list(width = "18%", targets = 2),
        list(width = "12%", targets = 3),
        list(width = "20%", targets = 4),
        list(width = "35%", targets = 5)
      )
    )
  })
  # output$quality_summary <- DT::renderDT({ shiny::req(quality_flags()); DT::datatable(safe_dt_df(quality_flag_summary(quality_flags())), options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$quality_summary <- DT::renderDT({
    shiny::req(quality_flags())
    
    make_dt(
      safe_dt_df(quality_flag_summary(quality_flags())),
      pageLength = 10,
      scrollX = FALSE,
      columnDefs = list(
        list(width = "25%", targets = 0),
        list(width = "50%", targets = 1),
        list(width = "25%", targets = 2)
      )
    )
  })
  # output$missing_table <- DT::renderDT({ shiny::req(selected_df()); DT::datatable(safe_dt_df(missing_profile(selected_df())), options = list(pageLength = 15, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$missing_table <- DT::renderDT({
    shiny::req(selected_df())
    
    make_dt(
      safe_dt_df(missing_profile(selected_df())),
      pageLength = 15,
      scrollX = FALSE,
      columnDefs = list(
        list(width = "30%", targets = 0),
        list(width = "15%", targets = 1),
        list(width = "20%", targets = 2),
        list(width = "15%", targets = 3),
        list(width = "20%", targets = 4)
      )
    )
  })
  
  output$missing_plot <- shiny::renderPlot({
    shiny::req(selected_df())
    mp <- missing_profile(selected_df()) |> dplyr::filter(!is.na(missing_pct), is.finite(missing_pct)) |> dplyr::arrange(dplyr::desc(missing_pct), variable) |> dplyr::slice_head(n = 50)
    shiny::validate(shiny::need(nrow(mp) > 0, "No plottable missingness values available."))
    ggplot2::ggplot(mp, ggplot2::aes(x = reorder(variable, missing_pct), y = missing_pct)) + ggplot2::geom_col(na.rm = TRUE) + ggplot2::coord_flip() + ggplot2::labs(x = NULL, y = "Missing (%)", title = "Top variables by missingness") + ggplot2::theme_minimal(base_size = 10)
  })

  # output$numeric_table <- DT::renderDT({ shiny::req(selected_df()); DT::datatable(safe_dt_df(numeric_profile(selected_df())), options = list(pageLength = 15, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$numeric_table <- DT::renderDT({
    shiny::req(selected_df())
    
    make_dt(
      safe_dt_df(numeric_profile(selected_df())),
      pageLength = 15,
      scrollX = TRUE,
      columnDefs = list(
        list(width = "22%", targets = 0),
        list(width = "10%", targets = 1),
        list(width = "12%", targets = 2),
        list(width = "12%", targets = 3),
        list(width = "12%", targets = 4),
        list(width = "12%", targets = 5),
        list(width = "12%", targets = 6),
        list(width = "12%", targets = 7),
        list(width = "12%", targets = 8),
        list(width = "12%", targets = 9),
        list(width = "15%", targets = 10)
      )
    )
  })
  output$numeric_var_ui <- shiny::renderUI({ shiny::req(selected_df()); nums <- names(selected_df())[vapply(selected_df(), is.numeric, logical(1))]; if (length(nums) == 0) return(shiny::tags$p("No numeric variables available.")); shiny::selectInput("numeric_var", "Numeric variable", choices = nums) })

  output$numeric_plot <- shiny::renderPlot({
    shiny::req(selected_df(), input$numeric_var)
    df <- selected_df()
    shiny::validate(shiny::need(input$numeric_var %in% names(df), "Select a numeric variable."))
    plot_dat <- df |> dplyr::select(value = dplyr::all_of(input$numeric_var)) |> dplyr::filter(!is.na(value), is.finite(value))
    shiny::validate(shiny::need(nrow(plot_dat) > 0, "No non-missing numeric values available for this variable."))
    ggplot2::ggplot(plot_dat, ggplot2::aes(x = value)) + ggplot2::geom_histogram(bins = 30, na.rm = TRUE) + ggplot2::labs(x = input$numeric_var, y = "Count", title = paste("Distribution of", input$numeric_var)) + ggplot2::theme_minimal(base_size = 10)
  })

  output$cat_var_ui <- shiny::renderUI({ shiny::req(selected_df()); df <- selected_df(); cats <- names(df)[!vapply(df, is.numeric, logical(1))]; if (length(cats) == 0) return(shiny::tags$p("No categorical/character variables available.")); shiny::selectInput("cat_var", "Categorical variable", choices = cats) })
  cat_freq <- shiny::reactive({ shiny::req(selected_df(), input$cat_var); df <- selected_df(); shiny::validate(shiny::need(input$cat_var %in% names(df), "Select categorical variable.")); tibble::tibble(value = display_value(df[[input$cat_var]])) |> dplyr::mutate(value = clean_excel_text(as.character(value))) |> dplyr::count(value, name = "n") |> dplyr::mutate(percent = 100 * n / sum(n)) |> dplyr::arrange(dplyr::desc(n)) })

  output$cat_plot <- shiny::renderPlot({
    dat <- cat_freq() |> dplyr::filter(!is.na(value), !is.na(n), is.finite(n)) |> dplyr::slice_head(n = 30)
    shiny::validate(shiny::need(nrow(dat) > 0, "No categorical values available."))
    ggplot2::ggplot(dat, ggplot2::aes(x = reorder(value, n), y = n)) + ggplot2::geom_col(na.rm = TRUE) + ggplot2::coord_flip() + ggplot2::labs(x = NULL, y = "Count", title = paste("Top levels for", input$cat_var)) + ggplot2::theme_minimal(base_size = 10)
  })

  # output$cat_table <- DT::renderDT({ DT::datatable(safe_dt_df(cat_freq()), options = list(pageLength = 15, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$cat_table <- DT::renderDT({
    make_dt(
      safe_dt_df(cat_freq()),
      pageLength = 15,
      scrollX = FALSE,
      columnDefs = list(
        list(width = "60%", targets = 0),
        list(width = "20%", targets = 1),
        list(width = "20%", targets = 2)
      )
    )
  })
  # output$raw_data <- DT::renderDT({ shiny::req(selected_df()); DT::datatable(safe_dt_df(selected_df(), max_rows = 1000), filter = "top", options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE), rownames = FALSE) })
  output$raw_data <- DT::renderDT({
    shiny::req(selected_df())
    
    make_dt(
      safe_dt_df(selected_df(), max_rows = 1000),
      pageLength = 10,
      scrollX = TRUE,
      filter = "top"
    )
  })
  
  output$download_specs <- shiny::downloadHandler(
    filename = function() paste0("data_specs_reviewer_", format(Sys.Date(), "%Y%m%d"), ".xlsx"),
    content = function(file) {
      shiny::req(specs())
      shiny::withProgress(message = "Preparing Excel specification workbook", value = 0, {
        shiny::incProgress(0.25, detail = "Collecting dataset specifications")
        current_specs <- specs()
        shiny::incProgress(0.50, detail = "Writing specification workbook and quality flags")
        write_specs_workbook(current_specs, file, lib_name = input$library_name, quality_flags = quality_flags())
        shiny::incProgress(0.25, detail = "Workbook ready")
      })
      shiny::showNotification("Specification workbook has been prepared for download.", type = "message", duration = 5)
    }
  )
}
