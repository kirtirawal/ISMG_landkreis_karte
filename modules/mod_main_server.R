mod_main_server <- function(id, is_dark = reactive(FALSE)) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # --- Dynamic Theme Helper ---
    curr_theme <- reactive({
      if (isTRUE(is_dark())) {
        list(
          bg          = "#1f2937",
          bg_panel    = "#151d2b",
          txt         = "#e2e8f0",
          grid        = "#334155",
          tooltip_bg  = "#0f172a",
          tooltip_txt = "#e2e8f0",
          border      = "#334155",
          na_fill     = "#374151"
        )
      } else {
        list(
          bg          = "#ffffff",
          bg_panel    = "#fafbff",
          txt         = "#1a3a5c",
          grid        = "#e9ecef",
          tooltip_bg  = "#ffffff",
          tooltip_txt = "#1a3a5c",
          border      = "#e2e8f0",
          na_fill     = "#e5e7eb"
        )
      }
    })
    
    # --- Latitude lookup for districts (North-South order) ---
    district_lat <- local({
      if (exists("germany_districts") && inherits(germany_districts, "sf")) {
        suppressWarnings({
          germany_districts %>%
            dplyr::select(nuts_id, geometry) %>%
            sf::st_centroid() %>%
            dplyr::mutate(lat = sf::st_coordinates(.)[,2]) %>%
            sf::st_drop_geometry() %>%
            dplyr::mutate(zone = dplyr::case_when(
              lat > 52.0 ~ "North",
              lat > 51.6 ~ "Mid",
              TRUE ~ "South"
            ))
        })
      } else {
        tibble::tibble(
          nuts_id = c("DEE04", "DEE05", "DEE07", "DEE08", "DEE01", "DEE02",
                      "DEE09", "DEE06", "DEE03", "DEE0A", "DEE0B", "DEE0C",
                      "DEE0D", "DEE0E"),
          lat = c(52.85, 51.62, 52.05, 51.15, 51.83, 51.48,
                  51.75, 52.20, 52.13, 51.55, 51.45, 51.80,
                  52.60, 51.87),
          zone = c("North", "South", "North", "South", "Mid", "South",
                   "Mid", "North", "North", "South", "South", "Mid",
                   "North", "Mid")
        )
      }
    })
    
    # --- 1. Filter data for map ---
    map_data <- reactive({
      req(input$selected_param)
      Daten_long %>%
        dplyr::filter(variable == input$selected_param) %>%
        dplyr::mutate(value = suppressWarnings(as.numeric(value))) %>%
        dplyr::filter(!is.na(value))
    })
    
    # --- 2. Selected region (from map click) ---
    selected_region <- reactive({
      if (!is.null(input$map_plot_selected) && nzchar(input$map_plot_selected)) {
        input$map_plot_selected
      } else {
        first_district <- map_data()$nuts_name[1]
        if (is.na(first_district)) "Magdeburg" else first_district
      }
    })
    
    # --- 3. Color palette for map ---
    map_palette <- reactive({
      scale_fill_viridis_c(option = input$color_palette,
                           na.value = curr_theme()$na_fill)
    })
    
    # --- 4. Interactive Map ---
    output$map_plot <- renderGirafe({
      t          <- curr_theme()
      border_col <- if (isTRUE(is_dark())) "#4b5563" else "#ffffff"
      
      gg_map <- ggplot(map_data()) +
        geom_sf_interactive(
          aes(
            geometry = geometry,
            fill     = value,
            tooltip  = paste0(
              "<span style='font-size:15px;font-weight:700;color:#1a1a1a;'>",
              nuts_name,
              "</span><br/>",
              "<span style='color:#555;font-size:12px;'>Jahr: </span>",
              "<span style='font-size:12px;'>", year, "</span><br/>",
              "<span style='color:#555;font-size:12px;'>Wert: </span>",
              "<span style='font-size:12px;font-weight:600;'>",
              round(value, 1),
              "</span>"
            ),
            data_id  = nuts_name
          ),
          color     = border_col,
          linewidth = 0.25
        ) +
        theme_void() +
        map_palette() +
        theme(
          plot.background   = element_rect(fill = t$bg,       color = NA),
          panel.background  = element_rect(fill = t$bg,       color = NA),
          legend.background = element_rect(fill = t$bg,       color = NA),
          legend.text       = element_text(color = t$txt,     size = 9),
          legend.title      = element_text(color = t$txt,     size = 9),
          plot.title        = element_text(color = t$txt,     size = 13,
                                           face = "bold",
                                           margin = margin(b = 8))
        ) +
        labs(fill = NULL, title = paste("Distribution:", input$selected_param))
      
      tooltip_css <- paste0(
        "background-color:", t$tooltip_bg, ";",
        "color:", t$tooltip_txt, ";",
        "border:1.5px solid #cccccc;",
        "border-radius:8px;",
        "padding:10px 14px;",
        "font-family:sans-serif;",
        "font-size:13px;",
        "box-shadow:0 4px 16px rgba(0,0,0,0.18);",
        "min-width:160px;"
      )
      
      girafe(
        ggobj     = gg_map,
        width_svg = 10, height_svg = 8,
        options   = list(
          opts_hover(css = "stroke:#ff3b3b;stroke-width:2.5;cursor:pointer;"),
          opts_selection(type = "single",
                         css  = "stroke:#ff3b3b;stroke-width:2.5;"),
          opts_tooltip(
            css           = tooltip_css,
            use_fill      = FALSE,
            use_cursor_pos = FALSE,
            offx          = 10,
            offy          = -40,
            delay_mouseover = 0,
            delay_mouseout  = 1000
          ),
          opts_toolbar(saveaspng = FALSE),
          opts_sizing(rescale = TRUE)
        )
      )
    })
    
    # --- 5. Bar chart for selected region (time series) ---
    output$bar_plot <- renderGirafe({
      
      validate(need(!is.null(input$map_plot_selected) && nzchar(input$map_plot_selected),
                "Click a region on the map to see its trend."))
  
      t           <- curr_theme()
      region_name <- input$map_plot_selected
      bar_data    <- map_data() %>% dplyr::filter(nuts_name == region_name)
      
      # validate(need(nrow(bar_data) > 0, "No data for selected region."))
      
      gg_bar <- ggplot(bar_data, aes(x = year, y = value, fill = value)) +
        geom_col_interactive(
          aes(tooltip = paste0(
            "<span style='font-size:14px;font-weight:700;'>", region_name, "</span><br/>",
            "<span style='color:#555;font-size:12px;'>Jahr: </span>",
            "<span style='font-size:12px;'>", year, "</span><br/>",
            "<span style='color:#555;font-size:12px;'>Wert: </span>",
            "<span style='font-size:12px;font-weight:600;'>", round(value, 1), "</span>"
          )),
          width = 0.7
        ) +
        scale_fill_viridis_c(option = input$color_palette) +
        theme_minimal(base_size = 11) +
        theme(
          plot.background  = element_rect(fill = t$bg,   color = NA),
          panel.background = element_rect(fill = t$bg,   color = NA),
          panel.grid.major = element_line(color = t$grid, linewidth = 0.5),
          panel.grid.minor = element_blank(),
          axis.text        = element_text(color = t$txt),
          axis.title       = element_text(color = t$txt, face = "bold"),
          plot.title       = element_text(color = t$txt, face = "bold", size = 12),
          legend.position  = "none"
        ) +
        labs(title = paste("Trend:", region_name), x = "Jahr", y = NULL)
      
      tooltip_css <- paste0(
        "background-color:", t$tooltip_bg, ";",
        "color:", t$tooltip_txt, ";",
        "border:1.5px solid #cccccc;",
        "border-radius:8px;",
        "padding:10px 14px;",
        "font-family:sans-serif;",
        "font-size:13px;",
        "box-shadow:0 4px 16px rgba(0,0,0,0.18);",
        "min-width:140px;"
      )
      
      girafe(
        ggobj     = gg_bar,
        width_svg = 8, height_svg = 10,
        options   = list(
          opts_hover(css = "fill:#ff3b3b;"),
          opts_tooltip(
            css            = tooltip_css,
            use_fill       = FALSE,
            use_cursor_pos = FALSE,
            offx           = 10,
            offy           = -40,
            delay_mouseover  = 0,
            delay_mouseout   = 1000
          ),
          opts_toolbar(saveaspng = FALSE)
        )
      )
    })
    
    # --- 6. North-South bar chart (guaranteed no zone_lookup) ---
    output$ns_bar_plot <- renderGirafe({
      req(input$selected_param, input$selected_year)
      
      t <- curr_theme()
      yr <- as.integer(input$selected_year)
      
      # Get data, drop geometry
      plot_data_raw <- Daten_long %>%
        dplyr::filter(variable == input$selected_param, year == yr)
      
      if (inherits(plot_data_raw, "sf")) {
        plot_data_raw <- sf::st_drop_geometry(plot_data_raw)
      }
      
      validate(need(nrow(plot_data_raw) > 0, "No data for this indicator/year."))
      
      # Join with district_lat (local object, NOT zone_lookup)
      plot_data <- plot_data_raw %>%
        dplyr::left_join(district_lat, by = "nuts_id") %>%
        dplyr::filter(!is.na(lat)) %>%
        dplyr::arrange(dplyr::desc(lat)) %>%
        dplyr::mutate(nuts_name = factor(nuts_name, levels = unique(nuts_name)))
      
      validate(need(nrow(plot_data) > 0, "No latitude data for selected districts."))
      
      n <- nrow(plot_data)
      bar_colours <- colorRampPalette(c("#10B981", "#8B5CF6"))(n)
      
      gg_bar <- ggplot(plot_data, aes(x = value, y = nuts_name, fill = nuts_name)) +
        geom_col_interactive(
          aes(tooltip = paste0(
            "<b>", nuts_name, "</b><br>",
            "Jahr: ", yr, "<br>",
            "Wert: ", round(value, 1)
          )),
          width = 0.7
        ) +
        scale_fill_manual(values = bar_colours) +
        theme_minimal(base_size = 11) +
        theme(
          plot.background  = element_rect(fill = t$bg,   color = NA),
          panel.background = element_rect(fill = t$bg,   color = NA),
          panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(color = t$grid, linewidth = 0.4),
          axis.text        = element_text(color = t$txt),
          axis.title       = element_text(color = t$txt, face = "bold"),
          plot.title       = element_text(color = t$txt, face = "bold", size = 12),
          legend.position  = "none"
        ) +
        labs(
          title = paste("North-South:", input$selected_param),
          subtitle = paste("Jahr:", yr),
          x = NULL, y = NULL
        )
      
      tooltip_css <- paste0(
        "background-color:", t$tooltip_bg, ";",
        "color:", t$tooltip_txt, ";",
        "border:1.5px solid #cccccc;",
        "border-radius:8px;",
        "padding:10px 14px;",
        "font-family:sans-serif;",
        "font-size:13px;",
        "box-shadow:0 4px 16px rgba(0,0,0,0.18);",
        "min-width:160px;"
      )
      
      girafe(
        ggobj = gg_bar,
        width_svg = 8, height_svg = 10,
        options = list(
          opts_hover(css = "fill:#ff3b3b; cursor:pointer;"),
          opts_tooltip(css = tooltip_css, use_fill = FALSE,
                       use_cursor_pos = FALSE, offx = 10, offy = -40),
          opts_toolbar(saveaspng = FALSE)
        )
      )
    })
    
  })
}