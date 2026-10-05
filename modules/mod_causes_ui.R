# ============================================================
# Causes Module UI
# ============================================================

mod_causes_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    tags$style(HTML("
      .causes-plot-wrap svg { width: 100% !important; height: 100% !important; }
      .causes-plot-wrap .girafe_container_std { width: 100% !important; }
    ")),
    
    tags$script(HTML("
      (function initTooltips() {
        function run() {
          if (typeof bootstrap === 'undefined') return;
          document
            .querySelectorAll('[data-bs-toggle=\"tooltip\"]')
            .forEach(function (el) {
              if (el._tooltip) el._tooltip.dispose();
              el._tooltip = new bootstrap.Tooltip(el);
            });
        }
        document.addEventListener('DOMContentLoaded', run);
        document.addEventListener('shiny:connected', run);
        document.addEventListener('shiny:value', run);
        document.addEventListener('shiny:inputchanged', run);
      })();
    ")),
    
    div(
      class = "causes-page",
      
      # ==========================================
      # HERO
      # ==========================================
      div(
        class = "causes-hero",
        div(
          class = "causes-hero-content",
          tags$span(class = "causes-eyebrow", "MORTALITY SURVEILLANCE DASHBOARD"),
          tags$h1("Mortality Patterns and Causes of Death in Germany"),
          tags$p(paste("Interactive analysis of mortality, ICD-10 diagnoses,",
                       "avoidable mortality and regional differences."))
        ),
        div(
          class = "causes-study-box",
          tags$h3("Study Information"),
          tags$p(tags$strong("Author: "), "Dr. Jane Doe (Placeholder)"),
          tags$p(tags$strong("Institution: "),
                 "Institut für Sozialmedizin und Gesundheitssystemforschung (ISMG)"),
          tags$p(tags$strong("University: "),
                 "Otto-von-Guericke Universität Magdeburg"),
          tags$p(tags$strong("Data Source: "),
                 "Destatis • ICD-10 Statistics • 2021–2024"),
          tags$p(tags$strong("Status: "), "Demonstration Version")
        )
      ),
      
      # ==========================================
      # TABS
      # ==========================================
      div(
        class = "causes-tabs",
        bslib::navset_tab(
          id = ns("causes_view"),
          selected = "overview",
          
          # ------------------------------------------
          # TAB 1: OVERVIEW
          # ------------------------------------------
          bslib::nav_panel(
            title = tagList(icon("circle-info"), "Überblick"),
            value = "overview",
            div(
              class = "causes-overview",
              div(class = "overview-card",
                  h2("Research Question"),
                  p(paste("How do mortality patterns vary across Germany's",
                          "federal states and which diagnoses contribute",
                          "most strongly to regional differences?"))),
              div(class = "overview-card",
                  h2("Data Source"),
                  tags$ul(
                    tags$li("Destatis Mortality Statistics"),
                    tags$li("ICD-10 Classification"),
                    tags$li("Federal States of Germany"),
                    tags$li("Years 2021–2024"))),
              div(class = "overview-features",
                  overview_feature("Geographic Distribution",
                                   "Shows mortality rates across Germany and identifies regional hotspots.",
                                   "map-location-dot"),
                  overview_feature("Trend Analysis",
                                   "Shows changes in mortality indicators across multiple years.",
                                   "chart-line"),
                  overview_feature("Top Diagnoses",
                                   "Compares leading causes of death against Germany.",
                                   "ranking-star"),
                  overview_feature("Avoidable Mortality",
                                   "Highlights potentially preventable mortality.",
                                   "shield-heart")),
              div(class = "demo-disclaimer",
                  tags$strong("Demonstration Notice"),
                  tags$p(paste("This dashboard is intended solely for demonstration",
                               "purposes. Author information, study metadata and",
                               "project descriptions are placeholders and should",
                               "be replaced before publication.")))
            )
          ),
          
          # ------------------------------------------
          # TAB 2: VISUALIZATIONS
          # ------------------------------------------
          bslib::nav_panel(
            title = tagList(icon("chart-column"), "Visualisierungen"),
            value = "visualizations",
            
            div(
              id = ns("main_wrapper"),
              class = "causes-container",
              
              # ---- Top Bar / Toggles ----
              div(
                class = "causes-topbar",
                div(class = "brand-title",
                    span("MORTA-STAT"),
                    span(class = "brand-badge", "v4.2 · Destatis")),
                div(class = "topbar-actions",
                    tags$button(
                      id = ns("theme_toggle"),
                      class = "action-btn",
                      onclick = sprintf("
                        var container = document.getElementById('%s');
                        var isLight = container.classList.toggle('light-mode');
                        this.innerHTML = isLight ? '<span>🌙</span> Dark' : '<span>☀️</span> Light';
                        Shiny.setInputValue('%s', isLight ? 'light' : 'dark', {priority: 'event'});
                      ", ns("main_wrapper"), ns("cv_theme_mode")),
                      HTML("<span>☀️</span> Light")),
                    tags$button(
                      id = ns("lang_toggle"),
                      class = "action-btn",
                      onclick = sprintf("
                        var isDE = this.getAttribute('data-lang') !== 'en';
                        this.setAttribute('data-lang', isDE ? 'en' : 'de');
                        this.innerHTML = isDE ? '<span>🇩🇪</span> DE' : '<span>🇬🇧</span> EN';
                        Shiny.setInputValue('%s', isDE ? 'en' : 'de', {priority: 'event'});
                        document.querySelectorAll('[data-de]').forEach(function(el) {
                          el.textContent = isDE ? el.getAttribute('data-en') : el.getAttribute('data-de');
                        });
                      ", ns("cv_lang")),
                      `data-lang` = "de",
                      HTML("<span>🇬🇧</span> EN")))
              ),
              
              # ---- Controls Panel ----
              div(
                class = "causes-controls",
                div(class = "controls-title",
                    tags$span(`data-de` = "Parameter & Filter",
                              `data-en` = "Parameters & Filters",
                              "Parameter & Filter"),
                    tags$span(style = "font-size: 0.68rem; color: var(--text-muted);",
                              "Live Reactive")),
                fluidRow(
                  column(
                    4,
                    tags$label(class = "form-label",
                               tags$span(`data-de` = "Berichtsjahr",
                                         `data-en` = "Year",
                                         "Berichtsjahr")),
                    selectInput(ns("cv_year"), NULL,
                                choices = c(2021, 2022, 2023, 2024),
                                selected = 2024, width = "100%")),
                  column(
                    8,
                    tags$label(class = "form-label",
                               tags$span(`data-de` = "Kennzahl",
                                         `data-en` = "Metric",
                                         "Kennzahl")),
                    selectInput(
                      ns("cv_metric"), NULL,
                      choices = c(
                        "Altersstandardisierte Rate je 100.000" =
                          "sterbefaelle_je_100k_altersstand",
                        "Rohe Rate je 100.000"                  =
                          "sterbefaelle_je_100k",
                        "Sterbefälle (absolut)"                 =
                          "sterbefaelle"
                      ),
                      selected = "sterbefaelle_je_100k_altersstand",
                      width = "100%"))),
                
                div(style = "margin-top: 8px;",
                    tags$label(class = "form-label",
                               tags$span(`data-de` = "ICD-10 Diagnosekapitel",
                                         `data-en` = "ICD-10 Chapter",
                                         "ICD-10 Diagnosekapitel")),
                    selectInput(ns("cv_icd"), NULL,
                                choices = NULL, width = "100%",
                                selectize = FALSE)),
                
                div(class = "state-pill-label",
                    tags$span(`data-de` = "Fokus-Bundesland:",
                              `data-en` = "Select State:",
                              "Fokus-Bundesland:"),
                    tags$span(style = "color: var(--accent-teal);", "16 Länder")),
                
                div(
                  class = "state-pill-row",
                  lapply(list(
                    c("DE-BW","BW"), c("DE-BY","BY"), c("DE-BE","BE"), c("DE-BB","BB"),
                    c("DE-HB","HB"), c("DE-HH","HH"), c("DE-HE","HE"), c("DE-MV","MV"),
                    c("DE-NI","NI"), c("DE-NW","NW"), c("DE-RP","RP"), c("DE-SL","SL"),
                    c("DE-SN","SN"), c("DE-ST","ST"), c("DE-SH","SH"), c("DE-TH","TH")
                  ), function(s) {
                    tags$span(
                      class = paste0("state-pill",
                                     if (s[1] == "DE-ST") " active" else ""),
                      `data-code` = s[1],
                      onclick = paste0(
                        "Shiny.setInputValue('", ns("cv_state_click"),
                        "','", s[1], "',{priority:'event'})"),
                      s[2])
                  })
                )
              ),
              
              # ---- KPI Cards ----
              uiOutput(ns("cv_kpi_boxes")),
              
              # ---- Methodology accordion ----
              div(class = "methodology-accordion",
                  bslib::accordion(
                    id   = ns("methodology"),
                    open = FALSE,
                    bslib::accordion_panel(
                      title = tagList(icon("book"), " Methodik & Definitionen"),
                      value = "methodology_main",
                      tags$h6("Was bedeutet altersstandardisiert?"),
                      tags$p(paste("Die altersstandardisierte Rate entfernt den Einfluss",
                                   "unterschiedlicher Altersstrukturen zwischen Regionen.",
                                   "Dadurch werden Bundesländer fair vergleichbar, unabhängig",
                                   "davon, ob ihre Bevölkerung im Schnitt älter oder jünger ist.")),
                      tags$h6("Was bedeutet 'vermeidbare Mortalität'?"),
                      tags$p(paste("Todesfälle, die durch Prävention, frühzeitige Diagnose",
                                   "oder wirksame Behandlung möglicherweise hätten verhindert",
                                   "werden können. Die OECD unterscheidet zwischen präventabler",
                                   "und behandelbarer Mortalität.")),
                      tags$h6("Wie werden die Diagnosen klassifiziert?"),
                      tags$p(paste("Alle Diagnosen folgen der ICD-10-Klassifikation der",
                                   "Weltgesundheitsorganisation (WHO). Kapitel wie I00-I99",
                                   "(Kreislaufsystem) und C00-D48 (Neubildungen) bündeln",
                                   "verwandte Krankheitsbilder.")),
                      tags$h6("Welche Jahre stehen zur Verfügung?"),
                      tags$p(paste("Die Daten umfassen die Berichtsjahre 2021 bis 2024.",
                                   "Für einzelne ICD-Kategorien liegen nicht alle Jahre vor;",
                                   "die Verfügbarkeit wird im ICD-Auswahlfeld angezeigt."))
                    )
                  )),
              
              # ---- Global methodological note ----
              div(class = "global-interpretation",
                  tags$b("Interpretation:"),
                  " Vergleiche zwischen Bundesländern sollten bevorzugt mit",
                  " altersstandardisierten Mortalitätsraten durchgeführt werden,",
                  " da Unterschiede in der Altersstruktur berücksichtigt werden."),
              
              # =========================================================
              # ROW A — Map  ‖  Diagnosen mit größter Abweichung
              # =========================================================
              fluidRow(
                column(
                  6,
                  div(class = "causes-card",
                      div(class = "causes-card-header",
                          span(class = "icon-tag", "🗺️"),
                          tagList(
                            tags$span(`data-de` = "Geografische Verteilung",
                                      `data-en` = "Geographic Distribution",
                                      "Geografische Verteilung"),
                            info_icon(paste(
                              "Rot bedeutet über dem Bundesdurchschnitt, Blau unter",
                              "dem Bundesdurchschnitt. Die Farben zeigen relative",
                              "Unterschiede und keine absolute Risikoaussage."))),
                          uiOutput(ns("cv_map_badge"))),
                      div(class = "causes-plot-wrap",
                          girafeOutput(ns("cv_map"),
                                       width = "100%", height = "460px")))),
                column(
                  6,
                  div(class = "causes-card",
                      div(class = "causes-card-header",
                          span(class = "icon-tag", "📋"),
                          tagList(
                            tags$span(`data-de` = "Diagnosen mit größter Abweichung",
                                      `data-en` = "Diagnoses with Largest Deviation",
                                      "Diagnosen mit größter Abweichung"),
                            info_icon(paste(
                              "Jeder Eintrag vergleicht das ausgewählte Bundesland mit",
                              "dem Bundesdurchschnitt. Je größer der Abstand zwischen",
                              "den Punkten, desto größer die Abweichung.")))),
                      div(class = "causes-plot-wrap",
                          girafeOutput(ns("cv_top10"),
                                       width = "100%", height = "460px"))))
              ),
              
              uiOutput(ns("cv_map_interp")),
              
              # =========================================================
              # ROW B — Trend  ‖  Einfluss der Altersstruktur
              # =========================================================
              fluidRow(
                column(
                  6,
                  div(class = "causes-card",
                      div(class = "causes-card-header",
                          span(class = "icon-tag", "📈"),
                          tagList(
                            tags$span(`data-de` = "Verlauf 2021–2024",
                                      `data-en` = "Trend 2021–2024",
                                      "Verlauf 2021–2024"),
                            info_icon(paste(
                              "Zeigt die Entwicklung der Mortalität zwischen 2021 und",
                              "2024. Altersstandardisierte Raten erlauben faire Vergleiche",
                              "zwischen Bundesländern.")))),
                      div(class = "causes-plot-wrap",
                          girafeOutput(ns("cv_trend"),
                                       width = "100%", height = "300px")),
                      uiOutput(ns("cv_trend_summary")))),
                column(
                  6,
                  div(class = "causes-card",
                      div(class = "causes-card-header",
                          span(class = "icon-tag", "⚖️"),
                          tagList(
                            tags$span(`data-de` = "Einfluss der Altersstruktur",
                                      `data-en` = "Impact of Population Age Structure",
                                      "Einfluss der Altersstruktur"),
                            info_icon(paste(
                              "Die altersstandardisierte Rate entfernt Unterschiede in",
                              "der Altersstruktur der Bevölkerung. Für Vergleiche",
                              "zwischen Regionen sollte sie bevorzugt verwendet werden.")))),
                      div(class = "causes-plot-wrap",
                          girafeOutput(ns("cv_dual_bar"),
                                       width = "100%", height = "300px")),
                      uiOutput(ns("cv_age_gap_kpi"))))
              ),
              
              # =========================================================
              # ROW C — Donut  ‖  Beitrag zur erhöhten Mortalität
              # =========================================================
              fluidRow(
                column(
                  6,
                  div(class = "causes-card",
                      div(class = "causes-card-header",
                          span(class = "icon-tag", "🥧"),
                          tagList(
                            tags$span(`data-de` = "Verteilung der Todesursachen",
                                      `data-en` = "Distribution of Causes of Death",
                                      "Verteilung der Todesursachen"),
                            info_icon(paste(
                              "Zeigt die Verteilung der wichtigsten Todesursachen im",
                              "ausgewählten Bundesland. 'Andere Ursachen' fasst alle",
                              "verbleibenden Diagnosen zusammen.")))),
                      tags$p("Top 8 Ursachen im ausgewählten Bundesland",
                             class = "hint-text"),
                      div(class = "causes-plot-wrap",
                          plotly::plotlyOutput(ns("cv_cause_pie"),
                                               height = "380px")),
                      uiOutput(ns("cv_pie_summary")))),
                column(
                  6,
                  div(class = "causes-card",
                      div(class = "causes-card-header",
                          span(class = "icon-tag", "🔥"),
                          tagList(
                            tags$span(`data-de` = "Beitrag zur erhöhten Mortalität",
                                      `data-en` = "Contribution to Excess Mortality",
                                      "Beitrag zur erhöhten Mortalität"),
                            info_icon(paste(
                              "Zeigt diejenigen Diagnosen, die am stärksten dazu",
                              "beitragen, dass die Mortalität über dem Bundesdurchschnitt",
                              "liegt.")))),
                      div(class = "causes-plot-wrap",
                          girafeOutput(ns("cv_contribution"),
                                       width = "100%", height = "380px"))))
              ),
              
              # =========================================================
              # ROW C.5 — Nationales Ranking
              # =========================================================
              div(class = "causes-card",
                  div(class = "causes-card-header",
                      span(class = "icon-tag", "🏆"),
                      tagList(
                        tags$span(`data-de` = "Nationales Ranking",
                                  `data-en` = "National Ranking",
                                  "Nationales Ranking"),
                        info_icon(paste(
                          "Vergleicht das ausgewählte Bundesland mit allen anderen",
                          "Bundesländern. Rang 1 entspricht der höchsten Mortalität",
                          "innerhalb Deutschlands.")))),
                  div(class = "causes-plot-wrap",
                      girafeOutput(ns("cv_ranking"),
                                   width = "100%", height = "480px"))),
              
              # =========================================================
              # ROW D — Vermeidbare Mortalität
              # =========================================================
              div(class = "causes-card",
                  div(class = "causes-card-header",
                      span(class = "icon-tag", "🛡️"),
                      tagList(
                        tags$span(`data-de` = "Potenziell vermeidbare Sterbefälle",
                                  `data-en` = "Selected Preventable Indicators",
                                  "Potenziell vermeidbare Sterbefälle"),
                        info_icon(paste(
                          "Diese Darstellung enthält ausgewählte Diagnosegruppen, die",
                          "häufig durch Prävention oder bessere Versorgung beeinflusst",
                          "werden können. Sie entspricht nicht der vollständigen",
                          "OECD-Definition vermeidbarer Mortalität.")))),
                  
                  div(class = "interp-box",
                      tags$h5("ℹ️ Was bedeutet 'vermeidbare Mortalität'?",
                              style = "margin-top:0;"),
                      tags$p(paste("Vermeidbare Mortalität umfasst Todesfälle, die durch",
                                   "Prävention, frühzeitige Diagnose oder wirksame",
                                   "Behandlung möglicherweise hätten verhindert",
                                   "werden können.")),
                      tags$ul(
                        tags$li(tags$strong("Prävention: "),
                                "z. B. Tabakkontrolle, Alkoholprävention"),
                        tags$li(tags$strong("Früherkennung: "),
                                "z. B. Krebs-Screenings"),
                        tags$li(tags$strong("Behandlung: "),
                                "z. B. Diabetes- oder COPD-Management")),
                      tags$p(style = "font-size:0.8rem; color:var(--text-muted); margin-bottom:4px;",
                             paste("Hinweis: Diese Sektion deckt nur die im Datensatz",
                                   "vorhandenen ICD-Blöcke ab (F10-F19, K70-K77,",
                                   "J40-J47, E10-E14, S00-T98) und entspricht NICHT",
                                   "der vollständigen OECD/Eurostat-Definition.")),
                      tags$p(style = "font-size:0.78rem; color:var(--text-muted); margin-bottom:0;",
                             paste("Die OECD unterscheidet zwischen präventabler",
                                   "Mortalität (durch Prävention vermeidbar) und",
                                   "behandelbarer Mortalität (durch rechtzeitige,",
                                   "wirksame Behandlung vermeidbar)."))),
                  
                  uiOutput(ns("cv_diagnosis_info")),
                  
                  div(class = "causes-plot-wrap",
                      girafeOutput(ns("cv_avoidable"),
                                   width = "100%", height = "300px"))),
              
              # =========================================================
              # ROW E — Executive Summary
              # =========================================================
              uiOutput(ns("cv_policy_insight"))
            )
          )
        )
      )
    ),
    
    tags$script(HTML(sprintf("
      Shiny.addCustomMessageHandler('%s', function(code) {
        document.querySelectorAll('.state-pill').forEach(function(el) {
          el.classList.toggle('active', el.getAttribute('data-code') === code);
        });
      });

      function fixMobileSelects() {
        document.querySelectorAll('select').forEach(function(el) {
          el.setAttribute('inputmode', 'none');
        });
      }
      document.addEventListener('DOMContentLoaded', fixMobileSelects);
      $(document).on('shiny:connected shiny:value shiny:inputchanged', fixMobileSelects);
    ", ns("update_pills"))))
  )
}