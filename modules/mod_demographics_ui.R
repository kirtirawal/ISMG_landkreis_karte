# ============================================================
# Demographics UI
# ============================================================

mod_demographics_ui <- function(id) {
  ns <- NS(id)
  
  variable_choices <- if (exists("Daten_long") && !is.null(Daten_long)) {
    sort(unique(Daten_long$variable))
  } else {
    "Keine Daten verfügbar"
  }
  
  year_choices <- as.character(2006:2023)
  
  tagList(
    tags$script(HTML(sprintf("
      function fixDemographicsSelects() {
        document.querySelectorAll('#%s select').forEach(function(el) {
          el.setAttribute('inputmode', 'none');
          el.setAttribute('autocomplete', 'off');
        });
      }

      document.addEventListener('DOMContentLoaded', fixDemographicsSelects);
      $(document).on('shiny:connected shiny:value', fixDemographicsSelects);
      setTimeout(fixDemographicsSelects, 500);
      setTimeout(fixDemographicsSelects, 1500);
    ", ns("")))),
    
    div(
      id = ns("demographics_root"),
      class = "demographics-page",
      
      # ------------------------------------------------------
      # Page header
      # ------------------------------------------------------
      div(
        class = "demographics-hero",
        
        div(
          class = "demographics-hero__content",
          
          tags$span(
            class = "demographics-eyebrow",
            "GESUNDHEITS- UND BEVÖLKERUNGSMONITOR"
          ),
          
          tags$h1(
            "Demografie und Bevölkerungsentwicklung"
          ),
          
          tags$p(
            paste(
              "Interaktive Analyse von Bevölkerung, Geburten,",
              "Sterbefällen, natürlichem Saldo und Wanderungsbewegungen",
              "in den Landkreisen und kreisfreien Städten Sachsen-Anhalts."
            )
          )
        ),
        
        tags$button(
          type = "button",
          class = "demographics-home-button navigation-card",
          `data-target` = "landing",
          icon("house"),
          tags$span("Zur Startseite")
        )
      ),
      
      # ------------------------------------------------------
      # RKI-style internal navigation
      # ------------------------------------------------------
      div(
        class = "demographics-tabs",
        
        bslib::navset_tab(
          id = ns("demographics_view"),
          selected = "overview",
          
          # ====================================================
          # TAB 1: OVERVIEW / EXPLANATION
          # ====================================================
          bslib::nav_panel(
            title = tagList(icon("circle-info"), "Überblick"),
            value = "overview",
            
            div(
              class = "demographics-tab-content demographics-overview",
              
              div(
                class = "overview-introduction",
                
                tags$span(
                  class = "demographics-section-kicker",
                  "EINORDNUNG"
                ),
                
                tags$h2(
                  "Was zeigt dieses Dashboard?"
                ),
                
                tags$p(
                  paste(
                    "Das Dashboard stellt demografische Entwicklungen und",
                    "Wanderungsbewegungen regional und über mehrere Jahre dar.",
                    "Die Visualisierungen helfen dabei, Unterschiede zwischen",
                    "Landkreisen zu erkennen, zeitliche Veränderungen zu verfolgen",
                    "und geografische Muster einzuordnen."
                  )
                )
              ),
              
              div(
                class = "overview-feature-grid",
                
                div(
                  class = "overview-feature-card",
                  div(class = "overview-feature-icon", icon("map-location-dot")),
                  tags$h3("Geografische Verteilung"),
                  tags$p(
                    paste(
                      "Die Karte vergleicht den ausgewählten Indikator zwischen",
                      "den Regionen. Die Farbintensität repräsentiert die Höhe",
                      "des jeweiligen Werts."
                    )
                  )
                ),
                
                div(
                  class = "overview-feature-card",
                  div(class = "overview-feature-icon", icon("chart-column")),
                  tags$h3("Zeitliche Entwicklung"),
                  tags$p(
                    paste(
                      "Nach Auswahl einer Region zeigt das Zeitreihendiagramm,",
                      "wie sich der entsprechende Indikator im verfügbaren",
                      "Beobachtungszeitraum entwickelt hat."
                    )
                  )
                ),
                
                div(
                  class = "overview-feature-card",
                  div(class = "overview-feature-icon", icon("compass")),
                  tags$h3("Nord-Süd-Vergleich"),
                  tags$p(
                    paste(
                      "Die Landkreise werden geografisch von Norden nach Süden",
                      "geordnet. Dadurch lassen sich räumliche Muster für das",
                      "ausgewählte Jahr leichter vergleichen."
                    )
                  )
                )
              ),
              
              div(
                class = "overview-details-grid",
                
                div(
                  class = "overview-indicators-panel",
                  
                  tags$span(
                    class = "demographics-section-kicker",
                    "VERFÜGBARE INDIKATOREN"
                  ),
                  
                  tags$h2("Inhalte des Datensatzes"),
                  
                  tags$ul(
                    class = "indicator-list",
                    tags$li(icon("users"), tags$span("Bevölkerung und Bevölkerungsentwicklung")),
                    tags$li(icon("baby"), tags$span("Geburten je 1.000 Einwohner:innen")),
                    tags$li(icon("heart-pulse"), tags$span("Sterbefälle je 1.000 Einwohner:innen")),
                    tags$li(icon("scale-balanced"), tags$span("Natürlicher Saldo")),
                    tags$li(icon("person-walking-arrow-right"), tags$span("Zu- und Fortzüge")),
                    tags$li(icon("graduation-cap"), tags$span("Bildungswanderung"))
                  )
                ),
                
                div(
                  class = "overview-reading-panel",
                  
                  tags$span(
                    class = "demographics-section-kicker",
                    "INTERPRETATION"
                  ),
                  
                  tags$h2("Hinweise zur Nutzung"),
                  
                  tags$ol(
                    class = "reading-steps",
                    tags$li(
                      tags$strong("Indikator auswählen"),
                      tags$span("Wählen Sie den gewünschten demografischen Parameter aus.")
                    ),
                    tags$li(
                      tags$strong("Karte untersuchen"),
                      tags$span("Bewegen Sie den Mauszeiger über Regionen und klicken Sie eine Region an.")
                    ),
                    tags$li(
                      tags$strong("Trend vergleichen"),
                      tags$span("Prüfen Sie die zeitliche Entwicklung und den Nord-Süd-Vergleich.")
                    )
                  )
                )
              )
              
              # NOTE: current-indicator-box was removed from here
              # and moved to the Visualizations tab, below the map.
            )
          ),
          
          # ====================================================
          # TAB 2: VISUALIZATIONS
          # ====================================================
          bslib::nav_panel(
            title = tagList(icon("chart-area"), "Visualisierungen"),
            value = "visualizations",
            
            div(
              class = "demographics-tab-content demographics-visualizations",
              
              # ------------------------------------------------
              # Controls
              # ------------------------------------------------
              div(
                class = "demographics-controls",
                
                div(
                  class = "control-heading",
                  div(
                    tags$span(
                      class = "demographics-section-kicker",
                      "FILTER UND DARSTELLUNG"
                    ),
                    tags$h2("Analyse konfigurieren")
                  ),
                  tags$p(
                    "Die Auswahl wird automatisch auf alle Visualisierungen angewendet."
                  )
                ),
                
                div(
                  class = "control-grid",
                  
                  div(
                    class = "control-field control-field--wide",
                    tags$label(`for` = ns("selected_param"), "Indikator"),
                    selectInput(
                      inputId = ns("selected_param"),
                      label = NULL,
                      choices = variable_choices,
                      width = "100%"
                    )
                  ),
                  
                  div(
                    class = "control-field",
                    tags$label(`for` = ns("color_palette"), "Farbschema"),
                    selectInput(
                      inputId = ns("color_palette"),
                      label = NULL,
                      choices = c(
                        "Klinisches Rot" = "inferno",
                        "Medizinisches Blau" = "mako"
                      ),
                      selected = "inferno",
                      width = "100%"
                    )
                  ),
                  
                  div(
                    class = "control-field",
                    tags$label(`for` = ns("selected_year"), "Vergleichsjahr"),
                    selectInput(
                      inputId = ns("selected_year"),
                      label = NULL,
                      choices = year_choices,
                      selected = "2023",
                      width = "100%"
                    )
                  )
                )
              ),
              
              # ------------------------------------------------
              # Map and time trend
              # ------------------------------------------------
              div(
                class = "visualization-grid visualization-grid--primary",
                
                # ================================================
                # MAP PANEL
                # ================================================
                div(
                  class = "visualization-panel visualization-panel--map",
                  div(
                    class = "visualization-panel__header",
                    div(
                      tags$span(class = "panel-kicker", "REGIONALER VERGLEICH"),
                      tags$h3("Geografische Verteilung")
                    ),
                    tags$span(
                      class = "panel-help",
                      title = paste(
                        "Die Farbintensität zeigt die relative Höhe des",
                        "ausgewählten Indikators in den Regionen."
                      ),
                      icon("circle-info")
                    )
                  ),
                  div(
                    class = "visualization-panel__body",
                    girafeOutput(ns("map_plot"), width = "100%", height = "600px")
                  ),
                  div(
                    class = "visualization-panel__footer",
                    icon("computer-mouse"),
                    tags$span("Region anklicken, um die Zeitreihe anzuzeigen.")
                  ),
                  
                  # ---- Current indicator box moved here ----
                  div(
                    class = "current-indicator-box current-indicator-box--map",
                    div(
                      class = "current-indicator-box__icon",
                      icon("lightbulb")
                    ),
                    div(
                      tags$span(
                        class = "current-indicator-box__label",
                        "AKTUELLER INDIKATOR"
                      ),
                      uiOutput(ns("indicator_explanation"))
                    )
                  )
                ),
                
                # ================================================
                # TREND PANEL
                # ================================================
                div(
                  class = "visualization-panel visualization-panel--trend",
                  div(
                    class = "visualization-panel__header",
                    div(
                      tags$span(class = "panel-kicker", "ZEITLICHER VERLAUF"),
                      tags$h3("Entwicklung der ausgewählten Region")
                    ),
                    tags$span(
                      class = "panel-help",
                      title = "Das Diagramm zeigt die Werte der ausgewählten Region über die Zeit.",
                      icon("circle-info")
                    )
                  ),
                  div(
                    class = "visualization-panel__body",
                    girafeOutput(ns("bar_plot"), width = "100%", height = "600px")
                  )
                )
              ),
              
              # ------------------------------------------------
              # North-south comparison
              # ------------------------------------------------
              div(
                class = "visualization-panel visualization-panel--full",
                
                div(
                  class = "visualization-panel__header visualization-panel__header--responsive",
                  div(
                    tags$span(class = "panel-kicker", "RÄUMLICHER VERGLEICH"),
                    tags$h3("Nord-Süd-Vergleich")
                  ),
                  
                  div(
                    class = "ns-legend",
                    tags$span(
                      tags$span(
                        class = "ns-legend-dot",
                        style = "background:#10B981;"
                      ),
                      "Norden"
                    ),
                    tags$span(class = "ns-legend-arrow", "→"),
                    tags$span(
                      tags$span(
                        class = "ns-legend-dot",
                        style = "background:#8B5CF6;"
                      ),
                      "Süden"
                    ),
                    tags$span(
                      class = "ns-legend-note",
                      "Balkenlänge = Wert des Indikators"
                    )
                  )
                ),
                
                div(
                  class = "visualization-panel__body visualization-panel__body--north-south",
                  girafeOutput(ns("ns_bar_plot"), width = "100%", height = "500px")
                )
              )
            )
          )
        )
      )
    )
  )
}