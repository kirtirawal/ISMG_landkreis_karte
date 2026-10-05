# ============================================================
# app.R
# ============================================================

# ------------------------------------------------------------
# Global
# ------------------------------------------------------------

source("global.R")

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

source("R/navigation_helpers.R")

# ------------------------------------------------------------
# UI Modules
# ------------------------------------------------------------

source("modules/mod_landing_ui.R")
source("modules/mod_demographics_ui.R")
source("modules/mod_causes_ui.R")
source("modules/mod_gallery_ui.R")
source("modules/mod_python_ui.R")
source("modules/mod_lakosa_ui.R")
source("modules/global_carousel_ui.R")
source("modules/mod_heat_ui.R")

# ------------------------------------------------------------
# Server Modules
# ------------------------------------------------------------

source("modules/mod_landing_server.R")
source("modules/mod_demographics_server.R")
source("modules/mod_causes_server.R")
source("modules/mod_gallery_server.R")
source("modules/mod_lakosa_server.R")
source("modules/mod_heat_server.R")

# ============================================================
# UI
# ============================================================

ui <- bslib::page_navbar(
  
  id = "page",
  
  
  title = tags$a(
    
    href = "#",
    
    id = "home_logo",
    
    class = "app-brand",
    
    icon("heart-pulse"),
    
    span("Health Dashboard")
    
  ),
  
  theme = bslib::bs_theme(
    version = 5,
    primary = "#0868c9",
    bg = "#f4f7fb",
    fg = "#172033",
    base_font = bslib::font_google("Inter")
  ),
  
  header = tagList(
    
    shinyjs::useShinyjs(),
    
    dark_mode_css(),
    dark_mode_js(),
    
    tags$head(
      
      tags$link(rel = "stylesheet", href = "css/variables.css"),
      tags$link(rel = "stylesheet", href = "css/base.css"),
      tags$link(rel = "stylesheet", href = "css/navbar.css"),
      tags$link(rel = "stylesheet", href = "css/landing.css"),
      tags$link(rel = "stylesheet", href = "css/carousel.css"),
      tags$link(rel = "stylesheet", href = "css/modules.css"),
      tags$link(rel = "stylesheet", href = "css/dark-mode.css"),
      tags$link(rel = "stylesheet", href = "css/demographic.css"),
      tags$link(rel = "stylesheet", href = "css/causes.css"),
      tags$link(rel = "stylesheet", href = "css/lakosa.css"),
      tags$link(rel = "stylesheet", href = "css/gallery.css"),
      
      

      
      tags$script(
        src = "js/navigation.js"
      )
    )
  ),
  
  # ==========================================================
  # LANDING PAGE
  # ==========================================================
  
  bslib::nav_panel(
    title = "Home",
    value = "landing",
    mod_landing_ui("landing")
  ),
  
  # ==========================================================
  # DEMOGRAPHICS
  # ==========================================================
  
  bslib::nav_panel(
    title = "Demographics",
    value = "demographics",
    mod_demographics_ui("demographics")
  ),
  
  # ==========================================================
  # CAUSES
  # ==========================================================
  
  bslib::nav_panel(
    title = "Causes",
    value = "causes",
    mod_causes_ui("causes")
  ),
  
  # ==========================================================
  # GALLERY
  # ==========================================================
  
  bslib::nav_panel(
    title = "Gallery",
    value = "gallery",
    mod_gallery_ui("gallery")
  ),
  
  bslib::nav_panel(
    title = "LäKoSA",
    value = "lakosa",
    mod_lakosa_ui("lakosa")
  ),
  bslib::nav_panel(
    title = "Urban Heat",
    value = "heat_emissions",          # ← must match the card's target
    mod_heat_ui("heat_emissions")
  ),
  
  bslib::nav_spacer(),
  
  bslib::nav_item(
    dark_mode_toggle_btn()
  )
)

# ============================================================
# SERVER
# ============================================================

server <- function(input, output, session) {
  
  is_dark <- reactive({
    isTRUE(input$global_dark_mode)
  })
  
  # ----------------------------------------------------------
  # Landing
  # ----------------------------------------------------------
  
  mod_landing_server("landing")
  
  # ----------------------------------------------------------
  # Demographics
  # ----------------------------------------------------------
  
  mod_demographics_server(
    id = "demographics",
    is_dark = is_dark
  )
  
  # ----------------------------------------------------------
  # Causes
  # ----------------------------------------------------------
  
  mod_causes_server(
    id = "causes",
    causes_data = causes_data,
    germany_states = germany_states
  )
  
  # ----------------------------------------------------------
  # Gallery
  # ----------------------------------------------------------
  
  mod_gallery_server(
    id = "gallery",
    is_dark = is_dark
  )
  # ----------------------------------------------------------
  # LäKoSA
  # ----------------------------------------------------------
  mod_lakosa_server(
    id = "lakosa",
    lakosa_data = lakosa_data,
    lakosa_dict = lakosa_dictionary
  )
  mod_heat_server("heat_emissions", is_dark = is_dark)
  # ----------------------------------------------------------
  # Card Navigation
  # ----------------------------------------------------------
  
  observeEvent(
    input$navigation_target,
    {
      
      req(input$navigation_target)
      
      allowed_pages <- c(
        "landing",
        "demographics",
        "causes",
        "gallery",
        "python_tab",
        "heat_emissions" 
      )
      
      req(
        input$navigation_target %in%
          allowed_pages
      )
      
      bslib::nav_select(
        id = "page",
        selected = input$navigation_target,
        session = session
      )
    }
  )
}

# ============================================================
# RUN APP
# ============================================================

shinyApp(
  ui = ui,
  server = server
)