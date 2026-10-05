# modules/mod_python_ui.R
# User-friendly UI with filters, tabs, and clear navigation

mod_python_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    tags$head(
      tags$script(src = "https://cdn.plot.ly/plotly-2.35.2.min.js"),
      tags$style(HTML("
        .plot-container { min-height: 500px; background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important; color: white !important; }
        .insight-box { background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%); border-left: 4px solid #0284c7; padding: 15px; margin: 10px 0; border-radius: 8px; }
        .filter-section { background: #f8fafc; padding: 20px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #e2e8f0; }
        .nav-tabs .nav-link { color: #475569; border: none; padding: 12px 20px; font-weight: 500; }
        .nav-tabs .nav-link.active { color: #667eea; border-bottom: 3px solid #667eea; }
        .section-icon { font-size: 20px; margin-right: 8px; }
        .help-text { color: #64748b; font-size: 13px; font-style: italic; margin-top: 5px; }
      "))
    ),
    
    div(
      class = "container-fluid py-4",
      
      # Header with clear purpose
      div(
        class = "text-center mb-4",
        h1(class = "fw-bold", style = "color: #1e293b; font-size: 32px;",
           tags$span(class = "section-icon", "📊"),
           "Health Data Insights"
        ),
        p(class = "lead", style = "color: #64748b; max-width: 800px; margin: 10px auto;",
          "Explore patient health data through interactive visualizations. Select filters below and navigate through different analysis categories."
        )
      ),
      
      # ========== FILTER SECTION ==========
      div(
        class = "filter-section",
        h4(class = "fw-bold mb-3", style = "color: #334155;",
           tags$span("🔍"), " Filter the Data"
        ),
        p(class = "help-text", "Apply filters to focus on specific patient groups. All visualizations will update automatically."),
        
        bslib::layout_columns(
          col_widths = c(3, 3, 3, 3),
          
          # Age Filter
          bslib::card(
            class = "border-0",
            bslib::card_header(class = "fw-bold", "Age Group"),
            bslib::card_body(
              selectInput(
                ns("filter_age"),
                label = NULL,
                choices = list(
                  "All Ages" = "all",
                  "0-17 (Youth)" = "0-17",
                  "18-29 (Young Adult)" = "18-29",
                  "30-44 (Adult)" = "30-44",
                  "45-59 (Middle Age)" = "45-59",
                  "60-74 (Senior)" = "60-74",
                  "75+ (Elderly)" = "75+"
                ),
                selected = "all",
                selectize = TRUE
              )
            )
          ),
          
          # Gender Filter
          bslib::card(
            class = "border-0",
            bslib::card_header(class = "fw-bold", "Gender"),
            bslib::card_body(
              selectInput(
                ns("filter_gender"),
                label = NULL,
                choices = list(
                  "All" = "all",
                  "Male" = "male",
                  "Female" = "female"
                ),
                selected = "all",
                selectize = TRUE
              )
            )
          ),
          
          # View Mode
          bslib::card(
            class = "border-0",
            bslib::card_header(class = "fw-bold", "Display Options"),
            bslib::card_body(
              radioButtons(
                ns("view_mode"),
                label = NULL,
                choices = list(
                  "Charts Only" = "charts",
                  "Charts + Insights" = "both"
                ),
                selected = "both",
                inline = TRUE
              )
            )
          ),
          
          # Reset Button
          bslib::card(
            class = "border-0",
            bslib::card_header(class = "fw-bold", "Actions"),
            bslib::card_body(
              actionButton(
                ns("reset_filters"),
                label = tags$div(tags$span("🔄"), "Reset All"),
                class = "btn-outline-secondary w-100",
                style = "margin-top: 8px;"
              )
            )
          )
        )
      ),
      
      # ========== TAB NAVIGATION ==========
      bslib::navset_tab(
        id = ns("main_tabs"),
        
        # TAB 1: Overview
        bslib::nav_panel(
          title = tags$div(tags$span("📋"), " Overview"),
          value = "overview",
          
          div(class = "mt-4",
            h3(class = "fw-bold mb-3", "Patient Overview"),
            p(class = "help-text mb-4", "Start here to understand your patient population demographics and overall health status."),
            
            bslib::layout_columns(
              col_widths = c(6, 6),
              
              # Age Distribution
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold", 
                  tags$span("👥"), " Age & Gender Distribution"
                ),
                bslib::card_body(
                  uiOutput(ns("plot_age_gender"), class = "plot-container")
                )
              ),
              
              # Overall Health Score
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("❤️"), " Overall Health Score"
                ),
                bslib::card_body(
                  uiOutput(ns("plot_health_score"), class = "plot-container")
                )
              )
            )
          )
        ),
        
        # TAB 2: Mental Health
        bslib::nav_panel(
          title = tags$div(tags$span("🧠"), " Mental Health"),
          value = "mental_health",
          
          div(class = "mt-4",
            h3(class = "fw-bold mb-3", "Mental Health & Wellbeing"),
            p(class = "help-text mb-4", "Understand depression screening results and therapy usage patterns in the patient population."),
            
            bslib::layout_columns(
              col_widths = c(6, 6),
              
              # PHQ-9 Depression
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("📊"), " Depression Screening (PHQ-9)"
                ),
                bslib::card_body(
                  p(class = "help-text", "Shows distribution of depression severity. Scores ≥10 indicate clinically significant symptoms."),
                  uiOutput(ns("plot_phq9"), class = "plot-container")
                )
              ),
              
              # Therapy Usage
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("💊"), " Therapy Services Usage"
                ),
                bslib::card_body(
                  p(class = "help-text", "Shows which types of therapy patients are receiving."),
                  uiOutput(ns("plot_therapy"), class = "plot-container")
                )
              )
            )
          )
        ),
        
        # TAB 3: Healthcare
        bslib::nav_panel(
          title = tags$div(tags$span("🏥"), " Healthcare"),
          value = "healthcare",
          
          div(class = "mt-4",
            h3(class = "fw-bold mb-3", "Healthcare Utilization & Satisfaction"),
            p(class = "help-text mb-4", "See how patients use healthcare services and rate their satisfaction with care."),
            
            bslib::layout_columns(
              col_widths = c(12),
              
              # Satisfaction
              bslib::card(
                class = "shadow-sm mb-4",
                bslib::card_header(class = "fw-bold",
                  tags$span("😊"), " Patient Satisfaction"
                ),
                bslib::card_body(
                  p(class = "help-text", "Ratings from 1 (poor) to 5 (excellent). Higher bars indicate better satisfaction."),
                  uiOutput(ns("plot_satisfaction"), class = "plot-container")
                )
              )
            ),
            
            bslib::layout_columns(
              col_widths = c(6, 6),
              
              # Utilization Bar
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("📈"), " Visits by Department"
                ),
                bslib::card_body(
                  p(class = "help-text", "Average number of visits per patient to different medical departments."),
                  uiOutput(ns("plot_utilization"), class = "plot-container")
                )
              ),
              
              # Heatmap
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("🔥"), " Utilization by Age Group"
                ),
                bslib::card_body(
                  p(class = "help-text", "Heatmap showing which departments are most used by each age group. Darker = more visits."),
                  uiOutput(ns("plot_utilization_heatmap"), class = "plot-container")
                )
              )
            )
          )
        ),
        
        # TAB 4: Prevention
        bslib::nav_panel(
          title = tags$div(tags$span("🛡️"), " Prevention"),
          value = "prevention",
          
          div(class = "mt-4",
            h3(class = "fw-bold mb-3", "Preventive Care"),
            p(class = "help-text mb-4", "Track uptake of preventive services like checkups and cancer screenings. Higher percentages are better."),
            
            bslib::layout_columns(
              col_widths = c(12),
              
              # Preventive Care
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("✅"), " Preventive Services Uptake"
                ),
                bslib::card_body(
                  p(class = "help-text", "Percentage of patients receiving each preventive service. Target: 70% or higher."),
                  uiOutput(ns("plot_preventive"), class = "plot-container")
                )
              )
            )
          )
        ),
        
        # TAB 5: Insights (ML)
        bslib::nav_panel(
          title = tags$div(tags$span("🤖"), " AI Insights"),
          value = "ml_insights",
          
          div(class = "mt-4",
            h3(class = "fw-bold mb-3", "Machine Learning Insights"),
            p(class = "help-text mb-4", "Discover hidden patterns in the data using AI-powered analysis."),
            
            bslib::layout_columns(
              col_widths = c(6, 6),
              
              # Clustering
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("🔮"), " Patient Groups (Auto-Discovered)"
                ),
                bslib::card_body(
                  p(class = "help-text", "AI automatically groups similar patients together. Each color represents a distinct patient type."),
                  uiOutput(ns("plot_clustering"), class = "plot-container")
                )
              ),
              
              # Feature Importance
              bslib::card(
                class = "shadow-sm",
                bslib::card_header(class = "fw-bold",
                  tags$span("🎯"), " What Drives Health Status?"
                ),
                bslib::card_body(
                  p(class = "help-text", "Shows which factors (age, weight, visits) most strongly predict self-reported health."),
                  uiOutput(ns("plot_importance"), class = "plot-container")
                )
              )
            )
          )
        )
      ),
      
      # ========== FOOTER ==========
      div(
        class = "text-center mt-5 py-4",
        hr(),
        p(class = "text-muted",
          "💡 ", tags$i("Tip: Use the filters at the top to focus on specific patient groups. Click on charts to interact."),
          tags$br(),
          "For detailed documentation, see ", tags$code("python/VISUALIZATIONS_GUIDE.md")
        )
      )
    )
  )
}
