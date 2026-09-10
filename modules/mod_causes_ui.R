mod_causes_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    tags$style(HTML("
      .tab-pane { background: #f0f4f8; padding: 16px 8px; }

      /* Language toggle */
      .lang-toggle-wrap { display: flex; justify-content: flex-end; margin-bottom: 12px; }
      .lang-btn {
        background: #fff; border: 1.5px solid #b0c4e0; border-radius: 20px;
        padding: 4px 14px; font-size: 0.8rem; font-weight: 600; cursor: pointer;
        color: #1a3a5c; transition: all 0.18s; display: flex; align-items: center; gap: 6px;
      }
      .lang-btn:hover { background: #1a3a5c; color: #fff; border-color: #1a3a5c; }

      /* Controls bar */
      .causes-controls {
        background: linear-gradient(135deg, #1a3a5c 0%, #2563a8 60%, #1e7a5e 100%);
        border-radius: 14px; padding: 18px 22px 14px 22px;
        margin-bottom: 20px; box-shadow: 0 4px 18px rgba(26,58,92,0.18);
      }
      .causes-controls .form-label {
        font-size: 0.78rem; color: #c8daf4; margin-bottom: 3px;
        font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em;
      }
      /* KEYBOARD FIX: prevent mobile keyboard on all selects */
      select, .selectize-input input {
        font-size: 16px !important;  /* stops iOS zoom */
      }
      .causes-controls select {
        border-radius: 8px; border: none; font-size: 16px !important;
        background: rgba(255,255,255,0.95); color: #1a3a5c; font-weight: 500;
        -webkit-user-select: none; user-select: none;
        touch-action: manipulation;
      }
      .controls-title {
        color: #fff; font-size: 0.72rem; font-weight: 700;
        text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 12px; opacity: 0.8;
      }

      /* State pills */
      .state-pill-row { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 4px; }
      .state-pill-label {
        color: #c8daf4; font-size: 0.76rem; font-weight: 700;
        text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 5px; display: block;
      }
      .state-pill {
        background: rgba(255,255,255,0.15); color: #fff;
        border: 1.5px solid rgba(255,255,255,0.35); border-radius: 20px;
        padding: 5px 13px; font-size: 0.78rem; cursor: pointer;
        transition: all 0.16s; font-weight: 600; white-space: nowrap;
        -webkit-tap-highlight-color: transparent; touch-action: manipulation;
      }
      .state-pill:hover  { background: rgba(255,255,255,0.9); color: #1a3a5c; }
      .state-pill.active { background: #ffffff; color: #1a3a5c; border-color: #fff;
        box-shadow: 0 2px 8px rgba(0,0,0,0.18); }

      /* Section cards */
      .causes-card {
        background: #ffffff; border-radius: 14px;
        box-shadow: 0 2px 14px rgba(26,58,92,0.08);
        padding: 20px 24px 18px 24px; margin-bottom: 20px;
        border-top: 4px solid #2563a8;
      }
      .causes-card.card-green  { border-top-color: #1e7a5e; }
      .causes-card.card-purple { border-top-color: #6d28d9; }
      .causes-card.card-orange { border-top-color: #c05000; }

      .causes-card-header {
        font-size: 1.02rem; font-weight: 700; color: #1a3a5c;
        border-bottom: 2px solid #eef2fb; padding-bottom: 9px; margin-bottom: 15px;
        display: flex; align-items: center; gap: 8px;
      }

      /* Map info panel: shown on tap/hover */
      .map-info-panel {
        background: #1a3a5c; color: #fff; border-radius: 10px;
        padding: 10px 16px; margin-bottom: 10px; font-size: 0.85rem;
        min-height: 48px; display: flex; align-items: center; gap: 12px;
        box-shadow: 0 2px 8px rgba(26,58,92,0.18);
      }
      .map-info-panel .mip-name { font-weight: 700; font-size: 1rem; }
      .map-info-panel .mip-val  { font-size: 1.3rem; font-weight: 800; color: #93c5fd; }
      .map-info-panel .mip-lbl  { font-size: 0.72rem; color: #93c5fd; }
      .map-info-panel .mip-diff-pos { color: #fca5a5; font-size: 0.76rem; font-weight: 700; }
      .map-info-panel .mip-diff-neg { color: #86efac; font-size: 0.76rem; font-weight: 700; }

      /* Interpretation box */
      .interp-box {
        background: linear-gradient(135deg, #f0f6ff 0%, #e8f5f0 100%);
        border-left: 4px solid #2563a8; border-radius: 0 10px 10px 0;
        padding: 12px 16px; margin-bottom: 14px; font-size: 0.83rem; color: #1a3a5c;
      }
      .interp-box.green-border { border-left-color: #1e7a5e; }
      .interp-box .interp-title {
        font-weight: 700; font-size: 0.88rem; margin-bottom: 5px; display: block;
      }
      .interp-box ul { margin: 4px 0 0 0; padding-left: 16px; }
      .interp-box li { margin-bottom: 3px; line-height: 1.4; }

      /* Info badge */
      .info-badge {
        background: linear-gradient(135deg, #fffbeb 0%, #fff3cd 100%);
        color: #78350f; border: 1px solid #fbbf24; border-radius: 10px;
        padding: 10px 14px; font-size: 0.81rem; margin-bottom: 10px;
      }
      .info-badge .badge-title {
        font-weight: 700; font-size: 0.84rem; margin-bottom: 4px; display: block;
      }

      /* Summary table */
      .causes-summary-table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
      .causes-summary-table th {
        background: #1a3a5c; color: #fff; padding: 8px 10px;
        text-align: left; font-weight: 600; font-size: 0.78rem; white-space: nowrap;
      }
      .causes-summary-table td { padding: 7px 10px; border-bottom: 1px solid #e8eef8; }
      .causes-summary-table tr:hover td { background: #f0f6ff; }
      .causes-summary-table tr.de-row td { background: #fff8e1; font-weight: 700; }
      .causes-summary-table tr.selected-row td { background: #dbeafe; font-weight: 700; }
      .badge-above { background: #fee2e2; color: #be123c; border-radius: 4px;
        padding: 1px 6px; font-size: 0.72rem; font-weight: 700; }
      .badge-below { background: #dcfce7; color: #166534; border-radius: 4px;
        padding: 1px 6px; font-size: 0.72rem; font-weight: 700; }

      /* Plot wrapper */
      .causes-plot-wrap {
        background: #fafbff; border-radius: 10px;
        border: 1px solid #e8eef8; padding: 8px; min-height: 300px;
      }
      .hint-text { font-size: 0.78rem; color: #667788; margin-bottom: 6px; }
      .section-divider { border: none; border-top: 2px dashed #dde8f5; margin: 14px 0; }

      /* Mobile tweaks */
      @media (max-width: 768px) {
        .causes-card { padding: 14px 12px 12px 12px; }
        .causes-controls { padding: 14px 14px 10px 14px; }
        .interp-box { font-size: 0.79rem; padding: 10px 12px; }
      }
    ")),
    
    # ── Language toggle ───────────────────────────────────────────────────────
    div(class = "lang-toggle-wrap",
        tags$button(
          id = ns("lang_toggle"), class = "lang-btn",
          onclick = sprintf("
          var isDE = this.getAttribute('data-lang') !== 'en';
          this.setAttribute('data-lang', isDE ? 'en' : 'de');
          this.innerHTML = isDE ? '<span>&#127465;&#127466;</span> Deutsch'
                                : '<span>&#127468;&#127463;</span> English';
          Shiny.setInputValue('%s', isDE ? 'en' : 'de', {priority: 'event'});
          document.querySelectorAll('[data-de]').forEach(function(el) {
            el.textContent = isDE ? el.getAttribute('data-en') : el.getAttribute('data-de');
          });
        ", ns("cv_lang")),
          `data-lang` = "de",
          HTML("<span>&#127468;&#127463;</span> English")
        )
    ),
    
    # ══ CONTROLS ═════════════════════════════════════════════════════════════
    div(class = "causes-controls",
        div(class = "controls-title",
            tags$span(`data-de`="\u2699\ufe0f Steuerung & Filter",
                      `data-en`="\u2699\ufe0f Controls & Filters",
                      "\u2699\ufe0f Steuerung & Filter")),
        fluidRow(
          column(3,
                 tags$label(class = "form-label",
                            tags$span(`data-de`="\U0001f4c5 Jahr", `data-en`="\U0001f4c5 Year",
                                      "\U0001f4c5 Jahr")),
                 selectInput(ns("cv_year"), NULL,
                             choices = c(2021,2022,2023,2024), selected = 2024, width = "100%")
          ),
          column(5,
                 tags$label(class = "form-label",
                            tags$span(`data-de`="\U0001f9a0 ICD-10 Kapitel",
                                      `data-en`="\U0001f9a0 ICD-10 Chapter",
                                      "\U0001f9a0 ICD-10 Kapitel")),
                 selectInput(ns("cv_icd"), NULL, choices = NULL, width = "100%", selectize = FALSE)
          ),
          column(4,
                 tags$label(class = "form-label",
                            tags$span(`data-de`="\U0001f4ca Kennzahl", `data-en`="\U0001f4ca Metric",
                                      "\U0001f4ca Kennzahl")),
                 selectInput(ns("cv_metric"), NULL,
                             choices = c(
                               "Je 100.000 Einwohner (roh)"        = "sterbefaelle_je_100k",
                               "Je 100.000 (altersstandardisiert)" = "sterbefaelle_je_100k_altersstand"
                             ),
                             selected = "sterbefaelle_je_100k_altersstand", width = "100%")
          )
        ),
        tags$span(class = "state-pill-label",
                  tags$span(`data-de`="\U0001f5fa\ufe0f Bundesland ausw\u00e4hlen:",
                            `data-en`="\U0001f5fa\ufe0f Select State:",
                            "\U0001f5fa\ufe0f Bundesland ausw\u00e4hlen:")),
        div(class = "state-pill-row",
            lapply(list(
              c("DE-BW","BW"), c("DE-BY","BY"), c("DE-BE","BE"), c("DE-BB","BB"),
              c("DE-HB","HB"), c("DE-HH","HH"), c("DE-HE","HE"), c("DE-MV","MV"),
              c("DE-NI","NI"), c("DE-NW","NW"), c("DE-RP","RP"), c("DE-SL","SL"),
              c("DE-SN","SN"), c("DE-ST","ST"), c("DE-SH","SH"), c("DE-TH","TH")
            ), function(s) {
              tags$span(
                class = paste0("state-pill", if (s[1]=="DE-ST") " active" else ""),
                `data-code` = s[1],
                onclick = paste0("Shiny.setInputValue('", ns("cv_state_click"), "','",
                                 s[1], "',{priority:'event'})"),
                s[2]
              )
            })
        )
    ),
    
    # ══ SECTION 1 — TABELLE ══════════════════════════════════════════════════
    div(class = "causes-card",
        div(class = "causes-card-header",
            "\U0001f4cb ",
            tags$span(`data-de`="Sterbef\u00e4lle im \u00dcberblick \u2014 alle Bundesl\u00e4nder",
                      `data-en`="Deaths Overview \u2014 All States",
                      "Sterbef\u00e4lle im \u00dcberblick \u2014 alle Bundesl\u00e4nder")
        ),
        div(class = "info-badge",
            tags$span(class = "badge-title",
                      tags$span(`data-de`="\u2139\ufe0f So lesen Sie diese Tabelle",
                                `data-en`="\u2139\ufe0f How to read this table",
                                "\u2139\ufe0f So lesen Sie diese Tabelle")),
            tags$p(class = "mb-0", style = "margin-top:4px;",
                   tags$span(
                     `data-de`="Die Tabelle zeigt f\u00fcr jedes Bundesland drei Werte: absolute Sterbef\u00e4lle, rohe Rate je 100.000 Einwohner und altersstandardisierte Rate. Deutschland (gelb) dient als fester Vergleichswert. Das gew\u00e4hlte Bundesland (blau) ist hervorgehoben. Rot = \u00fcber dem Bundesdurchschnitt, Gr\u00fcn = darunter.",
                     `data-en`="The table shows three values per state: absolute deaths, crude rate per 100,000, and age-standardised rate. Germany (yellow) is the fixed benchmark. Selected state (blue) is highlighted. Red = above national average, Green = below.",
                     "Die Tabelle zeigt f\u00fcr jedes Bundesland: absolute Sterbef\u00e4lle, rohe Rate je 100.000 und altersstandardisierte Rate. Deutschland (gelb) = Vergleichswert. Gew\u00e4hltes Bundesland (blau) hervorgehoben."
                   )
            )
        ),
        div(style = "overflow-x: auto;", uiOutput(ns("cv_abs_table")))
    ),
    
    # ══ SECTION 2 — KARTE (mit Info-Panel) ═══════════════════════════════════
    div(class = "causes-card card-orange",
        div(class = "causes-card-header",
            "\U0001f5fa\ufe0f ",
            tags$span(`data-de`="Karte: Sterberate nach Bundesland",
                      `data-en`="Map: Death Rate by State",
                      "Karte: Sterberate nach Bundesland")
        ),
        # Mobile info panel — updates when state is clicked
        uiOutput(ns("cv_map_panel")),
        div(class = "interp-box",
            tags$span(class = "interp-title",
                      tags$span(`data-de`="\U0001f50d Wie lesen?",
                                `data-en`="\U0001f50d How to read?",
                                "\U0001f50d Wie lesen?")),
            tags$ul(
              tags$li(tags$span(
                `data-de`="Tippen / Klicken Sie auf ein Bundesland \u2014 der Wert erscheint oben im blauen Panel",
                `data-en`="Tap / Click a state \u2014 the value appears in the blue panel above",
                "Tippen / Klicken Sie auf ein Bundesland \u2014 der Wert erscheint im blauen Panel")),
              tags$li(tags$span(
                `data-de`="Dunklere Farbe = h\u00f6here Sterberate",
                `data-en`="Darker colour = higher death rate",
                "Dunklere Farbe = h\u00f6here Sterberate")),
              tags$li(tags$span(
                `data-de`="Roter Rahmen = aktuell ausgew\u00e4hltes Bundesland",
                `data-en`="Red border = currently selected state",
                "Roter Rahmen = aktuell ausgew\u00e4hltes Bundesland"))
            )
        ),
        div(class = "causes-plot-wrap",
            girafeOutput(ns("cv_map"), width = "100%", height = "340px"))
    ),
    
    # ══ SECTION 3 — DUAL BAR + TREND SIDE BY SIDE ════════════════════════════
    div(class = "causes-card card-green",
        div(class = "causes-card-header",
            "\U0001f4ca ",
            tags$span(`data-de`="Rohe vs. Altersstandardisierte Rate & Zeitreihe",
                      `data-en`="Crude vs. Age-Standardised Rate & Trend",
                      "Rohe vs. Altersstandardisierte Rate & Zeitreihe")
        ),
        div(class = "info-badge",
            tags$span(class = "badge-title",
                      tags$span(`data-de`="\u2139\ufe0f Was ist der Altersunterschied?",
                                `data-en`="\u2139\ufe0f What is the Age Gap?",
                                "\u2139\ufe0f Was ist der Altersunterschied?")),
            tags$p(class = "mb-0", style = "margin-top:4px;",
                   tags$span(
                     `data-de`="Die rohe Rate z\u00e4hlt alle Sterbef\u00e4lle je 100.000 Personen \u2014 unabh\u00e4ngig vom Alter. Die altersstandardisierte Rate bereinigt diesen Alterseffekt. Ein gro\u00dfer Unterschied zeigt, dass die Altersstruktur die Sterberate stark beeinflusst \u2014 typisch f\u00fcr \u00e4ltere Bundesl\u00e4nder wie Sachsen-Anhalt.",
                     `data-en`="The crude rate counts all deaths per 100,000 regardless of age. The age-standardised rate removes this effect. A large gap means age structure strongly drives the death rate \u2014 typical for older states like Saxony-Anhalt.",
                     "Die rohe Rate z\u00e4hlt alle Sterbef\u00e4lle je 100.000. Die altersstandardisierte Rate bereinigt den Alterseffekt. Ein gro\u00dfer Unterschied zeigt: Alter ist hier ein wichtiger Faktor."
                   )
            )
        ),
        fluidRow(
          column(6,
                 div(class = "interp-box",
                     tags$span(class = "interp-title",
                               tags$span(`data-de`="\U0001f50d Balkendiagramm \u2014 Wie lesen?",
                                         `data-en`="\U0001f50d Bar Chart \u2014 How to read?",
                                         "\U0001f50d Balkendiagramm \u2014 Wie lesen?")),
                     tags$ul(
                       tags$li(tags$span(
                         `data-de`="Heller Balken = rohe Rate, dunkler Balken = altersstandardisiert",
                         `data-en`="Light bar = crude rate, dark bar = age-standardised",
                         "Heller Balken = rohe Rate, dunkler Balken = altersstandardisiert")),
                       tags$li(tags$span(
                         `data-de`="Gro\u00dfer Abstand zwischen den Balken = Alter als wichtiger Einflussfaktor",
                         `data-en`="Large gap between bars = age is a major driver",
                         "Gro\u00dfer Abstand = Alter als wichtiger Einflussfaktor")),
                       tags$li(tags$span(
                         `data-de`="Deutschland dient stets als fester Vergleich",
                         `data-en`="Germany is always shown as the fixed benchmark",
                         "Deutschland dient stets als fester Vergleich"))
                     )
                 ),
                 div(class = "causes-plot-wrap",
                     girafeOutput(ns("cv_dual_bar"), width = "100%", height = "300px"))
          ),
          column(6,
                 div(class = "interp-box green-border",
                     tags$span(class = "interp-title",
                               tags$span(`data-de`="\U0001f50d Zeitreihe \u2014 Wie lesen?",
                                         `data-en`="\U0001f50d Trend Line \u2014 How to read?",
                                         "\U0001f50d Zeitreihe \u2014 Wie lesen?")),
                     tags$ul(
                       tags$li(tags$span(
                         `data-de`="Durchgezogene Linie = gew\u00e4hltes Bundesland, gestrichelt = Deutschland",
                         `data-en`="Solid line = selected state, dashed = Germany",
                         "Durchgezogene Linie = Bundesland, gestrichelt = Deutschland")),
                       tags$li(tags$span(
                         `data-de`="N\u00e4hern sich die Linien an? \u2192 Bundesland verbessert sich relativ zum Bund",
                         `data-en`="Lines converging? \u2192 State improving relative to Germany",
                         "Linien n\u00e4hern sich an \u2192 Verbesserung relativ zum Bund")),
                       tags$li(tags$span(
                         `data-de`="W\u00e4chst der Abstand? \u2192 Bundesland verschlechtert sich im Vergleich",
                         `data-en`="Gap growing? \u2192 State worsening compared to Germany",
                         "Abstand w\u00e4chst \u2192 Verschlechterung im Vergleich zum Bund"))
                     )
                 ),
                 div(class = "causes-plot-wrap",
                     girafeOutput(ns("cv_trend"), width = "100%", height = "300px"))
          )
        )
    ),
    
    # ══ SECTION 4 — TOP 10 ═══════════════════════════════════════════════════
    div(class = "causes-card card-purple",
        div(class = "causes-card-header",
            "\U0001f3c6 ",
            tags$span(`data-de`="Top-10-Todesursachen \u2014 Bundesland vs. Bundesdurchschnitt",
                      `data-en`="Top 10 Causes of Death \u2014 State vs. Germany",
                      "Top-10-Todesursachen \u2014 Bundesland vs. Bundesdurchschnitt")
        ),
        div(class = "interp-box",
            tags$span(class = "interp-title",
                      tags$span(`data-de`="\U0001f50d Wie lesen?",
                                `data-en`="\U0001f50d How to read?",
                                "\U0001f50d Wie lesen?")),
            tags$ul(
              tags$li(tags$span(
                `data-de`="Die 10 h\u00e4ufigsten Todesursachen decken \u00fcblicherweise \u00fcber 80% aller Sterbef\u00e4lle ab",
                `data-en`="The top 10 causes typically cover over 80% of all deaths",
                "Top-10-Ursachen decken \u00fcber 80% aller Sterbef\u00e4lle")),
              tags$li(tags$span(
                `data-de`="Roter Balken = Bundesland liegt \u00dcBER dem Bundesdurchschnitt (gestrichelte Linie)",
                `data-en`="Red bar = state is ABOVE the national average (dashed line)",
                "Rot = \u00dcBER Bundesdurchschnitt (gestrichelte Linie)")),
              tags$li(tags$span(
                `data-de`="Gr\u00fcner Balken = Bundesland liegt UNTER dem Bundesdurchschnitt",
                `data-en`="Green bar = state is BELOW the national average",
                "Gr\u00fcn = UNTER Bundesdurchschnitt")),
              tags$li(tags$span(
                `data-de`="Tippen / Hovern Sie \u00fcber einen Balken f\u00fcr genaue Werte",
                `data-en`="Tap / hover over a bar for exact values",
                "Tippen f\u00fcr genaue Werte"))
            )
        ),
        div(class = "causes-plot-wrap",
            girafeOutput(ns("cv_top10"), width = "100%", height = "400px"))
    ),
    
    # ══ JS ════════════════════════════════════════════════════════════════════
    tags$script(HTML(sprintf("
      // Sync state pills
      Shiny.addCustomMessageHandler('%s', function(code) {
        document.querySelectorAll('.state-pill').forEach(function(el) {
          el.classList.toggle('active', el.getAttribute('data-code') === code);
        });
      });

      // Sync metric dropdown labels on lang switch
      Shiny.addCustomMessageHandler('%s', function(opts) {
        var sel = document.getElementById('%s');
        if (!sel) return;
        for (var i = 0; i < sel.options.length; i++) {
          if (opts[i]) sel.options[i].text = opts[i];
        }
      });

      // KEYBOARD FIX: set inputmode=none + readonly on all selects after render
      function fixMobileSelects() {
        document.querySelectorAll('select').forEach(function(el) {
          el.setAttribute('inputmode', 'none');
        });
      }
      // Run on load and whenever Shiny updates the DOM
      document.addEventListener('DOMContentLoaded', fixMobileSelects);
      $(document).on('shiny:connected shiny:value shiny:inputchanged', fixMobileSelects);
      setTimeout(fixMobileSelects, 800);
      setTimeout(fixMobileSelects, 2000);
    ", ns("update_pills"), ns("update_metric_labels"), ns("cv_metric"))))
  )
}