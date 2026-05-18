# app.R
source("global.R")
source("modules/mod_main_ui.R")
source("modules/mod_main_server.R")
source("modules/mod_mortality_ui.R")
source("modules/mod_mortality_server.R")
source("modules/mod_causes_ui.R")
source("modules/mod_causes_server.R")
source("modules/carousel_component.R")

ui <- bslib::page_navbar(
  title = "Health Dashboard",
  theme = bslib::bs_theme(version = 5),
  
  # Inject global CSS + JS once at the app level
  header = tagList(
    dark_mode_css(),
    dark_mode_js(),
    useShinyjs(),
    
    # ── Global carousel (shown above all tabs) ──────────────────────────────
    div(class = "global-carousel-wrap",
        div(
          id             = "globalCarousel",
          class          = "carousel slide",
          `data-bs-ride` = "carousel",
          
          # Indicators
          div(class = "carousel-indicators",
              tags$button(type = "button", `data-bs-target` = "#globalCarousel",
                          `data-bs-slide-to` = "0", class = "active",
                          `aria-current` = "true", `aria-label` = "Slide 1"),
              tags$button(type = "button", `data-bs-target` = "#globalCarousel",
                          `data-bs-slide-to` = "1", `aria-label` = "Slide 2")
          ),
          
          # Slides — put your images in www/ as slide1.png and slide2.png
          div(class = "carousel-inner",
              div(class = "carousel-item active",
                  tags$img(src = "Picture 1.jpg", class = "d-block w-100 carousel-img",
                           alt = "Slide 1"),
                  div(class = "carousel-caption",
                      tags$h5("Landkreis Health Tracker"),
                      tags$p("Regionale Gesundheitsdaten auf einen Blick")
                  )
              ),
              div(class = "carousel-item",
                  tags$img(src = "Picture 2.jpg", class = "d-block w-100 carousel-img",
                           alt = "Slide 2"),
                  div(class = "carousel-caption",
                      tags$h5("Sterblichkeits- & Ursachenanalyse"),
                      tags$p("Deutschland und Sachsen-Anhalt im Vergleich")
                  )
              )
          ),
          
          # Prev / Next arrows
          tags$button(class = "carousel-control-prev", type = "button",
                      `data-bs-target` = "#globalCarousel", `data-bs-slide` = "prev",
                      tags$span(class = "carousel-control-prev-icon", `aria-hidden` = "true"),
                      tags$span(class = "visually-hidden", "Previous")
          ),
          tags$button(class = "carousel-control-next", type = "button",
                      `data-bs-target` = "#globalCarousel", `data-bs-slide` = "next",
                      tags$span(class = "carousel-control-next-icon", `aria-hidden` = "true"),
                      tags$span(class = "visually-hidden", "Next")
          )
        )
    )
  ),
  
  bslib::nav_panel("Overview",       mod_main_ui("main")),
  bslib::nav_panel("Mortality",      mod_mortality_ui("mort")),
  bslib::nav_panel("Causes of Death", mod_causes_ui("causes"))
)

server <- function(input, output, session) {
  
  # Reactive that tracks dark mode state (initialised from JS localStorage via input)
  is_dark <- reactive({
    isTRUE(input$global_dark_mode)
  })
  
  mod_main_server("main",   is_dark = is_dark)
  mod_mortality_server("mort", is_dark = is_dark)
  mod_causes_server("causes")
}

shinyApp(ui, server)