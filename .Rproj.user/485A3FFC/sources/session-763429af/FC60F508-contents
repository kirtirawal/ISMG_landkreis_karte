mod_main_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # --- Filter data by selected parameter ---
    map_data <- reactive({
      req(input$selected_param)
      Daten_long %>%
        filter(variable == input$selected_param) %>%
        mutate(
          value = ifelse(value == "k.A.", 0, value),
          value = suppressWarnings(as.numeric(value))
        )
    })
    
    # --- Reactive: selected region ---
    selected_region <- reactive({
      if (!is.null(input$map_plot_selected)) {
        input$map_plot_selected
      } else {
        unique(map_data()$nuts_name)[1]
      }
    })
    
    # --- Helper: color palette ---
    map_palette <- reactive({
      switch(
        input$color_palette,
        "green" = scale_fill_gradient(low = "#e5f5e0", high = "#31a354", na.value = "grey80"),
        "blue"  = scale_fill_gradient(low = "#deebf7", high = "#3182bd", na.value = "grey80"),
        "red"   = scale_fill_gradient(low = "#fee0d2", high = "#de2d26", na.value = "grey80"),
        "viridis" = scale_fill_viridis_c(option = "viridis", na.value = "grey80"),
        "plasma"  = scale_fill_viridis_c(option = "plasma", na.value = "grey80"),
        scale_fill_gradient(low = "#e5f5e0", high = "#31a354", na.value = "grey80") # default
      )
    })
    
    # --- Interactive Map ---
    output$map_plot <- renderGirafe({
      gg_map <- ggplot(map_data()) +
        geom_sf_interactive(
          aes(
            geometry = geometry,
            fill = value,
            tooltip = glue("<b>{nuts_name}</b><br>Jahr: {year}<br>Wert: {value}"),
            data_id = nuts_name
          ),
          color = "black",
          linewidth = 0.3
        ) +
        theme_void() +
        map_palette() +  # use reactive palette
        labs(
          fill = input$selected_param,
          title = paste("Map of", input$selected_param)
        ) +
        theme(plot.title = element_text(size = 14))
      
      girafe(
        ggobj = gg_map,
        width_svg = 10,
        height_svg = 6,
        options = list(
          opts_hover(css = "stroke:red;stroke-width:2;"),
          opts_selection(type = "single"),
          opts_zoom(max = 2)
        )
      )
    })
    
    # --- Bar chart for selected region ---
    output$bar_plot <- renderGirafe({
      region_name <- selected_region()
      bar_data <- map_data() %>% filter(nuts_name == region_name)
      
      gg_bar <- ggplot(bar_data, aes(x = year, y = value, fill = year)) +
        geom_col_interactive(
          aes(
            tooltip = glue("Jahr: {year}<br>Wert: {value}")
          ),
          width = 0.6
        ) +
        theme_minimal(base_size = 11) +
        labs(
          title = paste("Time series for", region_name),
          x = "Year",
          y = input$selected_param
        ) +
        theme(
          legend.position = "none",
          plot.title = element_text(size = 12),
          axis.text.x = element_text(angle = 45, hjust = 1, size = 9)
        )
      
      girafe(
        ggobj = gg_bar,
        width_svg = 8,
        height_svg = 5,
        options = list(
          opts_hover(css = "fill:orange;")
        )
      )
    })
    
  })
}
