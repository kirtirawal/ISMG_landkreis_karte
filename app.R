source("global.R")
source("modules/mod_main_ui.R")
source("modules/mod_main_server.R")

ui <- fluidPage(
  mod_main_ui("main_ui")
)

server <- function(input, output, session) {
  mod_main_server("main_ui")
  
}

shinyApp(ui, server)