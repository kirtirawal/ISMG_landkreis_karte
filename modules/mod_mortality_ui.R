mod_causes_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    # ── Extra CSS for this tab ─────────────────────────────────────────────────
    tags$style(HTML("

      /* ── Reading guide / insight box ── */
      .insight-box {
        background: linear-gradient(135deg, #f0f6ff 0%, #e8f0fb 100%);
        border-left: 4px solid var(--top-bar-blue);
        border-radius: 0 10px 10px 0;
        padding: 10px 14px;
        font-size: 0.82rem;
        color: var(--txt-primary);
        margin-bottom: 10px;
        transition: background 0.25s;
      }
      body.dark-mode .insight-box {
        background: linear-gradient(135deg, #0d1b2e 0%, #1a2744 100%);
        border-left-color: var(--top-bar-blue);
      }
      .insight-box .insight-title {
        font-weight: 700;
        font-size: 0.84rem;
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 6px;
      }
      .insight-box ul {
        margin: 4px 0 0 0;
        padding-left: 16px;
        line-height: 1.7;
      }

      /* ── How-to-read legend strip ── */
      .legend-strip {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        align-items: center;
        padding: 8px 12px;
        background: var(--bg-card2);
        border-radius: 8px;
        font-size: 0.78rem;
        color: var(--txt-secondary);
        margin-bottom: 8px;
        border: 1px solid var(--border-plot);
      }
      .legend-item {
        display: flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
      }
      .legend-dot {
        width: 12px; height: 12px;
        border-radius: 50%;
        flex-shrink: 0;
      }
      .legend-line {
        width: 22px; height: 3px;
        flex-shrink: 0;
      }
      .legend-dash {
        width: 22px; height: 0;
        border-top: 2px dashed #555;
        flex-shrink: 0;
      }

      /* ── Side-by-side section row ── */
      .section-row { margin-bottom: 20px; }

      /* ── Top-10 bar colour legend ── */
      .top10-legend {
        display: flex; gap: 16px; margin-bottom: 8px;
        font-size: 0.78rem; color: var(--txt-secondary);
      }
      .top10-legend .leg-above { color: #c0392b; font-weight: 700; }
      .top10-legend .leg-below { color: #27ae60; font-weight: 700; }

      /* ── Section sub-title (small text under card header) ── */
      .card-subtext {
        font-size: 0.78rem;
        color: var(--txt-muted);
        margin-top: -8px;
        margin-bottom: 12px;
        line-height: 1.5;
      }
    ")),
    
    # ── Dark mode + Language toggles ──────────────────────────────────────────
    div(style = "display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;",
        dark_mode_toggle_btn(),
        tags$button(
          id      = ns("lang_toggle"),
          class   = "lang-btn",
          onclick = sprintf("
          var isDE = this.getAttribute('data-lang') !== 'en';
          this.setAttribute('data-lang', isDE ? 'en' : 'de');
          this.innerHTML = isDE
            ? '<span>\U0001f1e9\U0001f1ea</span> Deutsch'
            : '<span>\U0001f1ec\U0001f1e7</span> English';
          Shiny.setInputValue('%s', isDE ? 'en' : 'de', {priority: 'event'});
          document.querySelectorAll('[data-de]').forEach(function(el) {
            el.textContent = isDE ? el.getAttribute('data-en') : el.getAttribute('data-de');
          });
        ", ns("cv_lang")),
          `data-lang` = "de",
          tags$span("\U0001f1ec\U0001f1e7"), " English"
        )
    ),
    
    # ══════════════════════════════════════════════════════════════════════════
    # CONTROLS BAR
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "causes-controls",
        div(class = "controls-title",
            tags$span(`data-de`="\u2699\ufe0f Steuerung & Filter",
                      `data-en`="\u2699\ufe0f Controls & Filters",
                      "\u2699\ufe0f Steuerung & Filter")),
        fluidRow(
          column(3,
                 tags$label(class = "form-label",
                            tags$span(`data-de`="\U0001f4c5 Jahr",
                                      `data-en`="\U0001f4c5 Year", "\U0001f4c5 Jahr")),
                 selectInput(ns("cv_year"), NULL,
                             choices = c(2021,2022,2023,2024), selected = 2024,
                             width = "100%")
          ),
          column(5,
                 tags$label(class = "form-label",
                            tags$span(`data-de`="\U0001f9a0 ICD-10 Kapitel",
                                      `data-en`="\U0001f9a0 ICD-10 Chapter",
                                      "\U0001f9a0 ICD-10 Kapitel")),
                 selectInput(ns("cv_icd"), NULL, choices = NULL,
                             width = "100%", selectize = FALSE)
          ),
          column(4,
                 tags$label(class = "form-label",
                            tags$span(`data-de`="\U0001f4ca Kennzahl",
                                      `data-en`="\U0001f4ca Metric", "\U0001f4ca Kennzahl")),
                 selectInput(ns("cv_metric"), NULL,
                             choices = c(
                               "Sterbef\u00e4lle (absolut)"             = "sterbefaelle",
                               "Je 100.000 Einwohner (roh)"             = "sterbefaelle_je_100k",
                               "Je 100.000 (altersstandardisiert)"      = "sterbefaelle_je_100k_altersstand"
                             ),
                             selected = "sterbefaelle_je_100k_altersstand",
                             width = "100%")
          )
        ),
        tags$span(class = "state-pill-label",
                  tags$span(`data-de`="\U0001f5fa\ufe0f Bundesland ausw\u00e4hlen (anklicken):",
                            `data-en`="\U0001f5fa\ufe0f Select State (click to highlight):",
                            "\U0001f5fa\ufe0f Bundesland ausw\u00e4hlen (anklicken):")),
        div(class = "state-pill-row",
            lapply(list(
              c("DE-BW","BW"), c("DE-BY","BY"), c("DE-BE","BE"), c("DE-BB","BB"),
              c("DE-HB","HB"), c("DE-HH","HH"), c("DE-HE","HE"), c("DE-MV","MV"),
              c("DE-NI","NI"), c("DE-NW","NW"), c("DE-RP","RP"), c("DE-SL","SL"),
              c("DE-SN","SN"), c("DE-ST","ST"), c("DE-SH","SH"), c("DE-TH","TH")
            ), function(s) {
              tags$span(
                class       = paste0("state-pill", if (s[1]=="DE-ST") " active" else ""),
                `data-code` = s[1],
                onclick     = paste0("Shiny.setInputValue('", ns("cv_state_click"), "','",
                                     s[1], "',{priority:'event'})"),
                s[2]
              )
            })
        )
    ),
    
    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 1 — KPI + MAP  (unchanged as requested)
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "causes-card",
        div(class = "causes-card-header",
            "\U0001f4cd\u00a0",
            tags$span(`data-de`="\u00dcberblick: Bundesland vs. Deutschland",
                      `data-en`="Overview: Selected State vs. Germany",
                      "\u00dcberblick: Bundesland vs. Deutschland")
        ),
        fluidRow(
          column(4,
                 uiOutput(ns("cv_kpi_boxes")),
                 hr(class = "section-divider"),
                 div(class = "info-badge",
                     tags$span(class = "badge-title",
                               tags$span(`data-de`="\u2139\ufe0f Was ist der Altersunterschied?",
                                         `data-en`="\u2139\ufe0f What is the Age Gap?",
                                         "\u2139\ufe0f Was ist der Altersunterschied?")),
                     tags$p(class = "mb-0", style = "margin-top:4px;",
                            tags$span(`data-de`="Die ", `data-en`="The ", "Die "),
                            tags$strong(
                              tags$span(`data-de`="rohe Rate", `data-en`="crude rate", "rohe Rate")),
                            tags$span(
                              `data-de`=" z\u00e4hlt alle Sterbef\u00e4lle je 100.000 Personen. Die ",
                              `data-en`=" counts all deaths per 100,000 people. The ",
                              " z\u00e4hlt alle Sterbef\u00e4lle je 100.000 Personen. Die "),
                            tags$strong(
                              tags$span(`data-de`="altersstandardisierte Rate",
                                        `data-en`="age-standardised rate",
                                        "altersstandardisierte Rate")),
                            tags$span(
                              `data-de`=" bereinigt den Einfluss der Altersstruktur \u2014 so kann man \u00e4ltere Bundesl\u00e4nder (z.\u00a0B. Sachsen-Anhalt) fair mit j\u00fcngeren (z.\u00a0B. Hamburg) vergleichen.",
                              `data-en`=" removes the effect of age structure, so older states (e.g. Saxony-Anhalt) can be fairly compared to younger ones (e.g. Hamburg). A large gap means age is a major driver here.",
                              " bereinigt den Einfluss der Altersstruktur \u2014 so kann man \u00e4ltere Bundesl\u00e4nder fair mit j\u00fcngeren vergleichen."
                            )
                     )
                 ),
                 uiOutput(ns("cv_age_gap_kpi"))
          ),
          column(8,
                 div(class = "causes-plot-wrap",
                     girafeOutput(ns("cv_map"), width = "100%", height = "320px"))
          )
        )
    ),
    
    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 2 — DUAL BAR + TREND  (side by side)
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "section-row",
        fluidRow(
          
          # ── Left: Dual bar ──────────────────────────────────────────────────
          column(6,
                 div(class = "causes-card card-green h-100",
                     div(class = "causes-card-header",
                         "\U0001f4ca\u00a0",
                         tags$span(`data-de`="Rohe vs. altersstandardisierte Rate",
                                   `data-en`="Crude vs. Age-Standardised Rate",
                                   "Rohe vs. altersstandardisierte Rate")
                     ),
                     div(class = "card-subtext",
                         tags$span(
                           `data-de`="Vergleicht das ausgew\u00e4hlte Bundesland mit dem Bundesdurchschnitt. Die altersstandardisierte Rate neutralisiert den Einfluss einer \u00e4lteren Bev\u00f6lkerung.",
                           `data-en`="Compares the selected state to Germany. The age-standardised rate removes the effect of an older population structure.",
                           "Vergleicht das ausgew\u00e4hlte Bundesland mit dem Bundesdurchschnitt. Eine h\u00f6here rohe Rate bei \u00e4hnlicher standardisierter Rate deutet auf eine \u00e4ltere Bev\u00f6lkerung hin, nicht auf schlechtere Versorgung."
                         )
                     ),
                     # Legend strip
                     div(class = "legend-strip",
                         tags$span(style="font-weight:600; color:var(--txt-primary);",
                                   `data-de`="Lesehilfe:",
                                   `data-en`="How to read:",
                                   "Lesehilfe:"),
                         div(class="legend-item",
                             div(class="legend-dot", style="background:#94b8f0;"),
                             tags$span(`data-de`="Rohe Rate",
                                       `data-en`="Crude Rate", "Rohe Rate")),
                         div(class="legend-item",
                             div(class="legend-dot", style="background:#1e3a8a;"),
                             tags$span(`data-de`="Altersstandardisiert",
                                       `data-en`="Age-Standardised", "Altersstandardisiert")),
                         div(class="legend-item",
                             tags$span(style="font-size:1rem;", "\U0001f1e9\U0001f1ea"),
                             tags$span(`data-de`="= Deutschland",
                                       `data-en`="= Germany", "= Deutschland")),
                         div(class="legend-item",
                             tags$span(style="font-size:1rem;", "\U0001f4cd"),
                             tags$span(`data-de`="= Ausgew\u00e4hltes Bundesland",
                                       `data-en`="= Selected State",
                                       "= Ausgew\u00e4hltes Bundesland"))
                     ),
                     div(class = "causes-plot-wrap",
                         girafeOutput(ns("cv_dual_bar"), width = "100%", height = "280px"))
                 )
          ),
          
          # ── Right: Trend ────────────────────────────────────────────────────
          column(6,
                 div(class = "causes-card card-orange h-100",
                     div(class = "causes-card-header",
                         "\U0001f4c8\u00a0",
                         tags$span(`data-de`="Zeitreihe 2021\u20132024",
                                   `data-en`="Trend 2021\u20132024",
                                   "Zeitreihe 2021\u20132024")
                     ),
                     div(class = "card-subtext",
                         tags$span(
                           `data-de`="Zeigt die Entwicklung der ausgew\u00e4hlten Kennzahl \u00fcber die Zeit. Vergr\u00f6\u00dfernde L\u00fccken zwischen Bundesland und Deutschland deuten auf eine sich verschlechternde relative Position hin.",
                           `data-en`="Shows the trajectory of the selected metric over time. A widening gap between the state and Germany signals a deteriorating relative position.",
                           "Zeigt die Entwicklung \u00fcber die Zeit. Eine wachsende L\u00fccke zwischen Bundesland und Deutschland deutet auf eine sich verschlechternde relative Versorgungslage hin."
                         )
                     ),
                     # Legend strip
                     div(class = "legend-strip",
                         tags$span(style="font-weight:600; color:var(--txt-primary);",
                                   `data-de`="Lesehilfe:",
                                   `data-en`="How to read:",
                                   "Lesehilfe:"),
                         div(class="legend-item",
                             div(class="legend-line", style="background:#94a3b8;"),
                             tags$span(`data-de`="- - Deutschland",
                                       `data-en`="- - Germany", "- - Deutschland")),
                         div(class="legend-item",
                             div(class="legend-line", style="background:#1e3a8a;"),
                             tags$span(`data-de`="\u2014 Bundesland",
                                       `data-en`="\u2014 State",
                                       "\u2014 Ausgew\u00e4hltes Bundesland")),
                         div(class="legend-item",
                             tags$span(style="color:var(--txt-muted);font-style:italic;",
                                       `data-de`="Punkte = Jahreswerte (anklicken)",
                                       `data-en`="Dots = annual values (hover)",
                                       "Punkte = Jahreswerte"))
                     ),
                     div(class = "causes-plot-wrap",
                         girafeOutput(ns("cv_trend"), width = "100%", height = "280px"))
                 )
          )
        )
    ),
    
    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 3 — TOP 10  (redesigned for clinical/policy audience)
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "causes-card card-purple",
        div(class = "causes-card-header",
            "\U0001f3af\u00a0",
            tags$span(`data-de`="Top-10-Todesursachen \u2014 Bundesland vs. Bundesdurchschnitt",
                      `data-en`="Top 10 Causes of Death \u2014 State vs. Germany Benchmark",
                      "Top-10-Todesursachen \u2014 Bundesland vs. Bundesdurchschnitt")
        ),
        
        # Clinical reading guide
        div(class = "insight-box",
            div(class = "insight-title",
                tags$span("\U0001f4cb"),
                tags$span(`data-de`="Klinische Lesehilfe f\u00fcr Entscheidungstr\u00e4ger",
                          `data-en`="Clinical Reading Guide for Decision-Makers",
                          "Klinische Lesehilfe f\u00fcr Entscheidungstr\u00e4ger")
            ),
            tags$ul(
              tags$li(
                tags$span(`data-de`="Jeder Balken zeigt die Rate f\u00fcr das ausgew\u00e4hlte Bundesland.",
                          `data-en`="Each bar shows the rate for the selected state.",
                          "Jeder Balken zeigt die Rate f\u00fcr das ausgew\u00e4hlte Bundesland.")
              ),
              tags$li(
                tags$span(
                  `data-de`="Die gestrichelte Linie markiert den Bundesdurchschnitt als Referenzwert.",
                  `data-en`="The dashed line marks the Germany average as a reference benchmark.",
                  "Die gestrichelte Linie markiert den Bundesdurchschnitt als Referenzwert \u2014 Abweichungen zeigen Handlungsbedarf.")
              ),
              tags$li(
                tags$span(
                  `data-de`="\U0001f534 Rot = Bundesland liegt \u00fcber dem Bundesdurchschnitt \u2192 erh\u00f6hter Handlungsbedarf.",
                  `data-en`="\U0001f534 Red = State is above the Germany average \u2192 elevated priority for intervention.",
                  "\U0001f534 Rot = Bundesland liegt \u00fcber dem Bundesdurchschnitt \u2192 erh\u00f6hter Handlungsbedarf.")
              ),
              tags$li(
                tags$span(
                  `data-de`="\U0001f7e2 Gr\u00fcn = Bundesland liegt unter dem Bundesdurchschnitt \u2192 relative St\u00e4rke.",
                  `data-en`="\U0001f7e2 Green = State is below the Germany average \u2192 relative strength.",
                  "\U0001f7e2 Gr\u00fcn = Bundesland liegt unter dem Bundesdurchschnitt \u2192 relative St\u00e4rke.")
              ),
              tags$li(
                tags$span(
                  `data-de`="Tipp: ICD-10-Kapitel oben wechseln, um Ursachen zu vergleichen. Kennzahl auf \u2018altersstandardisiert\u2019 setzen f\u00fcr faire Bundesl\u00e4nder-Vergleiche.",
                  `data-en`="Tip: Switch the ICD-10 chapter above to compare causes. Use the age-standardised metric for fair state comparisons.",
                  "Tipp: ICD-10-Kapitel oben wechseln, um verschiedene Todesursachen zu vergleichen. Kennzahl \u2018altersstandardisiert\u2019 nutzen f\u00fcr faire Bundesl\u00e4nder-Vergleiche.")
              )
            )
        ),
        
        # Visual legend
        div(class = "top10-legend",
            div(class = "legend-item",
                div(class = "legend-dash"),
                tags$span(`data-de`="Bundesdurchschnitt (Referenz)",
                          `data-en`="Germany average (reference)",
                          "Bundesdurchschnitt (Referenz)")),
            div(class = "leg-above",
                "\U0001f534\u00a0",
                tags$span(`data-de`="Balken rot = \u00fcber Durchschnitt",
                          `data-en`="Red bar = above average",
                          "Balken rot = \u00fcber Bundesdurchschnitt")),
            div(class = "leg-below",
                "\U0001f7e2\u00a0",
                tags$span(`data-de`="Balken gr\u00fcn = unter Durchschnitt",
                          `data-en`="Green bar = below average",
                          "Balken gr\u00fcn = unter Bundesdurchschnitt"))
        ),
        
        div(class = "causes-plot-wrap",
            girafeOutput(ns("cv_top10"), width = "100%", height = "420px"))
    ),
    
    # ── JS: pill sync + lang toggle ───────────────────────────────────────────
    tags$script(HTML(sprintf("
      Shiny.addCustomMessageHandler('%s', function(code) {
        document.querySelectorAll('.state-pill').forEach(function(el) {
          el.classList.toggle('active', el.getAttribute('data-code') === code);
        });
      });
      Shiny.addCustomMessageHandler('%s', function(opts) {
        var sel = document.getElementById('%s');
        if (!sel) return;
        for (var i = 0; i < sel.options.length; i++) {
          if (opts[i]) sel.options[i].text = opts[i];
        }
      });
    ", ns("update_pills"), ns("update_metric_labels"), ns("cv_metric"))))
  )
}