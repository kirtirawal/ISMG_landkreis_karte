mod_causes_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    # ── Extra CSS (including new tooltip styles) ─────────────────────────────
    tags$style(HTML("
      /* ── Custom hover tooltip for the info icon ── */
      .map-info-wrapper {
        position: relative;
        display: inline-block;
        cursor: help;
      }
      .map-info-wrapper .info-icon {
        font-size: 1.2rem;
        color: var(--top-bar-blue);
        vertical-align: middle;
        margin-left: 6px;
      }
      .map-info-wrapper .tooltip-box {
        display: none;
        position: absolute;
        bottom: 130%;
        left: 50%;
        transform: translateX(-50%);
        background: white;
        border: 1px solid var(--border-plot);
        border-radius: 8px;
        padding: 10px 14px;
        width: 280px;
        font-size: 0.82rem;
        color: var(--txt-primary);
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 9999;
        pointer-events: none;
        white-space: normal;
        line-height: 1.5;
      }
      body.dark-mode .map-info-wrapper .tooltip-box {
        background: #1a2744;
        border-color: var(--border-plot);
        color: #e2e8f0;
      }
      .map-info-wrapper:hover .tooltip-box {
        display: block;
      }
      .map-info-wrapper .tooltip-box::after {
        content: '';
        position: absolute;
        top: 100%;
        left: 50%;
        margin-left: -6px;
        border-width: 6px;
        border-style: solid;
        border-color: var(--border-plot) transparent transparent transparent;
      }
    ")),
    
    # ── Dark mode + Language toggles ────────────────────────────────────────
    div(style = "display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;",
        dark_mode_toggle_btn(),
        tags$button(
          id      = ns("lang_toggle"),
          class   = "lang-btn",
          onclick = sprintf("
            var isDE = this.getAttribute('data-lang') !== 'en';
            this.setAttribute('data-lang', isDE ? 'en' : 'de');
            this.innerHTML = isDE
              ? '<span>&#127465;&#127466;</span> Deutsch'
              : '<span>&#127467;&#127463;</span> English';
            Shiny.setInputValue('%s', isDE ? 'en' : 'de', {priority: 'event'});
            document.querySelectorAll('[data-de]').forEach(function(el) {
              el.textContent = isDE ? el.getAttribute('data-en') : el.getAttribute('data-de');
            });
          ", ns("cv_lang")),
          `data-lang` = "de",
          tags$span("🇬🇧"), " English"
        )
    ),
    
    # ══════════════════════════════════════════════════════════════════════════
    # CONTROLS BAR
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "causes-controls",
        # Keep your existing controls code here
    ),
    
    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 1 — KPI + MAP
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "causes-card",
        div(class = "causes-card-header",
            "📍\u00a0",
            tags$span(class = "map-info-wrapper",
                      icon("info-circle", class = "info-icon"),
                      tags$span(
                        class = "tooltip-box",
                        id    = ns("map_tooltip_text"),
                        `data-de` = "Karte: Klicke auf ein Bundesland, um es auszuwählen. Dunkelblau = höhere Sterberate. Der rote Rahmen markiert dein gewähltes Bundesland. Vergleiche Ost und West — oft siehst du strukturelle Unterschiede.",
                        `data-en` = "Map: Click any state to select it. Darker blue = higher death rate. Red border = your selected state. Compare East vs West Germany — structural differences often stand out.",
                        "Karte: Klicke auf ein Bundesland, um es auszuwählen. Dunkelblau = höhere Sterberate. Der rote Rahmen markiert dein gewähltes Bundesland. Vergleiche Ost und West — oft siehst du strukturelle Unterschiede."
                      )
            )
        ),
        fluidRow(
          column(4,
                 uiOutput(ns("cv_kpi_boxes")),
                 hr(class = "section-divider"),
                 div(class = "info-badge",
                     # Keep your info badge code here
                 ),
                 uiOutput(ns("cv_age_gap_kpi"))
          ),
          column(8,
                 div(class = "causes-plot-wrap",
                     girafeOutput(ns("cv_map"), width = "100%", height = "320px"))
          )
        )
    ),
    
    # ── JS: pill sync, language toggle, and tooltip text update ─────────────
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

      var langInputId = '%s';
      $(document).on('shiny:inputchanged', function(event) {
        if (event.name === langInputId) {
          var isDE = event.value === 'de';
          var tooltipEl = document.getElementById('%s');
          if (tooltipEl) {
            tooltipEl.textContent = isDE
              ? tooltipEl.getAttribute('data-de')
              : tooltipEl.getAttribute('data-en');
          }
        }
      });
    ", 
                             ns("update_pills"), 
                             ns("update_metric_labels"), 
                             ns("cv_metric"), 
                             ns("cv_lang"), 
                             ns("map_tooltip_text")
    )))
  )
}
