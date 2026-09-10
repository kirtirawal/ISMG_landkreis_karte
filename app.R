# app.R
source("global.R")
source("modules/mod_main_ui.R")
source("modules/mod_main_server.R")
source("modules/mod_causes_ui.R")
source("modules/mod_causes_server.R")
source("modules/carousel_component.R")
source("modules/mod_gallery_ui.R")
source("modules/mod_gallery_server.R")

# Source Python analytics modules
source("modules/mod_python_ui.R")
source("modules/mod_python_server.R")


ui <- bslib::page_navbar(
  title = "Health Dashboard",
  theme = bslib::bs_theme(version = 5),
  
  header = tagList(
    dark_mode_css(),
    dark_mode_js(),
    useShinyjs(),
    
    div(class = "global-carousel-wrap",
        div(
          id             = "globalCarousel",
          class          = "carousel slide",
          `data-bs-ride` = "carousel",
          
          div(class = "carousel-indicators",
              tags$button(type = "button", `data-bs-target` = "#globalCarousel",
                          `data-bs-slide-to` = "0", class = "active",
                          `aria-current` = "true", `aria-label` = "Slide 1"),
              tags$button(type = "button", `data-bs-target` = "#globalCarousel",
                          `data-bs-slide-to` = "1", `aria-label` = "Slide 2")
          ),
          
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
  
  bslib::nav_panel("Overview",             mod_main_ui("main")),
  bslib::nav_panel("Causes of Death",      mod_causes_ui("causes")),
  bslib::nav_panel("Visualisation Gallery", mod_gallery_ui("gallery")),
  bslib::nav_panel("Python Analytics",     mod_python_ui("python_tab")),
  
  # Push the dark mode toggle to the right side of the navbar
  bslib::nav_spacer(),
  bslib::nav_item(dark_mode_toggle_btn())
)

server <- function(input, output, session) {
  
  is_dark <- reactive({
    isTRUE(input$global_dark_mode)
  })
  
  mod_main_server("main",      is_dark = is_dark)
  mod_causes_server("causes")
  mod_gallery_server("gallery", is_dark = is_dark)
  
  # Initialize Python module server
  mod_python_server("python_tab")
}

shinyApp(ui, server)