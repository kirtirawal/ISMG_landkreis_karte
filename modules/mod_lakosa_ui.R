# ============================================================
# LäKoSA Real Data UI — Version 3
# ============================================================
# - navset_card_tab (no class=, no selected=, no wrapper)
# - 2-column plot grid via .lakosa-plot-grid
# - "Was zeigt dieser Chart?" descriptions under each plot
# - Study Highlights KPI row wired in
# - "Über das Projekt" card now includes website link + participation CTA
# ============================================================

mod_lakosa_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(
      class = "lakosa-page",
      
      # ==================================================
      # HERO
      # ==================================================
      div(
        class = "lakosa-hero",
        
        div(
          class = "lakosa-hero-content",
          tags$span(
            class = "lakosa-hero-kicker",
            "LÄKOSA GESUNDHEITS- UND VERSORGUNGSMONITOR"
          ),
          tags$h1(
            "Gesundheit, Versorgung und Wohlbefinden"
          ),
          tags$p(
            paste(
              "Interaktive Erkundung von Zugang zur Gesundheitsversorgung,",
              "Patientenerfahrungen und demografischen Merkmalen",
              "aus der LäKoSA-Studie."
            )
          )
        ),
        
        div(
          class = "lakosa-hero-info",
          tags$h3("Studieninformationen"),
          tags$p(tags$strong("Projekt: "), "LäKoSA"),
          tags$p(
            tags$strong("Schwerpunkt: "),
            "Zugang zur Gesundheitsversorgung und Bevölkerungsgesundheit"
          ),
          tags$p(
            tags$strong("Datensatz: "),
            "Aufbereiteter Forschungsauszug"
          ),
          tags$p(
            tags$strong("Teilnehmende: "),
            "300 Befragte"
          ),
          tags$button(
            type = "button",
            class = "lakosa-home-button navigation-card",
            `data-target` = "landing",
            icon("house"),
            tags$span("Zur Startseite")
          )
        )
      ),
      
      # ==================================================
      # TABS
      # ==================================================
      bslib::navset_card_tab(
        
        id = ns("lakosa_tabs"),
        
        # ================================================
        # TAB 1 — ÜBERBLICK
        # ================================================
        bslib::nav_panel(
          title = tagList(icon("circle-info"), "Überblick"),
          
          div(
            class = "lakosa-tab-content",
            
            # ------------------------------------------------------------
            # "Über das Projekt" — with website link + participation CTA
            # ------------------------------------------------------------
            div(
              class = "overview-card project-card",
              h2("Über das Projekt"),
              
              p(
                paste(
                  "Die LäKoSA-Studie untersucht die Erfahrungen von Personen",
                  "mit dem Zugang zur Gesundheitsversorgung, der Inanspruchnahme",
                  "medizinischer Leistungen und dem Gesundheitszustand."
                )
              ),
              
              p(
                paste(
                  "Das Projekt liefert wissenschaftliche Evidenz für Forschung,",
                  "Gesundheitsplanung und zukünftige Versorgungsstrategien."
                )
              ),
              
              # ---- Official project website ----
              div(
                class = "project-link-box",
                icon("globe"),
                tags$span("Offizielle Projektseite:"),
                tags$a(
                  href   = "https://isa-ummd.de/laekosa/",
                  target = "_blank",
                  rel    = "noopener noreferrer",
                  class  = "project-link",
                  "LäKoSA Projektwebsite"
                )
              ),
              
              hr(),
              
              # ---- Participation call to action ----
              div(
                class = "participation-box",
                div(class = "participation-icon", icon("people-group")),
                
                div(
                  class = "participation-content",
                  tags$h4("Möchten Sie selbst teilnehmen?"),
                  tags$p(
                    paste(
                      "Interessieren Sie sich für Gesundheitsversorgung,",
                      "Patientenerfahrungen und wissenschaftliche Forschung?",
                      "Die LäKoSA-Studie freut sich über interessierte Personen",
                      "und Kooperationspartner."
                    )
                  ),
                  tags$a(
                    href   = "https://isa-ummd.de/laekosa/#kontakt",
                    target = "_blank",
                    rel    = "noopener noreferrer",
                    class  = "participation-button",
                    icon("paper-plane"),
                    "Kontakt zur Studie"
                  )
                )
              )
            ),
            
            # ------------------------------------------------------------
            # "Was enthält der Datensatz?"
            # ------------------------------------------------------------
            div(
              class = "overview-card",
              h2("Was enthält der Datensatz?"),
              p(
                paste(
                  "Der Datensatz kombiniert Informationen zur",
                  "Inanspruchnahme medizinischer Leistungen, zur",
                  "Zufriedenheit mit der Versorgung sowie zu",
                  "demografischen Merkmalen."
                )
              ),
              tags$ul(
                tags$li("Zugang zur Gesundheitsversorgung und Verfügbarkeit von Leistungen"),
                tags$li("Zufriedenheit mit medizinischen Leistungen"),
                tags$li("Fahrzeiten zu medizinischen Einrichtungen"),
                tags$li("Inanspruchnahme von Notfall-, Krankenhaus- und Rehabilitationsleistungen"),
                tags$li("Demografische und sozioökonomische Informationen")
              )
            ),
            
            uiOutput(ns("dataset_summary")),
            
            div(
              class = "lakosa-section-heading",
              h2("Zentrale Kennzahlen"),
              p("Ein schneller Überblick über die wichtigsten Befunde.")
            ),
            
            uiOutput(ns("study_highlights")),
            
            div(
              class = "lakosa-topic-grid",
              
              overview_feature(
                "Medizinische Versorgung",
                "Zugang zu medizinischen Leistungen, Zufriedenheit mit der Versorgung und Fahrzeiten.",
                "user-doctor"
              ),
              
              overview_feature(
                "Teilnehmerprofil",
                "Alter, Geschlecht, Erwerbssituation, Versicherung und Wohnsituation.",
                "people-group"
              )
            ),
            
            div(
              class = "overview-card",
              h2("Wie sind die Ergebnisse zu lesen?"),
              tags$ol(
                tags$li("Wählen Sie einen Bereich aus."),
                tags$li("Betrachten Sie die Verteilungen und Kennzahlen."),
                tags$li("Vergleichen Sie Gruppen von Teilnehmenden."),
                tags$li(
                  paste(
                    "Verwenden Sie die Ergebnisse als beschreibende",
                    "Hinweise und nicht als Ursachennachweis."
                  )
                )
              )
            ),
            
            div(
              class = "overview-card",
              h2("Fehlende und nicht anwendbare Antworten"),
              p(
                paste(
                  "Bestimmte Werte stehen für übersprungene Fragen",
                  "oder nicht anwendbare Antworten und werden nicht",
                  "als gültige Messwerte behandelt."
                )
              ),
              tags$table(
                class = "table",
                tags$tr(tags$th("Code"), tags$th("Bedeutung")),
                tags$tr(tags$td("900"), tags$td("Keine Antwort")),
                tags$tr(tags$td("996"), tags$td("Aufgrund der Fragebogenlogik übersprungen")),
                tags$tr(tags$td("997"), tags$td("Nicht zutreffend")),
                tags$tr(tags$td("998"), tags$td("Kann nicht beurteilt werden"))
              )
            ),
            
            div(
              class = "overview-disclaimer",
              icon("circle-info"),
              div(
                tags$strong("Hinweis zur Interpretation"),
                tags$p(
                  paste(
                    "Die dargestellten Ergebnisse sind beschreibend und",
                    "explorativ. Sie fassen Antworten der Teilnehmenden",
                    "zusammen und stellen weder klinische Diagnosen noch",
                    "kausale Zusammenhänge dar."
                  )
                )
              )
            )
          )
        ),
        
        # ================================================
        # TAB 2 — MEDIZINISCHE VERSORGUNG
        # ================================================
        bslib::nav_panel(
          title = tagList(icon("user-doctor"), "Medizinische Versorgung"),
          
          div(
            class = "lakosa-tab-content",
            
            uiOutput(ns("care_kpi_cards")),
            
            # ---- Row 1: Access | GP vs Specialist ----
            div(
              class = "lakosa-plot-grid",
              
              div(
                class = "overview-card",
                h2("Zugang zur Versorgung"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Diese Grafik fasst die",
                    "Zufriedenheit mit dem Zugang zu Hausarzt, Facharzt,",
                    "Informationen und Notfallversorgung zusammen.",
                    "Höhere Werte bedeuten eine bessere Bewertung."
                  )
                ),
                plotOutput(ns("care_access_plot"), height = "360px")
              ),
              
              div(
                class = "overview-card",
                h2("Hausarzt vs. Facharzt"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die Boxplots vergleichen die",
                    "Verteilung der Zufriedenheitswerte für Hausärzte und",
                    "Fachärzte. Die Linie in der Mitte ist der Median."
                  )
                ),
                plotOutput(ns("gp_specialist_plot"), height = "360px")
              )
            ),
            
            # ---- Row 2: Travel | Utilisation ----
            div(
              class = "lakosa-plot-grid",
              
              div(
                class = "overview-card",
                h2("Fahrzeiten zu medizinischen Einrichtungen"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die mediane Fahrzeit in Minuten",
                    "zu verschiedenen medizinischen Einrichtungen. Nützlich",
                    "für die Einschätzung der Erreichbarkeit im Versorgungsgebiet."
                  )
                ),
                plotOutput(ns("travel_time_plot"), height = "400px")
              ),
              
              div(
                class = "overview-card",
                h2("Inanspruchnahme medizinischer Leistungen"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die durchschnittliche Nutzung von",
                    "Notfallversorgung, stationären Aufenthalten und",
                    "ambulanter Versorgung."
                  )
                ),
                plotOutput(ns("utilisation_plot"), height = "400px")
              )
            ),
            
            # ---- Row 3: Waiting time (full width) ----
            div(
              class = "overview-card",
              h2("Wartezeiten auf Termine"),
              p(
                class = "plot-description",
                paste(
                  "Was zeigt dieser Chart? Die Bewertung der Wartezeiten auf",
                  "Haus- und Facharzttermine. Höhere Werte stehen für längere",
                  "gefühlte Wartezeiten."
                )
              ),
              plotOutput(ns("waiting_time_plot"), height = "340px")
            )
          )
        ),
        
        # ================================================
        # TAB 3 — TEILNEHMERPROFIL
        # ================================================
        bslib::nav_panel(
          title = tagList(icon("people-group"), "Teilnehmerprofil"),
          
          div(
            class = "lakosa-tab-content",
            
            # ---- Row 1: Age | Gender ----
            div(
              class = "lakosa-plot-grid",
              
              div(
                class = "overview-card",
                h2("Altersverteilung"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die Altersverteilung der",
                    "Teilnehmenden in Jahren. Die Balken zeigen, wie viele",
                    "Personen in jedes Altersintervall fallen."
                  )
                ),
                plotOutput(ns("age_plot"), height = "320px")
              ),
              
              div(
                class = "overview-card",
                h2("Geschlechterverteilung"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die Anzahl der Teilnehmenden",
                    "nach Geschlecht."
                  )
                ),
                plotOutput(ns("gender_plot"), height = "320px")
              )
            ),
            
            # ---- Row 2: Employment | Insurance ----
            div(
              class = "lakosa-plot-grid",
              
              div(
                class = "overview-card",
                h2("Erwerbssituation"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die Verteilung der Erwerbs-",
                    "situation (Vollzeit, Teilzeit, Rente, Arbeitssuchend usw.)."
                  )
                ),
                plotOutput(ns("employment_plot"), height = "340px")
              ),
              
              div(
                class = "overview-card",
                h2("Krankenversicherung"),
                p(
                  class = "plot-description",
                  paste(
                    "Was zeigt dieser Chart? Die Verteilung der Art der",
                    "Krankenversicherung (gesetzlich, privat)."
                  )
                ),
                plotOutput(ns("insurance_plot"), height = "340px")
              )
            ),
            
            # ---- Row 3: Living situation (full width) ----
            div(
              class = "overview-card",
              h2("Wohnsituation"),
              p(
                class = "plot-description",
                paste(
                  "Was zeigt dieser Chart? Die Wohnsituation erlaubt",
                  "Mehrfachantworten (z. B. allein lebend und mit Familie).",
                  "Dargestellt wird die Häufigkeit jeder Nennung."
                )
              ),
              plotOutput(ns("living_plot"), height = "360px")
            )
          )
        )
      )
    )
  )
}