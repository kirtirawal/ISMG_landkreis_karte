mod_main_ui <- function(id) {
  ns <- NS(id)
  
  variable_choices <- if (exists("Daten_long") && !is.null(Daten_long)) {
    unique(Daten_long$variable)
  } else {
    c("Keine Daten verfügbar")
  }
  
  tagList(
    
    # Mobile keyboard fix + select touch improvements
    tags$style(HTML("
      /* Prevent iOS zoom on select focus */
      select, .selectize-input input {
        font-size: 16px !important;
        -webkit-user-select: none;
        user-select: none;
        touch-action: manipulation;
      }
      /* Ensure girafe tooltips appear above everything on mobile */
      .girafe_container_std {
        position: relative;
        z-index: 1;
      }
      div.tooltip_svg {
        z-index: 9999 !important;
        pointer-events: none !important;
      }
    ")),
    
    tags$script(HTML(sprintf("
      // Keyboard fix: set inputmode=none on all selects after Shiny renders
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
        
        # --- Kopfzeile ---
        fluidRow(
          column(width = 12,
                 div(class = "main-header-border mb-3",
                     tags$h2(class = "dashboard-title", "LANDKREIS HEALTH TRACKER"),
                     tags$p(class = "dashboard-subtitle",
                            "Visualisierung klinischer Daten - Global Research Style")
                 )
          )
        ),
        
        # --- Steuerung ---
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
                                                            choices = c("Klinisches Rot"   = "inferno",
                                                                        "Medizinisches Blau" = "mako"),
                                                            selected = "inferno", width = "100%")
                                         )
                                )
                            )
                        )
                 )
        ),
        
        # --- Visualisierungen ---
        fluidRow(class = "g-3",
                 column(width = 7,
                        div(class = "jh-panel card h-100",
                            div(class = "card-body",
                                div(class = "panel-title", "GEOGRAFISCHE VERTEILUNG"),
                                # Mobile hint
                                tags$p(
                                  class = "text-muted mb-1",
                                  style = "font-size:0.75rem;",
                                  "\U0001f4f1 Auf Mobilger\u00e4ten: Kreis antippen \u2014 Wert erscheint als Karte"
                                ),
                                girafeOutput(ns("map_plot"), width = "100%", height = "600px")
                            )
                        )
                 ),
                 column(width = 5,
                        div(class = "jh-panel card h-100",
                            div(class = "card-body",
                                div(class = "panel-title", "ZEITREIHEN-ANALYSE"),
                                tags$p(
                                  class = "text-muted mb-1",
                                  style = "font-size:0.75rem;",
                                  "\U0001f4f1 Balken antippen f\u00fcr Jahreswert"
                                ),
                                girafeOutput(ns("bar_plot"), width = "100%", height = "600px")
                            )
                        )
                 )
        )
    )
  )
}