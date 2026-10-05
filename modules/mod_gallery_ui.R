mod_gallery_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # ---- Sprachumschaltung (steuert Diagramme & Notizen) ----
    tags$div(
      class = "lang-toggle-wrap",
      tags$span(class = "lang-toggle-label", "Diagrammsprache"),
      selectInput(
        ns("lang"), NULL,
        choices = c("DE" = "de", "EN" = "en"),
        selected = "de",
        width = "90px"
      )
    ),
    
    div(
      id = ns("gallery_root"),
      class = "gallery-wrap",
      
      # ============================================================
      # HERO
      # ============================================================
      div(
        class = "gallery-hero",
        div(class = "hero-layer hero-layer-constellation"),
        div(class = "hero-layer hero-layer-particles"),
        div(class = "hero-layer hero-layer-vignette"),
        div(
          class = "gallery-hero-content",
          
          tags$span(class = "gallery-kicker",
                    "VISUALISIERUNGS-INNOVATIONSLABOR"),
          
          tags$h1(class = "gallery-hero-title",
                  "Visualisierungs-Innovationslabor"),
          
          tags$p(class = "gallery-hero-subtitle",
                 "Gesundheitsdaten in Erkenntnis, Geschichten und Handlung verwandeln."),
          
          tags$p(class = "gallery-hero-description",
                 "Diese Galerie präsentiert eine Sammlung von Visualisierungskonzepten, die mit realen Bevölkerungs- und Gesundheitsdaten aus Sachsen-Anhalt entwickelt wurden."),
          
          tags$p(class = "gallery-hero-description",
                 "Jede Visualisierung beleuchtet eine andere Perspektive auf dieselben Daten und zeigt, wie Designentscheidungen Verständnis, Storytelling, Stakeholder-Einbindung und Entscheidungsfindung beeinflussen können."),
          
          tags$p(class = "gallery-hero-description",
                 "Das Ziel ist nicht nur, Daten zu präsentieren, sondern auch zu untersuchen, wie Visual Analytics komplexe Gesundheitsinformationen zugänglicher, interpretierbarer und handlungsorientierter machen kann."),
          
          div(
            class = "hero-stats",
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value",
                          `data-counter` = "14", "0"),
                tags$span(class = "hero-stat-label", "Landkreise")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value",
                          `data-counter` = "18", "0"),
                tags$span(class = "hero-stat-label", "Jahre")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value",
                          `data-counter` = "9", "0"),
                tags$span(class = "hero-stat-label", "Indikatorenfamilien")),
            div(class = "hero-stat",
                tags$span(class = "hero-stat-value",
                          `data-counter` = "7", "0"),
                tags$span(class = "hero-stat-label", "Visualisierungskonzepte"))
          )
        )
      ),
      
      # ============================================================
      # MANIFEST
      # ============================================================
      div(
        class = "gallery-manifesto",
        div(class = "manifesto-glow"),
        div(class = "manifesto-content",
            tags$h2(class = "manifesto-line",
                    "Daten allein verändern das Gesundheitssystem nicht."),
            tags$h3(class = "manifesto-line manifesto-emphasis",
                    "Verständnis schon."))
      ),
      
      # ============================================================
      # STORYTELLING-ZEITLEISTE
      # ============================================================
      div(
        class = "gallery-timeline",
        div(class = "timeline-progress"),
        div(class = "timeline-step",
            div(class = "timeline-icon", icon("database")),
            tags$span(class = "timeline-label", "Daten")),
        div(class = "timeline-arrow", icon("arrow-right")),
        div(class = "timeline-step",
            div(class = "timeline-icon", icon("chart-line")),
            tags$span(class = "timeline-label", "Muster")),
        div(class = "timeline-arrow", icon("arrow-right")),
        div(class = "timeline-step",
            div(class = "timeline-icon", icon("lightbulb")),
            tags$span(class = "timeline-label", "Erkenntnisse")),
        div(class = "timeline-arrow", icon("arrow-right")),
        div(class = "timeline-step",
            div(class = "timeline-icon", icon("users")),
            tags$span(class = "timeline-label", "Entscheidungen")),
        div(class = "timeline-arrow", icon("arrow-right")),
        div(class = "timeline-step",
            div(class = "timeline-icon", icon("heart-pulse")),
            tags$span(class = "timeline-label", "Gesellschaftliche Wirkung"))
      ),
      
      # ============================================================
      # WARUM VISUALISIERUNG WICHTIG IST + FORSCHUNGSFRAGEN
      # ============================================================
      div(
        class = "why-grid",
        
        div(
          class = "why-card",
          tags$h2("Warum Visualisierung wichtig ist"),
          tags$p("Ein einzelnes Diagramm erzählt selten die ganze Geschichte. Unterschiedliche visuelle Designs offenbaren unterschiedliche Aspekte derselben Daten – Trends, regionale Disparitäten, Zusammenhänge, Rangfolgen und zeitliche Entwicklungen."),
          tags$p("Diese Galerie untersucht, wie visuelle Darstellungen evidenzbasierte Kommunikation und informierte Entscheidungsfindung im Gesundheitswesen unterstützen können.")
        ),
        
        div(
          class = "research-questions",
          tags$h3(class = "rq-title", "Forschungsfragen"),
          tags$ol(
            class = "rq-list",
            tags$li("Welche Visualisierung kommuniziert Trends am besten?"),
            tags$li("Welche Visualisierung unterstützt Vergleiche am besten?"),
            tags$li("Welche Visualisierung unterstützt Entscheidungsfindung am besten?")
          )
        )
      ),
      
      # ============================================================
      # VISUALISIERUNGSREISE
      # ============================================================
      div(
        class = "viz-journey",
        tags$h3(class = "viz-journey-title", "Die Visualisierungsreise"),
        div(
          class = "viz-journey-track",
          div(class = "viz-stage",
              div(class = "viz-stage-icon", icon("database")),
              tags$span(class = "viz-stage-label", "Rohdaten")),
          div(class = "viz-stage-arrow", icon("arrow-right-long")),
          div(class = "viz-stage",
              div(class = "viz-stage-icon", icon("wand-magic-sparkles")),
              tags$span(class = "viz-stage-label", "Transformation")),
          div(class = "viz-stage-arrow", icon("arrow-right-long")),
          div(class = "viz-stage",
              div(class = "viz-stage-icon", icon("palette")),
              tags$span(class = "viz-stage-label", "Visuelle Kodierung")),
          div(class = "viz-stage-arrow", icon("arrow-right-long")),
          div(class = "viz-stage",
              div(class = "viz-stage-icon", icon("eye")),
              tags$span(class = "viz-stage-label", "Interpretation")),
          div(class = "viz-stage-arrow", icon("arrow-right-long")),
          div(class = "viz-stage",
              div(class = "viz-stage-icon", icon("bolt")),
              tags$span(class = "viz-stage-label", "Handlung"))
        )
      ),
      
      # ============================================================
      # ZITAT
      # ============================================================
      div(
        class = "quote-card",
        tags$p(class = "quote-text",
               "Gute Visualisierung zeigt Daten nicht nur – sie ermöglicht Verständnis."),
        tags$p(class = "quote-author", "— Visualisierungs-Innovationslabor")
      ),
      
      # ============================================================
      # FORSCHUNGSBANNER
      # ============================================================
      div(
        class = "research-banner",
        tags$h2(
          "7 Visualisierungskonzepte",
          tags$span(class = "banner-sep", "\u2022"),
          "1 Datensatz",
          tags$span(class = "banner-sep", "\u2022"),
          "Vielfältige Perspektiven"
        )
      ),
      
      # ============================================================
      # WIRKUNGSRASTER
      # ============================================================
      div(
        class = "impact-grid",
        div(class = "impact-card impact-pattern",
            div(class = "impact-icon", icon("magnifying-glass")),
            tags$h4(class = "impact-title", "Mustererkennung"),
            tags$p(class = "impact-desc",
                   "Verborgene Entwicklungen über Landkreise hinweg sichtbar machen.")),
        div(class = "impact-card impact-comm",
            div(class = "impact-icon", icon("users")),
            tags$h4(class = "impact-title", "Stakeholder-Kommunikation"),
            tags$p(class = "impact-desc",
                   "Erkenntnisse in zugängliche Narrative übersetzen.")),
        div(class = "impact-card impact-decision",
            div(class = "impact-icon", icon("chart-simple")),
            tags$h4(class = "impact-title", "Entscheidungsunterstützung"),
            tags$p(class = "impact-desc",
                   "Evidenzbasierte Planung fördern.")),
        div(class = "impact-card impact-health",
            div(class = "impact-icon", icon("heart-pulse")),
            tags$h4(class = "impact-title", "Public-Health-Erkenntnisse"),
            tags$p(class = "impact-desc",
                   "Regionale Gesundheitsdynamiken aufdecken."))
      ),
      
      # ============================================================
      # METHODIK
      # ============================================================
      div(
        class = "methodology-panel",
        tags$h3(class = "methodology-title", "Methodik der Galerie"),
        div(
          class = "methodology-grid",
          div(class = "methodology-item",
              tags$span(class = "methodology-label", "Datensatz"),
              tags$span(class = "methodology-value",
                        "Landkreis-Indikatoren, Sachsen-Anhalt")),
          div(class = "methodology-item",
              tags$span(class = "methodology-label", "Zeitraum"),
              tags$span(class = "methodology-value", "2006 – 2023 (18 Jahre)")),
          div(class = "methodology-item",
              tags$span(class = "methodology-label", "Regionen"),
              tags$span(class = "methodology-value", "14 Landkreise und Städte")),
          div(class = "methodology-item",
              tags$span(class = "methodology-label", "Indikatoren"),
              tags$span(class = "methodology-value", "9 Familien")),
          div(class = "methodology-item methodology-item-wide",
              tags$span(class = "methodology-label", "Design-Evaluation"),
              tags$span(class = "methodology-value",
                        "Vergleichende Prototypen-Tests über 7 Visualisierungstypen"))
        )
      ),
      
      # ============================================================
      # ABSCHNITTSÜBERSCHRIFT + RIBBON
      # ============================================================
      div(
        class = "section-header",
        tags$h2(class = "section-title", "Erkundete Visualisierungskonzepte"),
        div(
          class = "section-ribbon",
          tags$span("Forschung"),
          tags$span(class = "ribbon-dot", "\u2022"),
          tags$span("Design"),
          tags$span(class = "ribbon-dot", "\u2022"),
          tags$span("Storytelling"),
          tags$span(class = "ribbon-dot", "\u2022"),
          tags$span("Entscheidungsunterstützung")
        )
      ),
      
      # ============================================================
      # STORYTELLING-HINWEIS
      # ============================================================
      div(
        class = "storytelling-callout",
        "Entdecken Sie, wie ein einzelner Datensatz völlig unterschiedliche Geschichten erzählen kann – je nach Wahl des Visualisierungsdesigns."
      ),
      
      # ============================================================
      # PROTOTYP 01 – Trendanalyse
      # ============================================================
      div(class = "proto-card proto-trend",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("chart-line"), tags$span("Trendanalyse")),
              div(class = "proto-num", "01"),
              tags$h3(class = "proto-title", "Mehrlinien-Verlaufsdiagramm"),
              tags$p(class = "proto-desc",
                     "Alle 14 Landkreise in einem Diagramm, 2006–2023. Zum Hervorheben darüberfahren."),
              tags$span(class = "proto-tag", "zeitlich"),
              tags$span(class = "proto-tag", "alle Regionen")),
          div(class = "proto-body", uiOutput(ns("note_p1")),
              div(class = "proto-controls",
                  tags$label("Indikator:"),
                  selectInput(ns("p1_indicator"), NULL,
                              choices = c("Bevölkerung" = "Bevölkerung (Anzahl)"),
                              width = "280px")),
              girafeOutput(ns("p1_plot"), width = "100%", height = "360px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: Zeitreihen-Storytelling"))
      ),
      
      # ============================================================
      # PROTOTYP 02 – Rangfolgeanalyse
      # ============================================================
      div(class = "proto-card proto-ranking",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("ranking-star"), tags$span("Rangfolgeanalyse")),
              div(class = "proto-num", "02"),
              tags$h3(class = "proto-title", "Divergierendes Balkendiagramm"),
              tags$p(class = "proto-desc",
                     "Ein Jahr, von Nord nach Süd sortiert. Balken laufen von der Nulllinie nach rechts bzw. links."),
              tags$span(class = "proto-tag", "Momentaufnahme"),
              tags$span(class = "proto-tag", "Rangfolge")),
          div(class = "proto-body", uiOutput(ns("note_p2")),
              div(class = "proto-controls",
                  tags$label("Indikator:"),
                  selectInput(ns("p2_indicator"), NULL,
                              choices = c("Zuzüge" = "Zuzüge (je 1.000 Einwohner:innen)"),
                              width = "280px"),
                  tags$label("Jahr:"),
                  selectInput(ns("p2_year"), NULL,
                              choices = as.character(2006:2023),
                              selected = "2023", width = "80px")),
              girafeOutput(ns("p2_plot"), width = "100%", height = "400px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: Politik-Briefings"))
      ),
      
      # ============================================================
      # PROTOTYP 03 – Mustererkennung
      # ============================================================
      div(class = "proto-card proto-pattern",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("fire"), tags$span("Mustererkennung")),
              div(class = "proto-num", "03"),
              tags$h3(class = "proto-title", "Heatmap — Region × Jahr"),
              tags$p(class = "proto-desc",
                     "Zeilen = Landkreise (Nord–Süd), Spalten = Jahre."),
              tags$span(class = "proto-tag", "Überblick"),
              tags$span(class = "proto-tag", "Mustererkennung")),
          div(class = "proto-body", uiOutput(ns("note_p3")),
              div(class = "proto-controls",
                  tags$label("Indikator:"),
                  selectInput(ns("p3_indicator"), NULL,
                              choices = c("Bevölkerung" = "Bevölkerung (Anzahl)"),
                              width = "280px")),
              girafeOutput(ns("p3_plot"), width = "100%", height = "400px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: Management-Überblick"))
      ),
      
      # ============================================================
      # PROTOTYP 04 – Multivariate Analyse
      # ============================================================
      div(class = "proto-card proto-multi",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("circle-nodes"), tags$span("Multivariate Analyse")),
              div(class = "proto-num", "04"),
              tags$h3(class = "proto-title", "Blasendiagramm — 3 Variablen"),
              tags$p(class = "proto-desc",
                     "X = Geburten pro 1.000, Y = Bev.-Entwicklung seit 2011, Blasengröße = Bevölkerung."),
              tags$span(class = "proto-tag", "multivariat")),
          div(class = "proto-body", uiOutput(ns("note_p4")),
              div(class = "proto-controls",
                  tags$label("Jahr:"),
                  selectInput(ns("p4_year"), NULL,
                              choices = as.character(2011:2023),
                              selected = "2023", width = "90px"),
                  tags$label("Färbung nach:"),
                  selectInput(ns("p4_color"), NULL,
                              choices = c("Typ (Stadt/Landkreis)" = "type",
                                          "Nord–Süd" = "ns"),
                              width = "200px")),
              girafeOutput(ns("p4_plot"), width = "100%", height = "380px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: Positionierungsberichte"))
      ),
      
      # ============================================================
      # PROTOTYP 05 – Veränderungsanalyse
      # ============================================================
      div(class = "proto-card proto-change",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("arrow-trend-up"), tags$span("Veränderungsanalyse")),
              div(class = "proto-num", "05"),
              tags$h3(class = "proto-title", "Steigungsdiagramm — vorher vs. nachher"),
              tags$p(class = "proto-desc",
                     "2006 vs. gewähltes Jahr. Steigende bzw. fallende Linien zeigen die Richtung der Veränderung."),
              tags$span(class = "proto-tag", "Veränderung")),
          div(class = "proto-body", uiOutput(ns("note_p5")),
              div(class = "proto-controls",
                  tags$label("Indikator:"),
                  selectInput(ns("p5_indicator"), NULL,
                              choices = c("Bevölkerung" = "Bevölkerung (Anzahl)"),
                              width = "280px"),
                  tags$label("Rechtes Jahr:"),
                  selectInput(ns("p5_year"), NULL,
                              choices = as.character(2007:2023),
                              selected = "2023", width = "80px")),
              girafeOutput(ns("p5_plot"), width = "100%", height = "400px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: Politik-Briefs"))
      ),
      
      # ============================================================
      # PROTOTYP 06 – Facettenanalyse
      # ============================================================
      div(class = "proto-card proto-facet",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("table-cells"), tags$span("Facettenanalyse")),
              div(class = "proto-num", "06"),
              tags$h3(class = "proto-title",
                      "Small Multiples — ein Panel pro Landkreis"),
              tags$p(class = "proto-desc",
                     "14 Mini-Diagramme, Nord–Süd sortiert. Farben = geografische Zone."),
              tags$span(class = "proto-tag", "Facette")),
          div(class = "proto-body", uiOutput(ns("note_p7")),
              div(class = "proto-controls",
                  tags$label("Indikator:"),
                  selectInput(ns("p7_indicator"), NULL,
                              choices = c("Bevölkerung" = "Bevölkerung (Anzahl)"),
                              width = "280px")),
              plotOutput(ns("p7_plot"), width = "100%", height = "520px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: detaillierte Berichte"))
      ),
      
      # ============================================================
      # PROTOTYP 07 – Raumanalyse
      # ============================================================
      div(class = "proto-card proto-spatial",
          div(class = "proto-head",
              div(class = "proto-category",
                  icon("map-location-dot"), tags$span("Raumanalyse")),
              div(class = "proto-num", "07"),
              tags$h3(class = "proto-title", "Nord–Süd sortierte Balken"),
              tags$p(class = "proto-desc",
                     "Balken nach geografischer Breite sortiert (Norden oben). Blau → Koralle-Verlauf."),
              tags$span(class = "proto-tag", "geografisch")),
          div(class = "proto-body", uiOutput(ns("note_p8")),
              div(class = "proto-controls",
                  tags$label("Indikator:"),
                  selectInput(ns("p8_indicator"), NULL,
                              choices = c("Bevölkerung" = "Bevölkerung (Anzahl)"),
                              width = "280px"),
                  tags$label("Jahr:"),
                  selectInput(ns("p8_year"), NULL,
                              choices = as.character(2006:2023),
                              selected = "2023", width = "80px")),
              girafeOutput(ns("p8_plot"), width = "100%", height = "400px")),
          div(class = "proto-foot",
              tags$span(class = "use-case",
                        "\U0001f4a1 Ideal für: räumliche Berichte"))
      )
    )
    # Kein <script> mehr — kein Select-Button, keine Auswahl-Logik nötig
  )
}