mod_main_ui <- function(id) {
  ns <- NS(id)
  
  variable_choices <- if (exists("Daten_long") && !is.null(Daten_long)) {
    unique(Daten_long$variable)
  } else {
    c("Keine Daten verfügbar")
  }
  
  year_choices <- as.character(2006:2023)
  
  tagList(
    
    # Mobile keyboard fix + tooltip z-index
    tags$style(HTML("
      select, .selectize-input input {
        font-size: 16px !important;
        -webkit-user-select: none;
        user-select: none;
        touch-action: manipulation;
      }
      .girafe_container_std {
        position: relative;
        z-index: 1;
      }
      div.tooltip_svg {
        z-index: 9999 !important;
        pointer-events: none !important;
      }
      .ns-panel-title {
        font-size: 0.72rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.06em; color: #667788; margin-bottom: 4px;
      }
      .ns-legend {
        display: flex; gap: 16px; align-items: center;
        font-size: 0.78rem; color: #667788; margin-bottom: 6px;
      }
      .ns-legend-dot {
        width: 12px; height: 12px; border-radius: 50%; display: inline-block;
        margin-right: 4px; flex-shrink: 0;
      }
    ")),
    
    tags$script(HTML(sprintf("
      function fixMainSelects() {
        document.querySelectorAll('#%s select').forEach(function(el) {
          el.setAttribute('inputmode', 'none');
          el.setAttribute('autocomplete', 'off');
        });
      }
      document.addEventListener('DOMContentLoaded', fixMainSelects);
      $(document).on('shiny:connected shiny:value', fixMainSelects);
      setTimeout(fixMainSelects, 500);
      setTimeout(fixMainSelects, 1500);
    ", ns("")))),
    
    div(class = "dashboard-container p-3",
        
        # --- Header ---
        fluidRow(
          column(width = 12,
                 div(class = "main-header-border mb-3",
                     tags$h2(class = "dashboard-title", "LANDKREIS HEALTH TRACKER"),
                     tags$p(class = "dashboard-subtitle",
                            "Visualisierung klinischer Daten - Global Research Style")
                 )
          )
        ),
        
        # --- Controls ---
        fluidRow(class = "mb-3",
                 column(width = 12,
                        div(class = "jh-panel card",
                            div(class = "card-body py-2",
                                fluidRow(class = "align-items-center",
                                         column(width = 4,
                                                div(class = "panel-title mb-1", "PARAMETER WÄHLEN"),
                                                selectInput(ns("selected_param"), NULL,
                                                            choices = variable_choices, width = "100%")
                                         ),
                                         column(width = 3,
                                                div(class = "panel-title mb-1", "FARBSCHEMA"),
                                                selectInput(ns("color_palette"), NULL,
                                                            choices = c("Klinisches Rot"    = "inferno",
                                                                        "Medizinisches Blau" = "mako"),
                                                            selected = "inferno", width = "100%")
                                         ),
                                         column(width = 3,
                                                div(class = "panel-title mb-1", "JAHR (N-S CHART)"),
                                                selectInput(ns("selected_year"), NULL,
                                                            choices  = year_choices,
                                                            selected = "2023",
                                                            width    = "100%")
                                         )
                                )
                            )
                        )
                 )
        ),
        
        # --- Row 1: Map + Time-series bar ---
        fluidRow(class = "g-3 mb-3",
                 column(width = 7,
                        div(class = "jh-panel card h-100",
                            div(class = "card-body",
                                div(class = "panel-title", "GEOGRAFISCHE VERTEILUNG",
                                    # Add an info icon with a title attribute for a native browser tooltip
                                    tags$span(icon("info-circle"), 
                                              title = "Diese Karte zeigt die räumliche Verteilung des gewählten Parameters über alle Landkreise hinweg. Dunklere Farben repräsentieren höhere Werte.",
                                              style = "cursor: help; color: #667788; margin-left: 5px;")
                                ),
                                girafeOutput(ns("map_plot"), width = "100%", height = "600px")
                            )
                        )
                 ),
                 column(width = 5,
                        div(class = "jh-panel card h-100",
                            div(class = "card-body",
                                div(class = "panel-title", "ZEITREIHEN-ANALYSE",
                                    tags$span(icon("info-circle"), 
                                              title = "Zeigt die historische Entwicklung des ausgewählten Indikators für den ausgewählten Landkreis über den Zeitraum von 2006 bis 2023.",
                                              style = "cursor: help; color: #667788; margin-left: 5px;")
                                ),
                                girafeOutput(ns("bar_plot"), width = "100%", height = "600px")
                            )
                        )
                 )
        ),
        
        
        
        # --- Row 2: North–South bar chart ---
        fluidRow(class = "g-3",
                 column(width = 12,
                        div(class = "jh-panel card",
                            div(class = "card-body",
                                div(class = "panel-title", "NORD-SÜD VERGLEICH",
                                    tags$span(icon("info-circle"), 
                                              title = "Ordnet die Landkreise geografisch von Nord nach Süd an, um latitudinale Trends im gewählten Parameter für das ausgewählte Jahr zu identifizieren.",
                                              style = "cursor: help; color: #667788; margin-left: 5px;")
                                ),
                                # Color legend
                                div(class = "ns-legend",
                                    tags$span(
                                      tags$span(class = "ns-legend-dot",
                                                style = "background:#10B981;"), # Emerald Green
                                      "Norden"
                                    ),
                                    tags$span(style = "color:#aaa;", "\u2192"),
                                    tags$span(
                                      tags$span(class = "ns-legend-dot",
                                                style = "background:#8B5CF6;"), # Deep Purple
                                      "Süden"
                                    ),
                                    tags$span(style = "color:#aaa; margin-left:8px;",
                                              "Balkenlänge = Wert des Indikators")
                                ),
                                girafeOutput(ns("ns_bar_plot"), width = "100%", height = "480px")
                            )
                        )
                 )
        )
        
    )
  )
}