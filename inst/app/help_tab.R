help_tab <- shiny::tabPanel(
  
  "Help",
  
  shiny::fluidPage(
    
    shiny::h2("Data Review Guidance"),
    
    shiny::hr(),
    
    shiny::h3("Missingness Review"),
    
    shiny::p(
      "Missingness measures the proportion of records where a value is unavailable."
    ),
    
    shiny::tags$ul(
      shiny::tags$li("<5%: Usually acceptable"),
      shiny::tags$li("5%-20%: Review recommended"),
      shiny::tags$li(">20%: Potential concern")
    ),
    
    shiny::pre(
      "Example

Subject   Age
1001      34
1002      NA
1003      41

Missingness = 1/3 = 33.3%"
    ),
    
    shiny::hr(),
    
    shiny::h3("Cardinality Review"),
    
    shiny::p(
      "Cardinality is the number of distinct values within a variable."
    ),
    
    shiny::pre(
      "SEX
M
F

Cardinality = 2"
    ),
    
    shiny::p(
      "Unexpectedly high cardinality may indicate free-text entry issues, typographical variations, or standardization problems."
    ),
    
    shiny::hr(),
    
    shiny::h3("Sentinel Value Review"),
    
    shiny::p(
      "Sentinel values are placeholders used instead of missing data."
    ),
    
    shiny::pre(
      "Examples

999
9999
-999
01JAN1900
31DEC9999
Unknown
N/A"
    ),
    
    shiny::p(
      "Review sentinel values carefully because they may be incorrectly interpreted as valid data."
    ),
    
    shiny::hr(),
    
    shiny::h3("Numeric Review"),
    
    shiny::p(
      "Numeric review examines distributions and potential outliers."
    ),
    
    shiny::pre(
      "55
58
61
57
590

Potential outlier: 590"
    ),
    
    shiny::hr(),
    
    shiny::h3("Duplicate Review"),
    
    shiny::pre(
      "SUBJID VISIT
1001   Screening
1001   Screening"
    ),
    
    shiny::p(
      "Duplicate records can lead to incorrect counts and analysis results."
    )
    
  )
)