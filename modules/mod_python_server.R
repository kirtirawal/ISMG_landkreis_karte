mod_python_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Convert R dataframe to Python pandas dataframe once
    # We check if laekosa_data exists in the global environment
    py_df <- reactive({
      req(exists("laekosa_data", envir = .GlobalEnv))
      
      data <- get("laekosa_data", envir = .GlobalEnv)
      
      req(is.data.frame(data))
      req(nrow(data) > 0)
      
      reticulate::r_to_py(data, convert = TRUE)
    })
    
    # Helper to execute Python plotting functions
    render_python_plot <- function(plot_fn) {
      renderUI({
        tryCatch({
          # Pass the python object directly instead of a file path
          html_content <- plot_fn(py_df()) 
          HTML(html_content)
        }, error = function(e) {
          div(
            class = "alert alert-danger m-3",
            sprintf("Error executing Python plot: %s <br> Check column names in python/plots.py", e$message)
          )
        })
      })
    }
    
    # Bind outputs to Python functions
    output$plot_age_gender <- renderUI({
      
      html_content <- get_age_distribution_plot(py_df())
      
      cat(substr(html_content, 1, 300))
      
      HTML(html_content)
      
    })
    output$plot_utilization <- render_python_plot(get_healthcare_utilization_plot)
    output$plot_phq9        <- render_python_plot(get_mental_health_plot)
    output$plot_clustering  <- render_python_plot(get_ml_clustering_plot)
    output$plot_importance  <- render_python_plot(get_ml_feature_importance_plot)
  })
}