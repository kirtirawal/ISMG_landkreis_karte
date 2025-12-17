mod_main_ui <- function(id) {
  ns <- NS(id)
  
  # Safely get variable choices
  variable_choices <- if (exists("Daten_long") && !is.null(Daten_long)) {
    unique(Daten_long$variable)
  } else {
    c("Keine Daten verfügbar")
  }
  
  fluidPage(
    theme = bs_theme(bootswatch = "minty", version = 5),
    
    # ======================== STYLES ========================
    tags$head(
      tags$style(HTML("
        html, body { background-color: #f8f9fa; overflow-x: hidden; }

        /* Logo & title */
        .logo { width: 60px; max-width: 60px; margin-right: 12px; }
        .app-title { color: #0b7285; font-weight: 700; font-size: 1.5rem; margin: 0; }

        /* Accordion */
        .accordion-button { font-weight: 600; font-size: 1.1rem; }
        .accordion-button:not(.collapsed) { background-color: #e7f5ff; color: #0b7285; }
        .accordion-body { padding: 1rem; font-size: 0.95rem; }
        .accordion-item { margin-bottom: 0; }

        /* Carousel */
        .carousel-inner img { width: 100%; height: auto; max-height: 240px; object-fit: contain; }
        .carousel-control-prev-icon, .carousel-control-next-icon { filter: invert(1); }

        /* Info box */
        .info-box { background-color: #e7f5ff; border-left: 4px solid #0b7285; padding: 0.75rem; margin-bottom: 1rem; border-radius: 0.25rem; }

        /* Plot container */
        .plot-container { background-color: white; border-radius: 0.5rem; padding: 0.5rem; box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075); margin-bottom: 0; }

        /* Minimal gaps for plots */
        .plots-row .col { padding-bottom: 0.25rem; margin-bottom: 0; }
        .plots-row .col:last-child { padding-bottom: 0; }
        .plots-row > .col > .plot-container { margin-bottom: 0; }

        /* Fixed height for plots */
        .map-girafe, .bar-girafe { width: 100% !important; height: 300px !important; min-height: 300px !important; max-height: 300px !important; padding: 0 !important; margin: 0 !important; }
        .map-girafe svg, .bar-girafe svg { width: 100% !important; height: 100% !important; }

        /* Mobile adjustments */
        @media (max-width: 768px) {
          .carousel-inner img { height: 160px !important; object-fit: cover !important; }
          .app-title { font-size: 1.15rem; margin-bottom: 0.15rem; }
          .logo { width: 50px; margin-bottom: 0.15rem; }
          .accordion-body { font-size: 0.86rem; padding: 0.45rem 0.5rem !important; }
          .accordion-button { padding: 0.35rem 0.75rem !important; font-size: 1rem !important; }
          .info-box { padding: 0.45rem !important; margin-bottom: 0.35rem !important; }
        }
      ")),
      tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js")
    ),
    
    # ======================== IMAGE CAROUSEL ========================
    HTML('
      <div id="topCarousel" class="carousel slide mb-2" data-bs-ride="carousel">
        <div class="carousel-indicators">
          <button type="button" data-bs-target="#topCarousel" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
          <button type="button" data-bs-target="#topCarousel" data-bs-slide-to="1" aria-label="Slide 2"></button>
        </div>
        <div class="carousel-inner">
          <div class="carousel-item active">
            <img src="Picture 1.jpg" class="d-block w-100" alt="Banner 1">
          </div>
          <div class="carousel-item">
            <img src="Picture 2.jpg" class="d-block w-100" alt="Banner 2">
          </div>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#topCarousel" data-bs-slide="prev">
          <span class="carousel-control-prev-icon" aria-hidden="true"></span>
          <span class="visually-hidden">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#topCarousel" data-bs-slide="next">
          <span class="carousel-control-next-icon" aria-hidden="true"></span>
          <span class="visually-hidden">Next</span>
        </button>
      </div>
    '),
    
    # ======================== HEADER ========================
    fluidRow(
      column(
        width = 12,
        div(
          class = "d-flex flex-column flex-md-row align-items-center justify-content-center mb-4",
          img(src = "img/logo.png", class = "logo mb-2 mb-md-0"),
          div(
            class = "text-center",
            tags$h1("Deutsches Dashboard für öffentliche Daten", class = "app-title"),
            tags$p(class = "text-muted mb-0", style = "font-size: 0.95rem;",
                   "Interaktiver Landkreis-Explorer mit Zeitreihenanalyse")
          )
        )
      )
    ),
    
    # ======================== MAIN ACCORDION ========================
    tags$div(
      class = "accordion",
      id = ns("mainAccordion"),
      tags$div(
        class = "accordion-item",
        tags$h2(
          class = "accordion-header",
          id = ns("headingViz"),
          tags$button(
            class = "accordion-button",
            type = "button",
            `data-bs-toggle` = "collapse",
            `data-bs-target` = paste0("#", ns("collapseViz")),
            `aria-expanded` = "true",
            `aria-controls` = ns("collapseViz"),
            "🗺️ Interaktive Karte & 📊 Zeitreihenanalyse"
          )
        ),
        tags$div(
          id = ns("collapseViz"),
          class = "accordion-collapse collapse show",
          `aria-labelledby` = ns("headingViz"),
          `data-bs-parent` = paste0("#", ns("mainAccordion")),
          tags$div(
            class = "accordion-body",
            div(class = "info-box",
                tags$p(class = "mb-0",
                       tags$strong("💡 Anleitung: "),
                       "Wählen Sie einen Parameter aus der Liste, klicken Sie auf eine Region in der Karte,
                        und sehen Sie sich die Zeitreihe im Diagramm an.")
            ),
            fluidRow(
              column(
                width = 12,
                tags$label(class = "form-label fw-bold", `for` = ns("selected_param"), "📊 Parameter auswählen:"),
                selectInput(ns("selected_param"), NULL, choices = variable_choices, width = "100%", selectize = FALSE),
                tags$small(class = "text-muted", "Tipp: Beginnen Sie mit der Eingabe, um die Liste zu durchsuchen.")
              )
            ),
            # --- Color palette selector ---
            fluidRow(
              column(
                width = 12,
                tags$label(class = "form-label fw-bold", `for` = ns("color_palette"), "🎨 Map Color Palette:"),
                selectInput(ns("color_palette"), NULL,
                            choices = c("Green"="green","Blue"="blue","Red"="red","Viridis"="viridis","Plasma"="plasma"),
                            selected = "green",
                            width = "100%")
              )
            ),
            tags$hr(class = "my-2"),
            # --- Plots ---
            fluidRow(
              class = "g-0 plots-row",
              column(width = 12, md = 7,
                     div(class = "plot-container map-girafe", girafeOutput(ns("map_plot"), width = "100%", height = "300px"))),
              column(width = 12, md = 5,
                     div(class = "plot-container bar-girafe", girafeOutput(ns("bar_plot"), width = "100%", height = "300px"))
              )
            )
          )
        )
      )
    ),
    
    # ======================== FOOTER ========================
    tags$hr(class = "mt-4"),
    div(
      class = "text-center text-muted small pb-3",
      tags$p(class = "mb-1", "© 2025 Data Visualization Project"),
      tags$p(class = "mb-0", "Built with ❤️ using ",
             tags$a(href = "https://shiny.posit.co/", target = "_blank", "R Shiny"),
             " | ",
             tags$a(href = "https://rstudio.github.io/bslib/", target = "_blank", "bslib"),
             " | ",
             tags$a(href = "https://davidgohel.github.io/ggiraph/", target = "_blank", "ggiraph"))
    )
  )
}