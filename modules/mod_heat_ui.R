mod_heat_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # ---- Language toggle (charts only) ----
    tags$div(
      class = "lang-toggle-wrap",
      tags$span(class = "lang-toggle-label", "Diagrammsprache"),
      selectInput(ns("lang"), NULL,
                  choices = c("DE" = "de", "EN" = "en"),
                  selected = "de", width = "90px")
    ),
    
    div(
      id = ns("heat_root"),
      class = "heat-wrap",
      
      # ============================================================
      # HERO
      # ============================================================
      div(
        class = "gallery-hero heat-hero",
        div(class = "hero-layer hero-layer-constellation"),
        div(class = "hero-layer hero-layer-particles"),
        div(class = "hero-layer hero-layer-vignette"),
        div(
          class = "gallery-hero-content",
          
          tags$span(class = "gallery-kicker",
                    "URBAN HEAT EMISSIONS OBSERVATORY"),
          
          tags$h1(class = "gallery-hero-title",
                  "Urban Heat Emissions Observatory"),
          
          tags$p(class = "gallery-hero-subtitle",
                 "Hitze sichtbar machen. Daten verstehen. Entscheidungen verbessern."),
          
          tags$p(class = "gallery-hero-description",
                 "Diese Plattform untersucht die Zusammenhänge zwischen urbaner Wärmeentwicklung, Gebäudedichte, Grünflächenanteil und industrieller Wärmeabgabe in fünf Landkreisen Sachsen-Anhalts."),
          
          tags$p(class = "gallery-hero-description",
                 "Die Visualisierungen zeigen, wo Hitze entsteht, wann sie am stärksten auftritt und welche Bevölkerungsgruppen betroffen sind."),
          
          div(
            class = "hero-stats",
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value", "5"),
                tags$span(class = "hero-stat-label", "Landkreise")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value", "20"),
                tags$span(class = "hero-stat-label", "Monate")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value", "12"),
                tags$span(class = "hero-stat-label", "Indikatoren")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value", "96.7"),
                tags$span(class = "hero-stat-label", "Höchstes Hitze-Risiko")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value", "24.2 °C"),
                tags$span(class = "hero-stat-label", "Höchsttemperatur")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value", "871k"),
                tags$span(class = "hero-stat-label", "Betrachtete Bevölkerung"))
          )
        )
      ),
      
      # ============================================================
      # MANIFESTO
      # ============================================================
      div(
        class = "gallery-manifesto heat-manifesto",
        div(class = "manifesto-glow"),
        div(
          class = "manifesto-content",
          tags$h2(class = "manifesto-line", "Hitze ist unsichtbar."),
          tags$h3(class = "manifesto-line manifesto-emphasis",
                  "Daten machen sie sichtbar.")
        )
      ),
      
      # ============================================================
      # SUB-TABS
      # ============================================================
      bslib::navset_tab(
        id = ns("heat_tabs"),
        
        # --------------------------------------------------------
        # TAB 1 — ÜBERBLICK
        # --------------------------------------------------------
        bslib::nav_panel(
          title = "Überblick",
          value = "overview",
          
          div(
            class = "heat-page-intro",
            tags$h2(class = "heat-page-title",
                    "Status quo des urbanen Wärmesystems"),
            tags$p(class = "heat-page-subtitle",
                   "Ein Blick auf das gesamte System: Welche Landkreise tragen das höchste Hitze-Risiko, wie verteilt es sich, und welche saisonalen Muster sind erkennbar?")
          ),
          
          # Ranked bar + Ridge
          fluidRow(
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Hitze-Risiko nach Landkreis"),
                tags$p(class = "heat-card-subtitle",
                       "Höchster Risikowert pro Landkreis. Urban verdichtete Kreise liegen deutlich vor ländlichen Regionen."),
                plotOutput(ns("p1_ridge"),
                           height = "340px")
              )
            ),
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Verteilung des Hitze-Risikos"),
                tags$p(class = "heat-card-subtitle",
                       "Ridge-Diagramm über alle 20 Monate. Bimodale Verteilungen zeigen deutliche Sommer-Winter-Dynamik."),
                ggiraph::girafeOutput(ns("p1_ridge"),
                                      height = "340px")
              )
            )
          ),
          
          # Sparklines full width
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Saisonaler Verlauf je Landkreis"),
            tags$p(class = "heat-card-subtitle",
                   "20-Monats-Verlauf der mittleren Temperatur. Jede Kurve zeigt denselben Zeitraum – die Amplitude unterscheidet sich je nach Urbanisierungsgrad."),
            plotOutput(ns("p1_sparklines"),
                       height = "300px")
          )
        ),
        
        # --------------------------------------------------------
        # TAB 2 — HOTSPOTS
        # --------------------------------------------------------
        bslib::nav_panel(
          title = "Hotspots",
          value = "hotspots",
          
          div(
            class = "heat-page-intro",
            tags$h2(class = "heat-page-title",
                    "Wo konzentriert sich Hitze?"),
            tags$p(class = "heat-page-subtitle",
                   "Räumliche und strukturelle Analyse: Welche Faktoren erklären, wo Hitze entsteht – und welche Rolle spielen Dichte, Grünflächen und industrielle Wärme?")
          ),
          
          # Heatmap
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Landkreis × Monat — Hitze-Risiko"),
            tags$p(class = "heat-card-subtitle",
                   "Zeilen nach geografischer Breite sortiert (Norden oben). Farbintensität zeigt das Risikomaß."),
            ggiraph::girafeOutput(ns("p2_heatmap"),
                                  height = "420px")
          ),
          
          # Bubble + Lollipop
          fluidRow(
            column(
              width = 7,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Dichte, Risiko und Grünflächen"),
                tags$p(class = "heat-card-subtitle",
                       "X = Gebäudedichte, Y = Hitze-Risiko, Größe = Bevölkerung, Farbe = Grünflächenanteil."),
                ggiraph::girafeOutput(ns("p2_bubble"),
                                      height = "380px")
              )
            ),
            column(
              width = 5,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Rangfolge nach Spitzenrisiko"),
                tags$p(class = "heat-card-subtitle",
                       "Lollipop-Diagramm für präzise Reihenfolge und Abstände."),
                ggiraph::girafeOutput(ns("p2_lollipop"),
                                      height = "380px")
              )
            )
          ),
          
          # Decomposition
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Zusammensetzung der Wärmeemissionen"),
            tags$p(class = "heat-card-subtitle",
                   "Aufschlüsselung nach Gebäuden, Industrie, Wohnen und Restklima für den gewählten Landkreis."),
            div(
              class = "heat-filters",
              div(
                tags$label("Landkreis:"),
                selectInput(ns("p2_district"), NULL,
                            choices = c("Magdeburg" = "Magdeburg",
                                        "Halle" = "Halle",
                                        "Dessau-Roßlau" = "Dessau-Roßlau",
                                        "Stendal" = "Stendal",
                                        "Harz" = "Harz"),
                            selected = "Halle",
                            width = "220px")
              )
            ),
            ggiraph::girafeOutput(ns("p2_decomp"),
                                  height = "340px")
          )
        ),
        
        # --------------------------------------------------------
        # TAB 3 — ZEITVERLAUF
        # --------------------------------------------------------
        bslib::nav_panel(
          title = "Zeitverlauf",
          value = "trends",
          
          div(
            class = "heat-page-intro",
            tags$h2(class = "heat-page-title",
                    "Entwicklung über 20 Monate"),
            tags$p(class = "heat-page-subtitle",
                   "Zeitliche Muster: Wie stark ist die Saisonalität, und gibt es einen systematischen Trend von 2023 auf 2024?")
          ),
          
          # Multi-line trend
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Temperaturverlauf aller Landkreise"),
            tags$p(class = "heat-card-subtitle",
                   "Hover hebt einen Landkreis hervor. Zwei Sommerpeaks (Juli 2023, Juli 2024) sind deutlich erkennbar."),
            ggiraph::girafeOutput(ns("p3_trend"),
                                  height = "400px")
          ),
          
          # Calendar + STL
          fluidRow(
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Hitze-Kalender"),
                tags$p(class = "heat-card-subtitle",
                       "Monat × Jahr für den gewählten Landkreis."),
                div(
                  class = "heat-filters",
                  div(
                    tags$label("Landkreis:"),
                    selectInput(ns("p3_district"), NULL,
                                choices = c("Magdeburg", "Halle",
                                            "Dessau-Roßlau", "Stendal", "Harz"),
                                selected = "Magdeburg",
                                width = "200px")
                  )
                ),
                ggiraph::girafeOutput(ns("p3_calendar"),
                                      height = "320px")
              )
            ),
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Saisonale Zerlegung"),
                tags$p(class = "heat-card-subtitle",
                       "Trend, Saison und Residualkomponente nebeneinander."),
                plotOutput(ns("p3_stl"),
                           height = "320px")
              )
            )
          ),
          
          # Slope + Anomaly
          fluidRow(
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "2023 vs. 2024"),
                tags$p(class = "heat-card-subtitle",
                       "Steigungsdiagramm für den gewählten Indikator."),
                ggiraph::girafeOutput(ns("p3_slope"),
                                      height = "360px")
              )
            ),
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Anomalien"),
                tags$p(class = "heat-card-subtitle",
                       "Abweichung vom 20-Monats-Mittel. Rote Balken = wärmer als üblich."),
                ggiraph::girafeOutput(ns("p3_anomaly"),
                                      height = "360px")
              )
            )
          )
        ),
        
        # --------------------------------------------------------
        # TAB 4 — RISIKO
        # --------------------------------------------------------
        bslib::nav_panel(
          title = "Risiko",
          value = "risk",
          
          div(
            class = "heat-page-intro",
            tags$h2(class = "heat-page-title",
                    "Wer ist betroffen?"),
            tags$p(class = "heat-page-subtitle",
                   "Verknüpfung von Hitze mit Bevölkerung: Expositionsanalyse, Risikoklassen und illustratives Szenario für Grünflächen-Interventionen.")
          ),
          
          # Risk matrix
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Risikomatrix"),
            tags$p(class = "heat-card-subtitle",
                   "Exposition (x) gegen Gefährdung (y). Größe = Bevölkerung. Quadranten zeigen Handlungskategorien."),
            ggiraph::girafeOutput(ns("p4_matrix"),
                                  height = "420px")
          ),
          
          # Small-multiple calendars
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Risikokalender je Landkreis"),
            tags$p(class = "heat-card-subtitle",
                   "Fünf Panels mit einheitlicher Farbskala für direkte Vergleichbarkeit."),
            plotOutput(ns("p4_calendars"),
                       height = "340px")
          ),
          
          # Exposure + Scenario
          fluidRow(
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Bevölkerung in Risikoklassen"),
                tags$p(class = "heat-card-subtitle",
                       "Wie viele Menschen leben in welcher Risikostufe?"),
                ggiraph::girafeOutput(ns("p4_exposure"),
                                      height = "360px")
              )
            ),
            column(
              width = 6,
              div(
                class = "heat-card",
                tags$h3(class = "heat-card-title",
                        "Szenario: Grünflächen erhöhen"),
                tags$p(class = "heat-card-subtitle",
                       "Illustratives Modell auf Basis beobachteter Korrelationen. Keine Prognose."),
                sliderInput(ns("p4_green_delta"), NULL,
                            min = 0, max = 30, value = 10, step = 1,
                            post = " %",
                            width = "100%"),
                ggiraph::girafeOutput(ns("p4_scenario"),
                                      height = "260px")
              )
            )
          ),
          
          # Comparison
          div(
            class = "heat-card",
            tags$h3(class = "heat-card-title",
                    "Landkreis-Vergleich"),
            tags$p(class = "heat-card-subtitle",
                   "Zwei Landkreise nebeneinander über alle Risikoindikatoren."),
            fluidRow(
              column(
                width = 6,
                div(
                  class = "heat-filters",
                  div(
                    tags$label("Landkreis A:"),
                    selectInput(ns("p4_cmp_a"), NULL,
                                choices = c("Halle", "Magdeburg",
                                            "Dessau-Roßlau", "Stendal", "Harz"),
                                selected = "Halle", width = "180px")
                  )
                ),
                ggiraph::girafeOutput(ns("p4_cmp_a_plot"),
                                      height = "300px")
              ),
              column(
                width = 6,
                div(
                  class = "heat-filters",
                  div(
                    tags$label("Landkreis B:"),
                    selectInput(ns("p4_cmp_b"), NULL,
                                choices = c("Halle", "Magdeburg",
                                            "Dessau-Roßlau", "Stendal", "Harz"),
                                selected = "Harz", width = "180px")
                  )
                ),
                ggiraph::girafeOutput(ns("p4_cmp_b_plot"),
                                      height = "300px")
              )
            )
          )
        ),
        
        # --------------------------------------------------------
        # TAB 5 — STORY
        # --------------------------------------------------------
        bslib::nav_panel(
          title = "Story",
          value = "story",
          
          div(
            class = "heat-page-intro",
            tags$h2(class = "heat-page-title",
                    "Die Geschichte in fünf Szenen"),
            tags$p(class = "heat-page-subtitle",
                   "Eine Synthese: Vom Muster über die Ungleichheit und den Hebel bis zur Entwicklung und zum Handlungsaufruf.")
          ),
          
          # Scene 1
          div(
            class = "heat-scene",
            tags$span(class = "heat-scene-number", "Szene 01"),
            tags$h3(class = "heat-scene-title", "Das Muster"),
            tags$p(class = "heat-caption",
                   "Jeder Landkreis erwärmt sich im Sommer. Die Amplitude hängt davon ab, wie Städte gebaut sind."),
            plotOutput(ns("s1_pattern"), height = "260px")
          ),
          
          # Scene 2
          div(
            class = "heat-scene",
            tags$span(class = "heat-scene-number", "Szene 02"),
            tags$h3(class = "heat-scene-title", "Die Ungleichheit"),
            tags$p(class = "heat-caption",
                   "Dichte Städte erwärmen sich bis zu viermal stärker als ländliche Landkreise."),
            ggiraph::girafeOutput(ns("s2_inequality"), height = "360px")
          ),
          
          # Scene 3
          div(
            class = "heat-scene",
            tags$span(class = "heat-scene-number", "Szene 03"),
            tags$h3(class = "heat-scene-title", "Der Hebel"),
            tags$p(class = "heat-caption",
                   "Grünflächen kühlen. Der Harz zeigt, wie stark dieser Effekt sein kann."),
            ggiraph::girafeOutput(ns("s3_leverage"), height = "360px")
          ),
          
          # Scene 4
          div(
            class = "heat-scene",
            tags$span(class = "heat-scene-number", "Szene 04"),
            tags$h3(class = "heat-scene-title", "Die Entwicklung"),
            tags$p(class = "heat-caption",
                   "Das Problem verschärft sich – in allen Landkreisen."),
            ggiraph::girafeOutput(ns("s4_trajectory"), height = "360px")
          ),
          
          # Scene 5
          div(
            class = "heat-scene",
            tags$span(class = "heat-scene-number", "Szene 05"),
            tags$h3(class = "heat-scene-title", "Der Aufruf"),
            tags$p(class = "heat-caption",
                   "Städte haben die Daten. Städte haben die Werkzeuge. Was fehlt, ist eine integrierte Sicht – die dieses Observatorium liefert.")
          ),
          
          # Closing quote
          div(
            class = "quote-card",
            tags$p(class = "quote-text",
                   "Gute Visualisierung zeigt Hitze nicht nur. Sie ermöglicht Handlung."),
            tags$p(class = "quote-author",
                   "— Urban Heat Emissions Observatory")
          )
        )
      )
    )
  )
}
