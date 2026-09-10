# modules/mod_python_ui.R

mod_python_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    tags$head(
      tags$script(
        src = "https://cdn.plot.ly/plotly-2.35.2.min.js"
      )
    ),
    
    div(
      class = "container-fluid py-2",
      div(
        class = "main-header-border mb-4",
        h3(class = "dashboard-title fw-bold", "Python Machine Learning & Analytics"),
        p(class = "dashboard-subtitle", "Interactive Python-rendered visualizations for patient cohort analytics and ML phenotyping.")
      ),
      
      # Descriptive Analytics Row
      div(class = "panel-title mt-2 mb-3", "Descriptive Cohort Analytics"),
      bslib::layout_column_wrap(
        width = 1/2,
        bslib::card(
          class = "jh-panel card mb-3",
          bslib::card_header(class = "fw-bold", "Age & Gender Distribution"),
          uiOutput(ns("plot_age_gender"))
        ),
        bslib::card(
          class = "jh-panel card mb-3",
          bslib::card_header(class = "fw-bold", "Healthcare Utilization by Department"),
          uiOutput(ns("plot_utilization"))
        )
      ),
      
      hr(class = "section-divider my-4"),
      
      # Machine Learning & Mental Health Analytics Row
      div(class = "panel-title mt-2 mb-3", "Mental Health & Patient Phenotyping (ML)"),
      bslib::layout_column_wrap(
        width = 1/3,
        bslib::card(
          class = "jh-panel card mb-3",
          bslib::card_header(class = "fw-bold", "PHQ-9 Composite Score"),
          uiOutput(ns("plot_phq9"))
        ),
        bslib::card(
          class = "jh-panel card mb-3",
          bslib::card_header(class = "fw-bold", "Patient Phenotypes (PCA & K-Means)"),
          uiOutput(ns("plot_clustering"))
        ),
        bslib::card(
          class = "jh-panel card mb-3",
          bslib::card_header(class = "fw-bold", "Random Forest Feature Importance"),
          uiOutput(ns("plot_importance"))
        )
      )
    )
  )
}