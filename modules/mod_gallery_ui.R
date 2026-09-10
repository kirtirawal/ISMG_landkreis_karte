mod_gallery_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$style(HTML("
      .gallery-wrap { padding: 12px 0; }
      .lang-toggle { display: flex; gap: 0; margin-bottom: 20px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; width: fit-content; }
      .lang-btn { padding: 6px 18px; font-size: 0.82rem; font-weight: 700; border: none; cursor: pointer; background: #fff; color: #667788; transition: background 0.15s, color 0.15s; }
      .lang-btn.active { background: #1a3a5c; color: #fff; }
      .gallery-title { font-size: 1.25rem; font-weight: 700; color: #1a3a5c; margin: 0 0 3px 0; }
      .gallery-sub { font-size: 0.84rem; color: #556677; margin: 0 0 18px 0; }
      .sel-banner { display: none; align-items: center; gap: 10px; background: #e8f5f0; border: 1.5px solid #1e7a5e; border-radius: 10px; padding: 10px 16px; margin-bottom: 20px; }
      .sel-banner.visible { display: flex; }
      .proto-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; margin-bottom: 28px; overflow: hidden; }
      .proto-head { padding: 14px 20px 10px 20px; border-bottom: 1px solid #f0f4f8; }
      .proto-num { display: inline-block; background: #1a3a5c; color: #fff; font-size: 0.7rem; font-weight: 700; border-radius: 20px; padding: 2px 10px; margin-bottom: 5px; }
      .proto-title { font-size: 0.98rem; font-weight: 700; color: #1a3a5c; margin: 0 0 3px 0; }
      .proto-desc { font-size: 0.79rem; color: #556677; line-height: 1.5; margin: 0 0 5px 0; }
      .proto-tag { display: inline-block; background: #eef2fb; color: #2563a8; font-size: 0.68rem; font-weight: 600; border-radius: 20px; padding: 2px 9px; margin: 2px 2px 0 0; }
      .proto-body { padding: 14px 20px 18px 20px; }
      .proto-controls { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 8px; }
      .proto-controls label { font-size: 0.76rem; color: #556677; font-weight: 600; margin: 0; white-space: nowrap; }
      .proto-controls select { font-size: 14px !important; height: 32px; }
      .proto-foot { display: flex; align-items: center; justify-content: space-between; padding: 10px 20px; background: #f8faff; border-top: 1px solid #eef2fb; }
      .use-case { font-size: 0.76rem; color: #667788; font-style: italic; }
      .sel-btn { background: #1a3a5c; color: #fff; border: none; border-radius: 8px; padding: 6px 16px; font-size: 0.8rem; font-weight: 700; cursor: pointer; transition: background 0.15s; white-space: nowrap; }
      .sel-btn:hover { background: #2563a8; }
      .sel-btn.active-sel { background: #1e7a5e; }
      body.dark-mode .proto-card  { background:#1f2937; border-color:#334155; }
      body.dark-mode .proto-head  { border-color:#334155; }
      body.dark-mode .proto-title { color:#e2e8f0; }
      body.dark-mode .proto-desc  { color:#94a3b8; }
      body.dark-mode .proto-num   { background:#378ADD; }
      body.dark-mode .proto-tag   { background:#1e3a5c; color:#93c5fd; }
      body.dark-mode .proto-foot  { background:#151d2b; border-color:#334155; }
      body.dark-mode .use-case    { color:#64748b; }
      body.dark-mode .gallery-title { color:#e2e8f0; }
      body.dark-mode .gallery-sub   { color:#94a3b8; }
      body.dark-mode .lang-btn      { background:#1f2937; color:#94a3b8; border-color:#334155; }
      body.dark-mode .lang-btn.active { background:#378ADD; color:#fff; }
    ")),
    
    # Language toggle
    tags$div(selectInput(ns("lang"), NULL, choices = c("EN" = "en", "DE" = "de"), selected = "en", width = "80px"),
             style = "display:inline-block;"),
    
    div(class = "gallery-wrap",
        tags$h2(class = "gallery-title", "\U0001f5bc\ufe0f Visualisation Gallery (real data)"),
        tags$p(class = "gallery-sub", "8 chart types based on the actual Landkreis dataset (2006–2023)."),
        
        div(id = ns("sel_banner"), class = "sel-banner",
            tags$span(style = "color:#1e7a5e;font-weight:700;", "\u2705 Selected:"),
            uiOutput(ns("selected_label"))),
        
        # Prototype 1 – Multi-line
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "01"), tags$h3(class = "proto-title", "Multi-line trend chart"),
                tags$p(class = "proto-desc", "All 14 districts on one chart, 2006–2023. Hover to highlight."),
                tags$span(class = "proto-tag", "temporal"), tags$span(class = "proto-tag", "all regions")),
            div(class = "proto-body", uiOutput(ns("note_p1")),
                div(class = "proto-controls", tags$label("Indicator:"), selectInput(ns("p1_indicator"), NULL, choices = c("Population" = "Bevölkerung (Anzahl)"), width = "280px")),
                girafeOutput(ns("p1_plot"), width = "100%", height = "360px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: time-series storytelling"),
                actionButton(ns("select_1"), "Select \u2192", class = "sel-btn", `data-p` = "1"))
        ),
        
        # Prototype 2 – Diverging bar
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "02"), tags$h3(class = "proto-title", "Diverging bar chart"),
                tags$p(class = "proto-desc", "One year, sorted north–south. Right/left from zero midline."),
                tags$span(class = "proto-tag", "snapshot"), tags$span(class = "proto-tag", "ranking")),
            div(class = "proto-body", uiOutput(ns("note_p2")),
                div(class = "proto-controls", tags$label("Indicator:"), selectInput(ns("p2_indicator"), NULL, choices = c("In‑migration" = "Zuzüge (je 1.000 Einwohner:innen)"), width = "280px"),
                    tags$label("Year:"), selectInput(ns("p2_year"), NULL, choices = as.character(2006:2023), selected = "2023", width = "80px")),
                girafeOutput(ns("p2_plot"), width = "100%", height = "400px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: policy briefings"),
                actionButton(ns("select_2"), "Select \u2192", class = "sel-btn", `data-p` = "2"))
        ),
        
        # Prototype 3 – Heatmap
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "03"), tags$h3(class = "proto-title", "Heatmap — region × year"),
                tags$p(class = "proto-desc", "Rows = districts (north–south), columns = years."),
                tags$span(class = "proto-tag", "overview"), tags$span(class = "proto-tag", "pattern detection")),
            div(class = "proto-body", uiOutput(ns("note_p3")),
                div(class = "proto-controls", tags$label("Indicator:"), selectInput(ns("p3_indicator"), NULL, choices = c("Population" = "Bevölkerung (Anzahl)"), width = "280px")),
                girafeOutput(ns("p3_plot"), width = "100%", height = "400px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: executive overview"),
                actionButton(ns("select_3"), "Select \u2192", class = "sel-btn", `data-p` = "3"))
        ),
        
        # Prototype 4 – Bubble chart (adapted)
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "04"), tags$h3(class = "proto-title", "Bubble chart — 3 variables"),
                tags$p(class = "proto-desc", "X = births per 1,000, Y = pop. change since 2011, bubble size = population."),
                tags$span(class = "proto-tag", "multi-variable")),
            div(class = "proto-body", uiOutput(ns("note_p4")),
                div(class = "proto-controls", tags$label("Year:"), selectInput(ns("p4_year"), NULL, choices = as.character(2006:2023), selected = "2023", width = "80px"),
                    tags$label("Colour by:"), selectInput(ns("p4_color"), NULL, choices = c("Type (city/district)" = "type", "North–South" = "ns"), width = "200px")),
                girafeOutput(ns("p4_plot"), width = "100%", height = "380px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: positioning report"),
                actionButton(ns("select_4"), "Select \u2192", class = "sel-btn", `data-p` = "4"))
        ),
        
        # Prototype 5 – Slope chart
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "05"), tags$h3(class = "proto-title", "Slope chart — before vs after"),
                tags$p(class = "proto-desc", "2006 vs chosen year. Rising/falling lines show direction of change."),
                tags$span(class = "proto-tag", "change")),
            div(class = "proto-body", uiOutput(ns("note_p5")),
                div(class = "proto-controls", tags$label("Indicator:"), selectInput(ns("p5_indicator"), NULL, choices = c("Population" = "Bevölkerung (Anzahl)"), width = "280px"),
                    tags$label("Right year:"), selectInput(ns("p5_year"), NULL, choices = as.character(2007:2023), selected = "2023", width = "80px")),
                girafeOutput(ns("p5_plot"), width = "100%", height = "400px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: policy briefs"),
                actionButton(ns("select_5"), "Select \u2192", class = "sel-btn", `data-p` = "5"))
        ),
        
        # Prototype 7 – Small multiples
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "07"), tags$h3(class = "proto-title", "Small multiples — one panel per district"),
                tags$p(class = "proto-desc", "14 mini‑charts, north–south order. Colours = geographic zone."),
                tags$span(class = "proto-tag", "facet")),
            div(class = "proto-body", uiOutput(ns("note_p7")),
                div(class = "proto-controls", tags$label("Indicator:"), selectInput(ns("p7_indicator"), NULL, choices = c("Population" = "Bevölkerung (Anzahl)"), width = "280px")),
                plotOutput(ns("p7_plot"), width = "100%", height = "520px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: detailed reports"),
                actionButton(ns("select_7"), "Select \u2192", class = "sel-btn", `data-p` = "7"))
        ),
        
        # Prototype 8 – N–S ranked bar
        div(class = "proto-card",
            div(class = "proto-head", div(class = "proto-num", "08"), tags$h3(class = "proto-title", "North–south ranked bar"),
                tags$p(class = "proto-desc", "Bars sorted by latitude (north at top). Blue → coral gradient."),
                tags$span(class = "proto-tag", "geographic")),
            div(class = "proto-body", uiOutput(ns("note_p8")),
                div(class = "proto-controls", tags$label("Indicator:"), selectInput(ns("p8_indicator"), NULL, choices = c("Population" = "Bevölkerung (Anzahl)"), width = "280px"),
                    tags$label("Year:"), selectInput(ns("p8_year"), NULL, choices = as.character(2006:2023), selected = "2023", width = "80px")),
                girafeOutput(ns("p8_plot"), width = "100%", height = "400px")),
            div(class = "proto-foot", tags$span(class = "use-case", "\U0001f4a1 Best for: spatial reporting"),
                actionButton(ns("select_8"), "Select \u2192", class = "sel-btn", `data-p` = "8"))
        )
    ),
    
    tags$script(HTML(sprintf("
      Shiny.addCustomMessageHandler('%s', function(p) {
        document.querySelectorAll('.sel-btn').forEach(function(b) {
          b.classList.remove('active-sel');
          b.textContent = 'Select \u2192';
        });
        var btn = document.querySelector('.sel-btn[data-p=\"' + p + '\"]');
        if (btn) { btn.classList.add('active-sel'); btn.textContent = '\u2705 Selected'; }
        var banner = document.getElementById('%s');
        if (banner) banner.classList.add('visible');
      });
    ", ns("highlight_selected"), ns("sel_banner"))))
  )
}