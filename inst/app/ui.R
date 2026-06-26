ui <- bslib::page_navbar(
  title = "Data Specs Reviewer",
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  sidebar = bslib::sidebar(
    width = 260,
    # shiny::tags$style(shiny::HTML("
    #   body, .navbar, .form-control, .selectize-input, .btn, .card, .dataTables_wrapper { font-size: 12px !important; }
    #   table.dataTable, table.dataTable th, table.dataTable td { font-size: 11px !important; }
    #   .card-header { font-size: 12px !important; font-weight: 600; }
    #   h1, h2, h3, h4, h5 { font-size: 14px !important; }
    #   .sidebar { font-size: 12px !important; }
    #   .shiny-notification { font-size: 12px !important; }
    #   .small-help { font-size: 11px; color:#666; line-height:1.25; margin-top:-6px; margin-bottom:10px; }
    # ")),
    shiny::tags$style(shiny::HTML("
      body,
      .navbar,
      .form-control,
      .selectize-input,
      .btn,
      .card,
      .dataTables_wrapper {
        font-size: 12px !important;
      }
    
      table.dataTable,
      table.dataTable th,
      table.dataTable td {
        font-size: 11px !important;
        vertical-align: top !important;
      }
    
      table.dataTable td {
        white-space: normal !important;
      }
    
      .card-header {
        font-size: 12px !important;
        font-weight: 600;
      }
    
      h1 {
        font-size: 20px !important;
      }
    
      h2 {
        font-size: 18px !important;
      }
    
      h3 {
        font-size: 16px !important;
      }
    
      h4,
      h5 {
        font-size: 14px !important;
      }
    
      .sidebar {
        font-size: 12px !important;
      }
    
      .shiny-notification {
        font-size: 12px !important;
      }
    
      .small-help {
        font-size: 11px;
        color: #666;
        line-height: 1.25;
        margin-top: -6px;
        margin-bottom: 10px;
      }
    
      .dataTables_filter {
        margin-bottom: 8px;
      }
    
      .dataTables_length {
        margin-bottom: 8px;
      }
    ")),
    shiny::fileInput("files", "Upload SAS7BDAT or Excel files", multiple = TRUE, accept = c(".sas7bdat", ".xls", ".xlsx", ".xlsm", ".xlsb", ".csv")),
    shiny::checkboxInput("all_sheets", "Read all Excel sheets", TRUE),
    shiny::uiOutput("dataset_picker"),
    shiny::numericInput("cat_threshold", "Categorical level threshold", value = 10, min = 0, step = 1),
    shiny::numericInput("high_missing_cutoff", "High missingness flag (%)", value = 20, min = 0, max = 100, step = 5),
    shiny::numericInput("high_cardinality_cutoff", "High-cardinality threshold", value = 50, min = 1, step = 5),
    shiny::textInput("index_vars", "Subject/Index variable(s)", placeholder = "e.g., USUBJID|SUBJID|SubjectID"),
    shiny::tags$div(class = "small-help", "Optional. Used to count unique subjects/records and check duplicates. Use | to enter alternatives."),
    shiny::selectInput("order", "Variable display order", choices = c("Dataset order" = "varnum", "Alphabetical" = "name"), selected = "varnum"),
    shiny::tags$div(class = "small-help", "Dataset order keeps the original column order."),
    shiny::textInput("library_name", "Library name in output", value = "MYDATA"),
    shiny::hr(),
    # shiny::tags$div(style = "font-size:11px; line-height:1.25; color:#555;", shiny::tags$b("Credits"), shiny::tags$br(), "Original SAS programmer: Meyers, Jeffrey", shiny::tags$br(), "Shiny app author: Prasanth V.P", shiny::tags$br(), "Email: ", shiny::tags$a(href = "mailto:prasanth.stat@gmail.com", "prasanth.stat@gmail.com")),
    shiny::tags$div(
      style = "font-size:11px; line-height:1.25; color:#555;",
      
      shiny::strong("Data Specs Reviewer"),
      shiny::tags$br(),
      
      "Prasanth V.P.",
      shiny::tags$br(),
      
      shiny::tags$a(
        href = "mailto:prasanth.stat@gmail.com",
        "prasanth.stat@gmail.com"
      )
    ),
    shiny::hr(),
    shiny::downloadButton("download_specs", "Generate Specification Workbook", class = "btn-primary")
  ),
  bslib::nav_panel("Library Summary", bslib::layout_columns(bslib::card(bslib::card_header("Datasets in uploaded library"), DT::DTOutput("lib_summary")), bslib::card(bslib::card_header("Variables present in multiple datasets"), DT::DTOutput("var_summary")), col_widths = c(12, 12))),
  bslib::nav_panel("Dataset Specs", bslib::card(bslib::card_header(shiny::textOutput("spec_title")), DT::DTOutput("dataset_specs"))),
  bslib::nav_panel("Data Quality Flags", bslib::layout_columns(bslib::card(bslib::card_header("Flag summary"), DT::DTOutput("quality_summary")), bslib::card(bslib::card_header("Detailed flags"), DT::DTOutput("quality_flags")), col_widths = c(12, 12))),
  bslib::nav_panel("Missingness Review", bslib::layout_columns(bslib::card(bslib::card_header("Missingness by variable"), shiny::plotOutput("missing_plot", height = 420)), bslib::card(bslib::card_header("Missingness table"), DT::DTOutput("missing_table")), col_widths = c(7, 5))),
  bslib::nav_panel("Numeric Review", bslib::layout_columns(bslib::card(bslib::card_header("Numeric summary and outlier flags"), DT::DTOutput("numeric_table")), bslib::card(bslib::card_header("Distribution plot"), shiny::uiOutput("numeric_var_ui"), shiny::plotOutput("numeric_plot", height = 380)), col_widths = c(7, 5))),
  bslib::nav_panel("Categorical Review", bslib::card(bslib::card_header("Frequency review"), shiny::uiOutput("cat_var_ui"), shiny::plotOutput("cat_plot", height = 420), DT::DTOutput("cat_table"))),
  bslib::nav_panel("Raw Data", bslib::card(bslib::card_header("Preview selected dataset"), DT::DTOutput("raw_data"))),
  # bslib::nav_panel("Help", bslib::card(bslib::card_header("Data Specs Reviewer: Features & Functionality"), shiny::tags$ul(shiny::tags$li("Generate dataset specification workbooks from SAS, Excel, XLSB, and CSV files."), shiny::tags$li("Automatically detect comma-, semicolon-, and tab-delimited files."), shiny::tags$li("Review variable metadata including labels, types, lengths, formats, and values."), shiny::tags$li("Create specification sheets with workbook navigation and hyperlinks."), shiny::tags$li("Identify data quality issues such as missing values, duplicate IDs, sentinel values, and potential outliers."), shiny::tags$li("Summarize variables shared across multiple datasets."), shiny::tags$li("Assess subject/index uniqueness and duplicate records."), shiny::tags$li("Review numeric and categorical variable distributions."), shiny::tags$li("Explore uploaded datasets interactively."), shiny::tags$li("Export study documentation in Excel format.")), shiny::tags$hr(), shiny::tags$p(shiny::tags$b("Credits")), shiny::tags$p("Original SAS macro programmer: Meyers, Jeffrey."), shiny::tags$p("Shiny app author: Prasanth V.P; email: ", shiny::tags$a(href = "mailto:prasanth.stat@gmail.com", "prasanth.stat@gmail.com"))))
  # bslib::nav_panel(
  #   "Help",
  #   
  #   bslib::layout_columns(
  #     
  #     bslib::card(
  #       bslib::card_header("Data Specs Reviewer: Features & Functionality"),
  #       
  #       shiny::tags$ul(
  #         shiny::tags$li("Generate dataset specification workbooks from SAS, Excel, XLSB, and CSV files."),
  #         shiny::tags$li("Automatically detect comma-, semicolon-, and tab-delimited files."),
  #         shiny::tags$li("Review variable metadata including labels, types, lengths, formats, and values."),
  #         shiny::tags$li("Create specification sheets with workbook navigation and hyperlinks."),
  #         shiny::tags$li("Identify data quality issues such as missing values, duplicate IDs, sentinel values, and potential outliers."),
  #         shiny::tags$li("Summarize variables shared across multiple datasets."),
  #         shiny::tags$li("Assess subject/index uniqueness and duplicate records."),
  #         shiny::tags$li("Review numeric and categorical variable distributions."),
  #         shiny::tags$li("Explore uploaded datasets interactively."),
  #         shiny::tags$li("Export study documentation in Excel format.")
  #       )
  #     ),
  #     
  #     bslib::card(
  #       bslib::card_header("How to Interpret Data Quality Flags"),
  #       
  #       shiny::h4("Missingness"),
  #       
  #       shiny::p(
  #         shiny::strong("Plain-language meaning: "),
  #         "Missingness means that a variable has blank, unavailable, or unrecorded values."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Example: "),
  #         "If AGE is available for 80 out of 100 subjects, then 20 subjects are missing AGE, so the missingness is 20%."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Why it matters: "),
  #         "High missingness may reduce the usefulness of a variable, affect analysis quality, or indicate incomplete data collection."
  #       ),
  #       
  #       shiny::tags$ul(
  #         shiny::tags$li("Low missingness may be acceptable depending on the variable."),
  #         shiny::tags$li("High missingness should be reviewed, especially for variables expected to be collected for most subjects."),
  #         shiny::tags$li("Some missingness may be expected for optional or conditional fields.")
  #       ),
  #       
  #       shiny::hr(),
  #       
  #       shiny::h4("Cardinality"),
  #       
  #       shiny::p(
  #         shiny::strong("Plain-language meaning: "),
  #         "Cardinality is the number of distinct values in a variable."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Low-cardinality example: "),
  #         "A variable such as SEX may contain only a few values, such as M and F."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("High-cardinality example: "),
  #         "A variable such as SUBJECT_ID may have a different value for every subject."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Why it matters: "),
  #         "Very low cardinality may indicate a constant or near-constant variable. Very high cardinality may indicate identifiers, free-text fields, or values that may require standardization."
  #       ),
  #       
  #       shiny::tags$ul(
  #         shiny::tags$li("Constant variables may add little analytical value."),
  #         shiny::tags$li("High-cardinality character variables may represent IDs, names, comments, or uncontrolled text."),
  #         shiny::tags$li("Cardinality flags are usually review prompts rather than definite errors.")
  #       ),
  #       
  #       shiny::hr(),
  #       
  #       shiny::h4("Sentinel Values"),
  #       
  #       shiny::p(
  #         shiny::strong("Plain-language meaning: "),
  #         "Sentinel values are special placeholder values used instead of true missing values."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Examples: "),
  #         "9999, 7777, UNKNOWN, UNK, 07/07/7777, or 09/09/9999."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Why it matters: "),
  #         "These values may represent unknown, not applicable, or missing information. If they are treated as real values, they can distort summaries and analyses."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Simple example: "),
  #         "If AGE contains 34, 45, 52, and 9999, the value 9999 should not be treated as a real age."
  #       ),
  #       
  #       shiny::tags$ul(
  #         shiny::tags$li("Sentinel values are not always errors."),
  #         shiny::tags$li("They should be reviewed before analysis."),
  #         shiny::tags$li("They may need to be recoded as missing or handled according to study rules.")
  #       ),
  #       
  #       shiny::hr(),
  #       
  #       shiny::h4("Numeric Review and Outliers"),
  #       
  #       shiny::p(
  #         shiny::strong("Plain-language meaning: "),
  #         "Numeric review summarizes numeric variables and highlights unusually high or low values."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Example: "),
  #         "If weight values are 55, 58, 62, 60, and 590, the value 590 may be an outlier."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Why it matters: "),
  #         "Outliers may indicate data entry errors, unit conversion issues, or genuine extreme observations."
  #       ),
  #       
  #       shiny::tags$ul(
  #         shiny::tags$li("Outliers should be reviewed, not automatically removed."),
  #         shiny::tags$li("Clinical or study context is needed before deciding whether a value is invalid."),
  #         shiny::tags$li("The app flags potential outliers to support review and traceability.")
  #       ),
  #       
  #       shiny::hr(),
  #       
  #       shiny::h4("Duplicate Index Values"),
  #       
  #       shiny::p(
  #         shiny::strong("Plain-language meaning: "),
  #         "Duplicate index values occur when the same subject or record identifier appears more than expected."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Example: "),
  #         "If the index variable is SUBJECT_ID and subject 1001 appears twice in a dataset expected to have one row per subject, the app flags this for review."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Why it matters: "),
  #         "Duplicates may lead to double counting, incorrect summaries, or analysis errors."
  #       )
  #     ),
  #     
  #     bslib::card(
  #       bslib::card_header("Why Some Outputs Are Listings"),
  #       
  #       shiny::p(
  #         "Some data are more useful as listings rather than summary tables. Listings preserve subject-level detail and allow reviewers to inspect individual records directly."
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("When listings are appropriate: ")
  #       ),
  #       
  #       shiny::tags$ul(
  #         shiny::tags$li("The variable is not part of a primary or secondary endpoint."),
  #         shiny::tags$li("No formal statistical summary or inference is planned."),
  #         shiny::tags$li("Subject-level traceability is more important than aggregate interpretation."),
  #         shiny::tags$li("Summary tables would add programming and QC effort without adding meaningful interpretive value."),
  #         shiny::tags$li("The data are mainly needed for review, reconciliation, or transparency.")
  #       ),
  #       
  #       shiny::p(
  #         shiny::strong("Example: "),
  #         "If laboratory data are not linked to study endpoints and are not expected to drive study conclusions, listings may be sufficient. Listings retain complete subject-level visibility while avoiding unnecessary summary tables."
  #       )
  #     ),
  #     
  #     bslib::card(
  #       bslib::card_header("Credits"),
  #       
  #       shiny::p(shiny::strong("Original SAS macro programmer")),
  #       shiny::p("Meyers, Jeffrey."),
  #       
  #       shiny::p(shiny::strong("Shiny app and R package author")),
  #       shiny::p(
  #         "Prasanth V.P.; email: ",
  #         shiny::tags$a(
  #           href = "mailto:prasanth.stat@gmail.com",
  #           "prasanth.stat@gmail.com"
  #         )
  #       )
  #     ),
  #     
  #     col_widths = c(12, 12, 12, 12)
  #   )
  # )
  bslib::nav_panel(
    "Help",
    
    shiny::tabsetPanel(
      type = "tabs",
      
      shiny::tabPanel(
        "Overview",
        
        bslib::card(
          bslib::card_header("Data Specs Reviewer: Features & Functionality"),
          
          shiny::p(
            "Data Specs Reviewer helps users review dataset structure, variable-level metadata, data completeness, and potential data quality issues before analysis."
          ),
          
          shiny::tags$ul(
            shiny::tags$li("Generate dataset specification workbooks from SAS, Excel, XLSB, and CSV files."),
            shiny::tags$li("Automatically detect comma-, semicolon-, and tab-delimited files."),
            shiny::tags$li("Review variable metadata including labels, types, lengths, formats, and values."),
            shiny::tags$li("Create specification sheets with workbook navigation and hyperlinks."),
            shiny::tags$li("Identify data quality issues such as missing values, duplicate IDs, sentinel values, and potential outliers."),
            shiny::tags$li("Summarize variables shared across multiple datasets."),
            shiny::tags$li("Assess subject/index uniqueness and duplicate records."),
            shiny::tags$li("Review numeric and categorical variable distributions."),
            shiny::tags$li("Explore uploaded datasets interactively."),
            shiny::tags$li("Export study documentation in Excel format.")
          ),
          
          shiny::hr(),
          
          shiny::h4("Glossary"),
          
          DT::datatable(
            data.frame(
              Term = c(
                "Dataset Specification",
                "Metadata",
                "Missingness",
                "Cardinality",
                "Sentinel Value",
                "Numeric Review",
                "Outlier",
                "Duplicate Record",
                "Index Variable",
                "Quality Flag"
              ),
              Definition = c(
                "A structured summary describing datasets, variables, labels, formats, values, and related metadata.",
                "Information that describes the structure and characteristics of data, such as variable names, types, labels, lengths, and formats.",
                "The proportion or count of records where a value is unavailable, blank, or missing.",
                "The number of distinct values present within a variable.",
                "A placeholder value used to represent missing, unknown, not applicable, or invalid information.",
                "A review of numeric variables using summary statistics and potential outlier detection.",
                "An unusually high or low numeric value compared with the rest of the data.",
                "A repeated record or repeated key value where uniqueness is expected.",
                "A variable used to identify a subject, patient, record, or analysis unit.",
                "An automated finding generated by the application to highlight a potential data review issue."
              ),
              Example = c(
                "Dataset DM contains 250 records and 35 variables.",
                "AGE is numeric; SEX is character; TRTSDT is a date variable.",
                "20 missing values out of 100 records = 20% missingness.",
                "SEX has 2 distinct values: M and F.",
                "9999, 7777, UNKNOWN, UNK, 09/09/9999.",
                "Mean, median, minimum, maximum, and outlier counts.",
                "Weight values: 55, 58, 60, 590; 590 may need review.",
                "SUBJID 1001 appears twice where one record is expected.",
                "USUBJID, SUBJID, SubjectID.",
                "High missingness, duplicate index, sentinel value detected."
              ),
              stringsAsFactors = FALSE
            ),
            rownames = FALSE,
            options = list(
              pageLength = 10,
              scrollX = TRUE,
              dom = "t"
            )
          )
        )
      ),
      
      shiny::tabPanel(
        "Missingness",
        
        bslib::card(
          bslib::card_header("Missingness Review"),
          
          shiny::h4("What is Missingness?"),
          
          shiny::p(
            "Missingness refers to the amount of information that is unavailable for a variable. In simple terms, it tells us how many values are blank, missing, or not recorded."
          ),
          
          shiny::h4("Example"),
          
          shiny::pre(
            "Subject    Age
1001       34
1002       Missing
1003       41

Missingness for AGE = 1 missing value out of 3 records = 33.3%"
          ),
          
          shiny::h4("Why it Matters"),
          
          shiny::tags$ul(
            shiny::tags$li("High missingness may reduce the usefulness of a variable."),
            shiny::tags$li("High missingness may indicate incomplete data collection."),
            shiny::tags$li("Missing data may affect statistical summaries and interpretation."),
            shiny::tags$li("Some missingness may be expected for optional or conditional variables.")
          ),
          
          shiny::h4("How to Interpret"),
          
          shiny::tags$ul(
            shiny::tags$li("Low missingness may be acceptable depending on the variable."),
            shiny::tags$li("Moderate missingness should be reviewed."),
            shiny::tags$li("High missingness should be discussed, especially for key variables or expected fields.")
          )
        )
      ),
      
      shiny::tabPanel(
        "Cardinality",
        
        bslib::card(
          bslib::card_header("Cardinality Review"),
          
          shiny::h4("What is Cardinality?"),
          
          shiny::p(
            "Cardinality is the number of distinct or unique values present in a variable."
          ),
          
          shiny::h4("Low Cardinality Example"),
          
          shiny::pre(
            "SEX
M
F

Cardinality = 2"
          ),
          
          shiny::p(
            "This is expected for variables with a limited set of categories."
          ),
          
          shiny::h4("High Cardinality Example"),
          
          shiny::pre(
            "SUBJID
1001
1002
1003
1004
...

Cardinality may be close to the number of records."
          ),
          
          shiny::p(
            "This is expected for identifiers, but may need review for free-text or categorical variables."
          ),
          
          shiny::h4("Why it Matters"),
          
          shiny::tags$ul(
            shiny::tags$li("Very low cardinality may indicate a constant or near-constant variable."),
            shiny::tags$li("Very high cardinality may indicate identifiers, free-text fields, comments, or uncontrolled values."),
            shiny::tags$li("Cardinality flags are usually review prompts rather than definite errors."),
            shiny::tags$li("Unexpected cardinality patterns may indicate data standardization issues.")
          )
        )
      ),
      
      shiny::tabPanel(
        "Sentinel Values",
        
        bslib::card(
          bslib::card_header("Sentinel Value Review"),
          
          shiny::h4("What are Sentinel Values?"),
          
          shiny::p(
            "Sentinel values are special placeholder values used instead of true missing values. They often represent unknown, not applicable, unavailable, or invalid information."
          ),
          
          shiny::h4("Examples"),
          
          shiny::pre(
            "9999
7777
UNKNOWN
UNK
NA
07/07/7777
09/09/9999"
          ),
          
          shiny::h4("Simple Example"),
          
          shiny::pre(
            "AGE
34
45
52
9999

The value 9999 should not be interpreted as a real age."
          ),
          
          shiny::h4("Why it Matters"),
          
          shiny::tags$ul(
            shiny::tags$li("Sentinel values may distort summaries if treated as real values."),
            shiny::tags$li("They may need to be recoded as missing before analysis."),
            shiny::tags$li("They may be valid according to the source system but still require analysis handling."),
            shiny::tags$li("Sentinel values are not always errors; they are review items.")
          )
        )
      ),
      
      shiny::tabPanel(
        "Numeric Review",
        
        bslib::card(
          bslib::card_header("Numeric Review and Outliers"),
          
          shiny::h4("What is Numeric Review?"),
          
          shiny::p(
            "Numeric review summarizes numeric variables and highlights potentially unusual values. It helps reviewers understand the distribution, range, and possible outliers."
          ),
          
          shiny::h4("Common Summaries"),
          
          shiny::tags$ul(
            shiny::tags$li("Number of non-missing values"),
            shiny::tags$li("Number of missing values"),
            shiny::tags$li("Mean"),
            shiny::tags$li("Standard deviation"),
            shiny::tags$li("Median"),
            shiny::tags$li("Minimum and maximum"),
            shiny::tags$li("Potential outlier count")
          ),
          
          shiny::h4("Example"),
          
          shiny::pre(
            "Weight
55
58
60
62
590

Potential outlier = 590"
          ),
          
          shiny::h4("Why it Matters"),
          
          shiny::tags$ul(
            shiny::tags$li("Outliers may indicate data entry errors."),
            shiny::tags$li("Outliers may indicate unit conversion issues."),
            shiny::tags$li("Outliers may also be genuine values and should not be automatically removed."),
            shiny::tags$li("Clinical or study context is needed before deciding whether a value is invalid.")
          )
        )
      ),
      
      shiny::tabPanel(
        "Duplicate Records",
        
        bslib::card(
          bslib::card_header("Duplicate Index Review"),
          
          shiny::h4("What are Duplicate Records?"),
          
          shiny::p(
            "Duplicate records occur when the same subject, patient, record, or index value appears more often than expected."
          ),
          
          shiny::h4("Example"),
          
          shiny::pre(
            "SUBJID    VISIT
1001      Screening
1001      Screening"
          ),
          
          shiny::p(
            "If one row is expected per subject and visit, this duplicate should be reviewed."
          ),
          
          shiny::h4("Why it Matters"),
          
          shiny::tags$ul(
            shiny::tags$li("Duplicates may cause double counting."),
            shiny::tags$li("Duplicates may inflate sample sizes or event counts."),
            shiny::tags$li("Duplicates may indicate data extraction, merging, or source-system issues."),
            shiny::tags$li("Some repeated records may be expected depending on the dataset structure.")
          ),
          
          shiny::h4("Important Note"),
          
          shiny::p(
            "Duplicate review depends on the index variables provided by the user. If no subject or index variable is specified, duplicate review may be limited."
          )
        )
      ),
      
      shiny::tabPanel(
        "Credits",
        
        bslib::card(
          bslib::card_header("Credits"),
          
          shiny::h4("Acknowledgement"),
          
          shiny::p(
            "Data Specs Reviewer was inspired by the SAS-based data specification review approach developed by Jeffrey Meyers."
          ),
          
          shiny::p(
            "The original concept was extended into an interactive R package and Shiny application with additional data quality review capabilities, including missingness assessment, quality flagging, and dataset profiling."
          ),
          
          shiny::hr(),
          
          shiny::h4("Developer"),
          
          shiny::p(
            shiny::strong("Prasanth V.P.")
          ),
          
          shiny::p(
            "Email: ",
            shiny::tags$a(
              href = "mailto:prasanth.stat@gmail.com",
              "prasanth.stat@gmail.com"
            )
          )
        )
        
      )
    )
  )  
)
